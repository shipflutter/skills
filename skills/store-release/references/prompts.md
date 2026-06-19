# Release Prompts — ready to paste

Copy-paste prompts for driving each release step with an AI coding agent. Replace
`<...>` placeholders. The agent should always treat secrets as gitignored and use
dummy values in any committed file.

---

## Setup / scaffolding

**Scaffold the store-release tooling**
```
Set up the store-release pipeline for this Flutter app. Copy the store-release
skill's templates: ios/fastlane/{Fastfile,Appfile}, android/fastlane/{Fastfile,Appfile},
ios/Gemfile, android/Gemfile, and a .env.prod from assets/.env.example. Fill the
Appfiles/Fastfiles with our bundle id <com.example.myapp> and Apple team id
<XXXXXXXXXX>. Add android/fastlane and ios/fastlane to .gitignore. Do NOT commit
.env.prod, .p8, .p12, keystores, or service-account JSON — confirm they are gitignored.
```

**Split internal vs store deploy pipelines**
```
Restructure our deploy scripts into two paths: deploy.sh = INTERNAL distribution
WITHOUT fastlane (iOS TestFlight via no-codesign archive + xcodebuild -exportArchive
+ altool; Android Firebase). prod.sh = STORE releases THROUGH fastlane (iOS App Store
via deliver; Android Google Play via supply). prod.sh should restore the gitignored
fastlane folders from the private .app_dist mirror if missing, set Homebrew ruby +
UTF-8 locale, and wire ASC + Play credentials from .env.prod. Keep secrets out of git.
```

---

## iOS App Store

**Create the app record (one-time)**
```
The App Store Connect API key cannot create app records (403). Walk me through
creating the app in the App Store Connect web UI (My Apps → New App) with bundle id
<com.example.myapp>, name <App Name>, primary language <English (U.S.)>, SKU <sku-123>.
Then verify the record exists via spaceship before any upload.
```

**Prepare listing metadata + screenshots**
```
Generate App Store listing metadata files under ios/fastlane/metadata/<locale>/ for
locales <en-US, vi, ja, ko>: name, subtitle, description, keywords, promotional_text,
release_notes, and the URLs. Apply ASO best practices. Place screenshots under
ios/fastlane/screenshots/<locale>/ — note other locales fall back to en-US.
```

**Upload the listing (no binary)**
```
Upload the App Store listing (metadata + screenshots, no binary) via fastlane.
Use Homebrew ruby and a UTF-8 locale (export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8),
export ASC_KEY_ID/ASC_ISSUER_ID/ASC_KEY_P8, then cd ios && bundle exec fastlane
release_listing. If deliver crashes on fetch_app_store_review_detail with "No data",
create the review-detail object once via spaceship, then retry.
```

**Build + upload the binary**
```
Build and upload the iOS binary for version <3.0.1> build <25> WITHOUT fastlane:
flutter build ipa --release --no-codesign, then xcodebuild -exportArchive with a
manual ExportOptions.plist (method app-store-connect, signingStyle manual,
signingCertificate "Apple Distribution"), then xcrun altool --upload-app with the
.p8 API key. Confirm it lands in App Store Connect.
```

**Attach build + submit**
```
For the App Store version <3.0.1>, verify the version_string matches the build's
CFBundleShortVersionString (fix via spaceship if ASC created a 1.0 version), attach
build <3.0.1+25>, answer export compliance (ITSAppUsesNonExemptEncryption = false),
and report whether it's ready to Submit for Review. Do not submit without my confirmation.
```

---

## Android Google Play

**Prepare listing**
```
Generate Play Store listing files under android/fastlane/metadata/android/<locale>/:
title, short_description, full_description, and changelogs/<versionCode>.txt. Place
graphics under images/ (icon, featureGraphic, phoneScreenshots, sevenInch, tenInch).
```

**Validate + upload to internal**
```
Dry-run validate the Play listing (cd android && bundle exec fastlane validate_metadata),
then build the AAB and upload to the internal track as a draft with metadata
(bundle exec fastlane internal). Use SUPPLY_JSON_KEY pointing at the service-account
JSON. Report the Play Console review status.
```

**Promote to production**
```
Promote the current internal-track build to production via
fastlane promote_to_production. Confirm all Play Console Dashboard tasks (data safety,
content rating, target audience, privacy policy) are complete first, since Play blocks
the first production release until they are. Ask me before promoting.
```

---

## Troubleshooting

```
The first App Store submission was rejected with <90771 / ITMS-90683 / other>.
Diagnose against the store-release skill's first-release gotchas, fix the root cause
in ios/Runner/Info.plist (or wherever), bump the build number, and re-upload.
```
