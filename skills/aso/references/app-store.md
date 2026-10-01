# Apple App Store — fields, indexing, 2025–26 changes

State as of 2026-10-01. **[Apple]** = Apple's own docs; **[Vendor]** = ASO-industry observation;
**UNCONFIRMED** = not stated by Apple or contradicted by tests.

## Indexed fields

| Field | Limit | Indexed for App Store search | Notes |
|---|---|---|---|
| App name | 2–30 | ✅ highest weight [Apple] | Guideline 2.3.7: no prices, "#1", other apps' names |
| Subtitle | 30 | ✅ [Apple] | No unverifiable claims ("best", "#1") or other apps |
| Keyword field | 100 | ✅ hidden [Apple] | Apple's reference says "100 bytes"; App Store Connect counts **characters** (a ja field of 100 chars / 220 bytes was accepted, 2026-10-01) |
| Developer / company name | — | ✅ [Apple] | Never repeat it in keywords |
| Primary category | — | ✅ part of "text relevance" [Apple] | Secondary category: UNCONFIRMED |
| In-app purchase display name | 2–30 | Promoted IAPs appear in search [Apple]; names indexed [Vendor] | IAP description 45 |
| In-app event name | 30 | ✅ events are searchable [Apple] | Short description 50, long 120 |
| Promotional text | 170 | ❌ [Vendor consensus] | Editable without review — use it for news / offers |
| Description | 4000 | ❌ for App Store search; used for web search [Apple] | Write it for humans and Google |
| Screenshot captions | — | UNCONFIRMED (Appfigures 2025 claim; ConsultMyApp test of 64 phrases found "no strong evidence") | Treat as conversion copy; keyword in caption 1–2 costs nothing |
| What's New | 4000 | ❌ | Guideline 2.3.12: describe real changes |

Apple's ranking statement: text relevance (name, subtitle, keywords, primary category) + user
behavior ("downloads, ratings and reviews, and more").
<https://developer.apple.com/app-store/search/>

## Keyword field rules [Apple]

- Comma-separated, **no spaces after commas**. Multi-word phrases are allowed ("Real Estate") but
  Apple combines single words across name + subtitle + keyword field of the **same locale**, so
  single words cover more combinations.
- Don't repeat the app name, company name, or any word already in name/subtitle.
- Singular *or* plural, not both. No "app", "game", "free", "iPhone", category names, filler
  words, special characters.
- No trademarks, celebrity names, competitor app or company names (2.3.7, 5.2.1). Apple "may
  modify inappropriate keywords at any time".
- Words do **not** combine across locales: "bus" (en-US) + "metro" (es-MX) won't rank for
  "metro bus" [Vendor].

## Cross-localization (free keyword space)

Each storefront indexes its primary locale **plus** the extra locales in Apple's table
(<https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/>). Every
extra locale is another 30 + 30 + 100 characters for that storefront.

| Storefront | Indexed locales (primary first) |
|---|---|
| United States | en-US + es-MX, ar, zh-Hans, zh-Hant, fr-FR, ko, pt-BR, ru, vi |
| United Kingdom | en-GB (en-AU reported by AppTweak — UNCONFIRMED) |
| Canada | en-CA + fr-CA |
| Australia | en-AU + en-GB |
| Japan | ja + en-US |
| Mexico, Brazil, France, Germany, Italy, Netherlands, China, Korea | native + en-GB |
| Spain | es-ES + ca, en-GB |
| Switzerland | de-DE + en-GB, fr-FR, it |
| Belgium | en-GB + nl, fr-FR |
| Russia | ru + en-GB, uk |
| Singapore | en-GB + zh-Hans |
| Indonesia, Thailand, Türkiye, Vietnam | en-GB + local language |
| UAE, Saudi Arabia | en-GB + ar |
| India | en-GB + 11 Indic languages (10 added 2026-03-30) |

How to use it:

1. For your top storefront, list its indexed locales.
2. Give each one a **different** set of keyword-field words (English terms can go in es-MX or
   en-GB slots for the US / other storefronts). Never repeat a word across locales of one
   storefront — it adds nothing.
3. Keep each locale a genuine listing: real users in that language (e.g. es-MX also serves
   Mexico and Latin America) see its name and subtitle.
4. Weight of a secondary locale vs the primary: UNCONFIRMED — put the most important terms in the
   primary locale.

## 2025–26 changes

| When | Change | What to do |
|---|---|---|
| Apr 2025 | Apple Search Ads renamed **Apple Ads** | — |
| Spring 2025 (iOS 18.4) | **AI review summaries**; now US + AU, CA, IN, IE, NZ, SG, ZA, UK | Can't edit; can report a concern. Prompt satisfied users to review; fix what 1–2★ reviews say |
| 2025 | **Accessibility Nutrition Labels** (voluntary, per device; Apple says required eventually) | Declare what you support |
| Jun–Jul 2025 (WWDC25, iOS 26) | **App tags**: LLM-generated from metadata, human-reviewed, **US storefront, en-US metadata only** | App Store Connect → App Information → tags: deselect wrong ones (can't add). Make en-US description state the core use cases plainly so the right tags are generated |
| Jul 2025 | **Keywords on custom product pages (CPPs)** → CPPs appear in organic search | Assign keywords per CPP from the approved keyword field (no extra keyword space); one intent per CPP |
| Jul 24, 2025 | **Age ratings 4+ / 9+ / 13+ / 16+ / 18+**; new questions required by Jan 31, 2026 | Answer them or updates are blocked |
| Oct 29, 2025 | CPP limit **35 → 70** | — |
| Mar 2026 | **Up to 2 ads per search** in all markets | Organic slot 1 sits lower: conversion of the first screenshot matters more |
| Apr 28, 2026 | Builds must use the **Xcode 26 SDK**; iOS 26 **Liquid Glass icons** (Icon Composer `.icon`) | Ship a layered icon, test light / dark / tinted / clear |
| Sep 2026 | Social-media capability declaration (forces ≥ 13+); iPhone 18 Pro / Duo screenshot specs | — |
| WWDC26, "this fall" | **Asset Library** (creatives reviewed apart from builds), product page **header** and **search result** creative assets, page preview tool, Personalized Collections | Plan a search-result creative per priority keyword intent when it ships |

## Search-related numbers

- "Almost 65% of downloads happen directly after a search." [Apple Ads]
- Apple Ads Search Popularity: 1–5 in the UI, 5–100 via the Insights API. US values collapsed
  77% in four days (Sep 29, 2025) [Vendor] — use as a relative signal only.

## Screenshots, previews, icon [Apple]

- iPhone 6.9" required: 1320×2868, 1290×2796 or 1260×2736 (6.5" 1284×2778 only if no 6.9"). iPad
  13" required if the app runs on iPad: 2064×2752 or 2048×2732. 1–10 per device, no alpha.
- App previews: up to 3 per device, 15–30 s, screen captures of the app only (2.3.4).
- Product page optimization: up to 3 treatments, 90 days max, one test at a time; tests icon,
  screenshots, previews. Alternate icons must be in the binary.

Specs: <https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/>

## Metadata rejections to avoid (App Review Guidelines)

| Guideline | Rule |
|---|---|
| 2.3.1 | No misleading marketing or false price |
| 2.3.3 | Screenshots show the app in use — not only title art, login or splash |
| 2.3.4 | Previews: screen captures of the app only |
| 2.3.5 | Right category (Apple may change it) |
| 2.3.7 | Name ≤ 30; no prices, "Free", "50% off", "#1", "best", other apps' names, irrelevant phrases "to game the system" in name / subtitle / screenshots / keywords |
| 2.3.8 | Metadata suitable for 4+; "For Kids" / "For Children" reserved for the Kids category |
| 2.3.10 | No other platforms' names or imagery (Android, Google Play) |
| 2.3.12 | What's New describes significant changes |
| 5.2.1 / 5.2.5 | No third-party IP; no Apple trademarks used confusingly (iPhone, Siri…) in name / icon |

<https://developer.apple.com/app-store/review/guidelines/>

## Where to measure

- App Store Connect → Analytics → Acquisition / Sources: **App Store Search** impressions,
  product page views, downloads, conversion rate; per CPP since 2025.
- Search terms per keyword: only through Apple Ads (search-term report) or third-party rank
  trackers — App Store Connect doesn't list organic keywords.
- App Store Connect API Analytics Reports "App Store Discovery and Engagement": impressions by
  source, not by keyword.
