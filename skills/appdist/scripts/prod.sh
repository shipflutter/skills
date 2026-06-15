#!/usr/bin/env bash
#===============================================================================
# prod.sh — Internal Testing Deploy Wrapper
#
# Usage:
#   ./prod.sh              # deploy both iOS + Android to internal testing
#   ./prod.sh ios          # iOS → TestFlight only
#   ./prod.sh android      # Android → Play Store internal testing only
#
# Purpose:
#   Convenience wrapper around deploy.sh that explicitly sets the Play Store
#   track to internal testing. This is the recommended entry point for QA
#   and internal tester builds.
#
# How it works:
#   1. Sets PLAYSTORE_TRACK="internal"
#   2. Delegates all build/upload logic to deploy.sh
#   3. All env vars read from .env.prod (same as deploy.sh)
#
# Tracks:
#   Play Store → internal testing
#   iOS         → TestFlight (standard)
#
# See deploy.sh for full architecture and required env vars.
#===============================================================================
set -euo pipefail
cd "$(dirname "$0")"

PLATFORM="${1:-all}"

echo "Deploy: $PLATFORM"
echo ""

export PLAYSTORE_TRACK="internal"

bash deploy.sh "$PLATFORM"
