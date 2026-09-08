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
  if (!["list", "create", "update", "setActive", "invite", "resume"].includes(data.action) ||
      typeof data.country !== "string" || !/^[A-Z]{2}$/.test(data.country)) fail("invalid-argument", "invalid");
  const allowed = {
    list: ["action", "country", "cursor"],
    resume: ["action", "country", "uid"],
    create: ["action", "country", "requestId", "name", "email", "memberships"],
    update: ["action", "country", "requestId", "uid", "revision", "name", "memberships"],
    setActive: ["action", "country", "requestId", "uid", "revision", "active"],
    invite: ["action", "country", "requestId", "uid", "revision"],
  }[data.action];
  if (Object.keys(data).some((key) => !allowed.includes(key))) fail("invalid-argument", "invalid");
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
    active: user.active, revision: user.revision, provisioning: user.provisioning,
    verified: authUser?.emailVerified === true, invitationSent: user.invitationSent === true,
    editable: user.uid !== actor.uid && !user.protected && canManage(actor, user.countryCodes) && (user.provisioning === "ready" || user.operationActor === actor.uid),
  };
}

module.exports = {fail, memberships, validate, canManage, publicUser};
