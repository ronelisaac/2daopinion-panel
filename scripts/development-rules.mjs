import {mkdir, readFile, writeFile} from 'node:fs/promises';
import {pathToFileURL} from 'node:url';

export function developmentRules(source) {
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
  await writeFile('.firebase/development/firestore.rules', developmentRules(source));
  console.log('Development rules prepared; notices remain denied. Nothing deployed.');
}
