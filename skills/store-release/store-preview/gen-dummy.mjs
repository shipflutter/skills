#!/usr/bin/env node
/* ===========================================================================
 * gen-dummy.mjs — regenerate the DUMMY store-preview screenshots.
 *
 * Produces content-filled mock "PulseFit" app screens (not blank skeletons) so
 * the listing preview looks like a real submission. Everything is fake demo
 * data. Run from this folder:
 *
 *     node gen-dummy.mjs
 *
 * Writes: assets/{phone,iphone,tablet,ipad}-NN.svg, app-icon.svg,
 *         feature-graphic.svg — matching the paths in listing.json.
 * No dependencies (Node >= 16, ESM).
 * ======================================================================== */

import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = dirname(fileURLToPath(import.meta.url));
const OUT = join(ROOT, 'assets');
mkdirSync(OUT, { recursive: true });

/* ---- palette (kept in sync with the app icon) ---------------------------- */
const C = {
  ink: '#1d1d23',
  mut: '#8a8a99',
  card: '#ffffff',
  border: '#ececf2',
  track: '#e9e9f1',
  accent: '#ff8a3d',
  brand: '#5b5bd6',
  brand2: '#3a3aa3',
};
const FONT = '-apple-system,Segoe UI,Roboto,sans-serif';

/* ---- tiny SVG helpers; all units are in the 1080-wide design space -------
 * Each screen is authored on a 1080-wide canvas of arbitrary height, then the
 * <svg> viewBox is set to the real device pixel size and the artwork is scaled
 * + vertically centred to fit. This keeps one layout working across phone /
 * iphone / tablet / ipad aspect ratios. */
const DW = 1080; // design width
const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

const rrect = (x, y, w, h, r, fill, extra = '') =>
  `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" fill="${fill}"${extra ? ' ' + extra : ''}/>`;
const circ = (cx, cy, r, fill, extra = '') =>
  `<circle cx="${cx}" cy="${cy}" r="${r}" fill="${fill}"${extra ? ' ' + extra : ''}/>`;
const txt = (x, y, size, weight, fill, s, { anchor = 'start', opacity = 1 } = {}) =>
  `<text x="${x}" y="${y}" font-family="${FONT}" font-size="${size}" font-weight="${weight}" fill="${fill}"` +
  `${anchor !== 'start' ? ` text-anchor="${anchor}"` : ''}${opacity !== 1 ? ` opacity="${opacity}"` : ''}>${esc(s)}</text>`;

const M = 76;          // side margin
const CW = DW - 2 * M; // content width (928)

/* status bar + bottom tab bar shared chrome ------------------------------- */
function statusBar() {
  return [
    txt(M, 120, 38, 700, C.ink, '9:41'),
    rrect(885.2, 84, 118.8, 23.76, 8.64, C.ink, 'opacity="0.55"'),
    circ(820, 96, 12, C.ink, 'opacity="0.55"'),
    circ(852, 96, 12, C.ink, 'opacity="0.55"'),
  ].join('\n  ');
}

function tabBar(H, active) {
  const tabs = ['Today', 'Train', 'Coach', 'Stats', 'You'];
  const top = H - 200;
  const slot = DW / tabs.length;
  const out = [rrect(0, top, DW, 200, 0, C.card), `<line x1="0" y1="${top}" x2="${DW}" y2="${top}" stroke="${C.border}" stroke-width="2"/>`];
  tabs.forEach((t, i) => {
    const cx = slot * i + slot / 2;
    const on = i === active;
    out.push(circ(cx, top + 70, 26, on ? C.brand : C.track));
    out.push(txt(cx, top + 140, 30, on ? 700 : 500, on ? C.brand : C.mut, t, { anchor: 'middle' }));
  });
  return out.join('\n  ');
}

function watermark(H) {
  return txt(DW / 2, H - 220, 26, 700, C.mut, 'DEMO · sample screenshot', { anchor: 'middle', opacity: 0.65 });
}

function heading(title) {
  return txt(M, 252, 64, 800, C.ink, title);
}

/* ---- per-screen bodies (return [svgFragments, designHeight]) ------------- */

function today() {
  const s = [];
  s.push(txt(M, 168, 34, 600, C.mut, 'Good morning'));
  s.push(heading('Hi, Alex'));
  // streak hero
  s.push(rrect(M, 312, CW, 460, 64, 'url(#hero)'));
  s.push(circ(900, 470, 230, '#ffffff', 'opacity="0.10"'));
  s.push(txt(M + 56, 470, 130, 800, '#ffffff', '12'));
  s.push(txt(M + 56, 540, 38, 600, '#ffffff', 'day streak', { opacity: 0.92 }));
  s.push(txt(M + 56, 624, 30, 500, '#ffffff', 'You’re on fire — keep it up!', { opacity: 0.78 }));
  // streak progress dots
  for (let i = 0; i < 7; i++) {
    const on = i < 5;
    s.push(circ(M + 56 + i * 64, 700, 22, on ? C.accent : '#ffffff', on ? '' : 'opacity="0.35"'));
  }
  // habits list
  s.push(txt(M, 880, 40, 800, C.ink, 'Today’s habits'));
  s.push(txt(DW - M, 880, 32, 600, C.brand, '3 / 4', { anchor: 'end' }));
  const habits = [
    ['Morning run · 5 km', true],
    ['Drink 2 L water', true],
    ['Meditate · 10 min', true],
    ['Evening stretch', false],
  ];
  let y = 940;
  for (const [name, done] of habits) {
    s.push(rrect(M, y, CW, 150, 44, C.card, `stroke="${C.border}"`));
    s.push(circ(M + 80, y + 75, 44, done ? C.accent : C.card, done ? '' : `stroke="${C.track}" stroke-width="6"`));
    if (done) s.push(`<path d="M${M + 58} ${y + 76} l16 18 l30 -36" fill="none" stroke="#fff" stroke-width="10" stroke-linecap="round" stroke-linejoin="round"/>`);
    s.push(txt(M + 160, y + 88, 38, 600, done ? C.mut : C.ink, name));
    y += 178;
  }
  return [s, y + 40];
}

function workouts() {
  const s = [];
  s.push(heading('Workouts'));
  s.push(rrect(M, 296, CW, 110, 55, C.card, `stroke="${C.border}"`));
  s.push(circ(M + 64, 351, 24, C.track));
  s.push(txt(M + 124, 364, 36, 500, C.mut, 'Search workouts'));
  // chips
  const chips = ['All', 'Strength', 'Cardio', 'Mobility'];
  let cx = M;
  chips.forEach((c, i) => {
    const w = 60 + c.length * 24;
    s.push(rrect(cx, 460, w, 84, 42, i === 0 ? C.brand : C.card, i === 0 ? '' : `stroke="${C.border}"`));
    s.push(txt(cx + w / 2, 512, 34, 600, i === 0 ? '#fff' : C.ink, c, { anchor: 'middle' }));
    cx += w + 28;
  });
  // cards
  const cards = [
    ['Full Body HIIT', '20 min · Intermediate', '420 kcal'],
    ['Core Crusher', '15 min · Beginner', '180 kcal'],
    ['Morning Mobility', '10 min · All levels', '90 kcal'],
    ['Leg Day Builder', '30 min · Advanced', '520 kcal'],
  ];
  let y = 600;
  cards.forEach(([title, meta, kcal], i) => {
    s.push(rrect(M, y, CW, 230, 52, C.card, `stroke="${C.border}"`));
    s.push(rrect(M + 32, y + 32, 166, 166, 36, i % 2 ? 'url(#hero)' : 'url(#warm)'));
    s.push(`<path d="M${M + 95} ${y + 90} l34 25 l-34 25 z" fill="#fff"/>`);
    s.push(txt(M + 238, y + 96, 42, 800, C.ink, title));
    s.push(txt(M + 238, y + 150, 32, 500, C.mut, meta));
    s.push(rrect(M + 238, y + 168, 210, 50, 25, '#fff5ee'));
    s.push(txt(M + 268, y + 202, 28, 700, C.accent, kcal));
    y += 258;
  });
  return [s, y + 20];
}

function coaching() {
  const s = [];
  s.push(heading('Live coaching'));
  // big focus card
  const top = 312, h = 1180;
  s.push(rrect(M, top, CW, h, 76, 'url(#hero)'));
  s.push(circ(900, top + 200, 260, '#ffffff', 'opacity="0.08"'));
  s.push(txt(DW / 2, top + 120, 38, 600, '#ffffff', 'Set 2 of 3', { anchor: 'middle', opacity: 0.85 }));
  s.push(txt(DW / 2, top + 190, 56, 800, '#ffffff', 'Push-ups', { anchor: 'middle' }));
  // rep ring
  const rcx = DW / 2, rcy = top + 560, R = 270;
  s.push(circ(rcx, rcy, R, 'none', `stroke="#ffffff" stroke-width="34" opacity="0.18"`));
  s.push(`<path d="M ${rcx} ${rcy - R} A ${R} ${R} 0 1 1 ${rcx - R * 0.95} ${rcy + R * 0.31}" fill="none" stroke="${C.accent}" stroke-width="34" stroke-linecap="round"/>`);
  s.push(txt(rcx, rcy + 20, 180, 800, '#ffffff', '12', { anchor: 'middle' }));
  s.push(txt(rcx, rcy + 90, 40, 600, '#ffffff', '/ 15 reps', { anchor: 'middle', opacity: 0.85 }));
  // cue pill
  s.push(rrect(M + 60, top + 940, CW - 120, 150, 40, '#ffffff', 'opacity="0.16"'));
  s.push(txt(DW / 2, top + 1005, 36, 700, '#ffffff', 'Great form!', { anchor: 'middle' }));
  s.push(txt(DW / 2, top + 1055, 30, 500, '#ffffff', 'Keep your back straight, steady pace', { anchor: 'middle', opacity: 0.85 }));
  // stat tiles
  const stats = [['04:32', 'Time'], ['128', 'Total reps'], ['Good', 'Pace']];
  let x = M;
  const tw = (CW - 2 * 32) / 3;
  stats.forEach(([v, k]) => {
    s.push(rrect(x, top + h + 40, tw, 200, 44, C.card, `stroke="${C.border}"`));
    s.push(txt(x + tw / 2, top + h + 130, 56, 800, C.ink, v, { anchor: 'middle' }));
    s.push(txt(x + tw / 2, top + h + 185, 30, 500, C.mut, k, { anchor: 'middle' }));
    x += tw + 32;
  });
  return [s, top + h + 300];
}

function progress() {
  const s = [];
  s.push(heading('Progress'));
  // stat tiles
  const stats = [['18', 'Workouts'], ['240', 'Minutes'], ['9,820', 'Calories']];
  let x = M;
  const tw = (CW - 2 * 32) / 3;
  stats.forEach(([v, k]) => {
    s.push(rrect(x, 312, tw, 220, 44, C.card, `stroke="${C.border}"`));
    s.push(txt(x + tw / 2, 420, 58, 800, C.brand, v, { anchor: 'middle' }));
    s.push(txt(x + tw / 2, 478, 30, 500, C.mut, k, { anchor: 'middle' }));
    x += tw + 32;
  });
  // weekly bar chart
  s.push(rrect(M, 580, CW, 620, 52, C.card, `stroke="${C.border}"`));
  s.push(txt(M + 48, 668, 40, 800, C.ink, 'This week'));
  s.push(txt(DW - M - 48, 668, 30, 600, C.accent, '+18%', { anchor: 'end' }));
  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  const vals = [0.5, 0.8, 0.35, 0.95, 0.6, 0.25, 0.7];
  const base = 1110, maxH = 360, bw = 64;
  const gap = (CW - 96 - days.length * bw) / (days.length - 1);
  days.forEach((d, i) => {
    const bx = M + 48 + i * (bw + gap);
    const bh = Math.round(maxH * vals[i]);
    s.push(rrect(bx, base - maxH, bw, maxH, bw / 2, C.track));
    s.push(rrect(bx, base - bh, bw, bh, bw / 2, i === 3 ? C.accent : C.brand));
    s.push(txt(bx + bw / 2, base + 50, 30, 600, C.mut, d, { anchor: 'middle' }));
  });
  // PRs
  s.push(txt(M, 1300, 40, 800, C.ink, 'Personal records'));
  const prs = [['5K run', '24:18'], ['Plank hold', '3:40'], ['Push-ups', '42 reps']];
  let y = 1356;
  prs.forEach(([name, val]) => {
    s.push(rrect(M, y, CW, 140, 40, C.card, `stroke="${C.border}"`));
    s.push(circ(M + 78, y + 70, 40, '#fff5ee'));
    s.push(circ(M + 78, y + 70, 16, C.accent));
    s.push(txt(M + 150, y + 84, 38, 600, C.ink, name));
    s.push(txt(DW - M - 40, y + 84, 40, 800, C.brand, val, { anchor: 'end' }));
    y += 168;
  });
  return [s, y + 40];
}

function challenges() {
  const s = [];
  s.push(heading('Challenges'));
  // featured banner
  s.push(rrect(M, 312, CW, 420, 64, 'url(#hero)'));
  s.push(circ(910, 420, 220, '#ffffff', 'opacity="0.10"'));
  s.push(rrect(M + 48, 372, 220, 64, 32, '#ffffff', 'opacity="0.18"'));
  s.push(txt(M + 80, 414, 30, 700, '#ffffff', '3 days left'));
  s.push(txt(M + 48, 510, 54, 800, '#ffffff', 'June Step Challenge'));
  s.push(txt(M + 48, 566, 32, 500, '#ffffff', '720,000 / 1,000,000 steps', { opacity: 0.85 }));
  // progress bar
  s.push(rrect(M + 48, 610, CW - 96, 36, 18, '#ffffff', 'opacity="0.25"'));
  s.push(rrect(M + 48, 610, (CW - 96) * 0.72, 36, 18, C.accent));
  s.push(txt(DW - M - 48, 690, 32, 700, '#ffffff', '72%', { anchor: 'end' }));
  // leaderboard
  s.push(txt(M, 840, 40, 800, C.ink, 'Leaderboard'));
  const rows = [
    ['1', 'Maya R.', '8,420', false],
    ['2', 'Jordan K.', '7,950', false],
    ['3', 'Alex (You)', '7,310', true],
    ['4', 'Sam P.', '6,980', false],
    ['5', 'Priya N.', '6,540', false],
  ];
  let y = 900;
  rows.forEach(([rank, name, pts, me]) => {
    s.push(rrect(M, y, CW, 150, 44, me ? '#eef0ff' : C.card, `stroke="${me ? C.brand : C.border}"`));
    s.push(txt(M + 56, y + 92, 44, 800, me ? C.brand : C.mut, rank));
    s.push(circ(M + 160, y + 75, 44, me ? C.brand : C.track));
    s.push(txt(M + 240, y + 90, 38, 600, C.ink, name));
    s.push(txt(DW - M - 40, y + 90, 36, 800, me ? C.brand : C.ink, pts + ' pts', { anchor: 'end' }));
    y += 178;
  });
  return [s, y + 40];
}

const SCREENS = { Today: today, Workouts: workouts, 'Live coaching': coaching, Progress: progress, Challenges: challenges };

/* ---- assemble one screenshot -------------------------------------------- */
function screen(label, W, H, activeTab) {
  const [body, dh] = SCREENS[label]();
  const designH = dh + 240; // room for the bottom tab bar
  // "contain" the 1080×designH artwork inside the device viewBox: scale by the
  // smaller axis and centre both ways. Phones (same aspect) fill edge-to-edge;
  // wider tablets/iPads show the mock centred with side padding on the bg.
  const scale = Math.min(W / DW, H / designH);
  const scaledW = DW * scale;
  const scaledH = designH * scale;
  const offX = (W - scaledW) / 2;
  const offY = (H - scaledH) / 2;
  const inner = [
    `<rect width="${DW}" height="${designH}" fill="url(#bg)"/>`,
    statusBar(),
    body.join('\n  '),
    watermark(designH),
    tabBar(designH, activeTab),
  ].join('\n  ');
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" width="${W}" height="${H}" role="img" aria-label="${esc(label)}">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#f6f6fb"/><stop offset="1" stop-color="#eef0f8"/></linearGradient>
    <linearGradient id="hero" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="${C.brand}"/><stop offset="1" stop-color="${C.brand2}"/></linearGradient>
    <linearGradient id="warm" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#ff9d57"/><stop offset="1" stop-color="${C.accent}"/></linearGradient>
  </defs>
  <rect width="${W}" height="${H}" fill="url(#bg)"/>
  <g transform="translate(${offX.toFixed(2)} ${offY.toFixed(2)}) scale(${scale.toFixed(5)})">
  ${inner}
  </g>
</svg>
`;
}

/* ---- icon + feature graphic --------------------------------------------- */
function appIcon() {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="${C.brand}"/><stop offset="1" stop-color="${C.brand2}"/></linearGradient></defs>
  <rect width="512" height="512" rx="112" fill="url(#g)"/>
  <circle cx="356" cy="160" r="70" fill="${C.accent}"/>
  <path d="M120 360 L210 220 L300 320 L392 200" fill="none" stroke="#ffffff" stroke-width="34" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="256" y="452" text-anchor="middle" font-family="${FONT}" font-size="58" font-weight="800" fill="#ffffff" opacity="0.95">PF</text>
</svg>
`;
}

function featureGraphic() {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 500" width="1024" height="500">
  <defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#ffffff"/><stop offset="1" stop-color="#f1f1fb"/></linearGradient>
  <linearGradient id="ic" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="${C.brand}"/><stop offset="1" stop-color="${C.brand2}"/></linearGradient></defs>
  <rect width="1024" height="500" fill="url(#bg)"/>
  <rect x="0" y="0" width="1024" height="8" fill="${C.brand}"/>
  <text x="80" y="210" font-family="${FONT}" font-size="76" font-weight="800" fill="${C.ink}">PulseFit</text>
  <text x="82" y="280" font-family="${FONT}" font-size="40" font-weight="600" fill="${C.brand}">Habit &amp; workout coach</text>
  <text x="82" y="338" font-family="${FONT}" font-size="28" font-weight="500" fill="${C.mut}">Sample feature graphic · DEMO data</text>
  <g transform="translate(760,110)"><rect width="180" height="180" rx="40" fill="url(#ic)"/>
    <circle cx="125" cy="56" r="26" fill="${C.accent}"/>
    <path d="M42 126 L74 78 L106 112 L138 70" fill="none" stroke="#fff" stroke-width="13" stroke-linecap="round" stroke-linejoin="round"/></g>
</svg>
`;
}

/* ---- catalogue (must match listing.json) -------------------------------- */
const JOBS = [
  ['phone-01.svg', 'Today', 1080, 2400, 0],
  ['phone-02.svg', 'Workouts', 1080, 2400, 1],
  ['phone-03.svg', 'Live coaching', 1080, 2400, 2],
  ['phone-04.svg', 'Progress', 1080, 2400, 3],
  ['phone-05.svg', 'Challenges', 1080, 2400, 1],
  ['iphone-01.svg', 'Today', 1320, 2868, 0],
  ['iphone-02.svg', 'Workouts', 1320, 2868, 1],
  ['iphone-03.svg', 'Live coaching', 1320, 2868, 2],
  ['iphone-04.svg', 'Progress', 1320, 2868, 3],
  ['tablet-01.svg', 'Today', 1600, 2560, 0],
  ['tablet-02.svg', 'Live coaching', 1600, 2560, 2],
  ['tablet-03.svg', 'Progress', 1600, 2560, 3],
  ['ipad-01.svg', 'Today', 2064, 2752, 0],
  ['ipad-02.svg', 'Workouts', 2064, 2752, 1],
  ['ipad-03.svg', 'Progress', 2064, 2752, 3],
];

for (const [file, label, w, h, tab] of JOBS) {
  writeFileSync(join(OUT, file), screen(label, w, h, tab));
}
writeFileSync(join(OUT, 'app-icon.svg'), appIcon());
writeFileSync(join(OUT, 'feature-graphic.svg'), featureGraphic());

console.log(`Wrote ${JOBS.length} screenshots + app-icon.svg + feature-graphic.svg to ${OUT}`);
