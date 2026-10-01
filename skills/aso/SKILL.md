---
name: aso
description: App Store Optimization for the Apple App Store and Google Play — audit a store listing, research and prioritize keywords, rewrite and localize metadata within the character limits, plan screenshots / icon / A-B tests, and measure search results. Use when the user mentions ASO, store search ranking, keywords, app title/subtitle/short description, store listing copy, localizing a listing, store screenshots or listing experiments, or fastlane metadata (deliver / supply).
---

# ASO — rank in store search, then convert

ASO is two loops: **be found** (indexed text → rankings for the right keywords) and **be
chosen** (icon, screenshots, ratings → conversion rate, which feeds rankings back). Every run
works on a **keyword map**: one row per locale × field saying which terms that field owns.

The single source of truth for *what good looks like* is
[`ASO-CHECKLIST.md`](ASO-CHECKLIST.md). Read it before changing any listing. Translations in 12 languages
live in [`i18n/`](i18n/), with the same item IDs; the English file is the reference.

## Branches

Pick the branch the user asked for; a full optimization runs 1 → 5 in order.

### 1. Audit (always first)

1. Locate the listing text. fastlane: `fastlane/metadata/ios/<locale>/` (or
   `fastlane/metadata/<locale>/`) and `fastlane/metadata/android/<locale>/`. No fastlane? Ask for
   the console text, or pull it: `fastlane deliver download_metadata` / `fastlane supply init`.
2. Run the deterministic checks — never estimate character counts:
   ```bash
   python3 <skill>/scripts/aso_check.py --root .          # markdown report, exit 1 on errors
   python3 <skill>/scripts/aso_check.py --format json     # for further processing
   ```
3. Walk the rest of `ASO-CHECKLIST.md` by hand for what a script can't judge (relevance, local
   wording, screenshots, ratings, vitals).

**Done when** every locale has a row with `count/limit` per field and every ❌/⚠️ has a file path,
the rule broken and a concrete rewrite that fits the limit.

### 2. Keyword research → keyword map

Follow [`references/keyword-research.md`](references/keyword-research.md). Seed from the app's
core jobs, expand with the stores' own autocomplete, score, then assign:

```bash
python3 <skill>/scripts/keyword_suggest.py "habit tracker" --az --country us
python3 <skill>/scripts/keyword_suggest.py "habit tracker" --store apple --competition
python3 <skill>/scripts/keyword_suggest.py "quản lý chi tiêu" --country vn --lang vi
```

**Done when** each target locale has a keyword map: 1–2 head terms for the name/title, 3–6
secondary terms for subtitle / short description, and (App Store) a 100-character keyword field
of single, non-repeated words — each term with its autocomplete position and openness.

### 3. Write & localize metadata

Rules per store: [`references/app-store.md`](references/app-store.md) and
[`references/google-play.md`](references/google-play.md). Write each locale for its market
(local search terms, not a translation of English keywords). On the App Store, use
cross-localization: the extra locales a storefront indexes are free keyword space.

**Done when** `aso_check.py` reports 0 errors and the only warnings left are deliberate
(write the reason next to each).

### 4. Creatives & experiments

Icon, screenshots, video, custom product pages / custom store listings and A/B tests:
[`references/conversion.md`](references/conversion.md).

**Done when** the first 3 screenshots of each priority locale state one benefit each in ≤ 5
words of caption, and one experiment (single variable, hypothesis, success metric) is written up.

### 5. Measure & iterate

Change one field group at a time, wait 2–4 weeks, compare search impressions / downloads per
keyword (App Store Connect → Analytics → Sources: App Store Search; Play Console → Store
analysis / Acquisition by search term). Log every change with its date.

**Done when** the change log has the date, the fields changed, the before/after text and the
metric to read on the follow-up date.

## Guardrails

- Never upload to App Store Connect or Google Play, or submit for review, unless the user asks
  in this conversation. Editing local fastlane files is fine.
- No competitor brand names or trademarks in any indexed field; no fake claims, ratings or
  reviews.
- Keep the user's brand name and core positioning; propose, don't silently rename the app.

## Files

| File | Use |
|---|---|
| [`ASO-CHECKLIST.md`](ASO-CHECKLIST.md) | The full checklist (also the public link to hand any agent). |
| [`i18n/ASO-CHECKLIST.<lang>.md`](i18n/) | The checklist in vi, ja, ko, zh-Hans, zh-Hant, ar, fr, es, tr, id, th, hi (same IDs). |
| `scripts/aso_check.py` | Limits + policy audit over fastlane metadata, both stores, every locale. |
| `scripts/keyword_suggest.py` | App Store + Google Play autocomplete, a–z long-tail, App Store top-10 openness. |
| [`references/keyword-research.md`](references/keyword-research.md) | Sources, scoring, keyword-map template. |
| [`references/app-store.md`](references/app-store.md) | Apple fields, indexing, cross-localization, 2025–26 changes. |
| [`references/google-play.md`](references/google-play.md) | Play fields, metadata policy, ranking signals, 2025–26 changes. |
| [`references/conversion.md`](references/conversion.md) | Icon, screenshots, video, CPP / CSL, A/B tests, ratings. |
| [`references/tools.md`](references/tools.md) | Other agent skills, MCP servers and free APIs for ASO. |
| [`references/prompts.md`](references/prompts.md) | Ready-to-paste prompts for each branch. |
