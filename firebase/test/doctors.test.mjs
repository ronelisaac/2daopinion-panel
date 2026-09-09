import {before, beforeEach, after, test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment, assertSucceeds, assertFails} from '@firebase/rules-unit-testing';
import {doc, setDoc, updateDoc, getDoc, getDocs, collection, query, where, limit, writeBatch, serverTimestamp, deleteDoc} from 'firebase/firestore';
import {developmentRules} from '../../scripts/development-rules.mjs';

let environment;
const recordId = 'CL_987654321';
const access = roles => ({panelAccess: {version: 1, active: true, memberships: {CL: roles}}, email_verified: true});
function client(uid, roles) { return environment.authenticatedContext(uid, access(roles)).firestore(); }
function initial() {
  return {id: recordId, countryCode: 'CL', schemaVersion: 2, specialtyId: 'CL_qa_specialty', environment: 'development',
    name: 'Médico Ficticio QA', registryNumber: '987654321', specialty: 'Especialidad ficticia',
    status: 'pending', review: {}, revision: 1, createdBy: 'operator', createdAt: serverTimestamp(),
    updatedBy: 'operator', updatedAt: serverTimestamp()};
}
async function write(database, data, action = 'create', audit = true) {
  const batch = writeBatch(database);
  batch.set(doc(database, 'doctorRecords', recordId), data);
  if (audit) batch.set(doc(database, 'doctorRecords', recordId, 'events', String(data.revision)), {
    revision: data.revision, actorId: data.updatedBy, countryCode: data.countryCode,
    recordedAt: serverTimestamp(), action, snapshot: data,
  });
  return batch.commit();
}
async function create() {
  const database = client('operator', ['operations']);
  await assertSucceeds(write(database, initial()));
  return (await getDoc(doc(database, 'doctorRecords', recordId))).data();
}
function reviewed(previous, status = 'verified', actor = 'director') {
  return {...previous, revision: previous.revision + 1, status, updatedBy: actor, updatedAt: serverTimestamp(),
    review: {actorId: actor, at: serverTimestamp(), source: 'CL_RNPI', evidence: 'FICTICIO-123',
      note: 'Verificación ficticia sin uso clínico.', identityChecked: true, titleChecked: true, specialtyChecked: true}};
}
before(async () => {
  environment = await initializeTestEnvironment({projectId: 'demo-2daopinion', firestore: {
    host: '127.0.0.1', port: 8080, rules: developmentRules(readFileSync('firebase/firestore.rules', 'utf8'), {includeDoctors: true})}});
});
beforeEach(async () => {
  await environment.clearFirestore();
  await environment.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'specialties', 'CL_qa_specialty'), {countryCode: 'CL', active: true, name: 'Especialidad ficticia'});
    for (const [uid, roles] of [['operator', ['operations']], ['director', ['medicalDirector']], ['admin', ['superadmin']], ['doctor', ['doctor']]]) {
      await setDoc(doc(context.firestore(), 'panelStaff', uid), {active: true, provisioning: 'ready', memberships: {CL: roles}});
    }
  });
});
after(async () => environment.cleanup());

test('operations can read missing ID, create pending with atomic audit and query a bounded country page', async () => {
  const database = client('operator', ['operations']);
  await assertSucceeds(getDoc(doc(database, 'doctorRecords', recordId)));
  await create();
  const result = await assertSucceeds(getDocs(query(collection(database, 'doctorRecords'), where('countryCode', '==', 'CL'), limit(21))));
  assert.equal(result.size, 1);
  await assertSucceeds(getDoc(doc(database, 'doctorRecords', recordId, 'events', '1')));
});
test('country and query limit are mandatory', async () => {
  await create(); const database = client('operator', ['operations']);
  await assertFails(getDocs(collection(database, 'doctorRecords')));
  await assertFails(getDocs(query(collection(database, 'doctorRecords'), where('countryCode', '==', 'CL'), limit(22))));
  await assertFails(getDocs(query(collection(database, 'doctorRecords'), where('countryCode', '==', 'AR'), limit(21))));
});
for (const [label, change] of [
  ['empty name', {name: '   '}], ['long name', {name: 'x'.repeat(121)}], ['wrong type', {registryNumber: 123}],
  ['untrimmed name', {name: '  Nombre  '}], ['empty specialty', {specialty: ''}], ['other country', {countryCode: 'AR'}],
  ['verified creation', {status: 'verified'}], ['forged actor', {createdBy: 'director'}], ['unknown field', {clinicalAccess: true}],
  ['fractional revision', {revision: 1.5}], ['wrong environment', {environment: 'production'}], ['wrong id', {id: 'CL_1'}],
]) test(`reject ${label}`, async () => {await assertFails(write(client('operator', ['operations']), {...initial(), ...change}));});
test('record without audit is denied', async () => {await assertFails(write(client('operator', ['operations']), initial(), 'create', false));});
test('review requires medical director, another creator and all three checks', async () => {
  const previous = await create();
  await assertFails(write(client('operator', ['operations']), reviewed(previous, 'verified', 'operator'), 'review'));
  const unchecked = reviewed(previous); unchecked.review.specialtyChecked = false;
  await assertFails(write(client('director', ['medicalDirector']), unchecked, 'review'));
  await assertSucceeds(write(client('director', ['medicalDirector']), reviewed(previous), 'review'));
});
test('dual-role creator cannot self-review', async () => {
  const previous = await create();
  await environment.withSecurityRulesDisabled(context => setDoc(doc(context.firestore(), 'panelStaff', 'operator'), {active: true, provisioning: 'ready', memberships: {CL: ['operations', 'medicalDirector']}}));
  await assertFails(write(client('operator', ['operations', 'medicalDirector']), reviewed(previous, 'verified', 'operator'), 'review'));
});
for (const [label, change] of [
  ['empty evidence', {evidence: ''}], ['short note', {note: 'no'}], ['wrong source', {source: 'other'}],
  ['forged reviewer', {actorId: 'operator'}], ['invalid check type', {identityChecked: 'true'}], ['long note', {note: 'x'.repeat(2001)}],
]) test(`review rejects ${label}`, async () => {
  const data = reviewed(await create()); Object.assign(data.review, change);
  await assertFails(write(client('director', ['medicalDirector']), data, 'review'));
});
test('approval freezes registration fields; only suspension is allowed next', async () => {
  await assertSucceeds(write(client('director', ['medicalDirector']), reviewed(await create()), 'review'));
  const previous = (await getDoc(doc(client('operator', ['operations']), 'doctorRecords', recordId))).data();
  await assertFails(write(client('operator', ['operations']), {...previous, name: 'Otro nombre', status: 'pending', review: {}, revision: 3, updatedBy: 'operator', updatedAt: serverTimestamp()}, 'edit'));
  await assertFails(write(client('director', ['medicalDirector']), reviewed(previous, 'rejected'), 'review'));
  await assertSucceeds(write(client('director', ['medicalDirector']), reviewed(previous, 'suspended'), 'review'));
});
test('rejection can be corrected by operations and resets review with immutable history', async () => {
  await assertSucceeds(write(client('director', ['medicalDirector']), reviewed(await create(), 'rejected'), 'review'));
  const database = client('operator', ['operations']);
  const previous = (await getDoc(doc(database, 'doctorRecords', recordId))).data();
  await assertSucceeds(write(database, {...previous, status: 'pending', review: {}, name: 'Nombre corregido', revision: 3, updatedBy: 'operator', updatedAt: serverTimestamp()}, 'edit'));
  assert.equal((await getDoc(doc(database, 'doctorRecords', recordId, 'events', '2'))).data().snapshot.status, 'rejected');
});
test('duplicate/stale revisions, deletion and audit alteration are denied', async () => {
  const previous = await create(); const database = client('operator', ['operations']);
  await assertFails(write(database, initial()));
  await assertFails(write(database, {...previous, updatedAt: serverTimestamp()}, 'edit'));
  await assertFails(deleteDoc(doc(database, 'doctorRecords', recordId)));
  await assertFails(deleteDoc(doc(database, 'doctorRecords', recordId, 'events', '1')));
  await assertFails(setDoc(doc(database, 'doctorRecords', recordId, 'events', '1'), {actorId: 'other'}));
});
test('untrusted clients and doctor do not gain registry access', async () => {
  await create();
  for (const database of [environment.unauthenticatedContext().firestore(), client('patient', []), client('doctor', ['doctor'])]) {
    await assertFails(getDoc(doc(database, 'doctorRecords', recordId)));
    await assertFails(getDoc(doc(database, 'doctorRecords', recordId, 'events', '1')));
  }
});
test('canonical revocation and mismatched claims deny access', async () => {
  await create();
  await assertFails(getDoc(doc(client('operator', ['medicalDirector']), 'doctorRecords', recordId)));
  await environment.withSecurityRulesDisabled(context => setDoc(doc(context.firestore(), 'panelStaff', 'operator'), {active: false, provisioning: 'ready', memberships: {CL: ['operations']}}));
  await assertFails(getDoc(doc(client('operator', ['operations']), 'doctorRecords', recordId)));
});

for (const [label, change] of [
  ['legacy new record', {schemaVersion: 1}], ['missing specialty ID', {specialtyId: null}],
  ['unknown specialty', {specialtyId: 'CL_missing'}], ['foreign ID', {specialtyId: 'AR_qa_specialty'}],
  ['forged specialty name', {specialty: 'Otra especialidad'}], ['clinic required by client', {clinicId: 'CL_any'}],
]) test(`catalog rejects ${label}`, async () => {
  await assertFails(write(client('operator', ['operations']), {...initial(), ...change}));
});
test('inactive and foreign-country catalog references are denied at registration and approval', async () => {
  const previous = await create();
  for (const change of [{countryCode: 'CL', active: false}, {countryCode: 'AR', active: true}]) {
    await environment.withSecurityRulesDisabled(context => setDoc(doc(context.firestore(), 'specialties', 'CL_qa_specialty'), {...change, name: 'Especialidad ficticia'}));
    await assertFails(write(client('director', ['medicalDirector']), reviewed(previous), 'review'));
    await assertFails(write(client('operator', ['operations']), {...previous, revision: 2, updatedAt: serverTimestamp()}, 'edit'));
  }
});
test('catalog rename does not change historical label or prevent otherwise valid review', async () => {
  const previous = await create();
  await environment.withSecurityRulesDisabled(context => setDoc(doc(context.firestore(), 'specialties', 'CL_qa_specialty'), {countryCode: 'CL', active: true, name: 'Nombre actualizado'}));
  await assertSucceeds(write(client('director', ['medicalDirector']), reviewed(previous), 'review'));
});
test('legacy pending needs explicit operations mapping; existing verified can still be suspended', async () => {
  const database = client('operator', ['operations']);
  const legacy = {...initial(), schemaVersion: 1}; delete legacy.specialtyId;
  await environment.withSecurityRulesDisabled(context => setDoc(doc(context.firestore(), 'doctorRecords', recordId), legacy));
  const previous = (await getDoc(doc(database, 'doctorRecords', recordId))).data();
  await assertFails(write(client('director', ['medicalDirector']), reviewed(previous), 'review'));
  await assertSucceeds(write(database, {...previous, schemaVersion: 2, specialtyId: 'CL_qa_specialty', revision: 2, updatedAt: serverTimestamp()}, 'edit'));
  await environment.withSecurityRulesDisabled(context => setDoc(doc(context.firestore(), 'doctorRecords', recordId), {...legacy, status: 'verified', revision: 10}));
  const verified = (await getDoc(doc(database, 'doctorRecords', recordId))).data();
  await assertSucceeds(write(client('director', ['medicalDirector']), reviewed(verified, 'suspended'), 'review'));
});

test('superadmin reads registry and audit without writes, scoped and revocable', async () => {
  const previous = await create(), database = client('admin', ['superadmin']);
  await assertSucceeds(getDoc(doc(database, 'doctorRecords', recordId)));
  await assertSucceeds(getDoc(doc(database, 'doctorRecords', recordId, 'events', '1')));
  await assertFails(write(database, {...previous, revision: 2, updatedBy: 'admin', updatedAt: serverTimestamp()}, 'edit'));
  await assertFails(write(database, reviewed(previous), 'review'));
  await assertFails(deleteDoc(doc(database, 'doctorRecords', recordId)));
  await assertFails(getDoc(doc(environment.authenticatedContext('admin', {email_verified: true, panelAccess: {version: 1, active: true, memberships: {AR: ['superadmin']}}}).firestore(), 'doctorRecords', recordId)));
  await environment.withSecurityRulesDisabled(context => updateDoc(doc(context.firestore(), 'panelStaff', 'admin'), {active: false}));
  await assertFails(getDoc(doc(database, 'doctorRecords', recordId)));
});
