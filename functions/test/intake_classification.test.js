const {test, after} = require("node:test");
const assert = require("node:assert/strict");
const {randomBytes} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {createService} = require("../src/service");
const {validate} = require("../src/policy");
if (!process.env.FIREBASE_AUTH_EMULATOR_HOST || !process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Emulators required");
const app = initializeApp({projectId: "demo-2daopinion-classification"}, "classification");
const auth = getAuth(app), database = getFirestore(app);
const service = createService({auth, database, sendInvitation: async () => {throw Error("No invitations");}});
const code = expected => error => error.code === expected;
const context = uid => ({uid, token: {auth_time: Math.floor(Date.now() / 1000) + 1}});
async function account(role = "operations") {
  const uid = "classification-" + randomBytes(6).toString("hex");
  await auth.createUser({uid, email: uid + "@example.test", emailVerified: true});
  await database.doc("panelStaff/" + uid).set({uid, active: true, provisioning: "ready", memberships: {CL: [role]}});
  return uid;
}
async function fixture() {
  const uid = await account(), id = randomBytes(10).toString("hex"), specialtyId = "CL_qa_" + randomBytes(5).toString("hex");
  await database.doc("intakeRequests/" + id).set({id, countryCode: "CL", status: "received",
    environment: "development", mode: "document_review", createdAt: Timestamp.now(), documentCount: 0, hasVideo: false});
  await database.doc("specialties/" + specialtyId).set({id: specialtyId, countryCode: "CL", active: true, name: "Especialidad ficticia"});
  return {uid, id, specialtyId};
}
const read = data => service(context(data.uid), {action: "intakeClassificationGet", country: "CL", id: data.id});
const input = data => ({action: "intakeClassificationSet", country: "CL", id: data.id, specialtyId: data.specialtyId,
  source: "patientConfirmed", confirmed: true, revision: 0, requestId: randomBytes(16).toString("hex")});
after(async () => {await database.terminate(); await deleteApp(app);});
test("classification validates exact IDs, source, confirmation, revisions and rejects clinical/extra fields", () => {
  const base = input({id: "a".repeat(20), specialtyId: "CL_qa"});
  for (const change of [{id: "../x"}, {id: "a".repeat(21)}, {country: "AR"}, {specialtyId: "AR_qa"},
    {specialtyId: null}, {source: "diagnosis"}, {source: "unconfirmed"}, {confirmed: false},
    {confirmed: "true"}, {revision: -1}, {revision: 0.5}, {revision: Number.MAX_SAFE_INTEGER},
    {requestId: "bad"}, {uid: "someone"}, {diagnosis: "private"}, {specialtyName: "tampered"}]) {
    assert.throws(() => validate({...base, ...change}), code("invalid-argument"));
  }
  assert.equal(validate({...base, source: "unconfirmed", specialtyId: null}).specialtyId, null);
  assert.equal(validate({...base, source: "medicalReferral"}).source, "medicalReferral");
});
test("pending, classify, replay, correction and clearing are audited without touching intake", async () => {
  const data = await fixture(), intake = database.doc("intakeRequests/" + data.id);
  const before = (await intake.get()).data();
  assert.deepEqual(await read(data), {id: data.id, revision: 0, specialtyId: null, specialtyName: null,
    source: "unconfirmed", updatedAt: null, editable: true, specialtyActive: false});
  const command = input(data);
  await service(context(data.uid), command); await service(context(data.uid), command);
  const saved = await read(data);
  assert.equal(saved.specialtyId, data.specialtyId); assert.equal(saved.revision, 1);
  assert.equal(saved.specialtyActive, true); assert.ok(saved.updatedAt);
  await service(context(data.uid), {...input(data), revision: 1, source: "medicalReferral"});
  await service(context(data.uid), {...input(data), revision: 2, specialtyId: null, source: "unconfirmed"});
  assert.equal((await read(data)).specialtyId, null);
  const events = await database.collection("intakeClassifications/" + data.id + "/events").get();
  assert.equal(events.size, 3); assert.deepEqual((await intake.get()).data(), before);
  assert.equal((await database.doc("intakeClassificationLimits/" + data.uid).get()).data().count, 3);
});
test("only canonical country operations; revoked, disabled and unverified actors denied", async () => {
  const data = await fixture();
  for (const role of ["medicalDirector", "superadmin", "doctor", "finance"]) {
    const uid = await account(role);
    if (role === "superadmin") assert.equal((await read({...data, uid})).editable, false);
    else await assert.rejects(read({...data, uid}), code("permission-denied"));
    await assert.rejects(service(context(uid), input(data)), code("permission-denied"));
  }
  await assert.rejects(service(null, input(data)), code("unauthenticated"));
  await database.doc("panelStaff/" + data.uid).update({memberships: {AR: ["operations"]}});
  await assert.rejects(read(data), code("permission-denied"));
  await database.doc("panelStaff/" + data.uid).update({memberships: {CL: ["operations"]}, active: false});
  await assert.rejects(read(data), code("permission-denied"));
  await database.doc("panelStaff/" + data.uid).update({active: true});
  await auth.updateUser(data.uid, {disabled: true});
  await assert.rejects(read(data), code("permission-denied"));
  await auth.updateUser(data.uid, {disabled: false, emailVerified: false});
  await assert.rejects(service(context(data.uid), input(data)), code("permission-denied"));
});
test("missing/foreign intake and inactive/foreign/missing specialty fail closed", async () => {
  const data = await fixture();
  await assert.rejects(read({...data, id: "z".repeat(20)}), code("permission-denied"));
  for (const change of [{countryCode: "AR"}, {environment: "production"}, {id: "wrong"}]) {
    const ref = database.doc("intakeRequests/" + data.id), before = (await ref.get()).data();
    await ref.update(change); await assert.rejects(read(data), code("permission-denied")); await ref.set(before);
  }
  for (const change of [{active: false}, {countryCode: "AR"}, {id: "wrong"}]) {
    const ref = database.doc("specialties/" + data.specialtyId), before = (await ref.get()).data();
    await ref.update(change); await assert.rejects(service(context(data.uid), input(data)), code("failed-precondition")); await ref.set(before);
  }
  await database.doc("specialties/" + data.specialtyId).delete();
  await assert.rejects(service(context(data.uid), input(data)), code("failed-precondition"));
});
test("conflicts, concurrent classification, mismatched replays and readonly when reception ends", async () => {
  const data = await fixture(), command = input(data);
  const result = await Promise.allSettled([service(context(data.uid), command), service(context(data.uid), input(data))]);
  assert.equal(result.filter(item => item.status === "fulfilled").length, 1);
  assert.equal(result.find(item => item.status === "rejected").reason.code, "aborted");
  const event = (await database.collection("intakeClassifications/" + data.id + "/events").get()).docs[0];
  await assert.rejects(service(context(data.uid), {...input(data), requestId: event.id, source: "medicalReferral"}), code("already-exists"));
  await database.doc("intakeRequests/" + data.id).update({status: "reviewing"});
  assert.equal((await read(data)).editable, false);
  await assert.rejects(service(context(data.uid), {...input(data), revision: 1, source: "medicalReferral"}), code("failed-precondition"));
});
test("specialty deactivation is shown, unchanged input rejected and daily bound enforced", async () => {
  const data = await fixture();
  await service(context(data.uid), input(data));
  await assert.rejects(service(context(data.uid), {...input(data), revision: 1}), code("failed-precondition"));
  await database.doc("specialties/" + data.specialtyId).update({active: false});
  const current = await read(data);
  assert.equal(current.specialtyActive, false); assert.equal(current.specialtyName, "Especialidad ficticia");
  await database.doc("intakeClassificationLimits/" + data.uid).set({day: new Date().toISOString().slice(0, 10), count: 20});
  await assert.rejects(service(context(data.uid), {...input(data), revision: 1, source: "unconfirmed", specialtyId: null}), code("resource-exhausted"));
  assert.equal((await read(data)).revision, 1);
});

test("superadmin reads saved classification without edit rights and canonical scope remains authoritative",async()=>{
 const data=await fixture(),uid=await account("superadmin");
 await service(context(data.uid),input(data));
 const view=await read({...data,uid});assert.equal(view.editable,false);assert.ok(view.specialtyId);
 await database.doc("panelStaff/"+uid).update({memberships:{AR:["superadmin"]}});
 await assert.rejects(read({...data,uid}),code("permission-denied"));
 await database.doc("panelStaff/"+uid).update({memberships:{CL:["superadmin"]},active:false});
 await assert.rejects(read({...data,uid}),code("permission-denied"));
});
