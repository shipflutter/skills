#!/usr/bin/env bash
set -euo pipefail

DEVICE_ID="${1:-}"
DEVICE_ARGS=()
if [[ -n "$DEVICE_ID" ]]; then
  DEVICE_ARGS=(-d "$DEVICE_ID")
fi

flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_test.dart \
  "${DEVICE_ARGS[@]}"
