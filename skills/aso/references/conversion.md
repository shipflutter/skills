# Conversion — icon, screenshots, video, custom pages, experiments, ratings

Rankings bring impressions; the listing turns them into installs, and installs per impression
feed rankings back on both stores. Store specs: [`app-store.md`](app-store.md),
[`google-play.md`](google-play.md).

## What people actually see

- **Search results:** icon, name / title, rating, and (App Store) the first 1–3 portrait
  screenshots or the preview video; (Play) icon, title, rating, sometimes a screenshot strip.
  Most decisions happen here, before the product page.
- **Product page above the fold:** icon, name, subtitle / short description, rating count,
  screenshots 1–3. Few people read the description.
- Since March 2026 up to two Apple Ads sit above organic results, so the first organic screenshot
  works harder.

## Icon

- One shape, one or two colours, no words. Readable at 40 px on light and dark backgrounds.
- Distinct from the top-10 icons for your head keyword — put them side by side and squint.
- iOS 26: ship a layered Liquid Glass icon (Icon Composer); check light, dark, tinted and clear.
- Play: no badges, "free", ranks or fake notification dots (policy).
- First thing to A/B test: it shows on every surface.

## Screenshots

Order and copy:

1. **Screenshot 1 = the main job** in the user's words + the head keyword. It must work alone.
2. Screenshots 2–3: the next two reasons to install (features users search for).
3. Then proof (ratings, press, numbers you can verify), then secondary features.
4. **Captions ≤ 5 words, one benefit each**, large type; the screen must show that benefit.
5. Real app UI only (App Store 2.3.3; Play: tagline ≤ 20% of the image, no "Download now", "#1",
   "Best").
6. Localize captions **and** UI screenshots for every priority locale; right-to-left layouts for
   ar / he.
7. Panoramic or connected sets are fine, but each frame must still read on its own.
8. Dark-mode variants are worth a test for dev / productivity / night-use apps.

Counts: App Store 1–10 per device (use all 10 in priority locales); Play 2–8 phone, ≥ 4 at
≥ 1080 px to be eligible for featuring, plus tablet / Chromebook / Wear sets if supported
(shown per form factor).

## Video

- App Store previews: up to 3 per device, 15–30 s, screen capture only; it autoplays muted in
  search results and replaces the first screenshot there — make the first 3 s show the main job,
  readable without sound.
- Play: YouTube, first 30 s autoplay; portrait performed slightly better in 2025 tests (Phiture).
- A weak video converts worse than a strong screenshot 1 — test it, don't assume.

## Custom pages per intent

| | App Store custom product pages (CPP) | Google Play custom store listings (CSL) |
|---|---|---|
| Max | 70 | 50 |
| Organic search | Yes, keyword-assigned since Jul 2025 (keywords from the approved keyword field) | Yes, search-keyword targeting since 2024 |
| Can change | Screenshots, previews, promotional text | Name, icon, short / full description, graphics |
| Other uses | Apple Ads ad variants, deep links, per-CPP analytics | Country, churned / lapsed users, ads, URL parameter |

Recipe: for each high-value keyword intent ("budget planner" vs "split bills"), one page whose
first screenshot and caption answer exactly that search.

## Experiments

| | App Store product page optimization | Google Play store listing experiments |
|---|---|---|
| Variants | up to 3 + original | up to 2 + original (check console) |
| Run | ≤ 90 days, one test at a time | 1 default-graphics or ≤ 5 localized at once; auto-stop at 6 months |
| Tests | Icon (must be in the binary), screenshots, previews | Icon, feature graphic, screenshots, descriptions (localized only); **not the title or video** |

Rules for a valid test:

- One variable per test, one hypothesis: "Screenshot 1 showing X instead of Y will raise
  conversion because Z".
- Run at least 7 days (full weekly cycle), until the console reports confidence; don't stop on the
  first good day.
- Biggest expected lift first: icon → screenshot 1 → caption copy → order → video.
- Log the result (win / lose / flat) with dates; a flat result is still knowledge.

## Ratings and reviews

- Ask with the native prompt (`SKStoreReviewController` / `requestReview` on iOS — max 3 per
  year; Play In-App Review API) **after a success moment** (task done, streak hit), never at
  launch, after an error, or behind a gate. Never incentivize ratings (both stores ban it).
- Target ≥ 4.0 (≥ 4.5 for competitive categories); Play weights recent ratings, per country and
  per form factor.
- Reply to 1–3★ reviews within a few days, specifically, and say when a fix ships — the reviewer
  can change the rating. Mine reviews for keywords and missing features.
- Both stores now show **AI review summaries**: recurring complaints become a headline. Fix the
  top complaint before buying traffic.
- iOS: reset the rating summary with a major update only if the old ratings are hurting you.

## Quality signals that hurt conversion

- Play: Android vitals over the bad-behavior threshold → warning on the listing + lower
  visibility (crash 1.09%, ANR 0.47%, wake locks 5%).
- Download size, missing privacy / data-safety answers, stale "Updated" date (> 3 months), and
  rating counts that look small next to competitors.
