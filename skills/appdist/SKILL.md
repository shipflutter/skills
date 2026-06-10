---
name: appdist
description: Automated CI/CD deploy pipeline for Flutter mobile apps — iOS TestFlight, Android Firebase App Distribution, and Google Play Store internal testing. Use when setting up or running multi-platform app distribution, configuring signing assets (.app_dist/), generating GitHub Secrets for CI/CD, setting up GitHub Actions auto-deploy on push, sending Telegram build notifications, or troubleshooting deploy failures for iOS/Android Flutter apps.
---

# App Distribution — Multi-Platform Deploy Pipeline

One-command Flutter build + deploy to iOS TestFlight, Android Firebase App Distribution, and Google Play Store internal testing. Includes GitHub Actions CI/CD, Telegram notifications, and secrets management.

## Quick Start

```bash
# 1. Copy templates from this skill to project root
cp assets/.env.example .env.prod
cp -r assets/app_dist_template .app_dist
cp assets/github_workflows/deploy-uat.yml .github/workflows/

# 2. Fill in .env.prod with real values (see template)
# 3. Place signing files into .app_dist/ (see assets/app_dist_template/README.md)

# 4. Deploy
bash scripts/deploy.sh ios       # iOS → TestFlight
bash scripts/deploy.sh android   # Android → Firebase + Play Store internal
bash scripts/deploy.sh           # Both platforms
bash scripts/prod.sh             # Same as deploy.sh (explicit internal track)
```

## Architecture

```
deploy.sh [ios|android|all]
  ├── Source .env.prod → all credentials
  ├── Parse pubspec.yaml → version + build number
  │
  ├── [Android Pipeline]
  │   ├── keystore → android/key.properties
  │   ├── flutter build apk --release → firebase CLI → Firebase
  │   └── flutter build appbundle --release → upload-playstore.py → Play Console (internal)
  │
  ├── [iOS Pipeline]
  │   ├── P12 + WWDR → temp keychain → install profile
  │   ├── Patch Xcode project → flutter build ipa
  │   ├── xcodebuild -exportArchive → .ipa
  │   └── xcrun altool --upload-app → TestFlight
  │
  └── telegram.sh
      ├── notify_build_start (version, branch, commit, source)
      └── notify_build_finish (success/fail, duration)
```

## Scripts

All scripts are in `scripts/`. Copy them to the project root before running.

| Script | Purpose |
|--------|---------|
| `deploy.sh` | Main entry point — builds + deploys iOS and/or Android |
| `prod.sh` | Wrapper around deploy.sh — sets `PLAYSTORE_TRACK=internal` |
| `telegram.sh` | Sourced by deploy.sh — Telegram notification helpers |
| `prepare.sh` | Generates `.env.prod.git_vars.json` from `.app_dist/` assets for `gh secret set` |
| `upload-playstore.py` | Uploads AAB to Google Play Console via Android Publisher API v3 |

## Environment Variables (.env.prod)

Template at `assets/.env.example`. Fill in all values before running any deploy script.

### Required for iOS
- `APPLE_API_KEY_ID` — App Store Connect API key ID
- `ISSUER_ID` — App Store Connect issuer ID
- `APPLE_API_PRIVATE_KEY` — Private key content (with BEGIN/END lines)
- `TEAM_ID` — Apple Developer team ID (e.g., `86PC33ZDHF`)
- `BUNDLE_ID` — App bundle identifier (e.g., `app.shipflutter.mobile`)
- `P12_FILE` — Path to .p12 distribution certificate
- `P12_PASSWORD` — P12 certificate password
- `PROFILE_FILE` — Path to .mobileprovision
- `WWDR_CERT` — Path to AppleWWDRCAG3.cer

### Required for Android
- `ANDROID_KEYSTORE_FILE` — Path to .jks keystore
- `ANDROID_KEYSTORE_PASSWORD` — Keystore password
- `ANDROID_KEY_ALIAS` — Key alias
- `ANDROID_KEY_PASSWORD` — Key password
- `FIREBASE_APP_ID` — Firebase app identifier
- `FIREBASE_TOKEN` — Firebase CI token (from `firebase login:ci`)
- `FIREBASE_GROUPS` — Firebase tester group (e.g., `developer`)
- `PLAYSTORE_SERVICE_ACCOUNT_JSON` — Path to Google Play service account JSON
- `PLAYSTORE_PACKAGE_NAME` — Play Store package name
- `PLAYSTORE_TRACK` — internal/alpha/beta/production (default: `internal`)

### Required for Notifications
- `TELEGRAM_BOT_TOKEN` — Bot token from @BotFather
- `TELEGRAM_CHAT_ID` — Target chat/channel ID

## GitHub Actions CI/CD

Workflow template at `assets/github_workflows/deploy-uat.yml`. Copy to `.github/workflows/`.

### Required GitHub Secrets

Run `bash scripts/prepare.sh` to generate the secrets JSON, then:

```bash
gh secret set -f .env.prod.git_vars.json
```

Key secrets (see `resources/git_vars.json` in your project for full list):

| Secret | Type | Source |
|--------|------|--------|
| `APP_DIST_P12_B64` | base64 | `.app_dist/ship_flutter_cert_123123.p12` |
| `APP_DIST_PROFILE_B64` | base64 | `.app_dist/ShipFlutterAppstore.mobileprovision` |
| `APP_DIST_WWDR_B64` | base64 | `.app_dist/AppleWWDRCAG3.cer` |
| `ANDROID_KEYSTORE_B64` | base64 | `.app_dist/shipflutter.jks` |
| `PLAYSTORE_SERVICE_ACCOUNT_JSON_B64` | base64 | `.app_dist/playstore-service-account.json` |
| `APPLE_API_KEY_ID` | string | App Store Connect |
| `FIREBASE_TOKEN` | string | `firebase login:ci` |
| `TELEGRAM_BOT_TOKEN` | string | @BotFather |

### Workflow Behavior
- **Trigger**: push to `uat` branch or manual `workflow_dispatch`
- **iOS job** (macos-15): decode signing assets → build → TestFlight
- **Android job** (ubuntu-latest): decode keystore + SA JSON → APK → Firebase + AAB → Play Store internal

## .app_dist/ Directory

See `assets/app_dist_template/README.md` for which files to place there and how to obtain them.

## Common Tasks

### Set up deploy for a new Flutter project
1. Copy `scripts/` to project root
2. Copy `assets/.env.example` → `.env.prod` and fill in values
3. Create `.app_dist/` with signing assets (see template README)
4. Copy `assets/github_workflows/deploy-uat.yml` → `.github/workflows/`
5. Run `bash scripts/prepare.sh` → `gh secret set -f .env.prod.git_vars.json`
6. Push to `uat` branch to trigger CI deploy

### Deploy a new version manually
```bash
bash deploy.sh              # both platforms
bash deploy.sh ios          # iOS only
bash deploy.sh android      # Android only
```

### Troubleshoot deploy failures
1. Check `.env.prod` has all required vars set (not empty, not dummy values)
2. Verify `.app_dist/` files exist at the paths specified in `.env.prod`
3. Check iOS signing: `security find-identity -v -p codesigning`
4. Check Android signing: `keytool -list -v -keystore .app_dist/shipflutter.jks`
5. Run with `bash -x deploy.sh ios` for verbose output
6. Check Telegram for failure notification with commit and branch info

## References

- [Technical Design — Deploy Pipeline](references/ep01-shipflutter-deploy.md)
- [User Story — EP01.US001](references/EP01.US001.md)
