import {before,after,test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment,assertFails} from '@firebase/rules-unit-testing';
import {doc,setDoc,getDoc} from 'firebase/firestore';
import {developmentRules} from '../../scripts/development-rules.mjs';

let environment;
const source = readFileSync('firebase/firestore.rules','utf8');
const rules = developmentRules(source, {includeDoctors: false});
before(async()=>{
  environment=await initializeTestEnvironment({projectId:'demo-2daopinion',firestore:{host:'127.0.0.1',port:8080,rules}});
  await environment.clearFirestore();
});
after(async()=>environment.cleanup());
test('development configuration excludes unapproved notices and unrelated services',()=>{
  assert.ok(!rules.includes('match /patientNotices'));
  assert.ok(!rules.includes('match /doctorRecords'));
  assert.ok(developmentRules(source).includes('match /doctorRecords'));
  assert.ok(!developmentRules(source).includes('match /specialties'));
  assert.ok(developmentRules(source, {includeSpecialties: true}).includes('match /specialties'));
  assert.ok(!developmentRules(source, {includeSpecialties: true}).includes('match /patientNotices'));
  assert.throws(()=>developmentRules(source.replace('function specialtyRole(country, role)', 'function changedSpecialtyBoundary(country, role)')));
  assert.ok(!developmentRules(source, {includeDoctors: true}).includes('match /patientNotices'));
  assert.ok(rules.includes('match /consultationSubmissions'));
  assert.ok(rules.includes('match /draftAttachments'));
  assert.ok(rules.startsWith(source.slice(0,source.indexOf('    function intakeOperator'))));
  assert.throws(()=>developmentRules('changed structure'));
  assert.throws(()=>developmentRules(source.replace('function doctorRole(country, role)', 'function changedDoctorBoundary(country, role)'), {includeDoctors: false}));
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
test('explicit rollback subset keeps doctors closed even to a valid operator',async()=>{
  await environment.withSecurityRulesDisabled(async context=>{
    await setDoc(doc(context.firestore(),'panelStaff/operator'),{active:true,provisioning:'ready',memberships:{CL:['operations']}});
    await setDoc(doc(context.firestore(),'doctorRecords/CL_123'),{countryCode:'CL'});
  });
  const database=environment.authenticatedContext('operator',{email_verified:true,panelAccess:{version:1,active:true,memberships:{CL:['operations']}}}).firestore();
  await assertFails(getDoc(doc(database,'doctorRecords/CL_123')));
});
test('specialties stay closed in the unapproved development subset',async()=>{
  await environment.withSecurityRulesDisabled(async context=>{
    await setDoc(doc(context.firestore(),'panelStaff/admin'),{active:true,provisioning:'ready',memberships:{CL:['superadmin']}});
    await setDoc(doc(context.firestore(),'specialties/CL_qa'),{countryCode:'CL'});
  });
  const database=environment.authenticatedContext('admin',{email_verified:true,panelAccess:{version:1,active:true,memberships:{CL:['superadmin']}}}).firestore();
  await assertFails(getDoc(doc(database,'specialties/CL_qa')));
});
