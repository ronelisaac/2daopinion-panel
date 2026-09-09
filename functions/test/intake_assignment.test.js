const {test,after}=require("node:test");
const assert=require("node:assert/strict"),{randomBytes}=require("node:crypto");
const {initializeApp,deleteApp}=require("firebase-admin/app"),{getAuth}=require("firebase-admin/auth");
const {getFirestore,Timestamp}=require("firebase-admin/firestore");
const {createService}=require("../src/service"),{validate}=require("../src/policy");
const {workspaceTokenFor}=require("../src/doctor_availability");
if(!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST)throw Error("Emulators required");
const app=initializeApp({projectId:"demo-2daopinion-assignment"},"assignment"),database=getFirestore(app),auth=getAuth(app);
const service=createService({auth,database,sendInvitation:async()=>{throw Error("No invitations");}});
const context=uid=>({uid,token:{auth_time:Math.floor(Date.now()/1000)+1}});
const code=expected=>error=>error.code===expected;
const requestId=()=>randomBytes(16).toString("hex");
async function account(role){
 const uid="assignment-"+randomBytes(8).toString("hex");
 await auth.createUser({uid,email:uid+"@example.test",emailVerified:true});
 await database.doc("panelStaff/"+uid).set({uid,email:uid+"@example.test",active:true,provisioning:"ready",memberships:{CL:[role]}});
 return uid;
}
async function fixture(){
 const uid=await account("operations"),doctorUid=await account("doctor"),id=randomBytes(10).toString("hex");
 const doctorId="CL_"+String(1000000000+Math.floor(Math.random()*8000000000)),specialtyId="CL_qa_"+randomBytes(5).toString("hex");
 const doctor={id:doctorId,countryCode:"CL",environment:"development",schemaVersion:2,status:"verified",revision:2,
  specialtyId,name:"Profesional ficticio",registryNumber:doctorId.slice(3)};
 const link={uid:doctorUid,doctorId,countryCode:"CL",createdAt:Timestamp.now()};
 await database.doc("doctorRecords/"+doctorId).set(doctor);
 await database.doc("doctorAccountLinks/"+doctorId).set(link);
 await database.doc("panelStaff/"+doctorUid).update({doctorLinks:{CL:doctorId}});
 await database.doc("specialties/"+specialtyId).set({id:specialtyId,countryCode:"CL",active:true,name:"Especialidad ficticia"});
 await database.doc("doctorAvailability/"+doctorUid+"/countries/CL").set({uid:doctorUid,doctorId,countryCode:"CL",environment:"development",
  schemaVersion:1,accepting:true,workspaceToken:workspaceTokenFor(doctorUid,"CL",doctor,link),updatedAt:Timestamp.now()});
 await database.doc("intakeRequests/"+id).set({id,countryCode:"CL",environment:"development",status:"received"});
 await database.doc("intakeClassifications/"+id).set({id,countryCode:"CL",environment:"development",schemaVersion:1,
  specialtyId,specialtyName:"Especialidad ficticia",source:"patientConfirmed",revision:1});
 return {uid,doctorUid,id,doctorId,specialtyId};
}
const read=data=>service(context(data.uid),{action:"intakeAssignmentGet",country:"CL",id:data.id});
const input=data=>({action:"intakeAssignmentSet",country:"CL",id:data.id,doctorId:data.doctorId,
 classificationRevision:1,revision:0,confirmed:true,requestId:requestId()});
const release=(data,revision=1)=>({action:"intakeAssignmentRelease",country:"CL",id:data.id,revision,confirmed:true,
 reason:"wrongSelection",requestId:requestId()});
after(async()=>{await database.terminate();await deleteApp(app);});
test("strict assignment types, exact keys and no clinical overrides",()=>{
 const base=input({id:"a".repeat(20),doctorId:"CL_123"});
 for(const change of [{id:"../bad"},{country:"AR"},{doctorId:"CL_012"},{confirmed:false},{confirmed:"true"},{revision:-1},
 {revision:Number.MAX_SAFE_INTEGER},{classificationRevision:0},{doctorUid:"injected"},{paid:true},{requestId:"bad"}])
 assert.throws(()=>validate({...base,...change}),code("invalid-argument"));
 for(const reason of ["","diagnosis",false])assert.throws(()=>validate({...release({id:base.id}),reason}),code("invalid-argument"));
 assert.throws(()=>validate({action:"intakeAssignmentCandidates",country:"CL",id:base.id,classificationRevision:1,cursor:"../bad"}),code("invalid-argument"));
});
test("assignment replay, exclusivity, classification lock, release and reassign preserve intake",async()=>{
 const data=await fixture(),before=(await database.doc("intakeRequests/"+data.id).get()).data();
 assert.equal((await read(data)).canAssign,true);
 const command=input(data);await service(context(data.uid),command);await service(context(data.uid),command);
 const saved=await read(data);assert.equal(saved.status,"pendingAcceptance");assert.equal(saved.canAssign,false);assert.equal(saved.canRelease,true);
 assert.ok(!Object.hasOwn(saved,"doctorUid"));
 assert.equal((await service(context(data.uid),{action:"intakeClassificationGet",country:"CL",id:data.id})).editable,false);
 const classify={action:"intakeClassificationSet",country:"CL",id:data.id,revision:1,source:"unconfirmed",specialtyId:null,confirmed:true,requestId:requestId()};
 await assert.rejects(service(context(data.uid),classify),code("failed-precondition"));
 await assert.rejects(service(context(data.uid),{...input(data),revision:1}),code("failed-precondition"));
 await service(context(data.uid),release(data));assert.equal((await read(data)).status,"released");
 await service(context(data.uid),{...input(data),revision:2});
 assert.equal((await database.collection("intakeAssignments/"+data.id+"/events").get()).size,3);
 assert.deepEqual((await database.doc("intakeRequests/"+data.id).get()).data(),before);
});
test("candidate pages match classification and doctor eligibility without exposing identities",async()=>{
 const data=await fixture();
 let cursor=null,found=false;
 do {
 const page=await service(context(data.uid),{action:"intakeAssignmentCandidates",country:"CL",id:data.id,classificationRevision:1,cursor});
 for(const candidate of page.items){assert.deepEqual(Object.keys(candidate).sort(),["id","name","registry"]);assert.equal(candidate.id,data.doctorId);found=true;}
 cursor=page.nextCursor;
 }while(cursor);
 assert.equal(found,true);
 await database.doc("doctorAvailability/"+data.doctorUid+"/countries/CL").update({accepting:false});
 await assert.rejects(service(context(data.uid),input(data)),code("failed-precondition"));
});
test("all reliable physician blocks, foreign specialty and stale classification rejected at write",async()=>{
 const data=await fixture();
 const paths=["doctorRecords/"+data.doctorId,"doctorAdministration/"+data.doctorId,"panelStaff/"+data.doctorUid,
 "doctorAccountLinks/"+data.doctorId,"doctorAvailability/"+data.doctorUid+"/countries/CL","specialties/"+data.specialtyId];
 const changes=[{status:"suspended"},{active:false},{active:false},{uid:"missing"},{workspaceToken:"stale"},{active:false}];
 for(let index=0;index<paths.length;index++){
 const ref=database.doc(paths[index]),snapshot=await ref.get();
 await ref.set({...snapshot.data(),...changes[index]});
 await assert.rejects(service(context(data.uid),input(data)),code("failed-precondition"));
 if(snapshot.exists)await ref.set(snapshot.data());else await ref.delete();
 }
 await auth.updateUser(data.doctorUid,{disabled:true});
 await assert.rejects(service(context(data.uid),input(data)),code("failed-precondition"));
 await auth.updateUser(data.doctorUid,{disabled:false});
 await assert.rejects(service(context(data.uid),{...input(data),classificationRevision:2}),code("failed-precondition"));
 await database.doc("doctorRecords/"+data.doctorId).update({specialtyId:"CL_foreign"});
 await assert.rejects(service(context(data.uid),input(data)),code("failed-precondition"));
});
test("canonical operations only, no inheritance, revocation and country isolation",async()=>{
 const data=await fixture();
 for(const role of ["superadmin","medicalDirector","doctor","finance"]){
 const uid=await account(role);await assert.rejects(read({...data,uid}),code("permission-denied"));
 await assert.rejects(service(context(uid),input(data)),code("permission-denied"));
 }
 await database.doc("panelStaff/"+data.uid).update({active:false});
 await assert.rejects(read(data),code("permission-denied"));
 await database.doc("panelStaff/"+data.uid).update({active:true});
 await database.doc("intakeRequests/"+data.id).update({countryCode:"AR"});
 await assert.rejects(read(data),code("permission-denied"));
});
test("concurrent assignment yields one event, replay mismatch and quota blocked",async()=>{
 const data=await fixture(),commands=[input(data),input(data)];
 const result=await Promise.allSettled(commands.map(command=>service(context(data.uid),command)));
 assert.equal(result.filter(item=>item.status==="fulfilled").length,1);
 const successful=commands[result.findIndex(item=>item.status==="fulfilled")];
 await assert.rejects(service(context(data.uid),{...successful,revision:1}),code("already-exists"));
 await database.doc("intakeAssignmentLimits/"+data.uid).set({day:new Date().toISOString().slice(0,10),count:20});
 await assert.rejects(service(context(data.uid),release(data)),code("resource-exhausted"));
 assert.equal((await database.collection("intakeAssignments/"+data.id+"/events").get()).size,1);
});
test("classification racing with assignment cannot leave an active stale classification",async()=>{
 const data=await fixture();
 const results=await Promise.allSettled([
 service(context(data.uid),input(data)),
 service(context(data.uid),{action:"intakeClassificationSet",country:"CL",id:data.id,revision:1,
 source:"unconfirmed",specialtyId:null,confirmed:true,requestId:requestId()})]);
 assert.equal(results.filter(result=>result.status==="fulfilled").length,1);
 const assignment=(await database.doc("intakeAssignments/"+data.id).get()).data();
 const route=(await database.doc("intakeClassifications/"+data.id).get()).data();
 assert.ok(!assignment || (route.revision===assignment.classificationRevision && route.source!=="unconfirmed"));
});
