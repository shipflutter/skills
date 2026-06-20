# First-Release Checklist — App Store + Google Play

A first public submission has setup steps that never recur. This is the full list,
in order, for a Flutter app. Placeholders below use dummy values — replace with
your own and keep real values in `.env.prod` (gitignored).

Legend: ☐ one-time setup · ▶ run every release · ⚠ first-release-only blocker

---

## 0. Prerequisites (both stores)

- ☐ Apple Developer Program membership (paid, $99/yr) — team id like `XXXXXXXXXX`.
- ☐ Google Play Developer account (one-time $25) — a Google Cloud project for the API.
- ☐ Flutter app builds release locally: `flutter build ipa` / `flutter build appbundle`.
- ☐ Final `applicationId` (Android) and `PRODUCT_BUNDLE_IDENTIFIER` (iOS) decided — these are **permanent** once published. Example: `com.example.myapp`.
- ☐ App icon with no alpha for iOS, adaptive icon for Android.
- ☐ Homebrew ruby + bundler installed: `brew install ruby && gem install bundler`.

---

## 1. Apple App Store

### 1a. App Store Connect setup (one-time)

- ☐ Create an **App Store Connect API key**: Users and Access → Integrations → App Store Connect API → generate a key with "App Manager" access.
  - Note the **Key ID** (`XXXXXXXXXX`), **Issuer ID** (`00000000-0000-0000-0000-000000000000`).
  - Download the `.p8` **once** (Apple never shows it again). Store at `~/.appstoreconnect/private_keys/AuthKey_XXXXXXXXXX.p8`.
- ⚠ **Create the app record in the web UI** (My Apps → ＋ → New App). The API key role **cannot** create apps (`POST /v1/apps` → 403), and `fastlane produce` needs an Apple-ID login, not the API key. Set: platform iOS, name, primary language, bundle id, SKU.
- ☐ Distribution certificate + provisioning profile. Either let Xcode manage automatic signing, OR for CI use a manual "Apple Distribution" cert (`.p12`) + an App Store provisioning profile (`.mobileprovision`).

### 1b. Listing content (one-time, edit later)

- ☐ Metadata per locale under `ios/fastlane/metadata/<locale>/`: `name.txt`, `subtitle.txt`, `description.txt`, `keywords.txt`, `promotional_text.txt`, plus `release_notes.txt`, support/marketing URLs, privacy policy URL.
- ☐ Screenshots under `ios/fastlane/screenshots/<locale>/` for required device sizes (6.7", 6.5", 5.5", iPad 12.9" if you support iPad). Other locales fall back to `en-US`.
- ☐ App Privacy answers (data collection) — filled in the web UI, required before submission.
- ☐ Age rating questionnaire — web UI.
- ⚠ **App Review information** (contact name/email/phone, demo account if login-gated). A brand-new version has **no** `appStoreReviewDetail` object; see gotcha #3 below.

### 1c. Upload (run every release ▶)

- ▶ Bump `version:` in `pubspec.yaml` (e.g. `3.0.1+25` → name `3.0.1`, build `25`).
- ▶ Build + upload the binary to TestFlight / App Store Connect (no-fastlane path — see `appdist` skill `deploy.sh ios`): unsigned archive → `xcodebuild -exportArchive` with `ExportOptions.plist` → `xcrun altool --upload-app`.
- ▶ Upload metadata + screenshots: `cd ios && bundle exec fastlane release_listing`.
- ▶ In the web UI (or via API): select the uploaded build for the version, answer export-compliance, then **Submit for Review**.

---

## 2. Google Play Store

### 2a. Play Console setup (one-time)

- ☐ Create the app in the Play Console (name, default language, app/game, free/paid).
- ☐ Create a **service account** for the API: Play Console → Setup → API access → link a Google Cloud project → create service account → grant "Release manager" → download the JSON key. Store outside the repo; point `PLAYSTORE_SERVICE_ACCOUNT_JSON` at it.
- ☐ Upload signing key (.jks) OR opt into Play App Signing (recommended). Record keystore password, key alias, key password in `.env.prod`.
- ☐ Complete the required **Dashboard tasks**: app access, ads declaration, content rating, target audience, data safety, privacy policy, store listing. Play will not let you release until these are green.

### 2b. Listing content (one-time, edit later)

- ☐ Metadata per locale under `android/fastlane/metadata/android/<locale>/`: `title.txt`, `short_description.txt`, `full_description.txt`.
- ☐ Graphics under `.../<locale>/images/`: `icon`, `featureGraphic`, `phoneScreenshots/`, `sevenInchScreenshots/`, `tenInchScreenshots/`.
- ☐ `changelogs/<versionCode>.txt` for release notes (needs the integer versionCode).

### 2c. Upload (run every release ▶)

- ▶ Bump `version:` in `pubspec.yaml` (Flutter maps `+N` to `versionCode`).
- ▶ `cd android && bundle exec fastlane validate_metadata` (dry run, no upload).
- ▶ `cd android && bundle exec fastlane internal` → builds AAB, uploads to the **internal** track as a draft, pushes metadata.
- ▶ Test on the internal track, then `fastlane promote_to_production` (or use the Console) when ready.

---

## 3. First-release gotchas (the ones that actually block you)

These are first-submission-specific — they don't recur on later releases.

1. **Reject 90771 — `UIBackgroundModes` without a matching capability.**
   e.g. `processing` listed but no `BGTaskSchedulerPermittedIdentifiers`. Remove
   the mode you don't actually use from `ios/Runner/Info.plist` (keep only what
   the app does, e.g. `audio` for background playback).

2. **ITMS-90683 — missing usage-description string.** Any permission the app
   touches needs a purpose string. Common miss: `NSPhotoLibraryUsageDescription`.
   Add it to `Info.plist`.

3. **`[!] No data` crash at `fetch_app_store_review_detail`.** The first-ever App
   Store version has no review-detail object and `deliver` fetches it with no
   rescue. Create it once via spaceship before running deliver:
   ```ruby
   ver.create_app_store_review_detail(attributes: { demo_account_required: false })
   ```

4. **Version-string mismatch.** App Store Connect auto-creates an editable
   version `1.0`, but your build is e.g. `3.0.1`. The App Store version string
   must equal the build's `CFBundleShortVersionString`, or the build won't
   attach. Fix via spaceship:
   ```ruby
   ver.update(attributes: { version_string: "3.0.1" })
   ```

5. **`invalid byte sequence in US-ASCII` in `deliver`.** Non-ASCII metadata
   (vi/ja/ko/…) under a non-UTF-8 locale. Always:
   `export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8`.

6. **System ruby can't find fastlane / `gh_inspector`.** The macOS system ruby
   2.6 `~/.gem` set is incomplete. Use Homebrew ruby + bundler:
   `export PATH="/opt/homebrew/opt/ruby/bin:$PATH"; bundle install; bundle exec fastlane …`.

7. **`.p12` "MAC verification failed" on `security import`** even with the right
   password — the file uses a modern format macOS can't read. Re-export to the
   legacy format with system LibreSSL:
   ```bash
   openssl pkcs12 -in old.p12 -nodes -passin pass:PW -out all.pem
   openssl pkcs12 -export -in all.pem -inkey all.pem -passout pass:PW -out new.p12
   ```

8. **Keychain has 0 valid identities.** Passing a keychain by bare name corrupts
   the search list. Use absolute `*.keychain-db` paths, set the temp keychain as
   default, and `security set-keychain-settings` to disable auto-lock.

9. **Play: "app must be reviewed" / dashboard tasks incomplete.** Play blocks the
   first production release until every required Dashboard task is green — there
   is no API shortcut. Do them once in the Console.

---

## 4. Env vars (see `assets/.env.example` for dummy values)

**iOS:** `APPLE_API_KEY_ID`, `ISSUER_ID`, `APPLE_API_PRIVATE_KEY` (or `.p8` path),
`TEAM_ID`, `BUNDLE_ID`, optionally `P12_FILE`/`P12_PASSWORD`/`PROFILE_FILE` for CI.

**Android:** `ANDROID_KEYSTORE_FILE`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `PLAYSTORE_SERVICE_ACCOUNT_JSON`,
`PLAYSTORE_PACKAGE_NAME`, `PLAYSTORE_TRACK`.

Fastlane reads ASC creds from `ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_KEY_P8` — if
your `.env.prod` uses the `APPLE_API_*` names, export the `ASC_*` aliases before
running (`prod.sh` does this for you).
