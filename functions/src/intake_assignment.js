const {createHash} = require("node:crypto");
const {FieldValue, FieldPath} = require("firebase-admin/firestore");
const {readOperationalAvailability} = require("./doctor_availability");
const {fail} = require("./policy");
function createIntakeAssignment({database, auth, now}) {
  function allowed(actor, country) {
    if (!actor || actor.active !== true || actor.provisioning !== "ready" ||
        !(actor.memberships?.[country]?.includes("operations") || actor.memberships?.[country]?.includes("superadmin"))) fail("permission-denied", "denied");
  }
  return async function assign(actor, input) {
    allowed(actor, input.country);
    return database.runTransaction(async transaction => {
      const reference = database.doc("intakeAssignments/" + input.id);
      const [canonical, intake, classification, existing] = await transaction.getAll(
        database.doc("panelStaff/" + actor.uid), database.doc("intakeRequests/" + input.id),
        database.doc("intakeClassifications/" + input.id), reference);
      allowed(canonical.data(), input.country);
      const operator = canonical.data().memberships[input.country].some(role => ["operations", "superadmin"].includes(role));
      const request = intake.data(), route = classification.data(), previous = existing.data();
      if (!request || request.id !== input.id || request.countryCode !== input.country ||
          request.environment !== "development") fail("permission-denied", "denied");
      if (previous && (previous.id !== input.id || previous.countryCode !== input.country ||
          previous.environment !== "development" || previous.schemaVersion !== 1 ||
          !["pendingAcceptance", "released"].includes(previous.status))) fail("failed-precondition", "invalid-state");
      const active = previous?.status === "pendingAcceptance";
      const routed = route?.id === input.id && route?.countryCode === input.country &&
        route?.environment === "development" && route?.schemaVersion === 1 &&
        ["patientConfirmed", "medicalReferral"].includes(route?.source) &&
        typeof route.specialtyId === "string" && /^CL_[a-z][a-z0-9_]{1,31}$/.test(route.specialtyId);
      const specialty = routed ? (await transaction.get(database.doc("specialties/" + route.specialtyId))).data() : null;
      const ready = request.status === "received" && !active && routed &&
        specialty?.id === route.specialtyId && specialty?.countryCode === input.country && specialty?.active === true;
      const view = {id: input.id, revision: previous?.revision || 0, status: previous?.status || "unassigned",
        doctorId: previous?.doctorId || null, doctorName: previous?.doctorName || null,
        updatedAt: previous?.updatedAt?.toDate().toISOString() || null, classificationRevision: route?.revision || 0,
        specialtyName: specialty?.name || null, canAssign: operator && !!ready, canRelease: operator && active && request.status === "received"};
      if (input.action === "intakeAssignmentGet") return view;
      if (input.action === "intakeAssignmentCandidates") {
        if (!ready || route.revision !== input.classificationRevision) fail("failed-precondition", "routing-changed");
        let query = database.collection("doctorRecords").where("countryCode", "==", input.country).orderBy(FieldPath.documentId()).limit(21);
        if (input.cursor) query = query.startAfter(input.cursor);
        const page = await transaction.get(query), visible = page.docs.slice(0, 20);
        const doctors = visible.filter(doc => doc.data().id === doc.id && doc.data().specialtyId === route.specialtyId &&
          doc.data().environment === "development").map(doc => doc.data());
        const states = doctors.length ? await transaction.getAll(...doctors.map(doctor => database.doc("doctorAdministration/" + doctor.id))) : [];
        const availability = doctors.length ? await readOperationalAvailability({transaction, database, auth, doctors,
          administrations: states.map(doc => doc.data()), country: input.country, checkedAt: new Date(now()).toISOString()}) : [];
        return {items: doctors.filter((_, index) => availability[index].state === "available")
          .map(doctor => ({id: doctor.id, name: doctor.name, registry: doctor.registryNumber})),
          nextCursor: page.docs.length > 20 ? visible.at(-1).id : null};
      }
      const eventRef = reference.collection("events").doc(input.requestId);
      const quotaRef = database.doc("intakeAssignmentLimits/" + actor.uid);
      const [event, quota] = await transaction.getAll(eventRef, quotaRef);
      const digest = createHash("sha256").update(JSON.stringify(input)).digest("hex");
      if (event.exists) {
        if (event.data().actorId !== actor.uid || event.data().digest !== digest) fail("already-exists", "request-mismatch");
        return {saved: true};
      }
      if ((previous?.revision || 0) !== input.revision) fail("aborted", "conflict");
      if (request.status !== "received") fail("failed-precondition", "locked");
      let after;
      if (input.action === "intakeAssignmentRelease") {
        if (!active) fail("failed-precondition", "not-assigned");
        after = {...previous, status: "released", releaseReason: input.reason};
      } else {
        if (!ready || route.revision !== input.classificationRevision) fail("failed-precondition", "routing-changed");
        const [doctorSnapshot, administration, link] = await transaction.getAll(
          database.doc("doctorRecords/" + input.doctorId), database.doc("doctorAdministration/" + input.doctorId),
          database.doc("doctorAccountLinks/" + input.doctorId));
        const doctor = doctorSnapshot.data();
        if (!doctor || doctor.id !== input.doctorId || doctor.countryCode !== input.country ||
            doctor.specialtyId !== route.specialtyId) fail("failed-precondition", "doctor-unavailable");
        const availability = await readOperationalAvailability({transaction, database, auth, doctors: [doctor],
          administrations: [administration.data()], country: input.country, checkedAt: new Date(now()).toISOString()});
        if (availability[0].state !== "available") fail("failed-precondition", "doctor-unavailable");
        after = {id: input.id, countryCode: input.country, doctorId: doctor.id, doctorUid: link.data().uid,
          doctorName: doctor.name, specialtyId: route.specialtyId, classificationRevision: route.revision,
          status: "pendingAcceptance", releaseReason: null, environment: "development", schemaVersion: 1};
      }
      const day = new Date(now()).toISOString().slice(0, 10), count = quota.data()?.day === day ? quota.data().count : 0;
      if (count >= 20) fail("resource-exhausted", "daily-limit");
      after = {...after, revision: input.revision + 1, updatedBy: actor.uid, updatedAt: FieldValue.serverTimestamp()};
      transaction.set(reference, after);
      transaction.create(eventRef, {actorId: actor.uid, intakeId: input.id, countryCode: input.country,
        digest, revision: after.revision, beforeStatus: previous?.status || "unassigned",
        beforeDoctorId: previous?.doctorId || null, afterStatus: after.status, afterDoctorId: after.doctorId,
        doctorUid: after.doctorUid, classificationRevision: after.classificationRevision,
        reason: after.releaseReason, recordedAt: FieldValue.serverTimestamp()});
      transaction.set(quotaRef, {day, count: count + 1});
      return {saved: true};
    });
  };
}
module.exports = {createIntakeAssignment};
