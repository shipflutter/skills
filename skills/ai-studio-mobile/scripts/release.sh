#!/bin/bash
# Bump build number + build + distribute cả 2 platform.
#   Android: versionCode++ → APK → Firebase App Distribution
#   iOS:     CURRENT_PROJECT_VERSION++ → IPA → TestFlight (ASC key, không cần 2FA)
# Dùng: ./scripts/release.sh "release notes"
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NOTES="${1:-ProFocus build mới}"
AND="$ROOT/profocus-android"
IOS="$ROOT/profocus-ios"
ADIST="$ROOT/.app_dist"

export JAVA_HOME="${JAVA_HOME:-/Applications/Android Studio.app/Contents/jbr/Contents/Home}"
export ANDROID_HOME="${ANDROID_HOME:-/Volumes/Fightech/development/Android/sdk}"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export BUNDLE_ID="vn.fighttech.profocus" APP_NAME="ProFocus: Frame & Timer" TEAM_ID="86PC33ZDHF"
export ASC_KEY_ID="5F4KKWDHNV" ASC_ISSUER_ID="2e641cf7-9320-4b02-91f3-f125235014de"
export ASC_KEY_P8="$ADIST/AuthKey_5F4KKWDHNV.p8"
AND_FB_APP="1:1072339919335:android:4ff2605d0d769b2d261d42"
TESTERS="hieu.trantrung1204@gmail.com"

echo "▶ Bump version…"
# Android versionCode++
AVC=$(grep -oE 'versionCode [0-9]+' "$AND/app/build.gradle" | grep -oE '[0-9]+')
ANEW=$((AVC + 1))
sed -i '' "s/versionCode $AVC/versionCode $ANEW/" "$AND/app/build.gradle"
echo "  Android versionCode $AVC → $ANEW"
# iOS CURRENT_PROJECT_VERSION++
IVC=$(grep -oE 'CURRENT_PROJECT_VERSION: "[0-9]+"' "$IOS/project.yml" | grep -oE '[0-9]+')
INEW=$((IVC + 1))
sed -i '' "s/CURRENT_PROJECT_VERSION: \"$IVC\"/CURRENT_PROJECT_VERSION: \"$INEW\"/" "$IOS/project.yml"
echo "  iOS build $IVC → $INEW"

echo "▶ Android: build + distribute Firebase…"
( cd "$AND" && ./gradlew assembleDebug -q )
APK="$AND/app/build/outputs/apk/debug/app-debug.apk"
firebase appdistribution:distribute "$APK" --app "$AND_FB_APP" --project profocusx \
  --testers "$TESTERS" --release-notes "$NOTES" 2>&1 | grep -iE "uploaded|distributed|Error" | head -5

echo "▶ iOS: build IPA + upload TestFlight…"
( cd "$IOS" && xcodegen generate >/dev/null 2>&1 && fastlane build_ipa >/dev/null 2>&1 && fastlane testflight_upload 2>&1 | grep -iE "Successfully uploaded|Ready to upload|Error" | head -5 )

echo "✓ release xong (Android Firebase + iOS TestFlight)"
