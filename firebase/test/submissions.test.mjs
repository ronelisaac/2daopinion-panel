import {before, after, beforeEach, test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment, assertSucceeds, assertFails} from '@firebase/rules-unit-testing';
import {doc, collection, query, where, limit, orderBy, getDoc, getDocs, setDoc, updateDoc, deleteDoc, writeBatch, serverTimestamp, Timestamp, runTransaction} from 'firebase/firestore';

let environment;
const id = 'DraftAbCdEfGhIjKl123';
const clinical = {schemaVersion:1,patientContext:'',knownDiagnosis:'Ficticio privado',symptomEvolution:'',medicalHistory:'',allergies:'',questions:'',studySummary:'',specialty:'',modality:'document_review'};
const draft = {id,authUserId:'patient',patientId:'AbCdEfGhIjKlMnOpQrSt',countryCode:'CL',status:'draft',environment:'development',policyVersion:'dev-draft-storage-2026-09-08',reason:'Caso ficticio',details:'Detalle ficticio privado',medicines:'',specialTreatments:'',previousProposals:'',clinicalContext:clinical,revision:1,createdAt:Timestamp.fromMillis(1000),updatedAt:Timestamp.fromMillis(1000)};
const databaseFor = (uid='patient', verified=true) => environment.authenticatedContext(uid,{email_verified:verified}).firestore();
const receipt = (changes={}) => ({id,authUserId:'patient',countryCode:'CL',revision:1,environment:'development',status:'received',policyVersion:'dev-submission-2026-09-08',accepted:true,submittedAt:serverTimestamp(),draft,...changes});
const intake = (changes={}) => ({id,countryCode:'CL',mode:'document_review',createdAt:serverTimestamp(),status:'received',environment:'development',...changes});
function send(database=databaseFor(), changes={}, summary={}) {
  const batch=writeBatch(database);
  batch.set(doc(database,'consultationSubmissions/patient'),receipt(changes));
  batch.set(doc(database,`intakeRequests/${id}`),intake(summary));
  return batch.commit();
}
before(async()=>{environment=await initializeTestEnvironment({projectId:'demo-2daopinion',firestore:{host:'127.0.0.1',port:8080,rules:readFileSync('firebase/firestore.rules','utf8')}});});
beforeEach(async()=>{
  await environment.clearFirestore();
  await environment.withSecurityRulesDisabled(async context=>{
    const database=context.firestore();
    await setDoc(doc(database,'profiles/patient'),{id:draft.patientId,countryCode:'CL'});
    await setDoc(doc(database,'consultationDrafts/patient'),draft);
    for (const [uid,memberships,active,provisioning] of [
      ['operator',{CL:['operations']},true,'ready'],
      ['argentina',{AR:['operations']},true,'ready'],
      ['mixed',{CL:['finance'],AR:['operations']},true,'ready'],
      ['doctor',{CL:['doctor']},true,'ready'],
      ['root',{CL:['superadmin']},true,'ready'],
      ['disabled',{CL:['operations']},false,'ready'],
      ['pending',{CL:['operations']},true,'pending'],
    ]) await setDoc(doc(database,`panelStaff/${uid}`),{uid,memberships,active,provisioning});
  });
});
after(async()=>environment.cleanup());

test('atomic receipt and metadata; owner retains private snapshot, operator sees only summary',async()=>{
  await assertSucceeds(send());
  const privateCopy=await assertSucceeds(getDoc(doc(databaseFor(),'consultationSubmissions/patient')));
  assert.equal(privateCopy.data().draft.details,draft.details);
  const visible=await assertSucceeds(getDoc(doc(databaseFor('operator'),`intakeRequests/${id}`)));
  assert.deepEqual(Object.keys(visible.data()).sort(),['countryCode','createdAt','environment','id','mode','status']);
  await assertSucceeds(getDocs(query(collection(databaseFor('operator'),'intakeRequests'),where('countryCode','==','CL'),orderBy('createdAt','desc'),limit(9))));
  await assertFails(getDoc(doc(databaseFor('operator'),'consultationSubmissions/patient')));
  await assertFails(getDoc(doc(databaseFor('operator'),'consultationDrafts/patient')));
});

test('receipt and summary cannot be created independently',async()=>{
  await assertFails(setDoc(doc(databaseFor(),'consultationSubmissions/patient'),receipt()));
  await assertFails(setDoc(doc(databaseFor(),`intakeRequests/${id}`),intake()));
});

for (const [label,changes] of Object.entries({consent:{accepted:false},version:{policyVersion:'dev-access-2026-09-08'},revision:{revision:2},snapshot:{draft:{...draft,details:'Alterado'}},owner:{authUserId:'other'},country:{countryCode:'AR'},time:{submittedAt:Timestamp.fromMillis(0)},state:{status:'paid'},extra:{doctorId:'doctor'},environment:{environment:'production'}})) {
  test(`reject forged submission: ${label}`,async()=>{await assertFails(send(databaseFor(),changes));});
}
test('reject metadata injection, inconsistent modality and pending attachments',async()=>{
  await assertFails(send(databaseFor(),{},{diagnosis:'private'}));
  await assertFails(send(databaseFor(),{},{mode:'review_and_consultation'}));
  await environment.withSecurityRulesDisabled(context=>setDoc(doc(context.firestore(),'draftAttachments/patient'),{count:1,bytes:10}));
  await assertFails(send());
});
test('reject whitespace-only fields and absent modality in trusted draft snapshot',async()=>{
  for (const changes of [{reason:' \n '},{details:'\t '},{clinicalContext:{...clinical,modality:''}}]) {
    const invalid={...draft,...changes};
    await environment.withSecurityRulesDisabled(context=>setDoc(doc(context.firestore(),'consultationDrafts/patient'),invalid));
    await assertFails(send(databaseFor(),{draft:invalid}));
  }
});
test('anonymous, unverified and other patients cannot submit or read copies',async()=>{
  for (const database of [environment.unauthenticatedContext().firestore(),databaseFor('patient',false),databaseFor('other')]) await assertFails(send(database));
  await send();
  for (const database of [environment.unauthenticatedContext().firestore(),databaseFor('patient',false),databaseFor('other')]) await assertFails(getDoc(doc(database,'consultationSubmissions/patient')));
});
test('roles, country scopes, canonical disable and bounded queries enforced by rules',async()=>{
  await send();
  for (const uid of ['argentina','mixed','doctor','root','disabled','pending','patient']) {
    await assertFails(getDocs(query(collection(databaseFor(uid),'intakeRequests'),where('countryCode','==','CL'),limit(9))));
  }
  const operator=databaseFor('operator');
  await assertFails(getDocs(collection(operator,'intakeRequests')));
  await assertFails(getDocs(query(collection(operator,'intakeRequests'),where('countryCode','==','CL'),limit(10))));
  await assertFails(getDocs(query(collection(operator,'intakeRequests'),limit(9))));
  await assertFails(getDoc(doc(databaseFor('operator',false),`intakeRequests/${id}`)));
  await environment.withSecurityRulesDisabled(context=>updateDoc(doc(context.firestore(),'panelStaff/operator'),{active:false}));
  await assertFails(getDoc(doc(operator,`intakeRequests/${id}`)));
});
test('submitted copy and receipt immutable; draft updates do not alter sent content',async()=>{
  await send();
  for (const path of ['consultationSubmissions/patient',`intakeRequests/${id}`]) {
    await assertFails(updateDoc(doc(databaseFor(),path),{status:'reviewing'}));
    await assertFails(deleteDoc(doc(databaseFor(),path)));
    await assertFails(updateDoc(doc(databaseFor('operator'),path),{status:'reviewing'}));
  }
  await assertSucceeds(updateDoc(doc(databaseFor(),'consultationDrafts/patient'),{details:'Nuevo borrador ficticio',revision:2,updatedAt:serverTimestamp()}));
  assert.equal((await getDoc(doc(databaseFor(),'consultationSubmissions/patient'))).data().draft.details,draft.details);
  await assertFails(send());
});
test('concurrent transaction retries create exactly one reception',async()=>{
  const database=databaseFor();
  const submit=async()=> {
    try { return await runTransaction(database,async transaction=>{
    const reference=doc(database,'consultationSubmissions/patient');
    const existing=await transaction.get(reference);
    if (existing.exists()) return existing.data().id;
    transaction.set(reference,receipt());
    transaction.set(doc(database,`intakeRequests/${id}`),intake());
    return id;
    }); } catch (error) {
      if (error.code !== 'permission-denied') throw error;
      const existing=await getDoc(doc(database,'consultationSubmissions/patient'));
      if (!existing.exists() || existing.data().id !== id) throw error;
      return existing.data().id;
    }
  };
  assert.deepEqual(await Promise.all([submit(),submit()]),[id,id]);
  const records=await getDocs(query(collection(databaseFor('operator'),'intakeRequests'),where('countryCode','==','CL'),limit(9)));
  assert.equal(records.size,1);
});
