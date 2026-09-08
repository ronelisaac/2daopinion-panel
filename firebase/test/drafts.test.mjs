import {before, after, beforeEach, test} from 'node:test';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment, assertSucceeds, assertFails} from '@firebase/rules-unit-testing';
import {doc, collection, getDoc, getDocs, setDoc, updateDoc, deleteDoc, writeBatch, serverTimestamp, Timestamp} from 'firebase/firestore';

let environment;
const version = 'dev-draft-storage-2026-09-08';
const draftId = 'DraftAbCdEfGhIjKl123';
const patientId = 'AbCdEfGhIjKlMnOpQrSt';
const clinical = {"schemaVersion":1,"patientContext":"","knownDiagnosis":"","symptomEvolution":"","medicalHistory":"","allergies":"","questions":"","studySummary":"","specialty":"","modality":""};
test('clinical context upgrades legacy drafts without changing ownership or submission state',async()=>{
  const database=databaseFor();
  await assertSucceeds(save(database));
  await assertSucceeds(updateDoc(doc(database,'consultationDrafts/alice'),{clinicalContext:{...clinical,questions:'Ejemplo ficticio'},revision:2,updatedAt:serverTimestamp()}));
  await assertSucceeds(updateDoc(doc(database,'consultationDrafts/alice'),{reason:'Edición antigua',revision:3,updatedAt:serverTimestamp()}));
  await assertFails(updateDoc(doc(databaseFor('bob'),'consultationDrafts/alice'),{clinicalContext:clinical,revision:4,updatedAt:serverTimestamp()}));
  await assertFails(save(environment.unauthenticatedContext().firestore(),{clinicalContext:clinical}));
});
test('clinical context accepts supported modalities and rejects extra, malformed and oversized fields',async()=>{
  const database=databaseFor();
  for (const modality of ['', 'document_review', 'review_and_consultation']) {
    await environment.clearFirestore();
    await environment.withSecurityRulesDisabled(context=>setDoc(doc(context.firestore(),'profiles/alice'),{id:patientId,countryCode:'CL'}));
    await assertSucceeds(save(database,{clinicalContext:{...clinical,modality}}));
  }
});
for (const field of ["patientContext","knownDiagnosis","symptomEvolution","medicalHistory","allergies","questions","studySummary","specialty"]) {
  test(`clinical context rejects long or non-string ${field}`,async()=>{
    for (const value of ['x'.repeat(4001), [], null, 22]) {
      await assertFails(save(databaseFor(),{clinicalContext:{...clinical,[field]:value}}));
    }
  });
}
test('clinical schema cannot smuggle extra keys, unknown modalities or versions',async()=>{
  for (const value of [null, [], {}, {...clinical,schemaVersion:2}, {...clinical,doctorId:'somebody'}, {...clinical,modality:'video_paid'}]) {
    await assertFails(save(databaseFor(),{clinicalContext:value}));
  }
});
before(async () => {
  environment = await initializeTestEnvironment({projectId:'demo-2daopinion', firestore:{host:'127.0.0.1',port:8080,rules:readFileSync('firebase/firestore.rules','utf8')}});
});
beforeEach(async () => {
  await environment.clearFirestore();
  await environment.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(),'profiles/alice'), {id:patientId,countryCode:'CL'});
    await setDoc(doc(context.firestore(),'profiles/bob'), {id:'OtherCdEfGhIjKlMn123',countryCode:'CL'});
  });
});
after(async () => environment.cleanup());
const databaseFor = (uid='alice', verified=true) => environment.authenticatedContext(uid,{email_verified:verified}).firestore();
const draft = (changes={}) => ({id:draftId,authUserId:'alice',patientId,countryCode:'CL',status:'draft',environment:'development',policyVersion:version,reason:'Ficticio',details:'',medicines:'',specialTreatments:'',previousProposals:'',revision:1,createdAt:serverTimestamp(),updatedAt:serverTimestamp(),...changes});
const consent = (changes={}) => ({draftId,authUserId:'alice',policyVersion:version,context:'development-draft-storage',accepted:true,acceptedAt:serverTimestamp(),...changes});
function save(database, draftChanges={}, consentChanges={}) {
  const batch = writeBatch(database);
  batch.set(doc(database,'consultationDrafts/alice'),draft(draftChanges));
  batch.set(doc(database,`consultationDrafts/alice/consents/${version}`),consent(consentChanges));
  return batch.commit();
}
test('verified owner saves incomplete draft and separate immutable acceptance atomically',async()=>{
  const database=databaseFor();
  await assertSucceeds(save(database));
  await assertSucceeds(getDoc(doc(database,'consultationDrafts/alice')));
  await assertSucceeds(getDoc(doc(database,`consultationDrafts/alice/consents/${version}`)));
  await assertSucceeds(updateDoc(doc(database,'consultationDrafts/alice'),{details:'Prueba actualizada',revision:2,updatedAt:serverTimestamp()}));
});
test('anonymous, unverified, other owner and absent profile cannot access drafts',async()=>{
  await save(databaseFor());
  for (const database of [environment.unauthenticatedContext().firestore(),databaseFor('alice',false),databaseFor('bob'),databaseFor('missing')]) {
    await assertFails(getDoc(doc(database,'consultationDrafts/alice')));
    await assertFails(getDoc(doc(database,`consultationDrafts/alice/consents/${version}`)));
    await assertFails(updateDoc(doc(database,'consultationDrafts/alice'),{reason:'Otro',revision:2,updatedAt:serverTimestamp()}));
  }
  await assertFails(save(databaseFor('alice',false)));
  await assertFails(save(databaseFor('bob')));
  await environment.withSecurityRulesDisabled(context => deleteDoc(doc(context.firestore(),'profiles/alice')));
  await assertFails(getDoc(doc(databaseFor(),'consultationDrafts/alice')));
});
test('draft alone or acceptance alone are denied; registration acceptance does not substitute',async()=>{
  const database=databaseFor();
  await assertFails(setDoc(doc(database,'consultationDrafts/alice'),draft()));
  await assertFails(setDoc(doc(database,`consultationDrafts/alice/consents/${version}`),consent()));
  await assertFails(save(database,{}, {policyVersion:'dev-access-2026-09-08',context:'development-registration'}));
});
for (const [label,changes] of Object.entries({owner:{authUserId:'bob'},patient:{patientId:'wrong'},country:{countryCode:'AR'},id:{id:'wrong'},status:{status:'submitted'},payment:{paymentStatus:'paid'},doctor:{doctorId:'any'},production:{environment:'production'},revision:{revision:2},fractionalRevision:{revision:1.5},version:{policyVersion:'old'},time:{createdAt:Timestamp.fromMillis(0)},invalidType:{reason:[]},longReason:{reason:'x'.repeat(4001)},longDetails:{details:'x'.repeat(4001)},longMedicines:{medicines:'x'.repeat(4001)},longTreatments:{specialTreatments:'x'.repeat(4001)},longProposals:{previousProposals:'x'.repeat(4001)}})) {
  test(`reject draft ${label}`,async()=>{ await assertFails(save(databaseFor(),changes)); });
}
for (const [label,changes] of Object.entries({owner:{authUserId:'bob'},draftId:{draftId:'wrong'},declined:{accepted:false},context:{context:'clinical-submission'},version:{policyVersion:'old'},time:{acceptedAt:Timestamp.fromMillis(0)},extra:{extra:true}})) {
  test(`reject draft acceptance ${label}`,async()=>{ await assertFails(save(databaseFor(),{},changes)); });
}
test('no list, delete, consent modification, stale revisions or identity/status changes',async()=>{
  const database=databaseFor();
  await save(database);
  await assertFails(getDocs(collection(database,'consultationDrafts')));
  await assertFails(deleteDoc(doc(database,'consultationDrafts/alice')));
  await assertFails(deleteDoc(doc(database,`consultationDrafts/alice/consents/${version}`)));
  await assertFails(updateDoc(doc(database,`consultationDrafts/alice/consents/${version}`),{accepted:false}));
  for (const changes of [{id:'OtherAbCdEfGhIjKl123'},{authUserId:'bob'},{patientId:'another'},{countryCode:'AR'},{createdAt:serverTimestamp()},{policyVersion:'next'},{status:'submitted'},{revision:1},{revision:3}]) {
    await assertFails(updateDoc(doc(database,'consultationDrafts/alice'),{revision:2,updatedAt:serverTimestamp(),...changes}));
  }
  await assertFails(setDoc(doc(database,'consultationDrafts/extra'),draft()));
});
