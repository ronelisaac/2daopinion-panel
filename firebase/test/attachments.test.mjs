import {before,after,beforeEach,test} from 'node:test';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment,assertSucceeds,assertFails} from '@firebase/rules-unit-testing';
import {doc,setDoc,getDoc,getDocs,collection,query,limit,writeBatch,serverTimestamp,updateDoc,deleteDoc} from 'firebase/firestore';
import {ref,uploadBytes,getBytes,deleteObject,listAll} from 'firebase/storage';
let environment;
const draftId='AbCdEfGhIjKlMnOpQrSt';
const fileId='a'.repeat(64);
const objectKey=`private-drafts/alice/${draftId}/${fileId}`;
const bytes=new Uint8Array([37,80,68,70]);
const metadata={contentType:'application/pdf',cacheControl:'private, no-store',customMetadata:{documentId:fileId,checksum:fileId}};
before(async()=>{environment=await initializeTestEnvironment({projectId:'demo-2daopinion',firestore:{host:'127.0.0.1',port:8080,rules:readFileSync('firebase/firestore.rules','utf8')},storage:{host:'127.0.0.1',port:9199,rules:readFileSync('firebase/storage.rules','utf8')}});});
beforeEach(async()=>{
  await environment.clearFirestore(); await environment.clearStorage();
  await environment.withSecurityRulesDisabled(async context=>{
    await setDoc(doc(context.firestore(),'profiles/alice'),{id:draftId,countryCode:'CL'});
    await setDoc(doc(context.firestore(),'consultationDrafts/alice'),{id:draftId,countryCode:'CL'});
  });
});
after(async()=>environment.cleanup());
const account=(uid='alice',verified=true)=>environment.authenticatedContext(uid,{email_verified:verified});
const record=(changes={})=>({id:fileId,authUserId:'alice',draftId,countryCode:'CL',title:'Informe ficticio',fileName:'ficticio.pdf',size:bytes.length,mimeType:'application/pdf',checksum:fileId,storageBackendId:'firebase-development-v1',objectKey,policyVersion:'dev-files-2026-09-08',acceptedAt:serverTimestamp(),createdAt:serverTimestamp(),...changes});
function reserve(context=account(),changes={},quota={}) {
  const database=context.firestore(); const batch=writeBatch(database);
  batch.set(doc(database,`draftAttachments/alice/files/${fileId}`),record(changes));
  batch.set(doc(database,'draftAttachments/alice'),{count:1,bytes:changes.size??bytes.length,lastDocumentId:fileId,updatedAt:serverTimestamp(),...quota});
  return batch.commit();
}
test('reservation and upload are private, immutable and quota backed',async()=>{
  const context=account(); await assertSucceeds(reserve(context));
  const storage=context.storage(); const object=ref(storage,objectKey);
  await assertSucceeds(uploadBytes(object,bytes,metadata));
  await assertSucceeds(getBytes(object));
  await assertFails(uploadBytes(object,bytes,metadata));
  await assertFails(listAll(ref(storage,'private-drafts/alice')));
  await assertSucceeds(getDocs(query(collection(context.firestore(),'draftAttachments/alice/files'),limit(20))));
  await assertFails(getDocs(collection(context.firestore(),'draftAttachments/alice/files')));
  await assertFails(updateDoc(doc(context.firestore(),`draftAttachments/alice/files/${fileId}`),{title:'Otro'}));
  await assertFails(deleteDoc(doc(context.firestore(),`draftAttachments/alice/files/${fileId}`)));
  await assertSucceeds(deleteObject(object));
});
test('anonymous, unverified and other users cannot reserve, read or delete',async()=>{
  await reserve(); await uploadBytes(ref(account().storage(),objectKey),bytes,metadata);
  for(const context of [environment.unauthenticatedContext(),account('alice',false),account('bob')]) {
    await assertFails(reserve(context));
    await assertFails(getDoc(doc(context.firestore(),`draftAttachments/alice/files/${fileId}`)));
    await assertFails(getBytes(ref(context.storage(),objectKey)));
    await assertFails(deleteObject(ref(context.storage(),objectKey)));
  }
});
test('no unreserved objects, alternate draft paths, altered sizes or types',async()=>{
  const storage=account().storage();
  await assertFails(uploadBytes(ref(storage,objectKey),bytes,metadata)); await reserve();
  await assertFails(uploadBytes(ref(storage,objectKey.replace(draftId,'wrong')),bytes,metadata));
  await assertFails(uploadBytes(ref(storage,objectKey),new Uint8Array(5),metadata));
  await assertFails(uploadBytes(ref(storage,objectKey),bytes,{...metadata,contentType:'text/html'}));
  await assertFails(uploadBytes(ref(storage,objectKey),bytes,{...metadata,customMetadata:{documentId:fileId,checksum:'wrong'}}));
});
test('metadata or quota alone and forged counters are rejected',async()=>{
  const database=account().firestore();
  await assertFails(setDoc(doc(database,`draftAttachments/alice/files/${fileId}`),record()));
  await assertFails(setDoc(doc(database,'draftAttachments/alice'),{count:1,bytes:4,lastDocumentId:fileId,updatedAt:serverTimestamp()}));
  for(const quota of [{count:0},{count:21},{bytes:0},{bytes:52428801}]) await assertFails(reserve(account(),{},quota));
});
test('lifetime reservations cannot exceed count or total bytes, nor be reset',async()=>{
  await environment.withSecurityRulesDisabled(context=>setDoc(doc(context.firestore(),'draftAttachments/alice'),{count:20,bytes:40,lastDocumentId:'b'.repeat(64),updatedAt:new Date()}));
  await assertFails(reserve(account(),{},{count:21,bytes:44}));
  await assertFails(reserve());
  await environment.withSecurityRulesDisabled(context=>setDoc(doc(context.firestore(),'draftAttachments/alice'),{count:11,bytes:52428800,lastDocumentId:'b'.repeat(64),updatedAt:new Date()}));
  await assertFails(reserve(account(),{},{count:12,bytes:52428804}));
});
for(const [label,change] of Object.entries({size:{size:5242881},empty:{size:0},mime:{mimeType:'text/html'},title:{title:'x'.repeat(121)},name:{fileName:'x'.repeat(256)},url:{url:'https://invalid.test'},backend:{storageBackendId:'external'},path:{objectKey:'elsewhere'},draft:{draftId:'other'},owner:{authUserId:'bob'},consent:{policyVersion:'other'}})) {
  test(`reject invalid attachment ${label}`,async()=>assertFails(reserve(account(),change)));
}
