const {createHash} = require("node:crypto");
function workspaceTokenFor(uid, country, doctor, link, administration) {
  return createHash("sha256").update(JSON.stringify([uid, country, doctor.id, link.createdAt.toMillis(),
    doctor.revision, ...(administration?.revision ? [administration.revision] : [])])).digest("hex");
}
async function readOperationalAvailability({transaction, database, auth, doctors, administrations, country, checkedAt}) {
  const links = await transaction.getAll(...doctors.map(doctor => database.doc("doctorAccountLinks/" + doctor.id)));
  const validUid = uid => typeof uid === "string" && /^[a-zA-Z0-9_-]{1,128}$/.test(uid);
  const validSpecialty = id => typeof id === "string" && /^CL_[a-z][a-z0-9_]{1,31}$/.test(id);
  const uids = [...new Set(links.map(link => link.data()?.uid).filter(validUid))];
  const paths = [...new Set([
    ...uids.flatMap(uid => ["panelStaff/" + uid, "doctorAvailability/" + uid + "/countries/" + country]),
    ...doctors.filter(doctor => validSpecialty(doctor.specialtyId)).map(doctor => "specialties/" + doctor.specialtyId),
  ])];
  const snapshots = paths.length ? await transaction.getAll(...paths.map(path => database.doc(path))) : [];
  const data = new Map(snapshots.map(snapshot => [snapshot.ref.path, snapshot.data()]));
  const accounts = uids.length ? await auth.getUsers(uids.map(uid => ({uid}))) : {users: []};
  const identities = new Map(accounts.users.map(account => [account.uid, account]));
  return doctors.map((doctor, index) => {
    const administration = administrations[index], link = links[index].data();
    const result = (state, confirmedAt = null) => ({state, confirmedAt, checkedAt});
    if (administration && administration.active !== true) return result("blockedAdministration");
    if (doctor.environment !== "development" || doctor.schemaVersion !== 2 || doctor.status !== "verified") return result("blockedReview");
    const specialty = data.get("specialties/" + doctor.specialtyId);
    if (!specialty || specialty.countryCode !== country || specialty.active !== true) return result("blockedSpecialty");
    if (!link) return result("unlinked");
    if (!validUid(link.uid) || link.doctorId !== doctor.id || link.countryCode !== country || !link.createdAt?.toMillis) return result("linkMismatch");
    const staff = data.get("panelStaff/" + link.uid), account = identities.get(link.uid);
    if (!staff || staff.uid !== link.uid || staff.doctorLinks?.[country] !== doctor.id) return result("linkMismatch");
    if (staff.active !== true || staff.provisioning !== "ready" || !staff.memberships?.[country]?.includes("doctor") ||
        !account || account.disabled || !account.emailVerified || !account.email ||
        account.email.toLowerCase() !== staff.email?.toLowerCase()) return result("blockedAccount");
    const preference = data.get("doctorAvailability/" + link.uid + "/countries/" + country);
    if (!preference || preference.uid !== link.uid || preference.doctorId !== doctor.id || preference.countryCode !== country ||
        preference.environment !== "development" || preference.schemaVersion !== 1 ||
        preference.workspaceToken !== workspaceTokenFor(link.uid, country, doctor, link, administration) ||
        typeof preference.accepting !== "boolean" || !preference.updatedAt?.toDate) return result("needsConfirmation");
    return result(preference.accepting ? "available" : "paused", preference.updatedAt.toDate().toISOString());
  });
}
module.exports = {workspaceTokenFor, readOperationalAvailability};
