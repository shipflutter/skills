# Ready-to-paste ASO prompts

Each prompt works with the `aso` skill installed, or on its own: an agent without the skill can
fetch the checklist from
`https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/ASO-CHECKLIST.md`.

## Audit only (no edits)

```text
Use the aso skill. Audit the store listing in fastlane/metadata for every locale on both stores:
run scripts/aso_check.py, then walk ASO-CHECKLIST.md for what the script can't judge.
Report a table (locale × field, count/limit + ✅/⚠️/❌), every issue with file path, rule and a
rewrite that fits the limit, and a score. Do not edit any file. Write the report in English.
```

## Audit and fix

```text
Use the aso skill. Audit fastlane/metadata (both stores, all locales), then rewrite the files that
fail, keeping each locale's language and the brand name. Re-run scripts/aso_check.py until it
reports 0 errors and list any warning you kept on purpose with the reason. Never upload.
```

## Keyword research for one market

```text
Use the aso skill, branch 2. My app: <one-line description>. Market: <country>, language <lang>.
Seeds: <3–5 seed terms>. Run scripts/keyword_suggest.py with --az and --competition, add the
competitors' titles from the top 10, and build the keyword map from references/keyword-research.md:
head terms for the name/title, secondary terms for subtitle/short description, and a 100-character
App Store keyword field. Show the scoring table and why each term won its slot.
```

## Localize a listing into a new market

```text
Use the aso skill, branch 3. Create fastlane/metadata for <locale> on <App Store / Google Play /
both> from the en-US listing. Do keyword research in that market first (local autocomplete,
local competitor titles) — do not translate English keywords. Fill every indexed field to ≥ 90%
of its limit, then run scripts/aso_check.py and fix every error.
```

## App Store cross-localization plan

```text
Use the aso skill. For the <storefront> App Store, list the locales Apple indexes there
(references/app-store.md). Give each indexed locale a different keyword field so no word repeats
across them, and show the combined keyword coverage for that storefront.
```

## Screenshot captions and order

```text
Use the aso skill, branch 4. From the keyword map and the app's top 5 user jobs, write captions
for 6–8 screenshots per platform: ≤ 5 words, one benefit each, the strongest job first, head
keyword in captions 1–2. Output a table: order, caption, what the screen shows, why.
```

## Design one A/B test

```text
Use the aso skill, branch 4. Propose one store listing experiment (Google Play store listing
experiment or App Store product page optimization): single variable, hypothesis, variants,
audience share, minimum run time and the success metric. Pick the variable with the largest
expected conversion lift for this app and explain why.
```

## Monthly ASO review

```text
Use the aso skill, branch 5. Read the change log in docs/aso-log.md (create it if missing) and
these numbers: <App Store Search impressions / downloads, Play search acquisitions, top search
terms>. Say what moved since the last change, what to keep, and the next single change to make,
with the date to check it.
```
