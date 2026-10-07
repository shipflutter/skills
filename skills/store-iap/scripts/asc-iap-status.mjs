#!/usr/bin/env node
/**
 * asc-iap-status.mjs — is my app + every IAP actually submitted?
 *
 * Prints, from the App Store Connect API (the ASC web UI lags and lies):
 *   - app store version state + attached build
 *   - latest builds + processing state
 *   - every subscription group / subscription + state + readiness blockers
 *   - every non-consumable IAP + state (via the v1 endpoint, which v2 hides)
 *   - the active review submission + ITEM COUNT  ← the authoritative check
 *
 * Usage:
 *   export ASC_KEY_ID=ABCD123456
 *   export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
 *   export ASC_KEY_PATH=/path/to/AuthKey_ABCD123456.p8
 *   export ASC_APP_ID=1234567890
 *   node asc-iap-status.mjs
 *
 * Requires Node >= 18 (built-in fetch). No dependencies.
 */
import { readFileSync } from 'node:fs';
import crypto from 'node:crypto';

const { ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH, ASC_APP_ID } = process.env;
for (const [k, v] of Object.entries({ ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH, ASC_APP_ID })) {
  if (!v) { console.error(`✗ missing env ${k}`); process.exit(1); }
}

const p8 = readFileSync(ASC_KEY_PATH, 'utf8');
const b64u = (o) => Buffer.from(typeof o === 'string' ? o : JSON.stringify(o)).toString('base64url');

function token() {
  const now = Math.floor(Date.now() / 1000);
  const si =
    `${b64u({ alg: 'ES256', kid: ASC_KEY_ID, typ: 'JWT' })}.` +
    `${b64u({ iss: ASC_ISSUER_ID, iat: now, exp: now + 300, aud: 'appstoreconnect-v1' })}`;
  // ES256 needs JOSE (R||S). Without ieee-p1363 Node emits DER and every call 401s.
  const sig = crypto.sign('sha256', Buffer.from(si), { key: p8, dsaEncoding: 'ieee-p1363' });
  return `${si}.${sig.toString('base64url')}`;
}

const get = async (path) => {
  const r = await fetch('https://api.appstoreconnect.apple.com' + path, {
    headers: { Authorization: `Bearer ${token()}` },
  });
  const j = await r.json().catch(() => ({}));
  if (j.errors) return { __error: j.errors[0]?.detail || JSON.stringify(j.errors) };
  return j;
};

const line = (s = '') => console.log(s);
const mark = (ok) => (ok ? '✅' : '❌');

// ── app ──────────────────────────────────────────────────────────────────────
const app = await get(`/v1/apps/${ASC_APP_ID}?fields[apps]=name,bundleId`);
if (app.__error) { console.error('✗ app:', app.__error); process.exit(1); }
line(`\n=== ${app.data.attributes.name}  (${app.data.attributes.bundleId}) ===`);

// ── version + attached build ─────────────────────────────────────────────────
const vers = await get(
  `/v1/apps/${ASC_APP_ID}/appStoreVersions?limit=1` +
  `&fields[appStoreVersions]=versionString,appStoreState,platform` +
  `&include=build&fields[builds]=version`
);
let versionState = null;
if (vers.data?.length) {
  const v = vers.data[0];
  versionState = v.attributes.appStoreState;
  const b = (vers.included || []).find((x) => x.type === 'builds');
  line(`\nVERSION  ${v.attributes.versionString}  state=${versionState}  build=${b ? b.attributes.version : '— none attached —'}`);
} else {
  line('\nVERSION  (none)');
}

// ── builds ───────────────────────────────────────────────────────────────────
const builds = await get(
  `/v1/builds?filter[app]=${ASC_APP_ID}&limit=5&sort=-uploadedDate` +
  `&fields[builds]=version,processingState,uploadedDate`
);
line('\nBUILDS (latest 5)   — TestFlight UI lags this; trust processingState');
for (const b of builds.data || []) {
  line(`  build ${String(b.attributes.version).padEnd(5)} ${b.attributes.processingState.padEnd(10)} ${b.attributes.uploadedDate}`);
}
if (!(builds.data || []).length) line('  (none — a fresh upload takes 1–3 min to appear)');

// ── subscriptions ────────────────────────────────────────────────────────────
const groups = await get(
  `/v1/apps/${ASC_APP_ID}/subscriptionGroups?limit=10&fields[subscriptionGroups]=referenceName`
);
line('\nSUBSCRIPTIONS');
if (!(groups.data || []).length) line('  (no subscription groups)');
for (const g of groups.data || []) {
  const locs = await get(
    `/v1/subscriptionGroups/${g.id}/subscriptionGroupLocalizations?limit=5&fields[subscriptionGroupLocalizations]=locale,name`
  );
  const hasGroupLoc = !!(locs.data || []).length;
  line(`  GROUP "${g.attributes.referenceName}" (${g.id})`);
  line(`    ${mark(hasGroupLoc)} group localization${hasGroupLoc ? `: ${(locs.data || []).map((l) => l.attributes.locale).join(', ')}` : ' — MISSING → "Add for Review" will fail'}`);

  const subs = await get(
    `/v1/subscriptionGroups/${g.id}/subscriptions?limit=20&fields[subscriptions]=productId,state`
  );
  for (const s of subs.data || []) {
    const [shot, sloc, price] = await Promise.all([
      get(`/v1/subscriptions/${s.id}/appStoreReviewScreenshot`),
      get(`/v1/subscriptions/${s.id}/subscriptionLocalizations?limit=5&fields[subscriptionLocalizations]=locale`),
      get(`/v1/subscriptions/${s.id}/prices?limit=1`),
    ]);
    const hasShot = !!shot?.data?.id;
    const hasLoc = !!(sloc.data || []).length;
    const hasPrice = !!(price.data || []).length;
    line(`    SUB ${s.attributes.productId}`);
    line(`        state=${s.attributes.state}  ${mark(hasShot)} reviewScreenshot  ${mark(hasLoc)} localization  ${mark(hasPrice)} price`);
  }
}

// ── non-consumables / other IAPs (v1: v2 hides CREATED-state products) ───────
const iaps = await get(`/v1/apps/${ASC_APP_ID}/inAppPurchases?limit=50`);
line('\nIN-APP PURCHASES (v1 endpoint — v2 can return [] for the same products)');
const subIds = new Set();
for (const g of groups.data || []) {
  const subs = await get(`/v1/subscriptionGroups/${g.id}/subscriptions?limit=20&fields[subscriptions]=productId`);
  for (const s of subs.data || []) subIds.add(s.attributes.productId);
}
const nonSubs = (iaps.data || []).filter((p) => !subIds.has(p.attributes?.productId));
if (!nonSubs.length) line('  (none)');
for (const p of nonSubs) {
  line(`  IAP ${p.attributes.productId}  state=${p.attributes.state ?? '(null — check the ASC UI status column)'}`);
}

// ── the authoritative check ──────────────────────────────────────────────────
const rs = await get(
  `/v1/apps/${ASC_APP_ID}/reviewSubmissions` +
  `?filter[state]=WAITING_FOR_REVIEW,IN_REVIEW,UNRESOLVED_ISSUES` +
  `&fields[reviewSubmissions]=state,platform&limit=5`
);
line('\nACTIVE REVIEW SUBMISSION  ← authoritative: did everything go together?');
if (!(rs.data || []).length) {
  line('  (none active — nothing is currently submitted)');
} else {
  for (const s of rs.data) {
    const items = await get(`/v1/reviewSubmissions/${s.id}/items?limit=30`);
    const n = (items.data || []).length;
    line(`  ${s.id}  state=${s.attributes.state}  items=${n}`);
    line(`  → expect: 1 version + every subscription + the group + every IAP.`);
  }
}

// ── verdict ──────────────────────────────────────────────────────────────────
const stranded = [];
for (const g of groups.data || []) {
  const subs = await get(`/v1/subscriptionGroups/${g.id}/subscriptions?limit=20&fields[subscriptions]=productId,state`);
  for (const s of subs.data || []) {
    if (s.attributes.state === 'READY_TO_SUBMIT') stranded.push(s.attributes.productId);
  }
}
line('');
if (versionState === 'WAITING_FOR_REVIEW' && stranded.length) {
  line(`⚠️  Version is in review but these are NOT: ${stranded.join(', ')}`);
  line('    → classic Guideline 2.1(b). See references/rejection-playbook.md');
  line('    (right after submitting this can be propagation lag — trust the item count above)');
} else if (versionState === 'WAITING_FOR_REVIEW') {
  line('✅ Version in review; no subscriptions stranded at READY_TO_SUBMIT.');
} else {
  line(`ℹ️  Version state: ${versionState ?? 'n/a'} — nothing submitted yet.`);
}
line('');
