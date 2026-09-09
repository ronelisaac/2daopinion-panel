const {test, after} = require("node:test");
const assert = require("node:assert/strict");
const {randomBytes} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {createService} = require("../src/service");
const {validate} = require("../src/policy");

if (!process.env.FIREBASE_AUTH_EMULATOR_HOST || !process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Emulators required");
const app = initializeApp({projectId: "demo-2daopinion-workspace"}, "workspace");
const auth = getAuth(app), database = getFirestore(app);
let time = Date.now(), sequence = 0;
const service = createService({auth, database, now: () => time, sendInvitation: async () => {throw new Error("Unexpected invitation");}});
const context = uid => ({uid, token: {auth_time: Math.floor(Date.now() / 1000) + 1}});
const code = expected => error => error.code === expected;
const read = uid => service(context(uid), {action: "myWorkspace", country: "CL"});
const pref = uid => database.doc("doctorAvailability/" + uid + "/countries/CL");
const command = view => ({action: "setAvailability", country: "CL", accepting: true, revision: view.revision,
  workspaceToken: view.workspaceToken, requestId: randomBytes(16).toString("hex")});
async function fixture() {
  const uid = "workspace-" + randomBytes(5).toString("hex");
  const doctorId = "CL_" + (9000000000 + ++sequence), specialtyId = "CL_qa_" + randomBytes(5).toString("hex");
  await auth.createUser({uid, email: uid + "@example.test", emailVerified: true});
  await database.doc("panelStaff/" + uid).set({uid, active: true, provisioning: "ready",
    memberships: {CL: ["doctor"]}, countryCodes: ["CL"], doctorLinks: {CL: doctorId}});
  await database.doc("doctorAccountLinks/" + doctorId).set({uid, doctorId, countryCode: "CL", createdAt: Timestamp.now()});
  await database.doc("specialties/" + specialtyId).set({countryCode: "CL", active: true});
  await database.doc("doctorRecords/" + doctorId).set({id: doctorId, countryCode: "CL",
    name: "Profesional ficticio", registryNumber: doctorId.slice(3), specialty: "Ficticia", specialtyId,
    schemaVersion: 2, environment: "development", status: "verified", revision: 2, review: {evidence: "PRIVATE"}});
  return {uid, doctorId, specialtyId};
}
after(async () => {await database.terminate(); await deleteApp(app);});
test("workspace inputs reject injected identity, countries, malformed booleans and revisions", () => {
  const base = {action: "setAvailability", country: "CL", accepting: true, revision: 0,
    workspaceToken: "a".repeat(64), requestId: "b".repeat(32)};
  assert.deepEqual(validate(base), base);
  for (const change of [{uid: "victim"}, {country: "AR"}, {accepting: "true"}, {accepting: null},
    {revision: -1}, {revision: 0.5}, {revision: Number.MAX_SAFE_INTEGER + 1},
    {workspaceToken: ""}, {requestId: "../x"}]) {
    assert.throws(() => validate({...base, ...change}), code("invalid-argument"));
  }
  assert.throws(() => validate({action: "myWorkspace", country: "CL", uid: "victim"}), code("invalid-argument"));
});
test("read returns only own minimal profile and unlinked accounts cannot save", async () => {
  const data = await fixture(), view = await read(data.uid);
  assert.equal(view.state, "ready"); assert.equal(view.accepting, false);
  assert.deepEqual(Object.keys(view.doctor).sort(), ["id", "name", "registry", "specialty"]);
  await database.doc("panelStaff/" + data.uid).update({doctorLinks: {}});
  assert.deepEqual(await read(data.uid), {state: "unlinked", doctor: null, accepting: false,
    revision: 0, workspaceToken: null, updatedAt: null});
  await assert.rejects(service(context(data.uid), command(view)), code("failed-precondition"));
});
test("save is atomic, optimistic, auditable, idempotent and independently pausable", async () => {
  const data = await fixture(), view = await read(data.uid), input = command(view);
  const staffBefore = (await database.doc("panelStaff/" + data.uid).get()).data();
  const authBefore = (await auth.getUser(data.uid)).toJSON();
  await service(context(data.uid), input);
  await service(context(data.uid), input);
  assert.equal((await pref(data.uid).get()).data().count, 1);
  assert.equal((await pref(data.uid).collection("events").get()).size, 1);
  const saved = await read(data.uid);
  assert.equal(saved.accepting, true); assert.equal(saved.revision, 1); assert.ok(saved.updatedAt);
  await assert.rejects(service(context(data.uid), {...input, accepting: false}), code("already-exists"));
  await assert.rejects(service(context(data.uid), {...input, requestId: "c".repeat(32)}), code("aborted"));
  await service(context(data.uid), {...command(saved), accepting: false});
  assert.equal((await read(data.uid)).accepting, false);
  assert.equal((await pref(data.uid).collection("events").get()).size, 2);
  assert.deepEqual((await database.doc("panelStaff/" + data.uid).get()).data(), staffBefore);
  assert.deepEqual((await auth.getUser(data.uid)).toJSON(), authBefore);
});
test("current role, active state, verified Auth and reverse link are mandatory", async () => {
  await assert.rejects(service(null, {action: "myWorkspace", country: "CL"}), code("unauthenticated"));
  for (const change of [{active: false}, {provisioning: "pending"}, {memberships: {CL: ["superadmin"]}},
    {memberships: {AR: ["doctor"], CL: ["operations"]}}]) {
    const data = await fixture();
    await database.doc("panelStaff/" + data.uid).update(change);
    await assert.rejects(read(data.uid), code("permission-denied"));
  }
  for (const change of [{disabled: true}, {emailVerified: false}]) {
    const data = await fixture(); await auth.updateUser(data.uid, change);
    await assert.rejects(read(data.uid), code("permission-denied"));
  }
  const data = await fixture(), other = await fixture();
  await database.doc("doctorAccountLinks/" + data.doctorId).update({uid: other.uid});
  await assert.rejects(read(data.uid), code("permission-denied"));
});
test("ineligible record and inactive specialty cannot accept new requests", async () => {
  for (const change of [{status: "pending"}, {status: "suspended"}, {schemaVersion: 1}, {environment: "production"}]) {
    const data = await fixture();
    await database.doc("doctorRecords/" + data.doctorId).update(change);
    const view = await read(data.uid);
    assert.equal(view.state, "blocked"); assert.equal(view.accepting, false);
    await assert.rejects(service(context(data.uid), command(view)), code("failed-precondition"));
  }
  const data = await fixture();
  await service(context(data.uid), command(await read(data.uid)));
  await database.doc("specialties/" + data.specialtyId).update({active: false});
  const blocked = await read(data.uid);
  assert.equal(blocked.accepting, false);
  await assert.rejects(service(context(data.uid), command(blocked)), code("failed-precondition"));
});
test("review changes and relinking invalidate old confirmations", async () => {
  const data = await fixture();
  await service(context(data.uid), command(await read(data.uid)));
  const old = await read(data.uid);
  await database.doc("doctorRecords/" + data.doctorId).update({revision: 3});
  assert.equal((await read(data.uid)).accepting, false);
  await assert.rejects(service(context(data.uid), command(old)), code("aborted"));
  await service(context(data.uid), command(await read(data.uid)));
  await database.doc("doctorAccountLinks/" + data.doctorId).update({createdAt: Timestamp.fromMillis(Date.now() + 10000)});
  assert.equal((await read(data.uid)).accepting, false);
});
test("concurrent revisions cannot overwrite one another", async () => {
  const data = await fixture(), view = await read(data.uid);
  const results = await Promise.allSettled([command(view), command(view)].map(input => service(context(data.uid), input)));
  assert.equal(results.filter(result => result.status === "fulfilled").length, 1);
  assert.equal(results.find(result => result.status === "rejected").reason.code, "aborted");
  assert.equal((await pref(data.uid).collection("events").get()).size, 1);
});
test("daily account quota does not charge retries and resets by UTC day", async () => {
  const data = await fixture();
  let last;
  for (let index = 0; index < 20; index++) {
    last = {...command(await read(data.uid)), accepting: index % 2 === 0};
    await service(context(data.uid), last);
  }
  await service(context(data.uid), last);
  await assert.rejects(service(context(data.uid), command(await read(data.uid))), code("resource-exhausted"));
  time += 86400000;
  await service(context(data.uid), command(await read(data.uid)));
  assert.equal((await pref(data.uid).get()).data().count, 1);
  assert.equal((await pref(data.uid).collection("events").get()).size, 21);
});
