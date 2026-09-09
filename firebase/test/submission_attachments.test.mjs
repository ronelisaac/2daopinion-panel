import {before,after,beforeEach,test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment,assertSucceeds,assertFails} from '@firebase/rules-unit-testing';
import {doc,setDoc,getDoc,writeBatch,serverTimestamp,Timestamp,updateDoc} from 'firebase/firestore';
import {ref,uploadBytes,getBytes,deleteObject,updateMetadata} from 'firebase/storage';

let environment;
let sequence=1000;
const draftId='AbCdEfGhIjKlMnOpQrSt';
const bytes=new Uint8Array([37,80,68,70]);
const draft={id:draftId,authUserId:'alice',patientId:draftId,countryCode:'CL',status:'draft',environment:'development',policyVersion:'dev-draft-storage-2026-09-08',reason:'Prueba ficticia',details:'Detalle ficticio',medicines:'',specialTreatments:'',previousProposals:'',revision:1,createdAt:Timestamp.fromMillis(1000),updatedAt:Timestamp.fromMillis(1000),clinicalContext:{schemaVersion:1,patientContext:'',knownDiagnosis:'',symptomEvolution:'',medicalHistory:'',allergies:'',questions:'',studySummary:'',specialty:'',modality:'document_review'}};
const account=(uid='alice')=>environment.authenticatedContext(uid,{email_verified:true});
const objectKey=id=>`private-drafts/alice/${draftId}/${id}`;
const metadata=(id,video=false)=>({contentType:video?'video/mp4':'application/pdf',customMetadata:{documentId:id,checksum:id}});
before(async()=>{environment=await initializeTestEnvironment({projectId:'demo-2daopinion',firestore:{host:'127.0.0.1',port:8080,rules:readFileSync('firebase/firestore.rules','utf8')},storage:{host:'127.0.0.1',port:9199,rules:readFileSync('firebase/storage.rules','utf8')}});});
beforeEach(async()=>{
  sequence+=100;
  await environment.clearFirestore(); await environment.clearStorage();
  await environment.withSecurityRulesDisabled(async context=>{
    await setDoc(doc(context.firestore(),'profiles/alice'),{id:draftId,countryCode:'CL'});
    await setDoc(doc(context.firestore(),'consultationDrafts/alice'),draft);
    await setDoc(doc(context.firestore(),'panelStaff/operator'),{active:true,provisioning:'ready',memberships:{CL:['operations']}});
  });
});
after(async()=>environment.cleanup());
async function reserve(index,{video=false,upload=true}={}) {
  const database=account().firestore();
  const id=(sequence+index).toString(16).padStart(64,'0');
  const quota=(await getDoc(doc(database,'draftAttachments/alice'))).data()??{count:0,bytes:0,videoCount:0};
  const batch=writeBatch(database);
  batch.set(doc(database,`draftAttachments/alice/files/${id}`),{id,authUserId:'alice',draftId,countryCode:'CL',title:'Archivo ficticio',fileName:video?'ficticio.mp4':'ficticio.pdf',mimeType:metadata(id,video).contentType,size:bytes.length,checksum:id,storageBackendId:'firebase-development-v1',objectKey:objectKey(id),policyVersion:'dev-files-2026-09-08',acceptedAt:serverTimestamp(),createdAt:serverTimestamp(),...(video?{durationMilliseconds:1000}:{})});
  batch.set(doc(database,'draftAttachments/alice'),{count:quota.count+1,bytes:quota.bytes+bytes.length,videoCount:(quota.videoCount??0)+(video?1:0),lastDocumentId:id,updatedAt:serverTimestamp()});
  await batch.commit();
  if (upload) await uploadBytes(ref(account().storage(),objectKey(id)),bytes,metadata(id,video));
  return id;
}
async function send(changes={},summaryChanges={}) {
  const database=account().firestore();
  const quota=(await getDoc(doc(database,'draftAttachments/alice'))).data();
  const batch=writeBatch(database);
  batch.set(doc(database,'consultationSubmissions/alice'),{id:draftId,authUserId:'alice',countryCode:'CL',revision:1,environment:'development',status:'received',policyVersion:'dev-submission-2026-09-09',accepted:true,submittedAt:serverTimestamp(),draft,...(quota?{attachmentBatch:quota}:{}),...changes});
  batch.set(doc(database,`intakeRequests/${draftId}`),{id:draftId,countryCode:'CL',mode:'document_review',createdAt:serverTimestamp(),status:'received',environment:'development',documentCount:(quota?.count??0)-(quota?.videoCount??0),hasVideo:quota?.videoCount===1,...summaryChanges});
  return batch.commit();
}
test('documents and optional video linked without revealing metadata or bytes to operations',async()=>{
  const first=await reserve(1); await reserve(2); await reserve(3,{video:true});
  await assertSucceeds(send());
  const summary=(await assertSucceeds(getDoc(doc(account('operator').firestore(),`intakeRequests/${draftId}`)))).data();
  assert.equal(summary.documentCount,2); assert.equal(summary.hasVideo,true);
  assert.equal(summary.fileName,undefined); assert.equal(summary.attachmentBatch,undefined);
  const receipt=(await getDoc(doc(account().firestore(),'consultationSubmissions/alice'))).data();
  assert.equal(receipt.attachmentBatch.count,3);
  await assertSucceeds(getBytes(ref(account().storage(),objectKey(first))));
  await assertFails(getBytes(ref(account('operator').storage(),objectKey(first))));
  await assertFails(getDoc(doc(account('operator').firestore(),`draftAttachments/alice/files/${first}`)));
});
test('submitted files cannot be deleted, replaced, relabeled or extended by clients',async()=>{
  const first=await reserve(1); await send();
  const object=ref(account().storage(),objectKey(first));
  await assertFails(deleteObject(object));
  await assertFails(uploadBytes(object,bytes,metadata(first)));
  await assertFails(updateMetadata(object,{customMetadata:{checksum:'changed'}}));
  await assertFails(reserve(2));
  await assertFails(updateDoc(doc(account().firestore(),`draftAttachments/alice/files/${first}`),{title:'Changed'}));
  await assertSucceeds(getBytes(object));
});
test('text-only submission also prevents adding unsubmitted files afterward',async()=>{
  await send(); await assertFails(reserve(1));
});
test('forged counts, batch or old acceptance cannot smuggle file references',async()=>{
  await reserve(1);
  await assertFails(send({attachmentBatch:{count:0} }));
  await assertFails(send({}, {documentCount:0}));
  await assertFails(send({}, {hasVideo:true}));
  await assertFails(send({policyVersion:'dev-submission-2026-09-08'}));
  await assertSucceeds(send());
});
test('missing reserved bytes are not certified by receipt and cannot be filled after freeze',async()=>{
  const id=await reserve(1,{upload:false});
  await send();
  await assertFails(uploadBytes(ref(account().storage(),objectKey(id)),bytes,metadata(id)));
  await assert.rejects(getBytes(ref(account().storage(),objectKey(id))), {code:'storage/object-not-found'});
});
test('client can restore a deleted reservation before submission, not after',async()=>{
  const id=await reserve(1);
  const object=ref(account().storage(),objectKey(id));
  await assertSucceeds(deleteObject(object));
  await assertSucceeds(uploadBytes(object,bytes,metadata(id)));
  await send();
  await assertFails(deleteObject(object));
});
