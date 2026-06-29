---
name: ai-studio-mobile
description: Re-brand and ship an existing native mobile app (iOS Swift/UIKit + Android Java) end-to-end — change bundle id, wire Firebase, send beta builds, add Settings features (i18n, theme, support→Telegram), build a landing page, and prepare store submission. Use when the user wants to clone a template native app into a new product and take it from rename to TestFlight/Firebase/Play, following the ProFocus playbook. Ask the user for the input checklist first, then execute phases in order.
---

# AI Studio Mobile — ship a native app from template

Re-create a shippable native mobile product (iOS + Android) from an existing template app,
following the ProFocus playbook. Always **ask the user for the inputs below first**, confirm,
then execute phases **one at a time**, keeping a `PLAN.md` checklist updated as the source of truth.

## Standing rules
- Maintain `PLAN.md` with a phase checklist; mark items ✅ as you finish and append a progress log.
- **After each phase that changes app code: bump the build number and send a fresh build** to
  Android (Firebase App Distribution) and iOS (TestFlight) via `scripts/release.sh`, then continue
  automatically without asking again (if the user has granted that mode).
- Verify every build compiles before distributing. Commit per phase on a `develop` branch; push.
- Keep secrets out of git (`.app_dist/`, `*.p12`, `*.p8`, `*.mobileprovision`, `*.jks`, `keystore.properties`, `**/.env.prod`).

## Inputs to collect first (ask the user)
See `references/intake.md` for the full questionnaire. Minimum:
1. App name + store title (store names are globally unique — have a fallback ≤30 chars).
2. New bundle/application id (e.g. `vn.fighttech.<app>`) — note Android namespace may stay as the
   template's even when applicationId changes.
3. Firebase project id + downloaded `google-services.json` / `GoogleService-Info.plist`, and the
   Firebase App IDs (android + ios) for App Distribution.
4. Apple: Team ID, ASC API key (`.p8` + key id + issuer id) for TestFlight upload **(no 2FA)**;
   Apple ID + app-specific password only if an app record must be created via `produce` **(needs 2FA)**.
5. Tester email(s); target languages; theme set; brand palette + fonts.
6. Telegram bot token + chat_id for in-app support; support/privacy/terms URLs.
7. Git remote to clone/push; landing host details for deploy.

## Phases (ProFocus order)
0. **Foundation** — clone template repos → `<app>-ios`, `<app>-android`; set up `.app_dist` (env + certs, gitignored), `.gitignore`, `PLAN.md`, `develop` branch.
1. **PRIORITY: rebrand + first build** — change bundle/application id, display name, Firebase configs; build both; **send first beta build** (Android→Firebase, iOS→TestFlight). Solve issues per `references/gotchas.md`.
1.5 **New features** (optional) — e.g. photo frame slideshow, Pomodoro presets.
2. **Settings** — app version display; **i18n** (in-code string table on iOS for instant runtime switch + rebuild root; `values-xx` + `LocaleHelper.attachBaseContext` + restart on Android; handle RTL); **theme** light/dark/system (iOS overrideUserInterfaceStyle; Android `AppCompatDelegate` night mode + DayNight theme); **support screen** (subject + message + accent color + Send→Telegram + device info); policy/terms links.
3. **Landing page** — static, self-contained site in `<app>-landingp` with brand styling; a "Try in web" interactive demo; `privacy.html` + `terms.html` linked from the app; verify render; deploy to the host.
4. **Store submission** — full `.app_dist` (Android keystore, iOS cert/profile adhoc+appstore); store listing metadata (`.app_marketing/METADATA.md`) in all languages; screenshots in the brand style; intro video + posters; submit (use `appdist`, `store-release` skills).
5. **Export** — keep this skill current so the playbook is reusable.

## Reusable assets
- `scripts/release.sh` — copy into `<app>/scripts/`; bumps Android `versionCode` + iOS
  `CURRENT_PROJECT_VERSION`, builds both, distributes to Firebase + TestFlight in one command.
- `references/intake.md` — the input questionnaire.
- `references/gotchas.md` — the hard-won fixes (fastlane UTF-8, produce 2FA over FIFO, cleartext WiFi, etc.).
- `references/i18n.md` — the iOS in-code table + Android locale-helper recipe.

Read the reference files before executing the matching phase.
