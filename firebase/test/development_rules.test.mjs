import {before,after,test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment,assertFails} from '@firebase/rules-unit-testing';
import {doc,setDoc,getDoc} from 'firebase/firestore';
import {developmentRules} from '../../scripts/development-rules.mjs';

let environment;
const source = readFileSync('firebase/firestore.rules','utf8');
const rules = developmentRules(source);
before(async()=>{
  environment=await initializeTestEnvironment({projectId:'demo-2daopinion',firestore:{host:'127.0.0.1',port:8080,rules}});
  await environment.clearFirestore();
});
after(async()=>environment.cleanup());
test('development configuration excludes unapproved notices and unrelated services',()=>{
  assert.ok(!rules.includes('match /patientNotices'));
  assert.ok(rules.includes('match /consultationSubmissions'));
  assert.ok(rules.includes('match /draftAttachments'));
  assert.ok(rules.startsWith(source.slice(0,source.indexOf('    function intakeOperator'))));
  assert.throws(()=>developmentRules('changed structure'));
  const config=JSON.parse(readFileSync('firebase.development.json','utf8'));
  assert.deepEqual(Object.keys(config).sort(),['firestore','storage']);
});
test('development keeps notices denied even to an otherwise valid owner',async()=>{
  await environment.withSecurityRulesDisabled(async context=>{
    await setDoc(doc(context.firestore(),'profiles/dev-patient'),{id:'patient'});
    await setDoc(doc(context.firestore(),'patientNotices/dev-patient/items/notice'),{id:'notice',recipientId:'dev-patient'});
  });
  const database=environment.authenticatedContext('dev-patient',{email_verified:true}).firestore();
  await assertFails(getDoc(doc(database,'patientNotices/dev-patient/items/notice')));
});
