const {createHash} = require("node:crypto");
const {FieldValue} = require("firebase-admin/firestore");
const {administrationEnabled} = require("./doctor_administration");
const {fail} = require("./policy");
const hash = value => createHash("sha256").update(value).digest("hex");

function createDoctorWorkspace({database, now}) {
  return async function workspace(actor, input) {
    const preferenceRef = database.doc("doctorAvailability/" + actor.uid + "/countries/" + input.country);
    return database.runTransaction(async transaction => {
      const [staffSnapshot, preferenceSnapshot] = await transaction.getAll(database.doc("panelStaff/" + actor.uid), preferenceRef);
      const staff = staffSnapshot.data(), preference = preferenceSnapshot.data();
      if (!staff || staff.active !== true || staff.provisioning !== "ready" ||
          !staff.memberships?.[input.country]?.includes("doctor")) fail("permission-denied", "denied");
      const doctorId = staff.doctorLinks?.[input.country];
      const empty = {state: "unlinked", doctor: null, accepting: false, revision: preference?.revision || 0,
        workspaceToken: null, updatedAt: null};
      if (!doctorId) {
        if (input.action !== "myWorkspace") fail("failed-precondition", "workspace-blocked");
        return empty;
      }
      if (typeof doctorId !== "string" || !/^CL_[1-9][0-9]{0,9}$/.test(doctorId)) fail("permission-denied", "denied");
      const [linkSnapshot, doctorSnapshot, administrativeSnapshot] = await transaction.getAll(database.doc("doctorAccountLinks/" + doctorId), database.doc("doctorRecords/" + doctorId), database.doc("doctorAdministration/" + doctorId));
      const administration = administrativeSnapshot.data();
      const link = linkSnapshot.data(), doctor = doctorSnapshot.data();
      if (!link || link.uid !== actor.uid || link.countryCode !== input.country ||
          link.doctorId !== doctorId || !link.createdAt?.toMillis) fail("permission-denied", "denied");
      if (!doctor || doctor.countryCode !== input.country || doctor.id !== doctorId) fail("permission-denied", "denied");
      let specialty = null;
      if (typeof doctor.specialtyId === "string" && /^CL_[a-z][a-z0-9_]{1,31}$/.test(doctor.specialtyId)) {
        specialty = (await transaction.get(database.doc("specialties/" + doctor.specialtyId))).data();
      }
      const ready = administrationEnabled(administration) && doctor.environment === "development" && doctor.schemaVersion === 2 && doctor.status === "verified" &&
        specialty?.countryCode === input.country && specialty.active === true;
      const workspaceToken = hash(JSON.stringify([actor.uid, input.country, doctorId, link.createdAt.toMillis(), doctor.revision, ...(administration?.revision ? [administration.revision] : [])]));
      const matching = preference?.workspaceToken === workspaceToken;
      const view = {state: ready ? "ready" : "blocked",
        doctor: {id: doctorId, name: doctor.name, registry: doctor.registryNumber, specialty: doctor.specialty},
        accepting: ready && matching && preference.accepting === true,
        revision: preference?.revision || 0, workspaceToken,
        updatedAt: matching ? preference.updatedAt?.toDate().toISOString() || null : null};
      if (input.action === "myWorkspace") return view;
      if (!ready) fail("failed-precondition", "workspace-blocked");
      if (input.workspaceToken !== workspaceToken) fail("aborted", "workspace-changed");
      const eventRef = preferenceRef.collection("events").doc(input.requestId);
      const event = await transaction.get(eventRef);
      const digest = hash(JSON.stringify(input));
      if (event.exists) {
        if (event.data().digest !== digest) fail("already-exists", "request-mismatch");
        return {saved: true};
      }
      if ((preference?.revision || 0) !== input.revision) fail("aborted", "conflict");
      const day = new Date(now()).toISOString().slice(0, 10);
      const count = preference?.day === day ? preference.count || 0 : 0;
      if (count >= 20) fail("resource-exhausted", "daily-limit");
      const after = {uid: actor.uid, countryCode: input.country, doctorId, workspaceToken,
        accepting: input.accepting, revision: input.revision + 1, updatedAt: FieldValue.serverTimestamp(),
        day, count: count + 1, environment: "development", schemaVersion: 1};
      transaction.set(preferenceRef, after);
      transaction.create(eventRef, {actorId: actor.uid, countryCode: input.country, doctorId,
        digest, revision: after.revision, beforeAccepting: view.accepting, afterAccepting: input.accepting,
        workspaceToken, recordedAt: FieldValue.serverTimestamp()});
      return {saved: true};
    });
  };
}

module.exports = {createDoctorWorkspace};
