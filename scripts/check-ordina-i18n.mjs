import fs from 'node:fs';
import vm from 'node:vm';

const root = new URL('../', import.meta.url);
const html = fs.readFileSync(new URL('ordina/index.html', root), 'utf8');
const snapshot = JSON.parse(fs.readFileSync(new URL('ordina/menu-snapshot.json', root), 'utf8'));
const source = fs.readFileSync(new URL('ordina/i18n.js', root), 'utf8');
const context = { window: {} };
vm.runInNewContext(source, context);
const i18n = context.window.ARGO_I18N;
const codes = ['it', 'en', 'el', 'es', 'de', 'fr'];

function fail(message) {
  console.error(`i18n check failed: ${message}`);
  process.exitCode = 1;
}

if (JSON.stringify(Object.keys(i18n.languages)) !== JSON.stringify(codes)) {
  fail('supported language list changed unexpectedly');
}

const uiKeys = Object.keys(i18n.ui.it);
for (const code of codes) {
  const missing = uiKeys.filter((key) => !i18n.ui[code]?.[key]);
  if (missing.length) fail(`${code} is missing UI keys: ${missing.join(', ')}`);
}

for (const [type, records, field] of [
  ['categories', snapshot.cats, 'name'],
  ['groups', snapshot.groups, 'name'],
  ['options', snapshot.options, 'name'],
  ['descriptions', snapshot.items.filter((item) => item.description), 'description']
]) {
  const missing = records.map((record) => record[field]).filter((value) => !i18n[type][value]);
  if (missing.length) fail(`${type} missing translations: ${missing.join(' | ')}`);
  const incomplete = Object.entries(i18n[type]).filter(([, row]) => codes.some((code) => !row[code]));
  if (incomplete.length) fail(`${type} has incomplete rows: ${incomplete.map(([key]) => key).join(' | ')}`);
}

const ids = new Set([...html.matchAll(/id="([^"]+)"/g)].map((match) => match[1]));
const referencedIds = new Set([...html.matchAll(/\$\('([^']+)'\)/g)].map((match) => match[1]));
const missingIds = [...referencedIds].filter((id) => !ids.has(id));
if (missingIds.length) fail(`JavaScript references missing IDs: ${missingIds.join(', ')}`);

const txKeys = new Set([...html.matchAll(/tx\('([^']+)'/g)].map((match) => match[1]));
const missingTx = [...txKeys].filter((key) => !i18n.ui.it[key]);
if (missingTx.length) fail(`JavaScript references missing UI translations: ${missingTx.join(', ')}`);

if (!process.exitCode) {
  console.log(`ARGO Direct i18n OK: ${codes.length} languages, ${snapshot.items.length} products, ${uiKeys.length} UI messages.`);
}
