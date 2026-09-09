const {test, after} = require("node:test");
const assert = require("node:assert/strict");
const {randomBytes} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {createService} = require("../src/service");
const {validate} = require("../src/policy");
if (!process.env.FIREBASE_AUTH_EMULATOR_HOST || !process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Emulators required");
const app = initializeApp({projectId: "demo-2daopinion-administration"}, "administration");
const auth = getAuth(app), database = getFirestore(app);
let time = Date.now(), sequence = 0;
const service = createService({auth, database, now: () => time, sendInvitation: async () => {throw new Error("Unexpected invitation");}});
const context = uid => ({uid, token: {auth_time: Math.floor(Date.now() / 1000) + 1}});
const code = expected => error => error.code === expected;
const requestId = () => randomBytes(16).toString("hex");
async function account(role) {
  const uid = "adminstate-" + randomBytes(6).toString("hex");
  await auth.createUser({uid, email: uid + "@example.test", emailVerified: true});
  await database.doc("panelStaff/" + uid).set({uid, email: uid + "@example.test", active: true,
    provisioning: "ready", memberships: {CL: [role]}, countryCodes: ["CL"], revision: 1});
  return uid;
}
async function fixture() {
  const operator = await account("operations"), doctorUid = await account("doctor");
  const id = "CL_" + (9000000000 + ++sequence), specialtyId = "CL_qa_" + randomBytes(5).toString("hex");
  await database.doc("panelStaff/" + doctorUid).update({doctorLinks: {CL: id}});
  await database.doc("doctorAccountLinks/" + id).set({uid: doctorUid, doctorId: id, countryCode: "CL", createdAt: Timestamp.now()});
  await database.doc("specialties/" + specialtyId).set({countryCode: "CL", active: true});
  await database.doc("doctorRecords/" + id).set({id, countryCode: "CL", name: "Ficticio",
    registryNumber: id.slice(3), specialty: "Ficticia", specialtyId,
    schemaVersion: 2, environment: "development", status: "verified", revision: 2, review: {evidence: "unchanged"}});
  return {operator, doctorUid, id};
}
const read = data => service(context(data.operator), {action: "doctorAdminList", country: "CL", ids: [data.id]});
const command = (data, revision = 0, active = false) => ({action: "doctorAdminSetActive", country: "CL", id: data.id,
  revision, active, reason: "Motivo administrativo ficticio", requestId: requestId()});
after(async () => {await database.terminate(); await deleteApp(app);});
test("strict IDs, lists, booleans, revisions and Unicode reason limits", () => {
  const base = command({id: "CL_123"});
  for (const change of [{country: "AR"}, {id: "CL_012"}, {active: "false"}, {revision: -1},
    {revision: Number.MAX_SAFE_INTEGER}, {reason: "         "}, {reason: "a".repeat(9)},
    {reason: "a".repeat(501)}, {requestId: "../bad"}, {status: "verified"}, {uid: "victim"}]) {
    assert.throws(() => validate({...base, ...change}), code("invalid-argument"));
  }
  for (const reason of ["a".repeat(10), "a".repeat(500), "😀".repeat(500)]) assert.equal(validate({...base, reason}).reason, reason);
  assert.equal(validate({...base, reason: "  reason trimmed  "}).reason, "reason trimmed");
  for (const ids of [[], ["CL_1", "CL_1"], ["../x"], Array.from({length: 21}, (_, index) => "CL_" + (index + 1))]) {
    assert.throws(() => validate({action: "doctorAdminList", country: "CL", ids}), code("invalid-argument"));
  }
});
test("default state, pause and reactivation preserve medical review, account and link", async () => {
  const data = await fixture();
  const references = ["doctorRecords/" + data.id, "panelStaff/" + data.doctorUid, "doctorAccountLinks/" + data.id];
  const before = await Promise.all(references.map(async path => (await database.doc(path).get()).data()));
  const {availability, ...administrative} = (await read(data)).items[0];
  assert.equal(availability.state, "needsConfirmation");
  assert.deepEqual(administrative, {id: data.id, active: true, revision: 0, reason: null, updatedAt: null});
  const input = command(data);
  await service(context(data.operator), input);await service(context(data.operator), input);
  const paused = (await read(data)).items[0];
  assert.equal(paused.active, false);assert.equal(paused.revision, 1);assert.ok(paused.updatedAt);
  await service(context(data.operator), command(data, 1, true));
  assert.equal((await read(data)).items[0].active, true);
  assert.equal((await database.collection("doctorAdministration/" + data.id + "/events").get()).size, 2);
  assert.deepEqual(await Promise.all(references.map(async path => (await database.doc(path).get()).data())), before);
});
test("operations and superadmin write; director only reads", async () => {
  const data = await fixture();
  const director = await account("medicalDirector");
  assert.equal((await service(context(director), {action: "doctorAdminList", country: "CL", ids: [data.id]})).items.length, 1);
  await assert.rejects(service(context(director), command(data)), code("permission-denied"));
  for (const role of ["superadmin", "doctor", "finance"]) {
    const uid = await account(role);
    if (role === "superadmin") await service(context(uid), command(data));
    else await assert.rejects(service(context(uid), command(data)), code("permission-denied"));
    if (role === "superadmin") assert.equal((await service(context(uid), {action: "doctorAdminList", country: "CL", ids: [data.id]})).items.length, 1);
    else await assert.rejects(service(context(uid), {action: "doctorAdminList", country: "CL", ids: [data.id]}), code("permission-denied"));
  }
  await database.doc("panelStaff/" + data.operator).update({active: false});
  await assert.rejects(read(data), code("permission-denied"));
  await assert.rejects(service(context(data.operator), command(data)), code("permission-denied"));
});
test("foreign or nonexistent records and wrong-country roles are denied", async () => {
  const data = await fixture();
  await assert.rejects(service(context(data.operator), {...command(data), id: "CL_999"}), code("permission-denied"));
  await database.doc("doctorRecords/" + data.id).update({countryCode: "AR"});
  await assert.rejects(read(data), code("permission-denied"));
  await assert.rejects(service(context(data.operator), command(data)), code("permission-denied"));
  await database.doc("panelStaff/" + data.operator).update({memberships: {AR: ["operations"], CL: ["doctor"]}});
  await assert.rejects(read(data), code("permission-denied"));
});
test("pause blocks doctor availability, reactivation requires fresh consent and never approves", async () => {
  const data = await fixture();
  const workspace = () => service(context(data.doctorUid), {action: "myWorkspace", country: "CL"});
  const initial = await workspace();
  const availability = {action: "setAvailability", country: "CL", revision: 0,
    workspaceToken: initial.workspaceToken, accepting: true, requestId: requestId()};
  await service(context(data.doctorUid), availability);
  await service(context(data.operator), command(data));
  assert.equal((await workspace()).state, "blocked");assert.equal((await workspace()).accepting, false);
  await assert.rejects(service(context(data.doctorUid), {...availability, revision: 1, requestId: requestId()}), code("failed-precondition"));
  await service(context(data.operator), command(data, 1, true));
  assert.equal((await workspace()).state, "ready");assert.equal((await workspace()).accepting, false);
  await assert.rejects(service(context(data.doctorUid), {...availability, revision: 1, requestId: requestId()}), code("aborted"));
  await database.doc("doctorRecords/" + data.id).update({status: "suspended"});
  await service(context(data.operator), command(data, 2, false));
  await service(context(data.operator), command(data, 3, true));
  assert.equal((await workspace()).state, "blocked");
});
test("inactive administration blocks previews and linking, but unlink remains possible", async () => {
  const data = await fixture(), admin = await account("superadmin");
  await service(context(data.operator), command(data));
  await service(context(admin), {action: "unlinkDoctor", country: "CL", uid: data.doctorUid,
    registry: data.id.slice(3), revision: 1, requestId: requestId()});
  const preview = {action: "doctorPreview", country: "CL", uid: data.doctorUid, registry: data.id.slice(3)};
  await assert.rejects(service(context(admin), preview), code("failed-precondition"));
  await assert.rejects(service(context(admin), {...preview, action: "linkDoctor", revision: 2, doctorRevision: 2, requestId: requestId()}), code("failed-precondition"));
  await database.doc("panelStaff/" + data.doctorUid).update({countryCodes: ["CL", "AR"], memberships: {CL: ["doctor"], AR: ["doctor"]}});
  await assert.rejects(service(context(admin), preview), code("permission-denied"));
});
test("concurrent writes and replay cannot overwrite another decision or duplicate audit", async () => {
  const data = await fixture(), input = command(data);
  const results = await Promise.allSettled([input, command(data)].map(value => service(context(data.operator), value)));
  assert.equal(results.filter(result => result.status === "fulfilled").length, 1);
  assert.equal(results.find(result => result.status === "rejected").reason.code, "aborted");
  const event = (await database.collection("doctorAdministration/" + data.id + "/events").get()).docs[0];
  const original = {...input, requestId: event.id};
  await service(context(data.operator), original);
  await assert.rejects(service(context(data.operator), {...original, reason: "Different legitimate reason"}), code("already-exists"));
  await assert.rejects(service(context(data.operator), command(data, 1, false)), code("failed-precondition"));
});
test("daily quota counts changes not retries and resets the following UTC day", async () => {
  const data = await fixture();let last;
  for (let index = 0; index < 20; index++) {
    last = command(data, index, index % 2 === 1);
    await service(context(data.operator), last);
  }
  await service(context(data.operator), last);
  await assert.rejects(service(context(data.operator), command(data, 20, false)), code("resource-exhausted"));
  time += 86400000;
  await service(context(data.operator), command(data, 20, false));
  assert.equal((await database.doc("doctorAdministrationLimits/" + data.operator).get()).data().count, 1);
});
