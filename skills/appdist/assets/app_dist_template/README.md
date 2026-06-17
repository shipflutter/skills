# .app_dist/ — Signing Assets Directory

Place these files here before running any deploy script. This directory is **gitignored** — never commit it.

## Required Files

| File | Platform | Purpose |
|------|----------|---------|
| `ship_flutter_cert_123123.p12` | iOS | Apple Distribution certificate (export from Keychain) |
| `ShipFlutterAppstore.mobileprovision` | iOS | App Store provisioning profile |
| `AppleWWDRCAG3.cer` | iOS | Apple WWDR intermediate certificate |
| `shipflutter.jks` | Android | Release signing keystore |
| `playstore-service-account.json` | Android | Google Play Console service account key |

## Getting the Files

### iOS
- P12: Keychain Access → My Certificates → export "Apple Distribution: ..." as .p12
- Mobileprovision: Download from [Apple Developer](https://developer.apple.com/account/resources/profiles/list)
- WWDR: Download from [Apple PKI](https://www.apple.com/certificateauthority/) → AppleWWDRCAG3.cer

### Android
- Keystore: Generate with `keytool -genkey -v -keystore shipflutter.jks -alias shipflutter -keyalg RSA -keysize 2048 -validity 10000`
- Service account JSON: Google Play Console → Setup → API Access → Create Service Account → download JSON key

## Security
- All files in this directory are gitignored
- Never commit signing keys or certificates
- Use `prepare.sh` to generate base64-encoded versions for GitHub Secrets
