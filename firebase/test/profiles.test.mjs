import {before, after, beforeEach, test} from 'node:test';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment, assertSucceeds, assertFails} from '@firebase/rules-unit-testing';
import {doc, collection, getDoc, getDocs, setDoc, updateDoc, deleteDoc, writeBatch, serverTimestamp, Timestamp} from 'firebase/firestore';

let environment;
const policy = 'dev-access-2026-09-08';
before(async () => {
  environment = await initializeTestEnvironment({projectId:'demo-2daopinion', firestore:{host:'127.0.0.1',port:8080,rules:readFileSync('firebase/firestore.rules','utf8')}});
});
beforeEach(async () => environment.clearFirestore());
after(async () => environment.cleanup());
const databaseFor = uid => environment.authenticatedContext(uid,{email_verified:false}).firestore();
const profile = (uid, changes = {}) => ({id:'AbCdEfGhIjKlMnOpQrSt',authUserId:uid,firstName:'Prueba',lastName:'Paciente',countryCode:'CL',locale:'es',policyVersion:policy,createdAt:serverTimestamp(),updatedAt:serverTimestamp(),...changes});
const consent = (uid, changes = {}) => ({authUserId:uid,policyVersion:policy,context:'development-registration',accepted:true,acceptedAt:serverTimestamp(),...changes});
function registration(database, uid, profileChanges={}, consentChanges={}) {
  const batch=writeBatch(database);
  batch.set(doc(database,`profiles/${uid}`),profile(uid,profileChanges));
  batch.set(doc(database,`profiles/${uid}/consents/${policy}`),consent(uid,consentChanges));
  return batch.commit();
}

test('own unverified account can atomically save profile and acceptance',async()=>{
  const database=databaseFor('alice');
  await assertSucceeds(registration(database,'alice'));
  await assertSucceeds(getDoc(doc(database,'profiles/alice')));
  await assertSucceeds(getDoc(doc(database,`profiles/alice/consents/${policy}`)));
});
test('anonymous cannot read or create profiles',async()=>{
  const database=environment.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(database,'profiles/alice')));
  await assertFails(registration(database,'alice'));
});
test('another patient cannot read, write or list identities and acceptances',async()=>{
  await registration(databaseFor('alice'),'alice');
  const database=databaseFor('bob');
  await assertFails(getDoc(doc(database,'profiles/alice')));
  await assertFails(getDoc(doc(database,`profiles/alice/consents/${policy}`)));
  await assertFails(updateDoc(doc(database,'profiles/alice'),{firstName:'Otro',updatedAt:serverTimestamp()}));
  await assertFails(registration(database,'alice'));
  await assertFails(getDocs(collection(database,'profiles')));
});
test('profile alone and acceptance alone cannot complete registration',async()=>{
  const database=databaseFor('alice');
  await assertFails(setDoc(doc(database,'profiles/alice'),profile('alice')));
  await assertFails(setDoc(doc(database,`profiles/alice/consents/${policy}`),consent('alice')));
});
for (const [label,changes] of Object.entries({role:{role:'admin'},owner:{authUserId:'bob'},id:{id:'invalid'},country:{countryCode:'AR'},locale:{locale:'xx'},version:{policyVersion:'old'},emptyName:{firstName:''},longName:{lastName:'x'.repeat(81)},password:{password:'must-not-persist'},time:{createdAt:Timestamp.fromMillis(0)}})) {
  test(`reject profile ${label}`,async()=>{await assertFails(registration(databaseFor('alice'),'alice',changes));});
}
for (const [label,changes] of Object.entries({declined:{accepted:false},version:{policyVersion:'old'},owner:{authUserId:'bob'},context:{context:'clinical'},time:{acceptedAt:Timestamp.fromMillis(0)}})) {
  test(`reject acceptance ${label}`,async()=>{await assertFails(registration(databaseFor('alice'),'alice',{},changes));});
}
test('name update allowed without changing immutable identity and acceptance',async()=>{
  const database=databaseFor('alice');
  await registration(database,'alice');
  await assertSucceeds(updateDoc(doc(database,'profiles/alice'),{firstName:'Actualizado',updatedAt:serverTimestamp()}));
  for (const changes of [{id:'DifferentIdAbCdEfG123'},{countryCode:'AR'},{authUserId:'bob'},{policyVersion:'next'},{createdAt:serverTimestamp()},{role:'admin'}]) {
    await assertFails(updateDoc(doc(database,'profiles/alice'),{...changes,updatedAt:serverTimestamp()}));
  }
  await assertFails(updateDoc(doc(database,`profiles/alice/consents/${policy}`),{accepted:false}));
  await assertFails(deleteDoc(doc(database,`profiles/alice/consents/${policy}`)));
  await assertFails(deleteDoc(doc(database,'profiles/alice')));
});
test('all clinical and financial collections remain denied',async()=>{
  const database=databaseFor('alice');
  for(const name of ['cases','payments','payouts','prescriptions','notifications','policyVersions']) {
    await assertFails(getDoc(doc(database,`${name}/example`)));
    await assertFails(setDoc(doc(database,`${name}/example`),{authUserId:'alice'}));
  }
});
