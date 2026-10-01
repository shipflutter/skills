# Keyword research → keyword map

Goal: for each locale, decide which search terms each indexed field owns. Search volume numbers
from third-party tools are estimates; the stores' own autocomplete order is the most honest free
signal of what people type.

## 1. Seeds

Write 5–10 seeds from the app's **jobs**, not its features or brand:

- The job in the user's words: "track habits", "split bills", "remove background".
- The category noun: "habit tracker", "budget app", "photo editor".
- The outcome: "stop procrastinating", "save money".
- Competitor *category* words seen in top-10 titles (never their brand names).

## 2. Expand (free sources)

| Source | How | Signal |
|---|---|---|
| App Store autocomplete | `scripts/keyword_suggest.py SEED --store apple --az --country XX` | Order = popularity in that storefront |
| Google Play autocomplete | `scripts/keyword_suggest.py SEED --store play --az --country XX --lang LL` | Order = popularity in that country/language |
| App Store top 10 | `--competition` (iTunes Search API) | How many top apps target the term in their name; how strong they are |
| Competitor titles & subtitles | Read the top-10 listings for each head term | Words the category converged on |
| Your reviews and competitors' reviews | Mine 1–3★ and 5★ review text for nouns users use | Real vocabulary, feature gaps |
| Apple Ads keyword popularity (5–100) | Apple Ads account → Keyword recommendations / Search popularity | Apple's own volume index (free with an account) |
| Google Trends, Google Keyword Planner | trends.google.com, ads.google.com → Keyword Planner | Seasonality and web volume (proxy only) |
| Your own search-term reports | App Store Connect → Analytics → Sources; Play Console → Store analysis / Acquisition | The terms already bringing installs — protect them |

Long-tail matters: new apps rarely rank for 1–2 word head terms; 3–4 word phrases convert better
and are winnable.

## 3. Score

For each candidate term:

| Factor | Scale | How |
|---|---|---|
| **Relevance** | 0–3 | 3 = describes the core job; 0 = unrelated (never use, Guideline 2.3.7 / Play spam policy) |
| **Popularity** | 1–10 | 11 − best autocomplete position (both stores → take the better); or Apple Ads popularity ÷ 10 |
| **Openness** | 0–100 | `--competition`: weak apps (< 1k ratings) and missing title matches in the top 10 |

`priority = relevance × popularity × (openness / 100)`; drop every term with relevance < 2.

Sanity rules:

- A term only the giants hold (openness < 20) goes in a lower-weight field, not the title.
- A brand-new app should aim most title weight at mid-popularity, high-openness long-tail terms,
  then move up to head terms once it ranks.
- Terms the autocomplete returns as app names ("habit tracker: coolio habits") are brands — skip.

## 4. Assign (the keyword map)

| Field weight (high → low) | App Store | Google Play |
|---|---|---|
| 1 | Name (30) | Title (30) |
| 2 | Subtitle (30) | Short description (80) |
| 3 | Keyword field (100, hidden) | Full description (4000): repetition and placement count |
| 4 | In-app purchase display names | Reviews / developer name (minor) |

Rules:

- Highest-priority term goes in the name/title, as close to the start as reads naturally.
- No word appears twice across one App Store locale's name + subtitle + keywords: Apple combines
  words across the three fields, so each word only needs to be there once.
- App Store keyword field: single words, comma-separated, no spaces, singular *or* plural (not
  both), no "app", no category name, no competitor brands.
- Google Play: put the head term in the title, the 2–3 secondary terms in the short description,
  and repeat each target term naturally a few times across the full description (≈ 2–3% density
  at most; the first lines matter most).

Template (one per locale):

```markdown
## Keyword map — <locale> (<storefront / country>) — <date>

| Term | Relevance | Best pos (Apple/Play) | Openness | Priority | Field |
|---|---|---|---|---|---|
| habit tracker | 3 | 1 / 1 | 12 | 3.6 | name / title |
| routine planner | 3 | 3 / 5 | 55 | 13.2 | subtitle / short |
| streak | 2 | 6 / – | 60 | 6.0 | keywords / full description |

Name (30): …
Subtitle (30): …
Keywords (100): …
Play title (30): …
Play short (80): …
```

## 5. Re-run monthly

Rankings drift with competitors and seasons. Re-run the expansion for the head seeds each month,
compare positions, and swap out keyword-field words that brought no impressions in 4–6 weeks.
