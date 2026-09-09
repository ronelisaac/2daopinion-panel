const {test, after} = require("node:test");
const assert = require("node:assert/strict");
const {randomBytes, createHash} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {createService} = require("../src/service");
if (!process.env.FIREBASE_AUTH_EMULATOR_HOST || !process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Emulators required");
const app = initializeApp({projectId: "demo-2daopinion-operational-availability"}, "operational-availability");
const auth = getAuth(app), database = getFirestore(app);
const now = Date.now();
const service = createService({auth, database, now: () => now, sendInvitation: async () => {throw Error("Unexpected invitation");}});
const context = uid => ({uid, token: {auth_time: Math.floor(Date.now()/1000)+1}});
const key = () => randomBytes(16).toString("hex");
let sequence = 0;
async function account(role) {
  const uid = "availability-" + randomBytes(6).toString("hex"), email = uid + "@example.test";
  await auth.createUser({uid,email,emailVerified:true});
  await database.doc("panelStaff/"+uid).set({uid,email,active:true,provisioning:"ready",countryCodes:["CL"],memberships:{CL:[role]},revision:1});
  return uid;
}
async function fixture() {
  const operator = await account("operations"), uid = await account("doctor"), id = "CL_"+(8000000000 + ++sequence);
  const specialtyId = "CL_qa_"+randomBytes(5).toString("hex"), createdAt = Timestamp.now();
  await database.doc("panelStaff/"+uid).update({doctorLinks:{CL:id}});
  await database.doc("doctorAccountLinks/"+id).set({uid,doctorId:id,countryCode:"CL",createdAt});
  await database.doc("specialties/"+specialtyId).set({countryCode:"CL",active:true});
  await database.doc("doctorRecords/"+id).set({id,countryCode:"CL",environment:"development",schemaVersion:2,status:"verified",
    name:"Ficticio",registryNumber:id.slice(3),specialty:"Ficticia",specialtyId,revision:2});
  return {operator,uid,id,specialtyId,createdAt};
}
const list = data => service(context(data.operator),{action:"doctorAdminList",country:"CL",ids:[data.id]});
const state = async data => (await list(data)).items[0].availability;
async function confirm(data, accepting = true) {
  const workspace = await service(context(data.uid),{action:"myWorkspace",country:"CL"});
  await service(context(data.uid),{action:"setAvailability",country:"CL",accepting,revision:workspace.revision,workspaceToken:workspace.workspaceToken,requestId:key()});
}
after(async()=>{await database.terminate();await deleteApp(app);});
test("available status uses same token as doctor workspace and exposes only minimal fields",async()=>{
  const data = await fixture();
  const workspace = await service(context(data.uid),{action:"myWorkspace",country:"CL"});
  const legacyToken = createHash("sha256").update(JSON.stringify([data.uid,"CL",data.id,data.createdAt.toMillis(),2])).digest("hex");
  assert.equal(workspace.workspaceToken,legacyToken);
  assert.equal((await state(data)).state,"needsConfirmation");
  await confirm(data);
  const before = (await database.doc("doctorAvailability/"+data.uid+"/countries/CL").get()).data();
  const result = await state(data);
  assert.equal(result.state,"available");assert.ok(result.confirmedAt);assert.equal(result.checkedAt,new Date(now).toISOString());
  assert.deepEqual(Object.keys(result).sort(),["checkedAt","confirmedAt","state"]);
  assert.deepEqual((await database.doc("doctorAvailability/"+data.uid+"/countries/CL").get()).data(),before);
  await confirm(data,false);assert.equal((await state(data)).state,"paused");
});
test("director gets administration without doctor availability; other roles cannot read",async()=>{
  const data = await fixture(), director = await account("medicalDirector");
  const input = {action:"doctorAdminList",country:"CL",ids:[data.id]};
  assert.equal((await service(context(director),input)).items[0].availability,undefined);
  for(const role of ["superadmin","doctor","finance"]) {
    const uid = await account(role);
    await assert.rejects(service(context(uid),input),error=>error.code==="permission-denied");
  }
  await database.doc("panelStaff/"+data.operator).update({active:false});
  await assert.rejects(list(data),error=>error.code==="permission-denied");
});
test("canonical and Auth account failures override a saved available preference",async()=>{
  for(const change of [{active:false},{provisioning:"pending"},{memberships:{CL:["finance"]}},{email:"different@example.test"}]) {
    const data = await fixture();await confirm(data);
    await database.doc("panelStaff/"+data.uid).update(change);
    assert.equal((await state(data)).state,"blockedAccount");
  }
  for(const change of [{disabled:true},{emailVerified:false}]) {
    const data = await fixture();await confirm(data);await auth.updateUser(data.uid,change);
    assert.equal((await state(data)).state,"blockedAccount");
  }
  const data = await fixture();await confirm(data);await auth.deleteUser(data.uid);
  assert.equal((await state(data)).state,"blockedAccount");
});
test("missing or mismatched links do not reveal another account preference",async()=>{
  const data = await fixture();await confirm(data);
  await database.doc("panelStaff/"+data.uid).update({doctorLinks:{}});
  assert.equal((await state(data)).state,"linkMismatch");
  await database.doc("doctorAccountLinks/"+data.id).update({uid:"../invalid"});
  assert.equal((await state(data)).state,"linkMismatch");
  await database.doc("doctorAccountLinks/"+data.id).delete();
  assert.equal((await state(data)).state,"unlinked");
});
test("administrative, professional and specialty eligibility override saved availability",async()=>{
  const data = await fixture();await confirm(data);
  await database.doc("doctorAdministration/"+data.id).set({active:false,revision:1});
  assert.equal((await state(data)).state,"blockedAdministration");
  await database.doc("doctorAdministration/"+data.id).set({active:true,revision:2});
  assert.equal((await state(data)).state,"needsConfirmation");
  await confirm(data);
  await database.doc("doctorRecords/"+data.id).update({status:"suspended"});
  assert.equal((await state(data)).state,"blockedReview");
  await database.doc("doctorRecords/"+data.id).update({status:"verified",revision:3});
  assert.equal((await state(data)).state,"needsConfirmation");
  await database.doc("specialties/"+data.specialtyId).update({active:false});
  assert.equal((await state(data)).state,"blockedSpecialty");
});
test("foreign preferences and changed link generations need a new confirmation",async()=>{
  const data = await fixture();await confirm(data);
  const path = "doctorAvailability/"+data.uid+"/countries/CL";
  await database.doc(path).update({countryCode:"AR"});
  assert.equal((await state(data)).state,"needsConfirmation");
  await database.doc(path).update({countryCode:"CL"});
  await database.doc("doctorAccountLinks/"+data.id).update({createdAt:Timestamp.fromMillis(now+99999)});
  assert.equal((await state(data)).state,"needsConfirmation");
});
test("bounded batch preserves input order and Auth service errors fail the list closed",async()=>{
  const data = await fixture(), other = await fixture();await confirm(data);
  const result = await service(context(data.operator),{action:"doctorAdminList",country:"CL",ids:[other.id,data.id]});
  assert.deepEqual(result.items.map(item=>item.id),[other.id,data.id]);
  assert.deepEqual(result.items.map(item=>item.availability.state),["needsConfirmation","available"]);
  const failing = createService({auth:{getUser:uid=>auth.getUser(uid),getUsers:async()=>{throw Error("Unavailable");}},database,
    sendInvitation:async()=>{},now:()=>now});
  await assert.rejects(failing(context(data.operator),{action:"doctorAdminList",country:"CL",ids:[data.id]}));
});
