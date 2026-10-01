# ASO Checklist — Apple App Store & Google Play

App Store Optimization checklist for app makers and AI agents. Updated **2026-10-01**.
Part of the [`aso` skill](https://github.com/shipflutter/skills/tree/develop/skills/aso) by
[ShipFlutter](https://shipflutter.app) · MIT.

- View: <https://github.com/shipflutter/skills/blob/develop/skills/aso/ASO-CHECKLIST.md>
- Raw (for agents): <https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/ASO-CHECKLIST.md>
- Install the full skill: `npx skills add shipflutter/skills --skill aso`
- Translations (same item IDs; this English file is the reference):
  [Tiếng Việt](i18n/ASO-CHECKLIST.vi.md) ·
  [日本語](i18n/ASO-CHECKLIST.ja.md) ·
  [한국어](i18n/ASO-CHECKLIST.ko.md) ·
  [简体中文](i18n/ASO-CHECKLIST.zh-Hans.md) ·
  [繁體中文](i18n/ASO-CHECKLIST.zh-Hant.md) ·
  [العربية](i18n/ASO-CHECKLIST.ar.md) ·
  [Français](i18n/ASO-CHECKLIST.fr.md) ·
  [Español](i18n/ASO-CHECKLIST.es.md) ·
  [Türkçe](i18n/ASO-CHECKLIST.tr.md) ·
  [Bahasa Indonesia](i18n/ASO-CHECKLIST.id.md) ·
  [ไทย](i18n/ASO-CHECKLIST.th.md) ·
  [हिन्दी](i18n/ASO-CHECKLIST.hi.md)

---

## If you are an AI agent, read this first

1. **Default mode is audit.** Read the listing, mark every item below, report. Only edit files
   when the user asked for fixes. **Never upload to App Store Connect / Play Console or submit
   for review** unless the user asked in this conversation.
2. **Find the listing.** fastlane: `fastlane/metadata/ios/<locale>/*.txt` (or
   `fastlane/metadata/<locale>/`) and `fastlane/metadata/android/<locale>/*.txt`. Otherwise ask
   the user to paste name / subtitle / keywords / description per locale, or the Play title /
   short / full description.
3. **Count with code, never by eye.** Items marked **(auto)** are checked by the free script:
   ```bash
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/aso_check.py
   python3 aso_check.py --root .            # markdown report; exit 1 on errors
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/keyword_suggest.py
   python3 keyword_suggest.py "habit tracker" --az --country us --competition
   ```
   (Python 3.10+, standard library only, no API keys.)
4. **Mark each item** `✅ pass` / `⚠️ improve` / `❌ fail` / `N/A`, with evidence (file, count, quote).
   Every ⚠️/❌ needs a concrete fix that fits the limit. Use the report template at the end.
5. **Don't invent data.** No search volumes, rankings or ratings you didn't measure. Say "not
   measured" instead. Facts marked UNCONFIRMED below are vendor observations, not store rules.

---

## Limits at a glance

| Store | Field | Limit | Indexed for search |
|---|---|---|---|
| App Store | App name | 30 | ✅ strongest |
| App Store | Subtitle | 30 | ✅ |
| App Store | Keyword field (hidden) | 100 | ✅ |
| App Store | Promotional text | 170 | ❌ (editable without review) |
| App Store | Description | 4000 | ❌ for App Store search |
| App Store | What's New | 4000 | ❌ |
| App Store | In-app event name / short / long | 30 / 50 / 120 | ✅ event name |
| App Store | IAP display name / description | 30 / 45 | ✅ promoted IAPs |
| Google Play | Title | 30 | ✅ strongest |
| Google Play | Short description | 80 | ✅ |
| Google Play | Full description | 4000 | ✅ (no hidden keyword field) |
| Google Play | What's new | 500 | ❌ |

Apple's docs call the keyword field "100 bytes", but App Store Connect counts characters
(a 100-character / 220-byte Japanese field was accepted on 2026-10-01).

---

## 0. Before you start

- [ ] **PRE-01** Write the app's 3 core **jobs** in users' words ("split bills with friends"), its audience and its top 5 competitors.
- [ ] **PRE-02** Pick priority markets: storefront / country + language, ranked by current installs or target users.
- [ ] **PRE-03** Listing lives in version control (fastlane `deliver` / `supply` metadata), so every change is diffable.
- [ ] **PRE-04** Baseline recorded **before** any change: search impressions, product page views, conversion rate, downloads per source, rating and count, per priority country (see section 10).
- [ ] **PRE-05** A change log exists (e.g. `docs/aso-log.md`): date, fields changed, before → after, metric to check, follow-up date.

## 1. Keyword research

- [ ] **KW-01** 5–10 seeds from the jobs and category nouns — not the brand, not features only.
- [ ] **KW-02** Expanded with each store's own **autocomplete**, per market and language (a–z long-tail). Order of suggestions = popularity signal.
- [ ] **KW-03** Top-10 competitor titles / subtitles read for each head term; their shared words noted. Never use their brand names.
- [ ] **KW-04** Own and competitor **reviews** mined for the nouns and verbs users use.
- [ ] **KW-05** Each candidate scored: relevance (0–3, drop < 2), popularity (autocomplete position or Apple Ads popularity), openness / difficulty (how many top-10 apps target it, how strong they are).
- [ ] **KW-06** New or small apps target winnable long-tail (3–4 words, mid popularity, high openness) before head terms.
- [ ] **KW-07** A **keyword map** per locale: which terms the name / title, subtitle / short description and keyword field / full description own. No term without a slot, no slot without a term.
- [ ] **KW-08** Terms already ranking 11–50 identified — the cheapest wins.
- [ ] **KW-09** Research is redone **per market** — keywords are researched in the local language, not translated from English.

## 2. App Store metadata (per locale)

- [ ] **AS-01** (auto) Name ≤ 30, subtitle ≤ 30, keyword field ≤ 100, promotional text ≤ 170, description ≤ 4000.
- [ ] **AS-02** (auto) Name, subtitle and keyword field each ≥ 90% full — empty characters are lost ranking.
- [ ] **AS-03** Name = brand + the highest-priority term, reading naturally ("Brand: Habit Tracker").
- [ ] **AS-04** (auto) Subtitle adds **new** words — none repeated from the name.
- [ ] **AS-05** (auto) Keyword field: commas, **no spaces after commas**, no trailing comma.
- [ ] **AS-06** (auto) Keyword field has no word already in the name or subtitle, and no duplicates.
- [ ] **AS-07** (auto) Singular **or** plural, not both.
- [ ] **AS-08** (auto) No wasted words: "app", "apps", "free", "iPhone", "iPad", "iOS", "Apple", the brand / company name; (manual) the category name.
- [ ] **AS-09** (auto, warning) Prefer single words over phrases — Apple combines words across name + subtitle + keyword field of the same locale.
- [ ] **AS-10** No competitor names, trademarks or celebrity names anywhere (Guidelines 2.3.7, 5.2.1).
- [ ] **AS-11** (auto) No price / ranking / call-to-action words in name, subtitle, keywords: "free", "best", "#1", "sale", "% off" (2.3.7), in any language.
- [ ] **AS-12** (auto) No emoji; no Apple trademarks used as if part of your name (iPhone, Siri…).
- [ ] **AS-13** **Primary category** is the most relevant one (it's part of text relevance); secondary set.
- [ ] **AS-14** Description: first 3 lines state the main job and the proof; scannable bullets; not used for keywords (not indexed for App Store search) but read by Google web search and Apple's tag generator.
- [ ] **AS-15** Promotional text used for current news / offers (changeable without review).
- [ ] **AS-16** (auto) Privacy policy URL and support URL are https; (manual) both load.
- [ ] **AS-17** In-app purchase display names describe what the user gets with a search term where natural ("Pro Habit Tracker").
- [ ] **AS-18** In-app events (if any): keyword in the 30-character event name; up to 10 published at once.
- [ ] **AS-19** **App tags** (US storefront, en-US metadata): reviewed in App Store Connect; wrong tags deselected (you can't add tags — make the en-US description state use cases plainly).
- [ ] **AS-20** Age-rating questionnaire answered under the 2025 tiers (4+ / 9+ / 13+ / 16+ / 18+).

## 3. Google Play metadata (per locale)

- [ ] **GP-01** (auto) Title ≤ 30, short description ≤ 80, full description ≤ 4000, What's new ≤ 500.
- [ ] **GP-02** (auto) Title and short description ≥ 90% full.
- [ ] **GP-03** Title = brand + head term; short description = one real sentence with 2–3 secondary terms and the main benefit.
- [ ] **GP-04** (auto) Title keywords appear in the full description, and within its first ~300 characters.
- [ ] **GP-05** Each target term appears 2–3 times naturally in the full description; related terms and synonyms used; no keyword lists.
- [ ] **GP-06** (auto) No word above ~3% density (keyword stuffing is a policy violation).
- [ ] **GP-07** (auto) Title / short description / developer name: no emoji, no repeated special characters (`!!!`, `★★`), no ALL CAPS (unless the brand).
- [ ] **GP-08** (auto) No "Free", "#1", "Best", "Top", "Popular", "New", "Editor's choice", "No ads", prices or promotions in title, icon or developer name — in every translation.
- [ ] **GP-09** No unattributed testimonials or anonymous user quotes in the description.
- [ ] **GP-10** Full description is structured: hook (2 lines) → key features with headings / bullets → proof → call to action; uses plain sentences an LLM can quote ("Use X to …") because Ask Play / AI highlights read it.
- [ ] **GP-11** Category and up to 5 **tags** set (Store settings).
- [ ] **GP-12** Contact email, website and privacy policy filled; the website describes the app too (Ask Play reads it).
- [ ] **GP-13** Data safety form complete and consistent with the app.

## 4. Localization

- [ ] **L10N-01** Every priority market has its own listing — not Play's auto-translation, not English.
- [ ] **L10N-02** (auto) Keyword field / short description is **not copied** from the base locale.
- [ ] **L10N-03** Local search terms from local autocomplete and local competitors (KW-09).
- [ ] **L10N-04** App Store **cross-localization**: for each priority storefront, list the extra locales Apple indexes there (US: en-US + es-MX, ar, zh-Hans, zh-Hant, fr-FR, ko, pt-BR, ru, vi; UK: en-GB; CA: en-CA + fr-CA; JP: ja + en-US; most others: native + en-GB) and give each locale **different** keyword-field words.
- [ ] **L10N-05** Locales used for cross-localization still read correctly to native speakers of that language (real users see them).
- [ ] **L10N-06** (auto) CJK / Thai / Arabic listings filled to the limit too — short fields there are the most common waste.
- [ ] **L10N-07** Screenshots and captions localized for priority locales; right-to-left layout for Arabic / Hebrew.
- [ ] **L10N-08** Claim words checked in the local language ("miễn phí", "gratis", "無料", "무료", "免费"…).

## 5. Icon, screenshots, video

- [ ] **CR-01** Icon: one clear symbol, no words, readable at 40 px, distinct from top-10 competitors' icons side by side.
- [ ] **CR-02** iOS 26: layered Liquid Glass icon checked in light, dark, tinted and clear modes.
- [ ] **CR-03** (auto, Play) Icon 512×512 PNG; feature graphic 1024×500 without alpha, no ranking / price / award claims.
- [ ] **CR-04** Screenshot 1 shows the **main job** with the head keyword in a ≤ 5-word caption; it works on its own in search results.
- [ ] **CR-05** Screenshots 2–3 show the next two reasons to install; one benefit per screenshot.
- [ ] **CR-06** Real app UI (App Store 2.3.3); Play captions ≤ 20% of the image; no "Download now", "#1", "Best", store badges.
- [ ] **CR-07** App Store: 6.9" iPhone set (1320×2868 / 1290×2796 / 1260×2736) and 13" iPad set (2064×2752 / 2048×2732) if the app runs on iPad; up to 10 each; no alpha.
- [ ] **CR-08** (auto) Play: 2–8 phone screenshots, sides 320–3840 px, long side ≤ 2× short; ≥ 4 at ≥ 1080 px (9:16 or 16:9) to be eligible for featuring; tablet / Chromebook / Wear sets if supported (shown per form factor).
- [ ] **CR-09** Video (optional, test it): App Store preview 15–30 s, screen capture only, first 3 s show the job without sound; Play YouTube link public / unlisted, ads off, first 30 s matter.
- [ ] **CR-10** Creatives match the keyword map: what people searched for is what screenshot 1 shows.

## 6. Custom pages & experiments

- [ ] **EXP-01** App Store **custom product pages** (up to 70) for the top keyword intents, each with keywords assigned from the approved keyword field.
- [ ] **EXP-02** Google Play **custom store listings** (up to 50) for high-value search keywords / countries / churned users.
- [ ] **EXP-03** One experiment always running on the top market: App Store product page optimization (≤ 3 treatments, ≤ 90 days) or Play store listing experiment (≤ 2 variants; title and video can't be tested).
- [ ] **EXP-04** Each test: one variable, written hypothesis, success metric, ≥ 7 days, stopped only at the console's confidence.
- [ ] **EXP-05** Test order by expected lift: icon → screenshot 1 → captions → screenshot order → video.
- [ ] **EXP-06** Results logged (win / lose / flat) and winners applied to other locales as new tests, not assumptions.

## 7. Ratings & reviews

- [ ] **RV-01** Native in-app review prompt (`requestReview` / Play In-App Review API) after a success moment; never at launch, after an error, or gated; no incentives.
- [ ] **RV-02** Average rating ≥ 4.0 in each priority country (Play rates per country and form factor, recent ratings weigh more).
- [ ] **RV-03** 1–3★ reviews answered within a few days, specifically; reply again when the fix ships.
- [ ] **RV-04** Top recurring complaint known and on the roadmap — AI review summaries on both stores surface it as a headline.
- [ ] **RV-05** Review text mined monthly for new keywords and feature requests.

## 8. Quality & technical signals

- [ ] **Q-01** Play Android vitals below bad-behavior thresholds (28 days): user-perceived crash rate < 1.09%, ANR < 0.47%, per phone model < 8%; excessive partial wake locks < 5% of sessions.
- [ ] **Q-02** Play memory / bitmap / DEX thresholds planned for February 2027 enforcement.
- [ ] **Q-03** Play target API 36 for new apps / updates (since 2026-08-31); Apple builds on the Xcode 26 SDK (since 2026-04-28).
- [ ] **Q-04** App updated at least every 1–3 months; What's New describes real changes (2.3.12).
- [ ] **Q-05** Download size kept small; no crash at first launch or sign-in wall before value.
- [ ] **Q-06** Privacy nutrition label / data safety and (optional, App Store) Accessibility Nutrition Labels declared.

## 9. Policy — rejection & removal checks

- [ ] **POL-01** No misleading claims, fake reviews, unverifiable "#1" / "best", prices in name / title (App Store 2.3.1, 2.3.7; Play metadata policy).
- [ ] **POL-02** No other platforms' names in App Store metadata ("Android", "Google Play") (2.3.10).
- [ ] **POL-03** No third-party trademarks or copycat names (5.2.1; Play impersonation policy).
- [ ] **POL-04** "For Kids" / "For Children" only in the Kids category (2.3.8).
- [ ] **POL-05** Screenshots / previews: app in use, not just splash or login (2.3.3, 2.3.4).
- [ ] **POL-06** Every translation follows the same rules (Play applies policy per language).

## 10. Measure & iterate

- [ ] **M-01** App Store Connect → Analytics: App Store Search impressions, product page views, conversion, downloads — per country and per custom product page.
- [ ] **M-02** Play Console → Grow overview / Statistics: acquisition by **search term** and traffic source (Store analysis was retired in June 2026; listing metrics moved to unique user clicks in July 2026 — don't compare across that date).
- [ ] **M-03** Keyword ranks tracked for the keyword map (rank tracker, Apple Ads search-term report, or monthly autocomplete re-runs).
- [ ] **M-04** One field group changed at a time; wait 2–4 weeks before judging; App Store name / subtitle / keywords only change with a new version.
- [ ] **M-05** Monthly: drop keyword-field words with no impressions after 4–6 weeks, add the next candidates, re-check competitors and seasonality.

---

## Report template

```markdown
# ASO audit — <App> — <date>

Stores: <App Store / Google Play> · Locales: <list> · Mode: <audit / fix>

## Score
<passed>/<total> items · <n> ❌ · <n> ⚠️ · script: <aso_check score line>

## Field table
| Store | Locale | Name/Title | Subtitle/Short | Keywords | Description |
|---|---|---|---|---|---|
| App Store | en-US | 28/30 ✅ | 30/30 ✅ | 97/100 ✅ | 3120/4000 ✅ |

## Issues (most impact first)
| ID | Status | Store · locale · file | Evidence | Fix (fits the limit) |
|---|---|---|---|---|
| AS-06 | ❌ | App Store · en-US · keywords.txt | "tracker" also in name | replace with "routine" (+7 chars) |

## Keyword map (per priority locale)
| Term | Relevance | Autocomplete pos | Openness | Field |

## Next 3 actions
1. …
```

## Sources

- Apple: [Search](https://developer.apple.com/app-store/search/) ·
  [Platform version information](https://developer.apple.com/help/app-store-connect/reference/platform-version-information) ·
  [App Store localizations](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/) ·
  [Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) ·
  [Screenshot specs](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/) ·
  [Custom product pages](https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions/) ·
  [App tags](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-tags)
- Google: [Store listing best practices](https://support.google.com/googleplay/android-developer/answer/13393723) ·
  [Metadata policy](https://support.google.com/googleplay/android-developer/answer/9898842) ·
  [Preview assets](https://support.google.com/googleplay/android-developer/answer/9866151) ·
  [Custom store listings](https://support.google.com/googleplay/android-developer/answer/9867158) ·
  [Store listing experiments](https://support.google.com/googleplay/android-developer/answer/6227309) ·
  [Android vitals](https://developer.android.com/topic/performance/vitals) ·
  [What's new in Play](https://google.play/business/whats-new/)
- Details and dates per store: [`references/app-store.md`](references/app-store.md),
  [`references/google-play.md`](references/google-play.md),
  [`references/conversion.md`](references/conversion.md),
  [`references/keyword-research.md`](references/keyword-research.md),
  [`references/tools.md`](references/tools.md).
