const {FieldValue} = require("firebase-admin/firestore");
const {administrationEnabled} = require("./doctor_administration");
const {fail, canManage} = require("./policy");

function targetAllowed(actor, target, country, linking) {
  if (!target || target.uid === actor.uid || target.protected) fail("failed-precondition", "protected");
  if (!target.countryCodes?.includes(country) || !canManage(actor, target.countryCodes)) fail("permission-denied", "denied");
  if (target.provisioning !== "ready") fail("aborted", "conflict");
  if (linking && (!target.active || !target.memberships?.[country]?.includes("doctor"))) fail("failed-precondition", "doctor-unavailable");
}

function eligible(doctor, specialty, country) {
  if (!doctor || doctor.countryCode !== country || doctor.environment !== "development" ||
      doctor.schemaVersion !== 2 || doctor.status !== "verified" ||
      !specialty || specialty.countryCode !== country || specialty.active !== true) fail("failed-precondition", "doctor-unavailable");
}

function createDoctorLinks({auth, database}) {
  async function identity(target) {
    let account;
    try { account = await auth.getUser(target.uid); } catch (_) { fail("failed-precondition", "doctor-unavailable"); }
    if (account.disabled || account.email?.toLowerCase() !== target.email?.toLowerCase()) fail("failed-precondition", "doctor-unavailable");
  }
  function specialtyRef(doctor, country) {
    if (typeof doctor?.specialtyId !== "string" || !/^CL_[a-z][a-z0-9_]{1,31}$/.test(doctor.specialtyId) ||
        doctor.countryCode !== country) fail("failed-precondition", "doctor-unavailable");
    return database.doc("specialties/" + doctor.specialtyId);
  }
  async function preview(actor, input) {
    const id = input.country + "_" + input.registry;
    const [targetSnapshot, doctorSnapshot, link, administration] = await database.getAll(
      database.doc("panelStaff/" + input.uid), database.doc("doctorRecords/" + id),
      database.doc("doctorAccountLinks/" + id), database.doc("doctorAdministration/" + id));
    const target = targetSnapshot.data(), doctor = doctorSnapshot.data();
    targetAllowed(actor, target, input.country, true);
    await identity(target);
    if (!administrationEnabled(administration.data())) fail("failed-precondition", "doctor-unavailable");
    const specialty = (await specialtyRef(doctor, input.country).get()).data();
    eligible(doctor, specialty, input.country);
    if (link.exists || target.doctorLinks?.[input.country]) fail("already-exists", "doctor-linked");
    return {id, registry: input.registry, name: doctor.name, specialty: doctor.specialty, revision: doctor.revision};
  }
  async function mutate(actor, input, operation) {
    const linking = input.action === "linkDoctor";
    const id = input.country + "_" + input.registry;
    const targetRef = database.doc("panelStaff/" + input.uid);
    const linkRef = database.doc("doctorAccountLinks/" + id);
    const doctorRef = database.doc("doctorRecords/" + id);
    if (linking) {
      const target = (await targetRef.get()).data();
      targetAllowed(actor, target, input.country, true);
      await identity(target);
    }
    return database.runTransaction(async (transaction) => {
      const [actorSnapshot, targetSnapshot, link, doctorSnapshot, administration] = await transaction.getAll(
        database.doc("panelStaff/" + actor.uid), targetRef, linkRef, doctorRef, database.doc("doctorAdministration/" + id));
      const currentActor = actorSnapshot.data(), before = targetSnapshot.data();
      if (!currentActor || !canManage(currentActor, [input.country])) fail("permission-denied", "denied");
      targetAllowed(currentActor, before, input.country, linking);
      if (before.revision !== input.revision) fail("aborted", "conflict");
      const links = {...before.doctorLinks};
      if (linking) {
        if (!administrationEnabled(administration.data())) fail("failed-precondition", "doctor-unavailable");
        const doctor = doctorSnapshot.data();
        const specialty = (await transaction.get(specialtyRef(doctor, input.country))).data();
        eligible(doctor, specialty, input.country);
        if (doctor.revision !== input.doctorRevision) fail("aborted", "conflict");
        if (link.exists || links[input.country]) fail("already-exists", "doctor-linked");
        links[input.country] = id;
      } else {
        if (links[input.country] !== id || !link.exists || link.data().uid !== input.uid ||
            link.data().countryCode !== input.country) fail("aborted", "conflict");
        delete links[input.country];
      }
      const after = {...before, doctorLinks: links, revision: before.revision + 1};
      const result = {uid: input.uid, doctorId: linking ? id : null};
      transaction.set(targetRef, after);
      if (linking) transaction.create(linkRef, {doctorId: id, uid: input.uid, countryCode: input.country,
        createdBy: actor.uid, createdAt: FieldValue.serverTimestamp()});
      else transaction.delete(linkRef);
      transaction.update(operation.reference, {target: input.uid, doctorId: id,
        beforeLinks: before.doctorLinks || {}, afterLinks: links, staffRevision: after.revision,
        status: "done", result, completedAt: FieldValue.serverTimestamp()});
      return result;
    });
  }
  return {preview, mutate};
}

module.exports = {createDoctorLinks};
