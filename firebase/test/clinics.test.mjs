import {before, beforeEach, after, test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment, assertSucceeds, assertFails} from '@firebase/rules-unit-testing';
import {doc, setDoc, getDoc, getDocs, collection, query, where, limit, writeBatch, serverTimestamp, deleteDoc} from 'firebase/firestore';
import {developmentRules} from '../../scripts/development-rules.mjs';

let environment;
const id = 'CL_qa_clinic';
const access = (roles, country = 'CL') => ({email_verified: true, panelAccess: {version: 1, active: true, memberships: {[country]: roles}}});
const client = (uid, roles, country) => environment.authenticatedContext(uid, access(roles, country)).firestore();
function initial() {
  return {id, countryCode: 'CL', schemaVersion: 1, environment: 'development', code: 'qa_clinic',
    name: 'Clínica ficticia', description: '', city: 'Ciudad ficticia', address: 'Dirección ficticia 123', email: '', phone: '', active: true, revision: 1,
    createdBy: 'admin', createdAt: serverTimestamp(), updatedBy: 'admin', updatedAt: serverTimestamp()};
}
async function write(database, data, action = 'create', audit = true) {
  const batch = writeBatch(database);
  batch.set(doc(database, 'clinics', id), data);
  if (audit) batch.set(doc(database, 'clinics', id, 'events', String(data.revision)), {
    revision: data.revision, actorId: data.updatedBy, countryCode: data.countryCode,
    recordedAt: serverTimestamp(), action, snapshot: data,
  });
  return batch.commit();
}
async function create() {
  const database = client('admin', ['superadmin']);
  await assertSucceeds(write(database, initial()));
  return (await getDoc(doc(database, 'clinics', id))).data();
}
const update = (previous, changes = {}) => ({...previous, revision: previous.revision + 1, updatedBy: 'admin', updatedAt: serverTimestamp(), ...changes});
before(async () => {
  environment = await initializeTestEnvironment({projectId: 'demo-2daopinion', firestore: {host: '127.0.0.1', port: 8080,
    rules: developmentRules(readFileSync('firebase/firestore.rules', 'utf8'), {includeClinics: true})}});
});
beforeEach(async () => {
  await environment.clearFirestore();
  await environment.withSecurityRulesDisabled(async context => {
    for (const [uid, role] of [['admin', 'superadmin'], ['operator', 'operations'], ['director', 'medicalDirector'], ['doctor', 'doctor'], ['finance', 'finance']]) {
      await setDoc(doc(context.firestore(), 'panelStaff', uid), {active: true, provisioning: 'ready', memberships: {CL: [role]}});
    }
  });
});
after(async () => environment.cleanup());

test('superadmin creates, edits, deactivates and reactivates with four immutable events', async () => {
  const database = client('admin', ['superadmin']);
  await assertSucceeds(getDoc(doc(database, 'clinics', id)));
  let previous = await create();
  for (const [action, changes] of [['edit', {name: 'Nombre corregido', description: 'Descripción'}], ['deactivate', {active: false}], ['reactivate', {active: true}]]) {
    await assertSucceeds(write(database, update(previous, changes), action));
    previous = (await getDoc(doc(database, 'clinics', id))).data();
  }
  assert.equal(previous.revision, 4);
  const events = await getDocs(query(collection(database, 'clinics', id, 'events'), limit(50)));
  assert.equal(events.size, 4);
  assert.deepEqual(events.docs[3].data().snapshot, previous);
});
for (const [label, change] of [
  ['empty name', {name: ''}], ['spaces', {name: '   '}], ['untrimmed', {name: ' Nombre '}], ['short name', {name: 'a'}],
  ['long name', {name: 'a'.repeat(101)}], ['long description', {description: 'a'.repeat(501)}], ['description type', {description: []}],
  ['code type', {code: 12}], ['code uppercase', {code: 'QA_SPECIALTY'}], ['short code', {code: 'a'}], ['path code', {code: '../bad'}],
  ['long code', {code: 'a'.repeat(33)}], ['numeric prefix', {code: '12aa'}], ['other country', {countryCode: 'AR'}],
  ['foreign ID', {id: 'CL_other'}], ['inactive creation', {active: false}], ['active type', {active: 'true'}],
  ['revision type', {revision: 1.1}], ['unknown field', {clinicalAccess: true}], ['wrong environment', {environment: 'production'}],
  ['forged creator', {createdBy: 'director'}], ['forged updater', {updatedBy: 'director'}], ['client timestamp', {updatedAt: new Date(0)}],
  ['missing city', {city: ''}], ['long city', {city: 'a'.repeat(101)}], ['short address', {address: 'a'}],
  ['long address', {address: 'a'.repeat(201)}], ['address type', {address: 123}], ['invalid email', {email: 'no@'}],
  ['long email', {email: 'a'.repeat(250)+'@example.test'}], ['email type', {email: []}], ['email whitespace', {email: ' a@example.test'}],
  ['email double dot', {email: 'a..b@example.test'}], ['invalid phone', {phone: '12345678'}],
  ['phone spacing', {phone: '+56 912345678'}], ['phone type', {phone: 12345678}], ['phone leading zero', {phone: '+012345678'}],
  ['short phone', {phone: '+1234567'}], ['long phone', {phone: '+1234567890123456'}],
]) test(`clinics reject ${label}`, async () => {
  await assertFails(write(client('admin', ['superadmin']), {...initial(), ...change}));
});
test('exact name and description boundaries succeed', async () => {
  const database = client('admin', ['superadmin']);
  await assertSucceeds(write(database, {...initial(), name: 'ab', description: 'a'.repeat(500), city: 'ab', address: 'abcde', email: 'QA+test@example.test', phone: '+12345678'}));
  const previous = (await getDoc(doc(database, 'clinics', id))).data();
  await assertSucceeds(write(database, update(previous, {name: 'a'.repeat(100), city: 'a'.repeat(100), address: 'a'.repeat(200), phone: '+123456789012345'}), 'edit'));
});
test('operations and medical director can only read bounded country catalog and audit', async () => {
  const previous = await create();
  for (const [uid, role] of [['operator', 'operations'], ['director', 'medicalDirector']]) {
    const database = client(uid, [role]);
    await assertSucceeds(getDocs(query(collection(database, 'clinics'), where('countryCode', '==', 'CL'), limit(21))));
    await assertSucceeds(getDoc(doc(database, 'clinics', id, 'events', '1')));
    await assertFails(write(database, update(previous, {updatedBy: uid, name: 'Nombre ajeno'}), 'edit'));
    await assertFails(write(database, update(previous, {updatedBy: uid, active: false}), 'deactivate'));
  }
});
test('query country and limit are mandatory, including for superadmin', async () => {
  await create(); const database = client('admin', ['superadmin']);
  await assertFails(getDocs(collection(database, 'clinics')));
  await assertFails(getDocs(query(collection(database, 'clinics'), limit(21))));
  await assertFails(getDocs(query(collection(database, 'clinics'), where('countryCode', '==', 'CL'), limit(22))));
  await assertFails(getDocs(query(collection(database, 'clinics'), where('countryCode', '==', 'AR'), limit(21))));
  await assertFails(getDocs(collection(database, 'clinics', id, 'events')));
});
test('anonymous, patient, doctor, finance, other country and mismatched claims are denied', async () => {
  await create();
  for (const database of [environment.unauthenticatedContext().firestore(), client('patient', []), client('doctor', ['doctor']),
    client('finance', ['finance']), client('admin', ['superadmin'], 'AR'), client('operator', ['superadmin']),
    environment.authenticatedContext('admin', {...access(['superadmin']), email_verified: false}).firestore()]) {
    await assertFails(getDoc(doc(database, 'clinics', id)));
    await assertFails(getDoc(doc(database, 'clinics', id, 'events', '1')));
  }
});
test('canonical revocation immediately denies reads and writes with existing claims', async () => {
  const previous = await create(); const database = client('admin', ['superadmin']);
  await environment.withSecurityRulesDisabled(context => setDoc(doc(context.firestore(), 'panelStaff', 'admin'), {active: false, provisioning: 'ready', memberships: {CL: ['superadmin']}}));
  await assertFails(getDoc(doc(database, 'clinics', id)));
  await assertFails(write(database, update(previous), 'edit'));
});
test('code, identity, creator, country and creation timestamp cannot change', async () => {
  const previous = await create(); const database = client('admin', ['superadmin']);
  for (const changes of [{code: 'other'}, {id: 'CL_other'}, {createdBy: 'other'}, {countryCode: 'AR'}, {createdAt: serverTimestamp()}]) {
    await assertFails(write(database, update(previous, changes), 'edit'));
  }
});
test('duplicate, stale revision, absent audit, false action and combined edit/status are denied', async () => {
  const previous = await create(); const database = client('admin', ['superadmin']);
  await assertFails(write(database, initial()));
  await assertFails(write(database, update(previous, {revision: 1}), 'edit'));
  await assertFails(write(database, update(previous), 'edit', false));
  await assertFails(write(database, update(previous), 'deactivate'));
  await assertFails(write(database, update(previous, {active: false, name: 'Otro nombre'}), 'deactivate'));
});
test('audit-only creation, audit alteration and physical deletion are denied', async () => {
  const previous = await create(); const database = client('admin', ['superadmin']);
  await assertFails(setDoc(doc(database, 'clinics', id, 'events', '2'), {revision: 2, countryCode: 'CL', actorId: 'admin', action: 'edit', recordedAt: serverTimestamp(), snapshot: update(previous)}));
  await assertFails(setDoc(doc(database, 'clinics', id, 'events', '1'), {actorId: 'other'}));
  await assertFails(deleteDoc(doc(database, 'clinics', id, 'events', '1')));
  await assertFails(deleteDoc(doc(database, 'clinics', id)));
});
