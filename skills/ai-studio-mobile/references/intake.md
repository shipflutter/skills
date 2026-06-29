# Intake questionnaire — ask before starting

## App identity
- App name (in-app) + Store title (globally unique; provide a ≤30-char fallback)
- New bundle/application id (iOS `PRODUCT_BUNDLE_IDENTIFIER`; Android `applicationId`)
- Android namespace: keep template's or change? (applicationId can differ from namespace)
- Marketing version (e.g. 1.0) + starting build number

## Firebase
- Firebase project id
- `google-services.json` (Android) + `GoogleService-Info.plist` (iOS) — request the files
- App Distribution App IDs: android `1:...:android:...`, ios `1:...:ios:...`
- Tester email(s) / group(s)

## Apple (TestFlight)
- Team ID
- ASC API key for upload (no 2FA): `.p8` file + Key ID + Issuer ID
- App record exists? If not, need Apple ID + app-specific password to run `produce` (2FA required)
- Export compliance: app uses non-exempt encryption? (usually no → `ITSAppUsesNonExemptEncryption=false`)

## Product features
- Languages (codes) + which is default; any RTL (ar)?
- Theme set (light/dark/system?)
- Brand palette (hex) + fonts
- Telegram support: bot token + chat_id
- Support / Privacy / Terms URLs

## Distribution & repos
- Git remote to clone the template from + repo to push to (branch, default `develop`)
- Landing page host + deploy method (rsync/scp/Pages)
- Android: Play Console access + upload keystore (for Phase 4)
