#!/usr/bin/env bash
set -euo pipefail

flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test/app_test.dart
