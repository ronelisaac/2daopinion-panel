import {mkdir, readFile, writeFile} from 'node:fs/promises';
import {pathToFileURL} from 'node:url';

export function developmentRules(source, {includeDoctors = true, includeSpecialties = true} = {}) {
  if (!includeSpecialties) {
    const start = source.indexOf('    function specialtyRole(country, role) {');
    const end = source.indexOf('    function doctorRole(country, role) {');
    if (start < 0 || end <= start || source.slice(start, end).includes('    function owner(')) {
      throw new Error('Review the specialty boundary before preparing development.');
    }
    source = source.slice(0, start) + source.slice(end);
  }
  if (!includeDoctors) {
    const doctors = source.indexOf('    function doctorRole(country, role) {');
    const notices = source.indexOf('    match /patientNotices/{uid}/items/{noticeId} {');
    if (doctors < 0 && source.includes('match /doctorRecords')) {
      throw new Error('Doctor candidate boundary not recognized; nothing prepared.');
    }
    if (doctors >= 0) {
      if (notices <= doctors || source.slice(doctors, notices).includes('    function owner(')) {
        throw new Error('Review the doctor candidate boundary before preparing development.');
      }
      source = source.slice(0, doctors) + source.slice(notices);
    }
  }
  const start = source.indexOf('    match /patientNotices/{uid}/items/{noticeId} {');
  const end = source.indexOf('    match /{document=**} {', start);
  if (start < 0 || end < start || source.indexOf('    match /', start + 10) !== end) {
    throw new Error('Review the candidate rules before preparing development.');
  }
  return source.slice(0, start) + source.slice(end);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const source = await readFile('firebase/firestore.rules', 'utf8');
  await mkdir('.firebase/development', {recursive:true});
  const includeDoctors = !process.argv.includes('--exclude-doctors');
  const includeSpecialties = !process.argv.includes('--exclude-specialties');
  await writeFile('.firebase/development/firestore.rules', developmentRules(source, {includeDoctors, includeSpecialties}));
  console.log(`Development rules prepared; doctors ${includeDoctors ? 'included' : 'excluded'}, specialties ${includeSpecialties ? 'included' : 'excluded'}, notices denied. Nothing deployed.`);
}
