const {createHash} = require("node:crypto");
const {FieldValue} = require("firebase-admin/firestore");
const {fail} = require("./policy");

function createIntakeClassification({database, now}) {
  function allowed(actor, country) {
    if (!actor || actor.active !== true || actor.provisioning !== "ready" ||
        !actor.memberships?.[country]?.includes("operations")) fail("permission-denied", "denied");
  }
  function view(id, record, editable, specialty) {
    return {id, revision: record?.revision || 0, specialtyId: record?.specialtyId || null,
      specialtyName: record?.specialtyName || null, source: record?.source || "unconfirmed",
      updatedAt: record?.updatedAt?.toDate().toISOString() || null, editable,
      specialtyActive: !!record?.specialtyId && specialty?.id === record.specialtyId &&
        specialty?.countryCode === "CL" && specialty?.active === true};
  }
  return async function classify(actor, input) {
    allowed(actor, input.country);
    return database.runTransaction(async transaction => {
      const reference = database.doc("intakeClassifications/" + input.id);
      const [canonical, intake, stored] = await transaction.getAll(
        database.doc("panelStaff/" + actor.uid), database.doc("intakeRequests/" + input.id), reference);
      allowed(canonical.data(), input.country);
      const request = intake.data(), previous = stored.data();
      if (!request || request.id !== input.id || request.countryCode !== input.country ||
          request.environment !== "development") fail("permission-denied", "denied");
      if (previous && (previous.id !== input.id || previous.countryCode !== input.country ||
          previous.environment !== "development" || previous.schemaVersion !== 1)) fail("failed-precondition", "invalid-state");
      if (input.action === "intakeClassificationGet") {
        const specialty = previous?.specialtyId
          ? (await transaction.get(database.doc("specialties/" + previous.specialtyId))).data() : null;
        return view(input.id, previous, request.status === "received", specialty);
      }
      const eventRef = reference.collection("events").doc(input.requestId);
      const quotaRef = database.doc("intakeClassificationLimits/" + actor.uid);
      const [event, quota] = await transaction.getAll(eventRef, quotaRef);
      const digest = createHash("sha256").update(JSON.stringify(input)).digest("hex");
      if (event.exists) {
        if (event.data().digest !== digest || event.data().actorId !== actor.uid) fail("already-exists", "request-mismatch");
        return {saved: true};
      }
      if (request.status !== "received") fail("failed-precondition", "locked");
      if ((previous?.revision || 0) !== input.revision) fail("aborted", "conflict");
      if ((previous?.specialtyId || null) === input.specialtyId &&
          (previous?.source || "unconfirmed") === input.source) fail("failed-precondition", "unchanged");
      const specialty = input.specialtyId
        ? (await transaction.get(database.doc("specialties/" + input.specialtyId))).data() : null;
      if (input.specialtyId && (!specialty || specialty.id !== input.specialtyId ||
          specialty.countryCode !== input.country || specialty.active !== true ||
          typeof specialty.name !== "string" || Array.from(specialty.name).length < 2 ||
          Array.from(specialty.name).length > 100)) fail("failed-precondition", "specialty-unavailable");
      const day = new Date(now()).toISOString().slice(0, 10);
      const count = quota.data()?.day === day ? quota.data().count : 0;
      if (count >= 20) fail("resource-exhausted", "daily-limit");
      const after = {id: input.id, countryCode: input.country, specialtyId: input.specialtyId,
        specialtyName: specialty?.name || null, source: input.source, revision: input.revision + 1,
        updatedBy: actor.uid, updatedAt: FieldValue.serverTimestamp(), environment: "development", schemaVersion: 1};
      transaction.set(reference, after);
      transaction.create(eventRef, {actorId: actor.uid, countryCode: input.country, intakeId: input.id,
        beforeSpecialtyId: previous?.specialtyId || null, beforeSource: previous?.source || "unconfirmed",
        afterSpecialtyId: input.specialtyId, afterSpecialtyName: after.specialtyName, afterSource: input.source,
        revision: after.revision, digest, recordedAt: FieldValue.serverTimestamp()});
      transaction.set(quotaRef, {day, count: count + 1});
      return {saved: true};
    });
  };
}
module.exports = {createIntakeClassification};
