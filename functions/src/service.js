const {createHash, randomUUID} = require("node:crypto");
const {FieldValue, FieldPath} = require("firebase-admin/firestore");
const {fail, memberships, validate, canManage, publicUser} = require("./policy");

const {createDoctorLinks} = require("./doctor_links");
const {createDoctorWorkspace} = require("./doctor_workspace");

const hash = (value) => createHash("sha256").update(value).digest("hex");

function createService({auth, database, sendInvitation, now = () => Date.now()}) {
  const staff = database.collection("panelStaff");
  const operations = database.collection("panelUserOperations");
  const control = database.doc("panelControl/users");
  const doctorLinks = createDoctorLinks({auth, database});
  const workspace = createDoctorWorkspace({database, now});

  async function actorFor(context) {
    if (!context?.uid) fail("unauthenticated", "denied");
    let account;
    try { account = await auth.getUser(context.uid); } catch (_) { fail("permission-denied", "denied"); }
    if (account.disabled || !account.emailVerified ||
        Number(context.token?.auth_time || 0) < Math.floor(Date.parse(account.tokensValidAfterTime || 0) / 1000)) fail("permission-denied", "denied");
    const reference = staff.doc(account.uid);
    let snapshot = await reference.get();
    if (!snapshot.exists) {
      const access = account.customClaims?.panelAccess;
      if (access?.version !== 1 || access.active !== true) fail("permission-denied", "denied");
      const scopes = memberships(access.memberships);
      if (!Object.values(scopes).some((assigned) => assigned.includes("superadmin"))) fail("permission-denied", "denied");
      await database.runTransaction(async (transaction) => {
        const [current, config] = await transaction.getAll(reference, control);
        if (current.exists) return;
        if (config.exists && config.data().anchorUid !== account.uid) fail("permission-denied", "denied");
        const record = {uid: account.uid, name: account.displayName || account.email, email: account.email, memberships: scopes, countryCodes: Object.keys(scopes), active: true, revision: 1, provisioning: "ready", protected: true, invitationSent: true};
        transaction.create(reference, record);
        transaction.set(control, {anchorUid: account.uid}, {merge: true});
        transaction.create(operations.doc("bootstrap"), {action: "bootstrap", actor: account.uid, target: account.uid, status: "done", createdAt: FieldValue.serverTimestamp()});
      });
      snapshot = await reference.get();
    }
    const actor = snapshot.data();
    if (!actor.active || actor.provisioning !== "ready") fail("permission-denied", "denied");
    return actor;
  }

  async function list(actor, input) {
    let query = staff.where("countryCodes", "array-contains", input.country).orderBy(FieldPath.documentId()).limit(21);
    if (input.cursor) query = query.startAfter(input.cursor);
    const snapshot = await query.get();
    const visible = snapshot.docs.slice(0, 20);
    const accounts = visible.length ? await auth.getUsers(visible.map((item) => ({uid: item.id}))) : {users: []};
    const users = visible.map((item) => publicUser(item.data(), accounts.users.find((account) => account.uid === item.id), actor));
    return {users, nextCursor: snapshot.docs.length > 20 ? visible.at(-1).id : null};
  }

  async function reserve(actor, input) {
    const operationId = hash(actor.uid + ":" + input.requestId);
    const reference = operations.doc(operationId);
    const digest = hash(JSON.stringify(input));
    const lease = randomUUID();
    return database.runTransaction(async (transaction) => {
      const [lock, previous] = await transaction.getAll(control, reference);
      if (previous.exists && previous.data().digest !== digest) fail("already-exists", "request-mismatch");
      if (previous.data()?.status === "done") return {done: previous.data().result};
      if ((lock.data()?.lockedUntil || 0) > now()) fail("aborted", "busy");
      const count = lock.data()?.day === new Date(now()).toISOString().slice(0, 10) ? (lock.data().count || 0) : 0;
      if (!previous.exists && count >= 100) fail("resource-exhausted", "daily-limit");
      transaction.set(control, {lease, lockedUntil: now() + 120000, day: new Date(now()).toISOString().slice(0, 10), count: count + (previous.exists ? 0 : 1)}, {merge: true});
      if (!previous.exists) transaction.create(reference, {digest, input, actor: actor.uid, country: input.country, action: input.action, status: "started", createdAt: FieldValue.serverTimestamp()});
      return {reference, operationId, lease};
    });
  }

  async function makePlan(actor, input, operation) {
    const stored = await operation.reference.get();
    if (stored.data().plan) {
      const plan = stored.data().plan;
      if (!canManage(actor, [...plan.after.countryCodes, ...(plan.before?.countryCodes || [])])) fail("permission-denied", "denied");
      return plan;
    }
    let before = null;
    let target = input.uid;
    if (input.action === "create") {
      target = "staff_" + operation.operationId.slice(0, 48);
      try { await auth.getUserByEmail(input.email); fail("already-exists", "email-exists"); }
      catch (error) { if (error.code !== "auth/user-not-found") throw error; }
    } else {
      const snapshot = await staff.doc(target).get();
      if (!snapshot.exists) fail("not-found", "missing");
      before = snapshot.data();
      if (before.uid === actor.uid || before.protected) fail("failed-precondition", "protected");
      if (!before.countryCodes.includes(input.country) || !canManage(actor, before.countryCodes)) fail("permission-denied", "denied");
      if (before.revision !== input.revision || before.provisioning !== "ready") fail("aborted", "conflict");
      if (input.action === "invite" && (!before.active || now() - (before.invitedAt || 0) < 60000)) fail("resource-exhausted", "invitation-cooldown");
    }
    const scopes = input.memberships || before.memberships;
    if (!canManage(actor, Object.keys(scopes))) fail("permission-denied", "denied");
    if (input.action === "update" && Object.keys(before.doctorLinks || {}).some((country) => !scopes[country]?.includes("doctor"))) {
      fail("failed-precondition", "doctor-link-present");
    }
    const after = {
      ...(before || {}), uid: target, name: input.name || before?.name, email: input.email || before?.email,
      memberships: scopes, countryCodes: Object.keys(scopes), active: input.action === "setActive" ? input.active : (before?.active ?? true),
      protected: false, revision: (before?.revision || 0) + 1, provisioning: "pending",
      invitationSent: before?.invitationSent || false,
    };
    const plan = {before, after};
    await database.runTransaction(async (transaction) => {
      const current = await transaction.get(staff.doc(target));
      if ((current.data()?.revision || 0) !== (before?.revision || 0)) fail("aborted", "conflict");
      transaction.set(staff.doc(target), {...after, operationId: operation.operationId, operationActor: actor.uid});
      transaction.update(operation.reference, {plan, target});
    });
    return plan;
  }

  async function synchronize(plan, action) {
    const record = plan.after;
    let account;
    try { account = await auth.getUser(record.uid); }
    catch (error) {
      if (error.code !== "auth/user-not-found" || action !== "create") throw error;
      account = await auth.createUser({uid: record.uid, email: record.email, displayName: record.name, emailVerified: false});
    }
    if (account.email?.toLowerCase() !== record.email || account.disabled) fail("failed-precondition", "identity-mismatch");
    if (action !== "invite") {
      await auth.updateUser(record.uid, {displayName: record.name});
      const claims = {...account.customClaims, panelAccess: {version: 1, active: record.active, memberships: record.memberships}};
      if (Buffer.byteLength(JSON.stringify(claims)) > 1000) fail("invalid-argument", "claims-limit");
      await auth.setCustomUserClaims(record.uid, claims);
      await auth.revokeRefreshTokens(record.uid);
    }
  }

  return async function manage(context, raw) {
    const input = validate(raw);
    const actor = await actorFor(context);
    if (["myWorkspace", "setAvailability"].includes(input.action)) return workspace(actor, input);
    if (!canManage(actor, [input.country])) fail("permission-denied", "denied");
    if (input.action === "resume") {
      const current = await staff.doc(input.uid).get();
      if (!current.exists || current.data().provisioning !== "pending" || !current.data().countryCodes.includes(input.country) || !canManage(actor, current.data().countryCodes)) fail("permission-denied", "denied");
      const operation = await operations.doc(current.data().operationId).get();
      if (!operation.exists || operation.data().actor !== actor.uid) fail("permission-denied", "denied");
      return manage(context, operation.data().input);
    }
    if (input.action === "list") return list(actor, input);
    if (input.action === "doctorPreview") return doctorLinks.preview(actor, input);
    const operation = await reserve(actor, input);
    if (operation.done) return operation.done;
    try {
      const currentActor = await actorFor(context);
      if (!canManage(currentActor, [input.country])) fail("permission-denied", "denied");
      if (["linkDoctor", "unlinkDoctor"].includes(input.action)) {
        return await doctorLinks.mutate(currentActor, input, operation);
      }
      const plan = await makePlan(currentActor, input, operation);
      await synchronize(plan, input.action);
      let invitationSent = plan.after.invitationSent;
      let invitedAt = plan.after.invitedAt || 0;
      if (input.action === "create" || input.action === "invite") {
        const previous = await operation.reference.get();
        if (!previous.data().invitationAttempted) {
          await operation.reference.update({invitationAttempted: true});
          invitedAt = now();
          try { await sendInvitation(plan.after.email); invitationSent = true; }
          catch (_) { invitationSent = false; }
          await operation.reference.update({invitationSent, invitedAt});
        } else {
          invitationSent = previous.data().invitationSent === true;
          invitedAt = previous.data().invitedAt || now();
        }
      }
      const after = {...plan.after, provisioning: "ready", invitationSent, invitedAt};
      const result = {uid: after.uid, invitationSent};
      await database.runTransaction(async (transaction) => {
        const current = await transaction.get(staff.doc(after.uid));
        if (current.data()?.operationId !== operation.operationId) fail("aborted", "conflict");
        transaction.set(staff.doc(after.uid), after);
        transaction.update(operation.reference, {status: "done", result, completedAt: FieldValue.serverTimestamp()});
      });
      return result;
    } catch (error) {
      await operation.reference.set({lastError: ["permission-denied", "already-exists", "not-found", "aborted", "failed-precondition", "resource-exhausted", "invalid-argument"].includes(error.code) ? error.code : "internal", failedAt: FieldValue.serverTimestamp()}, {merge: true});
      throw error;
    } finally {
      await database.runTransaction(async (transaction) => {
        const current = await transaction.get(control);
        if (current.data()?.lease === operation.lease) transaction.update(control, {lockedUntil: 0, lease: ""});
      });
    }
  };
}

module.exports = {createService};
