# Other ASO tools an agent can use

Checked 2026-10-01. Star counts drift; re-check before depending on a small project.

## Agent skill packs

| Pack | What to take from it | Cost |
|---|---|---|
| [appeeky/aso-skills](https://github.com/appeeky/aso-skills) (`npx skills add eronred/aso-skills`, ~2k★, 40 skills) | `aso-audit` 0–100 rubric (title 20, subtitle 15, keyword field 15, screenshots 15, ratings 15, rankings 10, description 5 / 15 on Play, video 5, icon 5, conversion 5); keyword buckets primary / secondary / long-tail / aspirational; `review-management`, `seasonal-aso`, a shared `app-marketing-context.md` every skill reads | Free; data via Appeeky API (100 free credits / month) or the user |
| [alirezarezvani/claude-skills → app-store-optimization](https://github.com/alirezarezvani/claude-skills) | Stdlib Python scripts: keyword analyzer, ASO scorer, metadata optimizer, review analyzer, A/B test planner, localization helper, launch checklist | Free; volumes are typed in by the user |
| [TimBroddin/skills → app-store-aso](https://github.com/TimBroddin/skills) | Metadata limit validator, screenshot caption strategy, [krankie](https://github.com/TimBroddin/krankie) rank-tracker CLI | Free |
| [rshankras/claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills) | iOS-side keyword optimizer, screenshot planner, review-response writer, rejection handler | Free |
| [furkancingoz/aso-skill](https://github.com/furkancingoz/aso-skill) | Push metadata to App Store Connect; What's New from git commits | Free; ASC API key |
| `asc` — [App Store Connect CLI](https://github.com/rorkai/App-Store-Connect-CLI) (`brew install asc`, ~7k★) | Metadata sync per localization, readiness check for placeholder text; `asc install-skills` | Free; ASC API key (.p8) |

## MCP servers

| Server | Tools | Auth |
|---|---|---|
| [appreply-co/mcp-appstore](https://github.com/appreply-co/mcp-appstore) — best free one | Search, details, reviews, similar apps, version history, keyword scores (traffic / difficulty), keyword suggestions by category / competitors / seeds — both stores | None |
| [JiantaoFu/AppInsightMCP](https://github.com/JiantaoFu/AppInsightMCP) | Thin wrapper over app-store-scraper + google-play-scraper incl. `suggest`, data safety | None |
| [KenanAtmaca/aso-mcp](https://github.com/KenanAtmaca/aso-mcp) (young) | Keyword gap, rank tracking with SQLite history, ASO brief, ASC push | None for scraping |
| App Store Connect: [JoshuaRileyDev/app-store-connect-mcp-server](https://github.com/JoshuaRileyDev/app-store-connect-mcp-server) (stale since 2025-09), [TrialAndErrorAI/appstore-connect-mcp](https://github.com/TrialAndErrorAI/appstore-connect-mcp) | Edit version localizations, analytics reports | ASC API key |
| Paid data: [Appfigures CLI/MCP](https://github.com/appfigures/cli), [AppTweak MCP](https://developers.apptweak.com/reference/mcp), [Astro MCP](https://github.com/TimBroddin/astro-mcp-server), [Appeeky](https://docs.appeeky.com) | Real volume / difficulty estimates, tracked ranks, review replies | Paid plans, small free tiers |
| Google Play | No mature MCP — use fastlane `supply` or the Play Developer API | Service-account JSON |

## Free endpoints (no key)

| Data | Endpoint | Notes |
|---|---|---|
| App Store autocomplete | `GET https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints?clientApplication=Software&term=…` + header `X-Apple-Store-Front: <storefront id>-1,29` | Empty without the header; plist XML. Used by `keyword_suggest.py` |
| Google Play autocomplete | `POST https://play.google.com/_/PlayStoreUi/data/batchexecute?rpcids=IJ4APc&hl=<lang>&gl=<COUNTRY>` | Same call as google-play-scraper `suggest()`; the old `market.android.com/suggest` is gone |
| App Store search / lookup | `https://itunes.apple.com/search?entity=software&country=us&term=…`, `/lookup?id=…` | Name, description, rating count; no subtitle or keywords; ~20 calls / minute |
| App Store reviews | `https://itunes.apple.com/<cc>/rss/customerreviews/page=<1-10>/id=<APP_ID>/sortby=mostrecent/json` | 50 per page — feed for review mining |
| Libraries | [google-play-scraper](https://github.com/facundoolano/google-play-scraper) (Node, active), [app-store-scraper](https://github.com/facundoolano/app-store-scraper), [aso](https://github.com/facundoolano/aso) (scoring model, unmaintained), [google-play-scraper (Python)](https://github.com/JoMingyu/google-play-scraper) | Scrapers: endpoints can change without notice |

## Official APIs (credentials)

- **Apple Ads Platform API — Insights → Search term popularity** returns Apple's own
  `searchPopularity1to100` per country / genre / week:
  [docs](https://developer.apple.com/documentation/apple-ads-platform-api/insights-endpoints).
  The legitimate replacement for scraped popularity.
- **App Store Connect API**: `appInfoLocalizations` (name, subtitle), `appStoreVersionLocalizations`
  (description, keywords, promotional text, what's new); name / subtitle / keywords only change
  with a new editable version, promotional text any time. Analytics Reports API "App Store
  Discovery and Engagement" splits impressions by source (App Store Search, Browse…), not by keyword.
- **Google Play Developer API**: `edits.listings` (title, short, full description);
  `reviews.list` / `reviews.reply` cover ~the last 7 days. Search-term reports live in the Play
  Console UI (Store performance), not the API.
- **fastlane** `deliver` / `supply`: the simplest way to keep listings in git and diff them.

## Formulas worth reusing

- Relevance is a **gate**, not a weight: drop low-relevance terms first, then rank the rest.
- `Opportunity = 0.4·Popularity + 0.3·(100 − Difficulty) + 0.3·Relevance` (appeeky) or the classic
  `Relevance × Volume ÷ Difficulty`.
- Difficulty from free data (aso lib): how the top 10 titles match the term (exact / broad /
  partial), how many of the top 100 target it, the top 10's rating counts, average rating and
  days since update.
- Cheapest wins: terms where the app already ranks 11–50.
