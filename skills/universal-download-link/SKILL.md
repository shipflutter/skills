---
name: universal-download-link
description: Add one shared "get the app" link + matching QR code that auto-detects the visitor's OS and forwards to the correct store (App Store on iOS, Google Play on Android; desktop sees a chooser). Use when a website, marketing page, business card, poster, or in-app share flow needs a single URL / single QR for both platforms instead of two separate store links.
---

# Universal Download Link

One URL — e.g. `https://example.com/get/` — and one QR code that work for **both** platforms. When
opened or scanned, a tiny `<head>` script detects the OS and `location.replace()`s to the right
store before the page paints; desktop/unknown visitors get a clean chooser with both buttons.

You print/share **one** QR; the destination decides per device.

## What this skill produces
1. `templates/get-index.html` — the universal redirect + desktop-chooser page (host at `/get/`).
2. `scripts/gen-qr.py` — generates a crisp single-`<path>` SVG QR encoding your `/get/` URL.
3. `templates/download-redirect.js` — optional: turn an existing informational `/download/` page
   into a soft auto-redirect (1.2s delay + "stay on page" escape hatch) without replacing it.

## Placeholders to replace

| Placeholder | Meaning | Example |
|---|---|---|
| `__APP_NAME__` | App display name | `Go Brain` |
| `__APP_TAGLINE__` | One-line promo | `Brain puzzles — free & offline` |
| `__APP_ICON__` | Icon path/URL | `../assets/app-icon.png` |
| `__IOS_URL__` | App Store URL | `https://apps.apple.com/app/id6782550523` |
| `__ANDROID_URL__` | Google Play URL | `https://play.google.com/store/apps/details?id=com.example.app` |
| `__GET_URL__` | Canonical universal URL | `https://example.com/get/` |
| `__PLAY_BROWSER_URL__` | Optional "play in browser" link (omit if none) | `../play/` |

## Quick start
```bash
# 1. Host the redirect page at /get/
mkdir -p <site>/get
cp templates/get-index.html <site>/get/index.html
# replace the __PLACEHOLDERS__ inside it

# 2. Generate the QR for the SAME url and drop it where you want it scanned
python3 scripts/gen-qr.py "https://example.com/get/" > qr-get.svg
#   …then paste the <svg> into your download/landing page (right-hand side reads well).

# 3. (optional) soft-redirect an existing /download/ page instead of /get/
cp templates/download-redirect.js <site>/js/download-redirect.js
#   <script src="js/download-redirect.js"></script>
```

## How the redirect works
```js
var ua = navigator.userAgent;
var isAndroid = /Android/i.test(ua);
var isIOS = /iPad|iPhone|iPod/i.test(ua) ||
  (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1); // iPadOS reports as Mac
if (isAndroid) location.replace(ANDROID_URL);
else if (isIOS) location.replace(IOS_URL);
// else: desktop — render the chooser below.
```
- Runs in `<head>`, **before paint**, so phone visitors never see the chooser flash.
- `location.replace` (not `href`) keeps the interstitial out of history → Back won't trap.
- `?stay=1` or `?noredirect` skips the redirect (for QA / forcing the chooser).

## QR generator notes
`scripts/gen-qr.py` (needs `pip install qrcode`) emits a single-path SVG matching the URL exactly —
it verifies the path set equals the encoded matrix, so the SVG is provably the right code. Flags:
```
python3 scripts/gen-qr.py "<url>" [out.svg] [--ecc M|L|Q|H]
```
The viewBox is `-2 -2 (n+4) (n+4)` (n = module count) with a built-in 2-module quiet zone, so it
drops into a fixed-size box (`.qr svg { width:160px }`) cleanly. White `<rect>` background + black
`<path>` — invert colors only if you keep enough contrast (dark modules on light is safest to scan).

## Deploy / SEO
- Mark `/get/` as `noindex,follow` (it's a utility redirect, not an SEO landing page) and keep it
  **out of** `sitemap.xml`.
- Point the canonical at the `/get/` URL itself.
- Make sure your deploy copies the new `get/` folder (a whole-tree `cp -R` does; a file allowlist
  won't — add it).
- Reuse `__GET_URL__` everywhere you'd otherwise hardcode two store links (app banner, socials,
  posters) so all install traffic flows through one measurable link.

See `examples/demo.html` for an interactive, dependency-free showcase (platform simulator + live
detection + the QR) you can hand to stakeholders.
