const { HttpsError } = require("firebase-functions/v2/https");

const roles = ["superadmin", "operations", "medicalDirector", "finance", "doctor"];
const fail = (code, message) => { throw new HttpsError(code, message); };
const uidValid = (value) => typeof value === "string" && /^[a-zA-Z0-9_-]{1,128}$/.test(value);

function memberships(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) fail("invalid-argument", "invalid");
  const entries = Object.entries(value);
  if (!entries.length || entries.length > 20) fail("invalid-argument", "invalid");
  const result = {};
  for (const [country, assigned] of entries) {
    if (!/^[A-Z]{2}$/.test(country) || !Array.isArray(assigned) || !assigned.length ||
        assigned.length > roles.length || assigned.some((role) => !roles.includes(role))) fail("invalid-argument", "invalid");
    result[country] = [...new Set(assigned)].sort();
  }
  if (Buffer.byteLength(JSON.stringify({version: 1, active: true, memberships: result})) > 800) fail("invalid-argument", "invalid");
  return result;
}

function validate(data) {
  if (!data || typeof data !== "object" || Array.isArray(data) ||
      Buffer.byteLength(JSON.stringify(data)) > 4096) fail("invalid-argument", "invalid");
  if (!["list", "create", "update", "setActive", "invite", "resume", "doctorPreview", "linkDoctor", "unlinkDoctor", "myWorkspace", "setAvailability", "doctorAdminList", "doctorAdminSetActive", "intakeClassificationGet", "intakeClassificationSet"].includes(data.action) ||
      typeof data.country !== "string" || !/^[A-Z]{2}$/.test(data.country)) fail("invalid-argument", "invalid");
  const allowed = {
    intakeClassificationGet: ["action", "country", "id"],
    intakeClassificationSet: ["action", "country", "id", "specialtyId", "source", "confirmed", "revision", "requestId"],
    list: ["action", "country", "cursor"],
    doctorAdminList: ["action", "country", "ids"],
    doctorAdminSetActive: ["action", "country", "id", "active", "revision", "reason", "requestId"],
    myWorkspace: ["action", "country"],
    setAvailability: ["action", "country", "requestId", "revision", "workspaceToken", "accepting"],
    doctorPreview: ["action", "country", "uid", "registry"],
    linkDoctor: ["action", "country", "uid", "revision", "requestId", "registry", "doctorRevision"],
    unlinkDoctor: ["action", "country", "uid", "revision", "requestId", "registry"],
    resume: ["action", "country", "uid"],
    create: ["action", "country", "requestId", "name", "email", "memberships"],
    update: ["action", "country", "requestId", "uid", "revision", "name", "memberships"],
    setActive: ["action", "country", "requestId", "uid", "revision", "active"],
    invite: ["action", "country", "requestId", "uid", "revision"],
  }[data.action];
  if (Object.keys(data).some((key) => !allowed.includes(key))) fail("invalid-argument", "invalid");
  if (["intakeClassificationGet", "intakeClassificationSet"].includes(data.action)) {
    if (data.country !== "CL" || typeof data.id !== "string" || !/^[a-zA-Z0-9]{20}$/.test(data.id)) fail("invalid-argument", "invalid");
    if (data.action === "intakeClassificationGet") return data;
    if (!["unconfirmed", "patientConfirmed", "medicalReferral"].includes(data.source) || data.confirmed !== true ||
        (data.source === "unconfirmed" ? data.specialtyId !== null :
          typeof data.specialtyId !== "string" || !/^CL_[a-z][a-z0-9_]{1,31}$/.test(data.specialtyId)) ||
        !Number.isSafeInteger(data.revision) || data.revision < 0 || data.revision >= Number.MAX_SAFE_INTEGER ||
        typeof data.requestId !== "string" || !/^[a-f0-9]{32}$/.test(data.requestId)) fail("invalid-argument", "invalid");
    return {action: data.action, country: data.country, id: data.id, specialtyId: data.specialtyId,
      source: data.source, confirmed: true, revision: data.revision, requestId: data.requestId};
  }
  if (["doctorAdminList", "doctorAdminSetActive"].includes(data.action)) {
    if (data.country !== "CL") fail("invalid-argument", "invalid");
    const validId = value => typeof value === "string" && /^CL_[1-9][0-9]{0,9}$/.test(value);
    if (data.action === "doctorAdminList") {
      if (!Array.isArray(data.ids) || data.ids.length < 1 || data.ids.length > 20 ||
          new Set(data.ids).size !== data.ids.length || !data.ids.every(validId)) fail("invalid-argument", "invalid");
      return data;
    }
    if (!validId(data.id) || typeof data.active !== "boolean" ||
        !Number.isSafeInteger(data.revision) || data.revision < 0 || data.revision >= Number.MAX_SAFE_INTEGER ||
        typeof data.reason !== "string" || Array.from(data.reason.trim()).length < 10 || Array.from(data.reason.trim()).length > 500 ||
        typeof data.requestId !== "string" || !/^[a-f0-9]{32}$/.test(data.requestId)) fail("invalid-argument", "invalid");
    return {...data, reason: data.reason.trim()};
  }
  if (["myWorkspace", "setAvailability"].includes(data.action)) {
    if (data.country !== "CL") fail("invalid-argument", "invalid");
    if (data.action === "setAvailability" && (typeof data.accepting !== "boolean" ||
        !Number.isSafeInteger(data.revision) || data.revision < 0 ||
        typeof data.workspaceToken !== "string" || !/^[a-f0-9]{64}$/.test(data.workspaceToken) ||
        typeof data.requestId !== "string" || !/^[a-f0-9]{32}$/.test(data.requestId))) fail("invalid-argument", "invalid");
    return data;
  }
  if (["doctorPreview", "linkDoctor", "unlinkDoctor"].includes(data.action)) {
    if (data.country !== "CL" || !uidValid(data.uid) || typeof data.registry !== "string" ||
        !/^[1-9][0-9]{0,9}$/.test(data.registry)) fail("invalid-argument", "invalid");
    if (data.action === "doctorPreview") return data;
    if (data.action === "linkDoctor" && (!Number.isSafeInteger(data.doctorRevision) || data.doctorRevision < 1)) fail("invalid-argument", "invalid");
  }
  if (data.action === "resume") {
    if (!uidValid(data.uid)) fail("invalid-argument", "invalid");
    return data;
  }
  if (data.action === "list") {
    if (data.cursor != null && !uidValid(data.cursor)) fail("invalid-argument", "invalid");
    return data;
  }
  if (typeof data.requestId !== "string" || !/^[a-f0-9]{32}$/.test(data.requestId)) fail("invalid-argument", "invalid");
  if (data.action !== "create" && (!uidValid(data.uid) || !Number.isSafeInteger(data.revision) || data.revision < 1)) fail("invalid-argument", "invalid");
  const result = {...data};
  if (["create", "update"].includes(data.action)) {
    if (typeof data.name !== "string" || !data.name.trim() || data.name.length > 100) fail("invalid-argument", "invalid");
    result.name = data.name.trim();
    result.memberships = memberships(data.memberships);
    if (!result.memberships[data.country]) fail("invalid-argument", "invalid");
  }
  if (data.action === "create") {
    if (typeof data.email !== "string" || data.email.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email.trim())) fail("invalid-argument", "invalid");
    result.email = data.email.trim().toLowerCase();
  }
  if (data.action === "setActive" && typeof data.active !== "boolean") fail("invalid-argument", "invalid");
  return result;
}

function canManage(actor, countries) {
  return actor.active === true && actor.provisioning === "ready" &&
    countries.every((country) => actor.memberships?.[country]?.includes("superadmin"));
}

function publicUser(user, authUser, actor) {
  return {
    uid: user.uid, name: user.name, email: user.email, memberships: Object.fromEntries(Object.entries(user.memberships).filter(([country]) => canManage(actor, [country]))),
    doctorLinks: Object.fromEntries(Object.entries(user.doctorLinks || {}).filter(([country]) => canManage(actor, [country]))),
    active: user.active, revision: user.revision, provisioning: user.provisioning,
    verified: authUser?.emailVerified === true, invitationSent: user.invitationSent === true,
    editable: user.uid !== actor.uid && !user.protected && canManage(actor, user.countryCodes) && (user.provisioning === "ready" || user.operationActor === actor.uid),
  };
}

module.exports = {fail, memberships, validate, canManage, publicUser};
