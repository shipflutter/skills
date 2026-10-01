# Google Play — fields, metadata policy, ranking signals, 2025–26 changes

State as of 2026-10-01. Everything is from Google's own pages unless marked **[Vendor]** or
**UNCONFIRMED**.

## Indexed fields

There is **no hidden keyword field**: Play reads the visible text.

| Field | Limit | Indexed | Notes |
|---|---|---|---|
| Title | 30 | ✅ highest weight [Vendor consensus] | Brand + the head term |
| Short description | 80 | ✅ [Vendor] | Shown above the fold on many surfaces; 2–3 secondary terms in a real sentence |
| Full description | 4000 | ✅ [Vendor] | First 250–300 characters weigh most [AppRadar]; mention each target term 2–3 times naturally |
| Developer name, package name | — | UNCONFIRMED (vendors disagree) | Don't rely on them |
| In-app product names | — | UNCONFIRMED (AppRadar: not indexed) | — |
| Review text | — | UNCONFIRMED as ranking signal; feeds AI review summaries and Ask Play | Ask for reviews that name the job ("great for tracking habits") |
| Text inside screenshots / video | — | ❌ [Vendor] | Conversion only |
| Tags | up to 5 | Category / discovery | Play Console → Store settings |

Google's only ranking statement: "ratings, reviews, downloads, and other factors", and a warning
against keyword spam. <https://support.google.com/googleplay/android-developer/answer/4448378>

Keyword density: Google gives no number, only bans "blocks of words" and repetitive or unrelated
keywords. Stay at a few natural mentions (`aso_check.py` warns above 3%).

## Metadata policy (enforced since 2021-09-29)

Title, icon, developer name — **not allowed**
(<https://support.google.com/googleplay/android-developer/answer/9898842>):

- emoji, emoticons, repeated special characters (`!!!`, `★★★`)
- ALL CAPS unless it is the brand
- performance claims: "#1", "Best", "Top", "Popular", "App of the year", "Best of Play 20XX"
- price / promo: "Free", "10% off", "$50 cash back", "free for limited time"
- Play program labels: "Editor's choice", "New"; "No Ads" is also listed as an example to avoid
- the icon: misleading symbols (fake notification badges), ranking / price / category badges

Descriptions: no misleading, irrelevant or excessive metadata, no keyword lists, no unattributed
or anonymous testimonials. The policy applies to **every translation**.

Graphics (<https://support.google.com/googleplay/android-developer/answer/9866151>): screenshot
taglines ≤ 20% of the image; no "Download now" / "Install now"; no "Best", "#1", "Top"; no device
frames or store badges; feature graphic without ranking / award / price.

Enforcement: rejection (previous version stays live) → removal → suspension (a strike) → limited
visibility → account termination.

## Asset specs

| Asset | Spec |
|---|---|
| Icon | 512×512, 32-bit PNG with alpha, ≤ 1024 KB |
| Feature graphic (required) | 1024×500, JPEG or 24-bit PNG, no alpha |
| Phone screenshots | 2–8, JPEG or 24-bit PNG, each side 320–3840 px, long side ≤ 2× short side |
| Eligible for featuring (apps) | ≥ 4 screenshots, ≥ 1080 px, 9:16 (1080×1920) or 16:9 |
| Games | ≥ 3 landscape 16:9 (or portrait equivalent) |
| Tablets 7"/10", Chromebook | ≥ 4, 1080–7680 px, 16:9 or 9:16 |
| Wear OS | ≥ 1, 1:1, ≥ 384×384, no frames |
| TV | ≥ 1 screenshot + 1280×720 banner |
| Android XR | 4–8 at 8:5 (3840×2400), ≤ 8 MB, + up to 2 spatial videos |
| Automotive | 2 portrait 800×1280 + 2 landscape 1024×768 |
| Video | YouTube URL, public or unlisted, embeddable, no ads / age gate; first 30 s autoplay; portrait allowed (Phiture: ~5% higher conversion in 2025 tests) |

Since I/O 2024 screenshots, ratings and reviews are shown **per form factor** — upload tablet /
Chromebook / Wear sets if you support them. Since July 2025 any app can add a hero content
carousel and a YouTube playlist carousel.

## Growth features

| Feature | Facts | Use |
|---|---|---|
| **Custom store listings** | Up to 50; target by country, pre-registration, churned / lapsed users, buyer states, ads traffic, **search keywords** (since I/O 2024), custom audiences, URL parameter; change name, icon, descriptions, graphics; not auto-translated | One listing per high-value keyword intent; I/O 2026: Grow overview → keyword recommendation → Gemini builds the keyword listing in one click |
| **Store listing experiments** | 1 default-graphics experiment **or** up to 5 localized at once; up to 2 variants (older guides say 3 — check the console); test icon, feature graphic, screenshots, and (localized) descriptions — **not title or video**; metric: unique user installs / opens; adjustable confidence and MDE; auto-stop after 6 months | Run continuously on the top locale |
| **Promotional content** (LiveOps) | All games; apps need "Premium growth tools" eligibility; create ≤ 60 days ahead, submit ≥ 4 days before (≥ 14 to request featuring); up to 4 weeks | Seasonal events, major updates |
| **Promo codes** | 500 / quarter (non-subscription), 10,000 / quarter per subscription | Reviewers, launch partners |
| **Pre-registration** | Up to 90 days, 2 apps at once, 1 reward, auto-install on launch | New apps: build day-1 install velocity |
| **Engage SDK** | Collections and the You tab (Sep 2025); on store listings for existing users from ~Jun 2026 | Re-engagement surfaces |

## Ranking signals

| Signal | Status |
|---|---|
| Ratings | Recent ratings weigh more (since 2019); **per country** (2021) and **per form factor** (2022) |
| Android vitals (28 days) | Bad-behavior thresholds below → less discoverable on all devices (overall) or that device (per model), plus a possible warning on the listing |
| Install velocity, retention, uninstall rate | UNCONFIRMED (vendor consensus) |
| App size | No official role; 2017 data: ~1% lower install conversion per +6 MB |

Android vitals thresholds (<https://developer.android.com/topic/performance/vitals>):

| Metric | Overall | Per phone model |
|---|---|---|
| User-perceived crash rate | 1.09% | 8% |
| User-perceived ANR rate | 0.47% | 8% |
| Excessive partial wake locks (> 2 h / 24 h, enforced 2026-03-01) | 5% of sessions | — |

Coming: memory, bitmap memory and DEX-optimization thresholds enforced **February 2027**;
Restore Credentials API for apps with sign-in from **April 2027**
(<https://support.google.com/googleplay/android-developer/answer/17492799>).

Platform requirements that affect visibility: target **API 36** for new apps / updates since
2026-08-31 (extensions to 2026-11-01); existing apps need ≥ API 35 to stay visible to new users on
newer Android. Developer verification is mandatory in Brazil, Indonesia, Singapore and Thailand
since 2026-09-30, global in 2027.

## AI surfaces (they read your listing text and reviews)

- AI "App highlights" (test since Feb 2024), "Ask Play about this app" (~May 2025), Guided Search
  (Sep 2025), AI review summaries "Users are saying" (Oct–Nov 2025, apps with enough reviews).
- I/O 2026-05-19: Ask Play conversational search, Ask Play highlights on result pages, Gemini app
  recommendations, Play Shorts (US). AppTweak: Ask Play answers from listing text **and the app's
  website**, English-only at first [UNCONFIRMED].
- Consequence: state the core use cases and audience in plain sentences in the full
  description and on the website — an LLM must be able to answer "is this app good for X?".

## Localization

- Free machine translation of the listing for 10 languages (ar, fr-FR, de, id, it, ja, pt-BR,
  es-419, es-ES, th); paid human translation from $0.07 / word. Without a localized listing Play
  shows an auto-translated one — a hand-written localized listing with local keywords beats it.
- Gemini translates app strings for free (since Sep 2025); I/O 2026: bulk listing upload by CSV /
  Google Sheets with Gemini pre-fill.
- Largest download markets 2025 (both stores combined, AppTweak): India 22%, Brazil, US,
  Indonesia, Mexico. By spend: US, Japan, South Korea.

## Reporting (changed in 2026)

- Jun 2026: the legacy **Store analysis** page was deprecated → traffic sources moved to **Grow
  overview** and **Statistics**; the "Search term" dimension remains.
- Jul 2026: store listing reports moved from acquisitions to **unique user clicks**; new visitor
  methodology from 2026-07-10 (lower counts); new reach / impression metrics. **Don't compare
  across July 2026.**
- Sep 2026: Day 2 / 3 / 14 / 28 retention by traffic source.

Sources: <https://google.play/business/whats-new/>,
<https://android-developers.googleblog.com/2026/05/io-2026-whats-new-in-google-play.html>.
