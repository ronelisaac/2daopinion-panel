const {test, before, after} = require("node:test");
const assert = require("node:assert/strict");
const {randomBytes} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore} = require("firebase-admin/firestore");
const {createService} = require("../src/service");
const {validate} = require("../src/policy");

if (!process.env.FIREBASE_AUTH_EMULATOR_HOST || !process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Emulators required; never run against remote Firebase.");
const app = initializeApp({projectId: "demo-2daopinion"});
const auth = getAuth(app);
const database = getFirestore(app);
const sent = [];
const service = createService({auth, database, sendInvitation: async (email) => sent.push(email)});
const context = (uid) => ({uid, token: {auth_time: Math.floor(Date.now() / 1000) + 1}});
const root = context("panel-test-root");
const requestId = () => randomBytes(16).toString("hex");
const create = (email, scopes = {CL: ["operations"]}) => ({action: "create", country: "CL", requestId: requestId(), name: "Equipo de prueba", email, memberships: scopes});
const get = async (uid) => (await database.doc("panelStaff/" + uid).get()).data();
const rejected = (code) => (error) => error.code === code;
before(async () => {
  await auth.createUser({uid: root.uid, email: "root@example.test", emailVerified: true});
  await auth.setCustomUserClaims(root.uid, {panelAccess: {version: 1, active: true, memberships: {CL: ["superadmin"], AR: ["superadmin"]}}});
});
after(async () => { await database.terminate(); await deleteApp(app); });

test("policy rejects extra fields, foreign paths, unknown roles and malformed text", () => {
  for (const input of [null, [], {action: "list", country: "CL", password: "secret"}, {...create("bad"), memberships: {}}, {...create("a@example.test"), memberships: {CL: ["owner"]}}, {action: "list", country: "CL", cursor: "../other"}, create("invalid")]) {
    assert.throws(() => validate(input), rejected("invalid-argument"));
  }
});
test("only a current verified superadmin can bootstrap and list", async () => {
  await assert.rejects(service(null, {action: "list", country: "CL"}), rejected("unauthenticated"));
  await auth.createUser({uid: "patient-test", email: "patient@example.test", emailVerified: true});
  await assert.rejects(service({...context("patient-test"), token: {...root.token, panelAccess: {active: true}}}, {action: "list", country: "CL"}), rejected("permission-denied"));
  const page = await service(root, {action: "list", country: "CL"});
  assert.equal(page.users[0].uid, root.uid);
  assert.equal(page.users[0].editable, false);
  assert.equal((await get(root.uid)).protected, true);
  await assert.rejects(service(root, {action: "list", country: "PE"}), rejected("permission-denied"));
});
test("create persists, sends access once and safely deduplicates retries", async () => {
  const command = create("staff@example.test");
  const first = await service(root, command);
  const again = await service(root, command);
  assert.deepEqual(first, again);
  assert.equal(sent.filter((email) => email === command.email).length, 1);
  const record = await get(first.uid);
  assert.equal(record.provisioning, "ready");
  assert.equal(record.revision, 1);
  const account = await auth.getUser(first.uid);
  assert.equal(account.emailVerified, false);
  assert.deepEqual(account.customClaims.panelAccess.memberships, {CL: ["operations"]});
  await assert.rejects(service(root, {...command, name: "Different"}), rejected("already-exists"));
  const audit = await database.collection("panelUserOperations").where("target", "==", first.uid).get();
  assert.equal(audit.docs.length, 1);
  assert.equal(audit.docs[0].data().status, "done");
});
test("existing patient account cannot be converted into staff by creating its email", async () => {
  await assert.rejects(service(root, create("patient@example.test")), rejected("already-exists"));
  assert.equal((await auth.getUser("patient-test")).customClaims?.panelAccess, undefined);
});
test("root and current account cannot be disabled or edited", async () => {
  await assert.rejects(service(root, {action: "setActive", country: "CL", requestId: requestId(), uid: root.uid, revision: 1, active: false}), rejected("failed-precondition"));
  assert.equal((await get(root.uid)).active, true);
});
test("update persists roles and rejects stale revisions", async () => {
  const created = await service(root, create("edit@example.test"));
  await service(root, {action: "update", country: "CL", requestId: requestId(), uid: created.uid, revision: 1, name: "Nombre actualizado", memberships: {CL: ["doctor", "finance"]}});
  const record = await get(created.uid);
  assert.equal(record.revision, 2);
  assert.equal(record.name, "Nombre actualizado");
  assert.deepEqual((await auth.getUser(created.uid)).customClaims.panelAccess.memberships.CL, ["doctor", "finance"]);
  await assert.rejects(service(root, {action: "setActive", country: "CL", requestId: requestId(), uid: created.uid, revision: 1, active: false}), rejected("aborted"));
});
test("country admin cannot read other-country roles, change multiscope target or grant abroad", async () => {
  const admin = await service(root, create("cl-admin@example.test", {CL: ["superadmin"]}));
  await auth.updateUser(admin.uid, {emailVerified: true});
  const member = await service(root, create("regional@example.test", {CL: ["doctor"], AR: ["finance"]}));
  const page = await service(context(admin.uid), {action: "list", country: "CL"});
  const regional = page.users.find((user) => user.uid === member.uid);
  assert.deepEqual(regional.memberships, {CL: ["doctor"]});
  assert.equal(regional.editable, false);
  await assert.rejects(service(context(admin.uid), {action: "setActive", country: "CL", requestId: requestId(), uid: member.uid, revision: 1, active: false}), rejected("permission-denied"));
  await assert.rejects(service(context(admin.uid), create("abroad@example.test", {CL: ["doctor"], AR: ["superadmin"]})), rejected("permission-denied"));
  await service(root, {action: "setActive", country: "CL", requestId: requestId(), uid: admin.uid, revision: 1, active: false});
  await assert.rejects(service(context(admin.uid), {action: "list", country: "CL"}), rejected("permission-denied"));
  assert.equal((await auth.getUser(admin.uid)).disabled, false);
  await service(root, {action: "setActive", country: "CL", requestId: requestId(), uid: admin.uid, revision: 2, active: true});
  assert.equal((await get(admin.uid)).active, true);
});
test("failed delivery retains a valid account and enforces resend cooldown", async () => {
  const failing = createService({auth, database, sendInvitation: async () => {throw new Error("mail");}});
  const result = await failing(root, create("mail-fail@example.test"));
  assert.equal(result.invitationSent, false);
  assert.equal((await get(result.uid)).provisioning, "ready");
  await assert.rejects(service(root, {action: "invite", country: "CL", uid: result.uid, revision: 1, requestId: requestId()}), rejected("resource-exhausted"));
  const later = createService({auth, database, now: () => Date.now() + 61000, sendInvitation: async (email) => sent.push(email)});
  const invited = await later(root, {action: "invite", country: "CL", uid: result.uid, revision: 1, requestId: requestId()});
  assert.equal(invited.invitationSent, true);
});
test("partial auth failure remains recoverable by the original actor without a second account", async () => {
  let failOnce = true;
  const proxy = new Proxy(auth, {get(target, property) {
    if (property === "setCustomUserClaims") return async (...args) => {
      if (failOnce) {failOnce = false; throw new Error("temporary");}
      return target.setCustomUserClaims(...args);
    };
    const value = target[property];
    return typeof value === "function" ? value.bind(target) : value;
  }});
  const failing = createService({auth: proxy, database, sendInvitation: async (email) => sent.push(email)});
  const command = create("recover@example.test");
  await assert.rejects(failing(root, command));
  const account = await auth.getUserByEmail(command.email);
  assert.equal((await get(account.uid)).provisioning, "pending");
  const recovered = await service(root, {action: "resume", country: "CL", uid: account.uid});
  assert.equal(recovered.uid, account.uid);
  assert.equal((await get(account.uid)).provisioning, "ready");
});
test("pagination is bounded and staff data cannot be read with the client REST API", async () => {
  for (let index = 0; index < 22; index++) {
    await service(root, create("page" + index + "@example.test"));
  }
  const first = await service(root, {action: "list", country: "CL"});
  assert.equal(first.users.length, 20);
  assert.ok(first.nextCursor);
  const second = await service(root, {action: "list", country: "CL", cursor: first.nextCursor});
  const ids = [...first.users, ...second.users].map((user) => user.uid);
  assert.equal(ids.length, new Set(ids).size);
  const response = await fetch("http://" + process.env.FIRESTORE_EMULATOR_HOST + "/v1/projects/demo-2daopinion/databases/(default)/documents/panelStaff/" + root.uid);
  assert.equal(response.status, 403);
});
test("concurrent mutation is rejected while a lease is held", async () => {
  await database.doc("panelControl/users").update({lockedUntil: Date.now() + 5000, lease: "test-held"});
  await assert.rejects(service(root, create("concurrent@example.test")), rejected("aborted"));
  await database.doc("panelControl/users").update({lockedUntil: 0, lease: ""});
});
test("global daily mutation budget blocks new operations", async () => {
  await database.doc("panelControl/users").update({day: new Date().toISOString().slice(0, 10), count: 100});
  await assert.rejects(service(root, create("over-budget@example.test")), rejected("resource-exhausted"));
});
