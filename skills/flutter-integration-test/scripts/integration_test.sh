#!/bin/bash
set -e

flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test
