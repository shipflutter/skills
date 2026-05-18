#!/bin/bash
set -e

flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test

flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_test.dart
