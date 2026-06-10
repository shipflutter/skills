#!/usr/bin/env bash
#===============================================================================
# prepare.sh — Generate GitHub Secrets JSON from signing assets
#
# Usage:
#   bash scripts/prepare.sh
#
# Overview:
#   Reads signing assets from .app_dist/ and string secrets from .env.prod,
#   then produces two JSON files:
#
#     .env.prod.git_vars.json   —  Full values (gitignored)
#     resources/git_vars.json   —  Key names only (committed)
#
#   After running, push secrets to GitHub:
#     gh secret set -f .env.prod.git_vars.json
#
# Asset discovery (configurable via env vars, falls back to convention):
#   IOS_P12_PATH          —  .app_dist/ship_flutter_cert_123123.p12
#   IOS_PROFILE_PATH      —  .app_dist/ShipFlutterAppstore.mobileprovision
#   IOS_WWDR_PATH         —  .app_dist/AppleWWDRCAG3.cer
#   ANDROID_KEYSTORE_PATH —  .app_dist/shipflutter.jks
#   PLAYSTORE_SA_PATH     —  .app_dist/playstore-service-account.json
#
#   String secrets read from .env.prod:
#   ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD,
#   APPLE_API_KEY_ID, ISSUER_ID, P12_PASSWORD, APPLE_API_PRIVATE_KEY,
#   FIREBASE_APP_ID, FIREBASE_TOKEN, FIREBASE_GROUPS,
#   TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID,
#   PLAYSTORE_PACKAGE_NAME, PLAYSTORE_TRACK
#
# Architecture:
#   Embedding a Python script avoids shell-level encoding quirks. base64
#   encoding is done by Python for byte-clean output. The shell wrapper
#   ensures the script is always run from the project root.
#===============================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[0;33m'; NC='\033[0m'
echo -e "${CYAN}Preparing secrets from .app_dist/ ...${NC}"

python3 << 'PYEOF'
import os, json, base64, re

app_dist = os.environ.get("APP_DIST", ".app_dist")
output_file = ".env.prod.git_vars.json"
ref_file = "resources/git_vars.json"
vars_data = {}

def b64(path):
    if os.path.isfile(path):
        with open(path, "rb") as f:
            return base64.b64encode(f.read()).decode()
    return ""

def parse_env(key):
    """Parse a KEY=value or KEY="value" line from .env.prod"""
    if not os.path.isfile(".env.prod"):
        return ""
    with open(".env.prod") as f:
        for line in f:
            m = re.match(rf'^{key}=["\']?(.+?)["\']?\s*$', line)
            if m:
                return m.group(1).strip()
    return ""

# ── Asset paths (env var overrides with convention fallback) ────────────────
ios_p12  = os.environ.get("IOS_P12_PATH",  f"{app_dist}/ship_flutter_cert_123123.p12")
ios_prof = os.environ.get("IOS_PROFILE_PATH", f"{app_dist}/ShipFlutterAppstore.mobileprovision")
ios_wwdr = os.environ.get("IOS_WWDR_PATH", f"{app_dist}/AppleWWDRCAG3.cer")
android_ks = os.environ.get("ANDROID_KEYSTORE_PATH", f"{app_dist}/shipflutter.jks")
ps_sa  = os.environ.get("PLAYSTORE_SA_PATH", f"{app_dist}/playstore-service-account.json")

# ── iOS signing assets ──────────────────────────────────────────────────────
missing_ios = False
p12_b64 = b64(ios_p12)
if p12_b64:
    vars_data["APP_DIST_P12_B64"] = p12_b64
    print(f"  \033[32m✓\033[0m APP_DIST_P12_B64 ({ios_p12})")
else:
    print(f"  \033[33m⚠\033[0m iOS P12 not found: {ios_p12}")

profile_b64 = b64(ios_prof)
if profile_b64:
    vars_data["APP_DIST_PROFILE_B64"] = profile_b64
    print(f"  \033[32m✓\033[0m APP_DIST_PROFILE_B64 ({ios_prof})")
else:
    print(f"  \033[33m⚠\033[0m iOS profile not found: {ios_prof}")

wwdr_b64 = b64(ios_wwdr)
if wwdr_b64:
    vars_data["APP_DIST_WWDR_B64"] = wwdr_b64
    print(f"  \033[32m✓\033[0m APP_DIST_WWDR_B64 ({ios_wwdr})")
else:
    print(f"  \033[33m⚠\033[0m WWDR cert not found: {ios_wwdr}")

# ── Android signing assets ──────────────────────────────────────────────────
ks_b64 = b64(android_ks)
if ks_b64:
    vars_data["ANDROID_KEYSTORE_B64"] = ks_b64
    print(f"  \033[32m✓\033[0m ANDROID_KEYSTORE_B64 ({android_ks})")
else:
    print(f"  \033[33m⚠\033[0m Android keystore not found: {android_ks}")

for key, label in [
    ("ANDROID_KEYSTORE_PASSWORD", "Keystore password"),
    ("ANDROID_KEY_ALIAS",         "Key alias"),
    ("ANDROID_KEY_PASSWORD",      "Key password"),
]:
    val = parse_env(key)
    if val:
        vars_data[key] = val
        print(f"  \033[32m✓\033[0m {key}")
    else:
        print(f"  \033[31m✗\033[0m {key}: missing — set in .env.prod ({label})")

# ── Apple API credentials ───────────────────────────────────────────────────
print("\nApple API:")
for key in ["APPLE_API_KEY_ID", "ISSUER_ID", "P12_PASSWORD", "APPLE_API_PRIVATE_KEY"]:
    val = parse_env(key)
    if val:
        vars_data[key] = val
        print(f"  \033[32m✓\033[0m {key}")
    else:
        print(f"  \033[33m⚠\033[0m {key}: empty")

# ── Firebase ────────────────────────────────────────────────────────────────
print("\nFirebase:")
for key in ["FIREBASE_APP_ID", "FIREBASE_TOKEN", "FIREBASE_GROUPS"]:
    val = parse_env(key)
    if val:
        vars_data[key] = val
        print(f"  \033[32m✓\033[0m {key}")
    else:
        print(f"  \033[33m⚠\033[0m {key}: empty")

# ── Telegram ────────────────────────────────────────────────────────────────
print("\nTelegram:")
for key in ["TELEGRAM_BOT_TOKEN", "TELEGRAM_CHAT_ID"]:
    val = parse_env(key)
    if val:
        vars_data[key] = val
        print(f"  \033[32m✓\033[0m {key}")
    else:
        print(f"  \033[33m⚠\033[0m {key}: empty")

# ── Google Play Store ───────────────────────────────────────────────────────
print("\nGoogle Play Store:")
ps_json = b64(ps_sa)
if ps_json:
    vars_data["PLAYSTORE_SERVICE_ACCOUNT_JSON_B64"] = ps_json
    print(f"  \033[32m✓\033[0m PLAYSTORE_SERVICE_ACCOUNT_JSON_B64 ({ps_sa})")
else:
    print(f"  \033[33m⚠\033[0m Play Store service account JSON not found: {ps_sa}")

ps_pkg = parse_env("PLAYSTORE_PACKAGE_NAME")
if ps_pkg:
    vars_data["PLAYSTORE_PACKAGE_NAME"] = ps_pkg
    print(f"  \033[32m✓\033[0m PLAYSTORE_PACKAGE_NAME: {ps_pkg}")
else:
    print(f"  \033[33m⚠\033[0m PLAYSTORE_PACKAGE_NAME: empty")

ps_track = parse_env("PLAYSTORE_TRACK") or "internal"
vars_data["PLAYSTORE_TRACK"] = ps_track
print(f"  \033[32m✓\033[0m PLAYSTORE_TRACK: {ps_track}")

# ── Write output ────────────────────────────────────────────────────────────
with open(output_file, "w") as f:
    json.dump(vars_data, f, indent=2)

ref = {k: "[set]" for k in vars_data}
with open(ref_file, "w") as f:
    json.dump(ref, f, indent=2)

print(f"\n\033[36mDone!\033[0m")
print(f"  Secrets JSON:  {output_file} (gitignored)")
print(f"  Reference:     {ref_file} (committed)")
print(f"\n  Push to GitHub: gh secret set -f {output_file}")
PYEOF
