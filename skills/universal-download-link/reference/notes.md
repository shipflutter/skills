# Universal download link — implementation notes

## The two halves
1. **`/get/` page** (`templates/get-index.html`) — the brain. UA detection + `location.replace`
   in `<head>`, plus a desktop chooser. This is the single source of truth for "where do installs go".
2. **The QR** (`scripts/gen-qr.py`) — just an image that encodes the `/get/` URL. It carries **no**
   logic; the page it points to does the per-device routing. So one printed QR serves both stores.

Keep them in sync: the QR must encode the **same** `__GET_URL__` the page is hosted at.

## Why `location.replace` in `<head>`
- In `<head>`, before the body paints → no chooser flash for phone users.
- `replace()` (not `location.href =`) does not push a history entry, so the browser Back button
  returns to wherever the user came from instead of bouncing back into the redirector.

## iPadOS detection gotcha
Modern iPads report a desktop-Safari UA. The `navigator.platform === "MacIntel" &&
navigator.maxTouchPoints > 1` check catches them as iOS. Keep it.

## In-app browsers / webviews
Facebook/Instagram/TikTok in-app browsers sometimes block `location.replace` to an app-store
scheme or show the page instead of redirecting. The desktop chooser is the safety net: the two
store buttons are always present, so a blocked redirect degrades to a manual tap.

## Deploy checklist
- [ ] `/get/index.html` is reachable at `__GET_URL__`.
- [ ] The QR on your landing/download page encodes exactly `__GET_URL__`.
- [ ] `/get/` is `noindex,follow` and **excluded** from `sitemap.xml`.
- [ ] Canonical on `/get/` points at itself.
- [ ] Deploy copies the new `get/` folder (whole-tree `cp -R` does; a file allowlist must add it).
- [ ] (optional) App banner / social bios / posters all point at `__GET_URL__` for one funnel.

## Testing
- Desktop: open `__GET_URL__?stay=1` → see the chooser (both store buttons).
- Mobile: open `__GET_URL__` on a phone → should land in the store immediately.
- Force a platform without a device: most browsers' devtools let you override the User-Agent;
  the chooser also lets you eyeball both links via `?stay=1`.

## Verifying the QR really encodes the URL
`gen-qr.py` asserts the emitted SVG path set equals the encoded QR matrix, so it cannot drift from
the URL. To double-check by eye, scan the produced SVG with any phone camera — it should open the
chooser (or redirect) for `__GET_URL__`.
