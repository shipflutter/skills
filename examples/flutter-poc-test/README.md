# Flutter POC Test

Demo Flutter app for three testing skills:

- `flutter-unit-test-coverage`: unit/widget tests plus coverage scripts.
- `flutter-integration-test`: `integration_test` flow without screenshots.
- `flutter-driver-screenshot-test`: `flutter drive` flow that saves screenshots on the host.

## App

The app is a deterministic score calculator. It uses fixed inputs by default:

- count: `12`
- multiplier: `8`
- discount: `10`
- total: `86.40`
- rating: `Growth`

No network, timers, randomness, device plugins, or DateTime are used.

## Files

- `lib/src/score_calculator.dart`: pure business logic for unit coverage.
- `test/score_calculator_test.dart`: unit tests.
- `test/widget_test.dart`: widget tests.
- `integration_test/app_test.dart`: normal integration test, no screenshots.
- `integration_test/screenshot_test.dart`: screenshot integration target.
- `integration_test/helpers/screenshot_helper.dart`: calls `takeScreenshot`, does not write files.
- `test_driver/integration_test.dart`: host driver that writes PNG files into `screenshots/`.
- `run_test.sh`: coverage script.
- `integration_test.sh`: normal integration test script.
- `e2e.sh`: screenshot driver script.

## Commands

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Coverage:

```bash
./run_test.sh --test
./run_test.sh --report
```

Normal integration test without screenshots:

```bash
./integration_test.sh
```

Screenshot driver test:

```bash
flutter devices
./e2e.sh <device-id>
```

Expected artifacts:

- `coverage/lcov.info`
- `coverage/html/index.html` when `genhtml` is installed
- `screenshots/score_calculator_home-<platform>.png`
