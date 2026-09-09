const {createHash} = require("node:crypto");
const {FieldValue} = require("firebase-admin/firestore");
const {fail} = require("./policy");

function administrationEnabled(record) {
  return !record || record.active === true;
}
function createDoctorAdministration({database, now}) {
  function allowed(actor, country, write) {
    const roles = actor?.memberships?.[country] || [];
    if (!actor || actor.active !== true || actor.provisioning !== "ready" ||
        !(roles.includes("operations") || (!write && roles.includes("medicalDirector")))) fail("permission-denied", "denied");
  }
  function requireDoctor(doctor, country, id) {
    if (!doctor || doctor.id !== id || doctor.countryCode !== country || doctor.environment !== "development") fail("permission-denied", "denied");
  }
  function view(id, data) {
    return {id, active: administrationEnabled(data), revision: data?.revision || 0,
      reason: data?.reason || null, updatedAt: data?.updatedAt?.toDate().toISOString() || null};
  }
  return async function administration(actor, input) {
    const write = input.action === "doctorAdminSetActive";
    allowed(actor, input.country, write);
    return database.runTransaction(async transaction => {
      const currentActor = (await transaction.get(database.doc("panelStaff/" + actor.uid))).data();
      allowed(currentActor, input.country, write);
      if (!write) {
        const docs = await transaction.getAll(...input.ids.map(id => database.doc("doctorRecords/" + id)));
        docs.forEach((snapshot, index) => requireDoctor(snapshot.data(), input.country, input.ids[index]));
        const states = await transaction.getAll(...input.ids.map(id => database.doc("doctorAdministration/" + id)));
        return {items: states.map((snapshot, index) => view(input.ids[index], snapshot.data()))};
      }
      const reference = database.doc("doctorAdministration/" + input.id);
      const eventRef = reference.collection("events").doc(input.requestId);
      const quotaRef = database.doc("doctorAdministrationLimits/" + actor.uid);
      const [doctor, state, event, quota] = await transaction.getAll(database.doc("doctorRecords/" + input.id), reference, eventRef, quotaRef);
      requireDoctor(doctor.data(), input.country, input.id);
      const digest = createHash("sha256").update(JSON.stringify(input)).digest("hex");
      if (event.exists) {
        if (event.data().digest !== digest || event.data().actorId !== actor.uid) fail("already-exists", "request-mismatch");
        return {saved: true};
      }
      const before = view(input.id, state.data());
      if (before.revision !== input.revision) fail("aborted", "conflict");
      if (before.active === input.active) fail("failed-precondition", "unchanged");
      const day = new Date(now()).toISOString().slice(0, 10);
      const count = quota.data()?.day === day ? quota.data().count : 0;
      if (count >= 20) fail("resource-exhausted", "daily-limit");
      const after = {id: input.id, countryCode: input.country, active: input.active,
        revision: input.revision + 1, reason: input.reason, updatedBy: actor.uid,
        updatedAt: FieldValue.serverTimestamp(), environment: "development", schemaVersion: 1};
      transaction.set(reference, after);
      transaction.create(eventRef, {actorId: actor.uid, countryCode: input.country, doctorId: input.id,
        digest, beforeActive: before.active, afterActive: input.active, reason: input.reason,
        revision: after.revision, recordedAt: FieldValue.serverTimestamp()});
      transaction.set(quotaRef, {day, count: count + 1});
      return {saved: true};
    });
  };
}
module.exports = {createDoctorAdministration, administrationEnabled};
