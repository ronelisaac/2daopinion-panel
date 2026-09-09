const {test, before, after} = require("node:test");
const assert = require("node:assert/strict");
const {randomBytes} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore} = require("firebase-admin/firestore");
const {createService} = require("../src/service");
const {validate} = require("../src/policy");

if (!process.env.FIREBASE_AUTH_EMULATOR_HOST || !process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Emulators required");
const app = initializeApp({projectId: "demo-2daopinion-links"}, "doctor-links");
const auth = getAuth(app), database = getFirestore(app);
const service = createService({auth, database, sendInvitation: async () => {throw new Error("Unexpected invitation");}});
const context = uid => ({uid, token: {auth_time: Math.floor(Date.now() / 1000) + 1}});
const admin = "link-admin-" + randomBytes(4).toString("hex");
const rejects = code => error => error.code === code;
let sequence = 0;
async function account(uid, role) {
  await auth.createUser({uid, email: uid + "@example.test", emailVerified: true});
  await database.doc("panelStaff/" + uid).set({uid, name: "Ficticio", email: uid + "@example.test",
    countryCodes: ["CL"], memberships: {CL: [role]}, active: true, provisioning: "ready", revision: 1});
}
async function fixture() {
  const suffix = randomBytes(5).toString("hex"), uid = "link-doctor-" + suffix;
  await account(uid, "doctor");
  const registry = String(8000000000 + ++sequence), doctorId = "CL_" + registry;
  const specialtyId = "CL_qa_" + suffix;
  await database.doc("specialties/" + specialtyId).set({countryCode: "CL", active: true});
  await database.doc("doctorRecords/" + doctorId).set({id: doctorId, countryCode: "CL", registryNumber: registry,
    name: "Profesional ficticio", specialty: "Especialidad ficticia", specialtyId,
    schemaVersion: 2, environment: "development", status: "verified", revision: 3});
  const command = {action: "linkDoctor", country: "CL", uid, registry, revision: 1,
    doctorRevision: 3, requestId: randomBytes(16).toString("hex")};
  return {uid, doctorId, specialtyId, command};
}
before(async () => {await account(admin, "superadmin");});
after(async () => {await database.terminate(); await deleteApp(app);});

test("link policy rejects malformed numbers, countries, revisions and injected roles", () => {
  const base = {action: "linkDoctor", country: "CL", uid: "target", registry: "123", revision: 1,
    doctorRevision: 1, requestId: "a".repeat(32)};
  for (const change of [{registry: 123}, {registry: "0123"}, {registry: "../x"}, {country: "AR"},
    {doctorRevision: 0}, {revision: 1.5}, {memberships: {CL: ["superadmin"]}}]) {
    assert.throws(() => validate({...base, ...change}), rejects("invalid-argument"));
  }
});
test("explicit preview, atomic one-to-one link, idempotency and unlink preserve auth and medical record", async () => {
  const data = await fixture();
  const doctorBefore = (await database.doc("doctorRecords/" + data.doctorId).get()).data();
  const authBefore = (await auth.getUser(data.uid)).toJSON();
  const preview = await service(context(admin), {action: "doctorPreview", country: "CL", uid: data.uid, registry: data.command.registry});
  assert.deepEqual(Object.keys(preview).sort(), ["id", "name", "registry", "revision", "specialty"]);
  assert.equal(preview.id, data.doctorId);
  const result = await service(context(admin), data.command);
  assert.deepEqual(await service(context(admin), data.command), result);
  const staff = (await database.doc("panelStaff/" + data.uid).get()).data();
  assert.equal(staff.revision, 2); assert.equal(staff.doctorLinks.CL, data.doctorId);
  assert.equal((await database.doc("doctorAccountLinks/" + data.doctorId).get()).data().uid, data.uid);
  const listed = await service(context(admin), {action: "list", country: "CL"});
  assert.equal(listed.users.find(user => user.uid === data.uid).doctorLinks.CL, data.doctorId);
  await assert.rejects(service(context(admin), {action: "update", country: "CL", uid: data.uid,
    revision: 2, name: "Ficticio", memberships: {CL: ["operations"]}, requestId: randomBytes(16).toString("hex")}),
    error => error.code === "failed-precondition" && error.message === "doctor-link-present");
  const unlink = {...data.command, action: "unlinkDoctor", revision: 2, requestId: randomBytes(16).toString("hex")};
  delete unlink.doctorRevision;
  await service(context(admin), unlink);
  assert.equal((await database.doc("doctorAccountLinks/" + data.doctorId).get()).exists, false);
  assert.deepEqual((await database.doc("panelStaff/" + data.uid).get()).data().doctorLinks, {});
  assert.deepEqual((await auth.getUser(data.uid)).toJSON(), authBefore);
  assert.deepEqual((await database.doc("doctorRecords/" + data.doctorId).get()).data(), doctorBefore);
  const audit = await database.collection("panelUserOperations").where("target", "==", data.uid).get();
  assert.equal(audit.size, 2);
  assert.ok(audit.docs.every(item => item.data().status === "done"));
});
test("only current superadmin can preview or link, never own account or protected user", async () => {
  const data = await fixture();
  await assert.rejects(service(context(data.uid), data.command), rejects("permission-denied"));
  await assert.rejects(service(null, data.command), rejects("unauthenticated"));
  await database.doc("panelStaff/" + data.uid).update({protected: true});
  await assert.rejects(service(context(admin), data.command), rejects("failed-precondition"));
});
test("inactive account, missing doctor role and foreign memberships cannot be linked", async () => {
  for (const change of [{active: false}, {memberships: {CL: ["operations"]}},
    {countryCodes: ["CL", "AR"], memberships: {CL: ["doctor"], AR: ["doctor"]}}]) {
    const data = await fixture();
    await database.doc("panelStaff/" + data.uid).update(change);
    await assert.rejects(service(context(admin), data.command), error => ["permission-denied", "failed-precondition"].includes(error.code));
  }
});
test("pending, legacy, suspended, inactive specialty and mismatched country fail closed", async () => {
  for (const change of [{status: "pending"}, {status: "suspended"}, {schemaVersion: 1},
    {countryCode: "AR"}, {environment: "production"}, {specialtyId: "CL_missing"}]) {
    const data = await fixture();
    await database.doc("doctorRecords/" + data.doctorId).update(change);
    await assert.rejects(service(context(admin), data.command), rejects("failed-precondition"));
  }
  const data = await fixture();
  await database.doc("specialties/" + data.specialtyId).update({active: false});
  await assert.rejects(service(context(admin), data.command), rejects("failed-precondition"));
});
test("stale doctor and staff revisions do not overwrite newer decisions", async () => {
  for (const change of [{doctorRevision: 2}, {revision: 2}]) {
    const data = await fixture();
    await assert.rejects(service(context(admin), {...data.command, ...change}), rejects("aborted"));
    assert.equal((await database.doc("doctorAccountLinks/" + data.doctorId).get()).exists, false);
  }
});
test("one doctor cannot be linked to two accounts and a retry key cannot change intent", async () => {
  const data = await fixture(), other = await fixture();
  await service(context(admin), data.command);
  await assert.rejects(service(context(admin), {...other.command, registry: data.command.registry}), rejects("already-exists"));
  await assert.rejects(service(context(admin), {...data.command, uid: other.uid}), rejects("already-exists"));
});
test("deactivation preserves trace and allows explicit unlink without reactivating account", async () => {
  const data = await fixture();
  await service(context(admin), data.command);
  await database.doc("panelStaff/" + data.uid).update({active: false});
  const unlink = {...data.command, action: "unlinkDoctor", revision: 2, requestId: randomBytes(16).toString("hex")};
  delete unlink.doctorRevision;
  await service(context(admin), unlink);
  assert.equal((await database.doc("panelStaff/" + data.uid).get()).data().active, false);
});
test("disabled Auth identity and revoked canonical administrator are denied", async () => {
  const data = await fixture();
  await auth.updateUser(data.uid, {disabled: true});
  await assert.rejects(service(context(admin), data.command), rejects("failed-precondition"));
  await database.doc("panelStaff/" + admin).update({active: false});
  await assert.rejects(service(context(admin), data.command), rejects("permission-denied"));
});
