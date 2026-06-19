---
name: store-release
description: First-release checklist and fastlane workflow for shipping a Flutter app to the Apple App Store and Google Play Store. Use when preparing a first public store submission, setting up App Store Connect / Google Play Console, configuring fastlane deliver/supply for metadata + screenshots, splitting internal (TestFlight/Firebase) vs production (store) deploy pipelines, or troubleshooting first-submission rejections (90771, ITMS-90683, missing review detail, version mismatch, UTF-8 locale, ruby/bundler).
---

# Store Release — App Store + Google Play first submission

Everything needed to take a Flutter app from "builds locally" to "submitted for
review" on both stores. Covers the one-time account/console setup, the metadata +
screenshots upload via fastlane, and the gotchas that block a *first* release
specifically.

> **Two-pipeline model.** Keep internal distribution and store release separate:
> - `deploy.sh` → **internal** builds, **no fastlane** (iOS TestFlight via
>   no-codesign archive + `xcodebuild -exportArchive` + `altool`; Android
>   Firebase App Distribution). See the `appdist` skill.
> - `prod.sh` → **store** releases, **through fastlane** (iOS App Store via
>   `deliver`; Android Google Play via `supply`).
>
> This skill owns the `prod.sh` / fastlane half and the submission checklist.

## When to use

- Submitting an app to the App Store or Play Store **for the first time**.
- Wiring up `fastlane deliver` (iOS) / `supply` (Android) for metadata + screenshots.
- A first submission got rejected and you need the known-blocker list.
- Generating ready-to-paste prompts for an AI agent to drive each release step.

## Quick start

```bash
# 1. Copy templates into the project
cp -r templates/ios/*       ios/fastlane/
cp -r templates/android/*   android/fastlane/
cp templates/ios/Gemfile    ios/Gemfile
cp templates/android/Gemfile android/Gemfile
cp assets/.env.example      .env.prod      # then fill with REAL values (gitignored)

# 2. Ruby env (system ruby 2.6 is usually broken — use Homebrew ruby)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8   # REQUIRED or deliver crashes on non-ASCII metadata

# 3. iOS App Store listing (metadata + screenshots, no binary)
cd ios && bundle install && bundle exec fastlane release_listing

# 4. Android Play Store (build AAB + upload to internal track + metadata)
cd android && bundle install && bundle exec fastlane internal
```

## What's in this skill

| File | Purpose |
|------|---------|
| `references/first-release-checklist.md` | The full step-by-step setup + submission checklist for both stores, with the first-release gotchas. **Read this first.** |
| `references/prompts.md` | Ready-to-paste prompts for an AI agent to drive each release step. |
| `references/fastlane-gotchas.md` | Ruby/bundler/locale/spaceship fixes for the errors that block a first upload. |
| `templates/ios/Fastfile` | iOS `deliver` lanes: `create_app`, `upload_metadata`, `upload_screenshots`, `release_listing`. |
| `templates/android/Fastfile` | Android `supply` lanes: `internal`, `metadata`, `validate_metadata`, `promote_to_production`. |
| `templates/ios/ExportOptions.plist` | Manual `app-store-connect` export options for the no-codesign archive flow. |
| `templates/*/Gemfile`, `templates/*/Appfile` | Pinned fastlane + app identifiers (placeholders). |
| `assets/.env.example` | All env vars with **dummy** values. Copy to `.env.prod` and fill in; never commit. |
| `guide/index.html` | Standalone interactive checklist page you can open in a browser. |

## Golden rules

1. **Never commit secrets.** `.env.prod`, `.p8`, `.p12`, `.mobileprovision`,
   `.jks`/keystores, and service-account JSON stay gitignored. Keep them in a
   private mirror (e.g. a separate `.app_dist` repo), not the app repo.
2. **App record must exist before the first upload.** ASC API keys cannot
   `POST /v1/apps` (403) — create the app once in the App Store Connect web UI.
   Same for Play: create the app in the Play Console first.
3. **UTF-8 locale is mandatory** for `deliver` if any locale has non-ASCII text.
4. **The App Store version string must equal the build's `CFBundleShortVersionString`** or the build won't attach.
5. **Use Homebrew ruby + bundler + `bundle exec`** — the macOS system ruby gem set is usually incomplete.

See `references/first-release-checklist.md` for the detailed walkthrough.
