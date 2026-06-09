#!/usr/bin/env bash
#===============================================================================
# deploy.sh — ShipFlutter iOS + Android Build & Deploy
#
# Usage:
#   ./deploy.sh                  # both iOS + Android (internal testing tracks)
#   ./deploy.sh ios              # iOS only → TestFlight
#   ./deploy.sh android          # Android only → Firebase + Play Store (internal)
#
# Prerequisites:
#   .env.prod            — filled from .env.example template (gitignored)
#   .app_dist/           — signing assets: P12, profile, WWDR, keystore, SA JSON
#   scripts/telegram.sh  — Telegram notification helpers (sourced at runtime)
#   scripts/upload-playstore.py — Play Store AAB upload (requires google-auth)
#
# Required env vars (from .env.prod):
#   iOS:  APPLE_API_KEY_ID, ISSUER_ID, APPLE_API_PRIVATE_KEY, TEAM_ID,
#         BUNDLE_ID, P12_FILE, P12_PASSWORD, PROFILE_FILE, WWDR_CERT,
#         TEMP_KEYCHAIN_NAME, TEMP_KEYCHAIN_PASS
#   Android: ANDROID_KEYSTORE_FILE, ANDROID_KEYSTORE_PASSWORD,
#            ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD,
#            FIREBASE_APP_ID, FIREBASE_TOKEN, FIREBASE_GROUPS,
#            PLAYSTORE_SERVICE_ACCOUNT_JSON, PLAYSTORE_PACKAGE_NAME
#   Telegram: TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID
#
# Architecture:
#   ┌─ deploy.sh ─────────────────────────────────────────────┐
#   │  1. Source .env.prod + parse pubspec.yaml version       │
#   │  2. Android: keystore → APK (Firebase) + AAB (Play)    │
#   │  3. iOS:     P12 keychain → archive → export → altool  │
#   │  4. Telegram: notify_build_start / notify_build_finish │
#   └────────────────────────────────────────────────────────┘
#
# Exit codes:  0 = success, 1 = build/upload failure
#
# Config: .env.prod (see .env.example for template)
# Version: auto-parsed from pubspec.yaml
# Tracks:  Play Store → internal testing (set via PLAYSTORE_TRACK env var)
#===============================================================================

#===============================================================================

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── Platform selection ──────────────────────────────────────────────────────
PLATFORM="${1:-all}"
case "$PLATFORM" in
  ios|android|all) ;;
  *) echo -e "${RED}Usage: ./deploy.sh [ios|android|all]${NC}"; exit 1 ;;
esac
DEPLOY_IOS=false; DEPLOY_ANDROID=false
[[ "$PLATFORM" == "ios" || "$PLATFORM" == "all" ]] && DEPLOY_IOS=true
[[ "$PLATFORM" == "android" || "$PLATFORM" == "all" ]] && DEPLOY_ANDROID=true

# ── Project root ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
APP_DIST="$PROJECT_ROOT/.app_dist"
PUBSPEC="$PROJECT_ROOT/pubspec.yaml"
IOS_DIR="$PROJECT_ROOT/ios"

# ── Load .env.prod ──────────────────────────────────────────────────────────
LOCAL_ENV="$PROJECT_ROOT/.env.prod"
if [[ -f "$LOCAL_ENV" ]]; then
  echo "Loading deploy environment: $LOCAL_ENV"
  set -a
  source "$LOCAL_ENV"
  set +a
else
  echo -e "${RED}$LOCAL_ENV not found. Copy .env.example to .env.prod and fill in values.${NC}"
  exit 1
fi

# ── Validate required vars ──────────────────────────────────────────────────
REQUIRED_VARS=(APPLE_API_KEY_ID ISSUER_ID APPLE_API_PRIVATE_KEY
               TEAM_ID BUNDLE_ID
               TEMP_KEYCHAIN_NAME TEMP_KEYCHAIN_PASS)
MISSING_VARS=()
for var in "${REQUIRED_VARS[@]}"; do
  [[ -z "${!var:-}" ]] && MISSING_VARS+=("$var")
done

# Android-specific required vars
if $DEPLOY_ANDROID; then
  for var in ANDROID_KEYSTORE_FILE ANDROID_KEYSTORE_PASSWORD ANDROID_KEY_ALIAS ANDROID_KEY_PASSWORD FIREBASE_APP_ID; do
    [[ -z "${!var:-}" ]] && MISSING_VARS+=("$var")
  done
fi

# iOS-specific required vars
if $DEPLOY_IOS; then
  for var in P12_FILE P12_PASSWORD PROFILE_FILE; do
    [[ -z "${!var:-}" ]] && MISSING_VARS+=("$var")
  done
fi

[[ ${#MISSING_VARS[@]} -gt 0 ]] && {
  echo -e "\n${RED}Missing required config in .env.prod:${NC}"
  for var in "${MISSING_VARS[@]}"; do echo "  - $var"; done
  exit 1
}

# Resolve relative paths
[[ -n "${APP_DIST:-}" ]] || APP_DIST="$PROJECT_ROOT/.app_dist"
$DEPLOY_IOS && [[ -n "${P12_FILE:-}" && ! "$P12_FILE" =~ ^/ ]] && P12_FILE="$PROJECT_ROOT/$P12_FILE"
$DEPLOY_IOS && [[ -n "${PROFILE_FILE:-}" && ! "$PROFILE_FILE" =~ ^/ ]] && PROFILE_FILE="$PROJECT_ROOT/$PROFILE_FILE"
$DEPLOY_IOS && [[ -n "${WWDR_CERT:-}" && ! "$WWDR_CERT" =~ ^/ ]] && WWDR_CERT="$PROJECT_ROOT/$WWDR_CERT"
$DEPLOY_ANDROID && [[ -n "${ANDROID_KEYSTORE_FILE:-}" && ! "$ANDROID_KEYSTORE_FILE" =~ ^/ ]] && ANDROID_KEYSTORE_FILE="$PROJECT_ROOT/$ANDROID_KEYSTORE_FILE"

ARCHIVE_DIR="${ARCHIVE_DIR:-build/ios/archive}"
EXPORT_DIR="${EXPORT_DIR:-build/ios/ipa}"
ANDROID_APK_DIR="${ANDROID_APK_DIR:-build/app/outputs/flutter-apk}"
ARCHIVE_PATH="$PROJECT_ROOT/$ARCHIVE_DIR/Runner.xcarchive"
EXPORT_PATH="$PROJECT_ROOT/$EXPORT_DIR"

# ── Helper Functions ────────────────────────────────────────────────────────
step()  { echo -e "\n${BOLD}${CYAN}[$1/$TOTAL_STEPS]${NC} $2"; }
ok()    { echo -e "         ${GREEN}✓${NC} $1"; }
fail()  { echo -e "         ${RED}✗${NC} $1"; }
info()  { echo -e "         $1"; }
banner() {
  local plat_label="iOS + Android"
  $DEPLOY_IOS && ! $DEPLOY_ANDROID && plat_label="iOS"
  ! $DEPLOY_IOS && $DEPLOY_ANDROID && plat_label="Android"
  echo -e "${BOLD}"
  printf '  ╔══════════════════════════════════════════════════════════════╗\n'
  printf '  ║   ShipFlutter %-9s Deploy %-21s ║\n' "$plat_label" "v${VERSION}+${BUILD_NO}"
  printf '  ╚══════════════════════════════════════════════════════════════╝\n'
  echo -e "${NC}"
}

# ── Source Telegram helpers ─────────────────────────────────────────────────
TELEGRAM_SCRIPT="$PROJECT_ROOT/scripts/telegram.sh"
[[ -f "$TELEGRAM_SCRIPT" ]] && source "$TELEGRAM_SCRIPT"

# ── Cleanup + trap ──────────────────────────────────────────────────────────
cleanup() {
  if $DEPLOY_IOS; then
    restore_xcode_signing 2>/dev/null || true
    if security list-keychains 2>/dev/null | grep -q "$TEMP_KEYCHAIN_NAME"; then
      security delete-keychain "$TEMP_KEYCHAIN_NAME" 2>/dev/null || true
    fi
  fi
}
trap cleanup EXIT
trap 'on_telegram_error' ERR 2>/dev/null || true

# ── iOS-specific: patch Xcode project ───────────────────────────────────────
if $DEPLOY_IOS; then
  patch_xcode_signing() {
    local pbxproj="$IOS_DIR/Runner.xcodeproj/project.pbxproj"
    cp "$pbxproj" "$pbxproj.bak"
    sed -i '' 's/CODE_SIGN_STYLE = Automatic;/CODE_SIGN_STYLE = Manual;/g' "$pbxproj"
    sed -i '' "s/DEVELOPMENT_TEAM = [A-Z0-9]\{1,\};/DEVELOPMENT_TEAM = $TEAM_ID;/g" "$pbxproj"
    if ! grep -q "PROVISIONING_PROFILE_SPECIFIER" "$pbxproj"; then
      sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;\\n\\t\\t\\t\\tPROVISIONING_PROFILE_SPECIFIER = \\"$PROVISIONING_PROFILE_NAME\\";/g" "$pbxproj"
    fi
    sed -i '' 's/"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" = "iPhone Developer";/"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Distribution";/g' "$pbxproj"
    ok "Xcode project patched (team: $TEAM_ID)"
  }
  restore_xcode_signing() {
    local pbxproj="$IOS_DIR/Runner.xcodeproj/project.pbxproj"
    [[ -f "$pbxproj.bak" ]] && mv "$pbxproj.bak" "$pbxproj"
  }
fi

# ═════════════════════════════════════════════════════════════════════════════
# Parse version
echo -e "${BOLD}${CYAN}[init]${NC} Parsing version from pubspec.yaml..."
VERSION_LINE=$(grep "^version:" "$PUBSPEC" | head -1)
VERSION=$(echo "$VERSION_LINE" | sed -E 's/version: *([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
BUILD_NO=$(echo "$VERSION_LINE" | sed -E 's/version:.*\+([0-9]+).*/\1/')
ok "Version: ${VERSION}  Build: ${BUILD_NO}"

# Calculate total steps
TOTAL_STEPS=0; $DEPLOY_ANDROID && TOTAL_STEPS=$((TOTAL_STEPS + 4)); $DEPLOY_IOS && TOTAL_STEPS=$((TOTAL_STEPS + 4))
CURRENT_STEP=0

echo ""
banner

# ── Notify Telegram ─────────────────────────────────────────────────────────
notify_build_start "ShipFlutter" "v${VERSION}+${BUILD_NO}" "$PLATFORM"

# ═════════════════════════════════════════════════════════════════════════════
# ANDROID PIPELINE
# ═════════════════════════════════════════════════════════════════════════════
if $DEPLOY_ANDROID; then

  # ── Android Step 1: Setup keystore ────────────────────────────────────────
  CURRENT_STEP=$((CURRENT_STEP + 1))
  step $CURRENT_STEP "Android: Setting up signing keystore"

  mkdir -p "$PROJECT_ROOT/android"
  cat > "$PROJECT_ROOT/android/key.properties" << KEYEOF
storePassword=${ANDROID_KEYSTORE_PASSWORD}
keyPassword=${ANDROID_KEY_PASSWORD}
keyAlias=${ANDROID_KEY_ALIAS}
storeFile=$PROJECT_ROOT/.app_dist/shipflutter.jks
KEYEOF
  ok "key.properties created"

  # ── Android Step 2: Build APK ─────────────────────────────────────────────
  CURRENT_STEP=$((CURRENT_STEP + 1))
  step $CURRENT_STEP "Android: Building release APK"
  info "Running: flutter build apk --release"
  echo "         ───────────────────────────────────────────────"

  BUILD_LOG=$(mktemp)
  set +e
  flutter build apk --release \
      --build-name="$VERSION" \
      --build-number="$BUILD_NO" \
      > "$BUILD_LOG" 2>&1
  APK_EXIT=$?
  set -e
  tail -30 "$BUILD_LOG"

  if [[ $APK_EXIT -eq 0 ]]; then
    ok "APK build succeeded"
  else
    fail "APK build FAILED (exit: $APK_EXIT)"
    tail -30 "$BUILD_LOG"
    rm -f "$BUILD_LOG"
    exit $APK_EXIT
  fi
  rm -f "$BUILD_LOG"

  APK_FILE=$(find "$PROJECT_ROOT/$ANDROID_APK_DIR" -name "app-release.apk" -type f 2>/dev/null | head -1)
  if [[ -z "$APK_FILE" ]]; then
    fail "APK not found in $ANDROID_APK_DIR"
    exit 1
  fi
  ok "APK: $(basename "$APK_FILE") ($(du -h "$APK_FILE" | cut -f1))"

  # ── Android Step 3: Upload to Firebase App Distribution ────────────────────
  CURRENT_STEP=$((CURRENT_STEP + 1))
  step $CURRENT_STEP "Android: Uploading to Firebase App Distribution"

  if [[ -z "${FIREBASE_TOKEN:-}" ]]; then
    info "FIREBASE_TOKEN not set — skipping Firebase upload"
  else
    # Install firebase CLI if missing
    if ! command -v firebase &>/dev/null; then
      info "Installing firebase-tools..."
      npm install -g firebase-tools 2>/dev/null || true
    fi

    RELEASE_NOTES="ShipFlutter v${VERSION} (build ${BUILD_NO}) — $(git -C "$PROJECT_ROOT" log -1 --format=%s 2>/dev/null || echo Release)"

    FIREBASE_OUTPUT=$(firebase appdistribution:distribute "$APK_FILE" \
      --app "$FIREBASE_APP_ID" \
      --release-notes "$RELEASE_NOTES" \
      --groups "$FIREBASE_GROUPS" \
      --token "$FIREBASE_TOKEN" 2>&1)
    FIREBASE_EXIT=$?

    if [[ $FIREBASE_EXIT -eq 0 ]]; then
      ok "Uploaded to Firebase App Distribution"
      echo -e "${GREEN}$FIREBASE_OUTPUT${NC}" | tail -5
    else
      fail "Firebase upload FAILED"
      echo -e "${RED}$FIREBASE_OUTPUT${NC}" | tail -10
    fi
  fi

  # ── Android Step 4: Upload to Google Play Store ───────────────────────────
  CURRENT_STEP=$((CURRENT_STEP + 1))
  step $CURRENT_STEP "Android: Uploading to Google Play Store (${PLAYSTORE_TRACK:-internal})"

  if [[ -z "${PLAYSTORE_SERVICE_ACCOUNT_JSON:-}" || ! -f "$PROJECT_ROOT/$PLAYSTORE_SERVICE_ACCOUNT_JSON" ]]; then
    info "Play Store service account JSON not found — skipping"
  else
    # Build AAB for Play Store
    info "Building Android App Bundle..."
    AAB_LOG=$(mktemp)
    set +e
    flutter build appbundle --release         --build-name="$VERSION"         --build-number="$BUILD_NO"         > "$AAB_LOG" 2>&1
    AAB_EXIT=$?
    set -e
    tail -10 "$AAB_LOG"
    rm -f "$AAB_LOG"

    if [[ $AAB_EXIT -ne 0 ]]; then
      fail "AAB build FAILED"
    else
      AAB_FILE=$(find "$PROJECT_ROOT/build/app/outputs/bundle/release" -name "app-release.aab" -type f 2>/dev/null | head -1)
      if [[ -z "$AAB_FILE" ]]; then
        fail "AAB not found"
      else
        ok "AAB: $(basename "$AAB_FILE") ($(du -h "$AAB_FILE" | cut -f1))"

        # Upload to Play Store
        pip3 install --quiet google-auth google-api-python-client 2>/dev/null || true
        PLAYSTORE_OUTPUT=$(python3 "$PROJECT_ROOT/scripts/upload-playstore.py"           --aab "$AAB_FILE"           --service-account-json "$PROJECT_ROOT/$PLAYSTORE_SERVICE_ACCOUNT_JSON"           --package-name "${PLAYSTORE_PACKAGE_NAME:-app.shipflutter.mobile}"           --track "${PLAYSTORE_TRACK:-internal}" 2>&1)
        PS_EXIT=$?

        if [[ $PS_EXIT -eq 0 ]]; then
          ok "Uploaded to Play Store (${PLAYSTORE_TRACK:-internal} track)"
          echo -e "${GREEN}$PLAYSTORE_OUTPUT${NC}"
        else
          fail "Play Store upload FAILED"
          echo -e "${RED}$PLAYSTORE_OUTPUT${NC}"
        fi
      fi
    fi
  fi

fi

# ═════════════════════════════════════════════════════════════════════════════
# IOS PIPELINE
# ═════════════════════════════════════════════════════════════════════════════
if $DEPLOY_IOS; then

  # ── iOS Step 1: Setup keychain + certs ────────────────────────────────────
  CURRENT_STEP=$((CURRENT_STEP + 1))
  step $CURRENT_STEP "iOS: Setting up signing assets"

  info "Creating temp keychain..."
  security create-keychain -p "$TEMP_KEYCHAIN_PASS" "$TEMP_KEYCHAIN_NAME" 2>/dev/null || true
  security list-keychains -d user -s "$TEMP_KEYCHAIN_NAME" "$(security list-keychains -d user | sed 's/"//g')" 2>/dev/null
  security set-keychain-settings -lut 21600 "$TEMP_KEYCHAIN_NAME" 2>/dev/null
  security unlock-keychain -p "$TEMP_KEYCHAIN_PASS" "$TEMP_KEYCHAIN_NAME" 2>/dev/null
  security unlock-keychain -p "${KEYCHAIN_UNLOCK_PASS:-}" "$TEMP_KEYCHAIN_NAME" 2>/dev/null || true

  if [[ -n "${WWDR_CERT:-}" && -f "$WWDR_CERT" ]]; then
    info "Importing Apple WWDR intermediate cert..."
    security import "$WWDR_CERT" -k "$TEMP_KEYCHAIN_NAME" -T /usr/bin/codesign 2>/dev/null || true
  fi

  info "Importing P12 certificate..."
  if ! security import "$P12_FILE" -k "$TEMP_KEYCHAIN_NAME" -P "$P12_PASSWORD" -T /usr/bin/codesign -T /usr/bin/security -T /usr/bin/xcodebuild 2>/tmp/p12_error.log; then
    fail "P12 import failed. Wrong password?"
    cat /tmp/p12_error.log
    exit 1
  fi
  ok "P12 certificate imported"

  security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$TEMP_KEYCHAIN_PASS" "$TEMP_KEYCHAIN_NAME" 2>/dev/null
  security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "${KEYCHAIN_UNLOCK_PASS:-}" "$TEMP_KEYCHAIN_NAME" 2>/dev/null || true

  PROFILE_DEST="${PROFILE_DEST:-$HOME/Library/MobileDevice/Provisioning Profiles}"
  mkdir -p "$PROFILE_DEST"
  cp "$PROFILE_FILE" "$PROFILE_DEST/ShipFlutterAppstore.mobileprovision"
  ok "Provisioning profile installed"

  # ── iOS Step 2: Build ─────────────────────────────────────────────────────
  CURRENT_STEP=$((CURRENT_STEP + 1))
  step $CURRENT_STEP "iOS: Building Flutter release"
  info "Running: flutter build ipa --release"
  echo "         ───────────────────────────────────────────────"
  patch_xcode_signing

  flutter clean >/dev/null 2>&1 || true

  BUILD_LOG=$(mktemp)
  set +e
  flutter build ipa --release \
      --build-name="$VERSION" \
      --build-number="$BUILD_NO" \
      > "$BUILD_LOG" 2>&1
  IOS_EXIT=$?
  set -e
  tail -30 "$BUILD_LOG"

  if [[ $IOS_EXIT -eq 0 ]]; then
    restore_xcode_signing
    ok "Build succeeded"
    rm -f "$BUILD_LOG"
  else
    restore_xcode_signing
    fail "Build FAILED (exit: $IOS_EXIT)"
    tail -30 "$BUILD_LOG"
    rm -f "$BUILD_LOG"
    exit $IOS_EXIT
  fi

  # ── iOS Step 3: Export IPA ────────────────────────────────────────────────
  CURRENT_STEP=$((CURRENT_STEP + 1))
  step $CURRENT_STEP "iOS: Exporting signed IPA"

  mkdir -p "$EXPORT_PATH"
  EXPORT_OPTIONS="$PROJECT_ROOT/build/ios/ExportOptions.plist"
  cat > "$EXPORT_OPTIONS" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>$BUNDLE_ID</key>
        <string>${PROVISIONING_PROFILE_NAME:-ShipFlutterAppstore}</string>
    </dict>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
PLIST

  export CODE_SIGN_KEYCHAIN="$TEMP_KEYCHAIN_NAME"
  info "Exporting archive..."

  EXPORT_LOG=$(mktemp)
  set +e
  xcodebuild -exportArchive \
      -archivePath "$ARCHIVE_PATH" \
      -exportPath "$EXPORT_PATH" \
      -exportOptionsPlist "$EXPORT_OPTIONS" \
      -allowProvisioningUpdates \
      > "$EXPORT_LOG" 2>&1
  EXPORT_EXIT=$?
  set -e
  tail -10 "$EXPORT_LOG"

  if [[ $EXPORT_EXIT -eq 0 ]]; then
    ok "Export succeeded"
    rm -f "$EXPORT_LOG"
  else
    fail "Export FAILED (exit: $EXPORT_EXIT)"
    tail -10 "$EXPORT_LOG"
    rm -f "$EXPORT_LOG"
    exit $EXPORT_EXIT
  fi

  IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" -type f 2>/dev/null | head -1)
  [[ -z "$IPA_FILE" ]] && { fail "No .ipa found"; exit 1; }
  ok "IPA: $(basename "$IPA_FILE") ($(du -h "$IPA_FILE" | cut -f1))"

  # ── iOS Step 4: Upload to TestFlight ──────────────────────────────────────
  CURRENT_STEP=$((CURRENT_STEP + 1))
  step $CURRENT_STEP "iOS: Uploading to TestFlight"

  API_KEY_FILE=$(mktemp)
  echo "$APPLE_API_PRIVATE_KEY" > "$API_KEY_FILE"
  chmod 600 "$API_KEY_FILE"

  UPLOAD_OUTPUT=$(xcrun altool --upload-app \
      -f "$IPA_FILE" -t ios \
      --apiKey "$APPLE_API_KEY_ID" \
      --apiIssuer "$ISSUER_ID" 2>&1)
  UPLOAD_EXIT=$?
  rm -f "$API_KEY_FILE"

  if [[ $UPLOAD_EXIT -ne 0 ]]; then
    info "Retrying in 10s..."
    sleep 10
    API_KEY_FILE=$(mktemp)
    echo "$APPLE_API_PRIVATE_KEY" > "$API_KEY_FILE"
    chmod 600 "$API_KEY_FILE"
    UPLOAD_OUTPUT=$(xcrun altool --upload-app \
        -f "$IPA_FILE" -t ios \
        --apiKey "$APPLE_API_KEY_ID" \
        --apiIssuer "$ISSUER_ID" 2>&1)
    UPLOAD_EXIT=$?
    rm -f "$API_KEY_FILE"
  fi

  if [[ $UPLOAD_EXIT -eq 0 ]]; then
    ok "Upload successful"
    echo -e "${GREEN}$UPLOAD_OUTPUT${NC}" | tail -8
  else
    fail "Upload FAILED"
    echo -e "${RED}$UPLOAD_OUTPUT${NC}" | tail -10
    exit $UPLOAD_EXIT
  fi
fi

# ── Done ────────────────────────────────────────────────────────────────────
elapsed="${SECONDS}s total"
notify_build_finish "true" "ShipFlutter" "v${VERSION}+${BUILD_NO}" "$PLATFORM"
trap - ERR

echo ""
echo -e "  ${GREEN}┌──────────────────────────────────────────────────────────────┐${NC}"
echo -e "  ${GREEN}│${NC}  ${BOLD}✓ DEPLOY COMPLETE${NC}"
echo -e "  ${GREEN}│${NC}"
echo -e "  ${GREEN}│${NC}  App:     ShipFlutter (${BUNDLE_ID})"
echo -e "  ${GREEN}│${NC}  Version: ${VERSION} (build ${BUILD_NO})"
echo -e "  ${GREEN}│${NC}  Platform: ${PLATFORM}"
echo -e "  ${GREEN}│${NC}  Time:    ${elapsed}"
echo -e "  ${GREEN}└──────────────────────────────────────────────────────────────┘${NC}\n"
echo -e "  ${CYAN}URL:${NC}     https://appstoreconnect.apple.com/apps"
