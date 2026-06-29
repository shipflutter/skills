# Gotchas & fixes (hard-won)

## fastlane / iOS signing
- **`invalid byte sequence in US-ASCII`** (CertChecker chokes on non-ASCII cert names):
  always run fastlane with `export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8`.
- **`produce` "Could not find option 'api_key'"**: `produce` (app creation) does NOT accept an ASC
  API key — authenticate with the Apple ID (`username: ENV["FASTLANE_USER"]`).
- **TestFlight upload** (`pilot`/`upload_to_testflight`) DOES use the ASC API key → **no 2FA**.
  So once the app record exists, all subsequent builds upload non-interactively.
- **App name already in use**: App Store names are globally unique. Use a ≤30-char variant.
- **Non-interactive 2FA** (only needed for `produce`): create a FIFO and a holder that keeps the
  write end open, then feed the code:
  ```
  mkfifo /tmp/p2fa; nohup sleep 99999 > /tmp/p2fa &
  # fastlane reads the 2FA code from the FIFO; when prompted:
  echo "123456" > /tmp/p2fa
  ```
- **simctl screenshot to an external `/Volumes` path** fails NSCocoa 513 → write to `/tmp` then `cp`.

## Android
- **Photo/HTTP send fails on Android 9+ (targetSdk ≥ 28)**: cleartext HTTP blocked. Add
  `android:usesCleartextTraffic="true"` to `<application>`. (iOS counterpart: `NSAllowsLocalNetworking`.)
- **CameraX needs API 21 but minSdk 18**: gate scanner to API 21+ and add
  `<uses-sdk tools:overrideLibrary="androidx.camera.core,androidx.camera.camera2,androidx.camera.lifecycle,androidx.camera.view" />`.
- **Theme switching (AppCompatDelegate night mode) only shows if the theme is DayNight**: make the
  settings/secondary themes `Theme.AppCompat.DayNight.*` and use `?android:attr/colorBackground` /
  `?android:attr/textColorPrimary` instead of hardcoded `@color/white`/`@color/black`.
- Build with JBR Java 21: `JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"`.

## iOS 12 support
- No `SceneDelegate` — use `AppDelegate` + `UIWindow`.
- Guard 13+ APIs (`monospacedSystemFont`, `overrideUserInterfaceStyle`, `selectedSegmentTintColor`).
- Setting a `UIDatePicker` `textColor` via KVC: guard `responds(to: setTextColor:)` to avoid crashes.

## Networking on device
- Local-network features need iOS `NSLocalNetworkUsageDescription` + `NSAllowsLocalNetworking`,
  and Android cleartext. Downsample images (≤2048px) before sending over WiFi.
