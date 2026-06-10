# ep01-shipflutter-deploy — Technical Design

## Overview

Automated multi-platform release pipeline for ShipFlutter. Single Bash entry point (`deploy.sh`) with platform-aware branching. Supports iOS → TestFlight, Android → Firebase App Distribution + Google Play Store (internal testing track). Telegram notifications on every build. GitHub Actions CI/CD on merge to `uat` (includes Play Store internal upload for Android).

## Architecture

```
deploy.sh [ios|android|all]
  │
  ├── Load .env.prod
  │   ├── Apple API credentials
  │   ├── iOS signing (P12, profile, WWDR)
  │   ├── Android signing (keystore)
  │   ├── Firebase (token, app ID, groups)
  │   ├── Play Store (service account JSON, package, track)
  │   └── Telegram (bot token, chat ID)
  │
  ├── Parse pubspec.yaml → VERSION + BUILD_NO
  │
  ├── [Android Pipeline]
  │   ├── 1. Create android/key.properties
  │   ├── 2. flutter build apk --release
  │   ├── 3. firebase appdistribution:distribute → developer group
  │   └── 4. flutter build appbundle --release → upload-playstore.py → Play Console (internal)
  │
  ├── [iOS Pipeline]
  │   ├── 1. Import P12 + WWDR → temp keychain
  │   │   └── Install .mobileprovision
  │   ├── 2. Patch Xcode project (manual signing, team 86PC33ZDHF)
  │   │   └── flutter build ipa --release
  │   ├── 3. xcodebuild -exportArchive (ExportOptions.plist)
  │   └── 4. xcrun altool --upload-app → TestFlight
  │
  └── scripts/telegram.sh
      ├── notify_build_start (🚀🍎/🤖/📱 + source + version)
      └── notify_build_finish (✅/❌ + duration + commit)
```

## Data Flow

```
pubspec.yaml ──parse──▶ VERSION (1.0.0) + BUILD_NO (8)

.env.prod ──source──▶ All credentials per platform

.app_dist/
  ship_flutter_cert_123123.p12 ──import──▶ temp keychain ──▶ codesign
  ShipFlutterAppstore.mobileprovision ──install──▶ ~/Library/.../Profiles/
  AppleWWDRCAG3.cer ──import──▶ temp keychain (trust chain)
  shipflutter.jks ──▶ android/key.properties ──▶ Gradle signing
  playstore-service-account.json ──▶ upload-playstore.py ──▶ Google Play API

flutter build ──▶ app-release.apk ──▶ firebase CLI ──▶ Firebase Distribution
flutter build ──▶ app-release.aab ──▶ python script ──▶ Google Play Console (internal)
flutter build ──▶ Runner.xcarchive ──▶ xcodebuild ──▶ .ipa ──▶ altool ──▶ TestFlight
```

## Entities

| Entity | Source | Platform | Purpose |
|--------|--------|----------|---------|
| `APPLE_API_KEY_ID` | `.env.prod` | iOS | App Store Connect API |
| `P12_FILE` / `P12_PASSWORD` | `.env.prod` | iOS | Distribution cert |
| `PROFILE_FILE` | `.env.prod` | iOS | Provisioning profile |
| `ANDROID_KEYSTORE_FILE` | `.env.prod` | Android | Signing keystore |
| `FIREBASE_TOKEN` | `.env.prod` | Android | Firebase CLI auth |
| `FIREBASE_APP_ID` | `.env.prod` | Android | Firebase app identifier |
| `PLAYSTORE_SERVICE_ACCOUNT_JSON` | `.env.prod` | Android | Google Play API auth |
| `PLAYSTORE_PACKAGE_NAME` | `.env.prod` | Android | Play Console app identifier |
| `PLAYSTORE_TRACK` | `.env.prod` | Android | internal (default for both deploy.sh & prod.sh) |
| `TELEGRAM_BOT_TOKEN` | `.env.prod` | Both | Telegram Bot API |
| `TELEGRAM_CHAT_ID` | `.env.prod` | Both | Target chat |

## iOS Signing Details

- **Team ID**: `86PC33ZDHF`
- **Bundle ID**: `app.shipflutter.mobile`
- **Certificate**: `Apple Distribution: Tran Trung Hieu (86PC33ZDHF)`
- **Profile**: `ShipFlutterAppstore` (App Store distribution)
- **Export method**: `app-store-connect`, manual signing
- **Temp keychain**: created per build, deleted on exit (trap EXIT)

## Android Signing Details

- **Keystore**: `.app_dist/shipflutter.jks`
- **Alias**: `shipflutter`
- **Passwords**: from `.env.prod` (`ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`)
- **key.properties**: generated at build time with absolute keystore path

## Firebase App Distribution

- **CLI**: `firebase-tools` (npm, auto-installed if missing)
- **Auth**: `FIREBASE_TOKEN` (CI refresh token from `firebase login:ci`)
- **App ID**: `1:558768715344:android:440c86df0782356fc28355`
- **Groups**: `developer`
- **Release Notes**: latest git commit message

## Google Play Store (Internal Testing)

- **API**: Google Play Android Publisher v3
- **Auth**: Service account JSON key (`playstore-uploader@shipflutterapp.iam.gserviceaccount.com`)
- **Upload**: Python script (`scripts/upload-playstore.py`)
  - Creates edit → uploads AAB → sets track → commits
- **Track**: `internal` for both `deploy.sh` and `prod.sh`. Set via `PLAYSTORE_TRACK` env var.
- **GitHub Actions CI**: Play Store upload runs in the Android job when `PLAYSTORE_SERVICE_ACCOUNT_JSON` is provided. The service account JSON is decoded from `PLAYSTORE_SERVICE_ACCOUNT_JSON_B64` GitHub secret at runtime.

## Telegram Notifications

- **Format**: emoji + app name + platform + status
- **Platform labels**: 🍎 iOS TestFlight, 🤖 Android Firebase, 📱 both
- **Source**: `💻 username@hostname` (local) or `🤖 GitHub Actions Pipeline` (CI)
- **Data**: version, branch, commit, duration, triggered by, commit message

## GitHub Actions (deploy-uat.yml)

- **Trigger**: push to `uat` branch / manual `workflow_dispatch`
- **Jobs**:
  - `deploy-ios`: macos-15, Flutter 3.41.9, Xcode archive + export + altool
  - `deploy-android`: ubuntu-latest, Java 17, Flutter 3.41.9, APK → Firebase + AAB → Play Store (internal)
- **Android Play Store upload**: service account JSON decoded from `PLAYSTORE_SERVICE_ACCOUNT_JSON_B64` GitHub secret into `.app_dist/playstore-service-account.json`, then uploaded via `scripts/upload-playstore.py` with `--track internal`.
- **Secrets**: all signing assets as base64 + string values

## scripts/prepare.sh

- **Purpose**: Generate `.env.prod.git_vars.json` from local `.app_dist/` assets
- **Encodes**: P12, mobileprovision, WWDR, keystore, Play Store service account JSON as base64
- **Extracts**: all string secrets from `.env.prod`
- **Output**: `.env.prod.git_vars.json` (gitignored, contains values) + `resources/git_vars.json` (committed, keys only)
- **Usage**: `bash scripts/prepare.sh` → `gh secret set -f .env.prod.git_vars.json`

## Security

- `.env.prod` and `.env.prod.git_vars.json` are gitignored
- `.env.example` is safe to commit (dummy values only)
- Temp keychain deleted on exit (trap EXIT)
- Private keys never written to persistent storage
- GitHub secrets encrypted at rest
- Service account keys never committed in plain text
