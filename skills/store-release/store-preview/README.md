# Store Listing Preview Tool

A single-file, JSON-driven mockup of how an app looks on the **Apple App Store**
and **Google Play** store pages — review listing copy, screenshots and graphics
before you submit. Ships with **dummy demo data** ("PulseFit") so it runs as-is.

## Run

```bash
cd store-preview
python3 -m http.server 8092
# open http://localhost:8092/
```
(Browsers block `fetch()` over `file://`, so serve it over http.)

## Features

- **App Store / Google Play** layout toggle, locale switcher.
- **ASO checks** — live per-field character-limit counters per store.
- **✏️ Edit on page** — click any rendered text (name, subtitle, description,
  keywords, what's new, title, short description, developer, rating…) to edit it
  inline; edits write back to the data and ASO counters update live. Each
  screenshot gets replace/remove/add controls; app icon + feature graphic are
  click-to-replace.
- **🖼️ Drag & drop images** — drop image files or a whole folder anywhere (or
  *Load images…*); auto-sorted into iPhone / iPad / phone / tablet galleries,
  app icon and feature graphic by filename + aspect ratio.
- **Edit JSON** — edit the raw listing JSON and apply.
- **⬇️ Export data** — download the current `listing.json` (including inline edits).
- **✅ Release checklist** — built-in interactive first-submission checklist
  (mirrors `../references/submission-checklist.md`); progress saved in the browser.

## Use with your own app

1. Click **Load JSON…** and open your own `listing.json` (same shape as the
   bundled one), or edit the demo inline.
2. Drag your screenshots (or their folder) onto the page to fill the galleries.
3. Tweak copy with **Edit on page** / **Edit JSON**, watch **ASO checks**, then
   **Export data**.

## `listing.json` shape

```jsonc
{
  "app":   { "name", "androidPackage", "iosBundleId", "versionName", "icon", "developer", "rating", "downloads", "locales": [...], ... },
  "limits": { "appstore": {...}, "googleplay": {...} },     // ASO character limits
  "locales": { "en-US": { "displayName", "appstore": {...}, "googleplay": {...}, "fullDescription", "whatsNew" }, ... },
  "screenshots": { "iphone": [{file,label,size}], "ipad": [...], "phone": [...], "tablet": [...] },
  "graphics": { "appIcon": {status,file,spec}, "featureGraphic": {status,file,spec} }
}
```

> Live reference deployment: https://fighttechvn.github.io/mobilestore/
