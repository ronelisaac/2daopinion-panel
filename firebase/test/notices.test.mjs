import {before, after, beforeEach, test} from 'node:test';
import {strict as assert} from 'node:assert';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment, assertSucceeds, assertFails} from '@firebase/rules-unit-testing';
import {doc, setDoc, getDoc, getDocs, query, collection, limit, where, orderBy, documentId, startAfter, updateDoc, deleteDoc, serverTimestamp, deleteField, Timestamp} from 'firebase/firestore';
let environment;
const noticeId = 'a'.repeat(64);
const path = `patientNotices/alice/items/${noticeId}`;
const date = new Timestamp(1750000000, 123456789);
const record = (id = noticeId) => ({id, recipientId: 'alice', schemaVersion: 1, templateCode: 'welcome', createdAt: date, readAt: null});
const account = (uid = 'alice', verified = true) => environment.authenticatedContext(uid, {email_verified: verified});
before(async () => {
  environment = await initializeTestEnvironment({projectId: 'demo-2daopinion', firestore: {host: '127.0.0.1', port: 8080, rules: readFileSync('firebase/firestore.rules', 'utf8')}});
});
beforeEach(async () => {
  await environment.clearFirestore();
  await environment.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'profiles/alice'), {id: 'profile', countryCode: 'CL'});
    await setDoc(doc(context.firestore(), path), record());
  });
});
after(async () => environment.cleanup());
test('recipient reads notices and changes only read state with server time', async () => {
  const reference = doc(account().firestore(), path);
  await assertSucceeds(getDoc(reference));
  await assertSucceeds(updateDoc(reference, {readAt: serverTimestamp()}));
  assert.ok((await getDoc(reference)).data().readAt instanceof Timestamp);
  await assertSucceeds(updateDoc(reference, {readAt: null}));
  assert.equal((await getDoc(reference)).data().readAt, null);
});
test('list is bounded and unread query is supported', async () => {
  const items = collection(account().firestore(), 'patientNotices/alice/items');
  await assertSucceeds(getDocs(query(items, where('readAt', '==', null), limit(100))));
  await assertSucceeds(getDocs(query(items, orderBy('createdAt', 'desc'), orderBy(documentId(), 'desc'), limit(21))));
  await assertFails(getDocs(items));
  await assertFails(getDocs(query(items, limit(101))));
});
test('anonymous, unverified and other accounts cannot read or change notices', async () => {
  for (const context of [environment.unauthenticatedContext(), account('alice', false), account('bob')]) {
    await assertFails(getDoc(doc(context.firestore(), path)));
    await assertFails(getDocs(query(collection(context.firestore(), 'patientNotices/alice/items'), limit(20))));
    await assertFails(updateDoc(doc(context.firestore(), path), {readAt: serverTimestamp()}));
  }
});
test('patient cannot create, delete, retarget or forge message contents', async () => {
  const database = account().firestore();
  await assertFails(setDoc(doc(database, `patientNotices/alice/items/${'b'.repeat(64)}`), record('b'.repeat(64))));
  await assertFails(deleteDoc(doc(database, path)));
  for (const change of [{recipientId: 'bob'}, {id: 'b'.repeat(64)}, {templateCode: 'paid'}, {createdAt: serverTimestamp()}, {schemaVersion: 2}, {url: 'https://invalid.test'}, {text: 'invented'}]) {
    await assertFails(updateDoc(doc(database, path), {...change, readAt: serverTimestamp()}));
  }
});
test('read timestamps cannot be forged or removed', async () => {
  for (const readAt of ['today', true, date, deleteField()]) {
    await assertFails(updateDoc(doc(account().firestore(), path), {readAt}));
  }
});
test('removed profile loses notice access', async () => {
  await environment.withSecurityRulesDisabled(context => deleteDoc(doc(context.firestore(), 'profiles/alice')));
  await assertFails(getDoc(doc(account().firestore(), path)));
});
test('equal timestamps paginate with an ID tie breaker without skipping messages', async () => {
  await environment.withSecurityRulesDisabled(async context => {
    for (let index = 1; index <= 22; index++) {
      const id = index.toString(16).padStart(64, '0');
      await setDoc(doc(context.firestore(), `patientNotices/alice/items/${id}`), record(id));
    }
  });
  const items = collection(account().firestore(), 'patientNotices/alice/items');
  const first = await getDocs(query(items, orderBy('createdAt', 'desc'), orderBy(documentId(), 'desc'), limit(20)));
  const last = first.docs.at(-1);
  const second = await getDocs(query(items, orderBy('createdAt', 'desc'), orderBy(documentId(), 'desc'), startAfter(last.data().createdAt, last.id), limit(20)));
  assert.equal(first.docs.length + second.docs.length, 23);
  assert.equal(new Set([...first.docs, ...second.docs].map(snapshot => snapshot.id)).size, 23);
});
