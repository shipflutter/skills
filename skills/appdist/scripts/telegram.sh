#!/bin/sh
#===============================================================================
# telegram.sh — Shared Telegram Build Notification Helpers
#
# Usage:
#   source scripts/telegram.sh   # sourced by deploy.sh after .env.prod is loaded
#
# Overview:
#   Provides notify_build_start() and notify_build_finish() functions that
#   send formatted build status messages to a Telegram chat via Bot API.
#   Also registers an ERR trap handler (on_telegram_error) so build failures
#   automatically send a failure notification.
#
# Required env vars:
#   TELEGRAM_BOT_TOKEN            — Bot token from @BotFather
#   TELEGRAM_CHAT_ID              — Target chat/channel ID
#   PROJECT_ROOT                  — Git repo root (used by deploy.sh)
#
# Optional env vars:
#   TELEGRAM_APP_NAME             — App name in notifications (default: ShipFlutter)
#   TELEGRAM_APP_VERSION          — Version string
#   TELEGRAM_DISABLE_NOTIFICATION — true/false (default: true)
#   PLATFORM                      — ios/android/all (used by error handler)
#   GITHUB_ACTIONS / CI           — auto-detected for source label
#
# Architecture:
#   ┌─ telegram.sh ──────────────────────────────────────────────┐
#   │  Source detection  →  💻 user@host  or  🤖 CI Pipeline    │
#   │  platform_label()  →  iOS TestFlight / Android Firebase   │
#   │  platform_emoji()  →  🍎 / 🤖 / 📱                        │
#   │  send_telegram()   →  curl → api.telegram.org              │
#   │  notify_build_start()    — 🚀 build started message       │
#   │  notify_build_finish()   — ✅/❌ build result message     │
#   │  on_telegram_error()     — ERR trap → failure notify      │
#   └───────────────────────────────────────────────────────────┘
#
# Message format (start):
#   🍎 ShipFlutter iOS TestFlight Build Started
#   Source: 💻 trantrunghieu@MacBook-Pro
#   Triggered by: Tran Trung Hieu
#   Version: v1.0.0+10
#   Branch: develop
#   Commit: abc1234
#   Start Time: 2026-06-09 21:00:00
#   Commit Message: fix: update deploy pipeline
#   Status: ⏳ Build in progress...
#
# Message format (finish):
#   ✅ Build completed / ❌ Build failed
#   Duration: 2m 34s
#
# Dependencies: curl, git, python3 (for JSON escaping)
#===============================================================================


TELEGRAM_DISABLE_NOTIFICATION="${TELEGRAM_DISABLE_NOTIFICATION:-true}"

BUILD_START_TIME=""
TELEGRAM_APP_NAME="${TELEGRAM_APP_NAME:-ShipFlutter}"

# ── Detect source ────────────────────────────────────────────────────────────
if [ -n "${GITHUB_ACTIONS:-}" ]; then
  TELEGRAM_SOURCE="🤖 GitHub Actions Pipeline"
elif [ -n "${CI:-}" ]; then
  TELEGRAM_SOURCE="🤖 CI Pipeline"
else
  TRIGGERED_BY=$(whoami 2>/dev/null || echo "unknown")
  HOSTNAME_SHORT=$(hostname -s 2>/dev/null || echo "local")
  TELEGRAM_SOURCE="💻 ${TRIGGERED_BY}@${HOSTNAME_SHORT}"
fi

# ── Platform helpers ─────────────────────────────────────────────────────────
platform_label() {
  case "${1:-}" in
    ios)     echo "iOS TestFlight" ;;
    android) echo "Android Firebase" ;;
    all)     echo "iOS TestFlight + Android Firebase" ;;
    *)       echo "${1:-}" ;;
  esac
}

platform_emoji() {
  case "${1:-}" in
    ios)     echo "🍎" ;;
    android) echo "🤖" ;;
    all)     echo "📱" ;;
    *)       echo "📦" ;;
  esac
}

send_telegram() {
  text="$1"
  if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
    echo "[telegram] TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID not set — skipping notification"
    return 0
  fi
  escaped_text=$(printf '%s' "$text" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null)
  if [ -z "$escaped_text" ]; then
    echo "[telegram] Failed to encode message — skipping"
    return 0
  fi
  curl -sS --location "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    --header 'Content-Type: application/json' \
    --data "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":${escaped_text},\"disable_notification\":${TELEGRAM_DISABLE_NOTIFICATION}}" \
    > /dev/null 2>&1 || true
}

notify_build_start() {
  BUILD_START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  app_name="${1:-$TELEGRAM_APP_NAME}"
  version="${2:-}"
  platform="${3:-all}"

  branch=$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  commit=$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")
  commit_msg=$(git -C "$PROJECT_ROOT" log -1 --format=%s 2>/dev/null || echo "unknown")
  triggered_by=$(git -C "$PROJECT_ROOT" log -1 --format=%an 2>/dev/null || echo "unknown")

  emoji=$(platform_emoji "$platform")
  label=$(platform_label "$platform")

  msg="${emoji} ${app_name} ${label} Build Started
Source: ${TELEGRAM_SOURCE}
Triggered by: ${triggered_by}
Version: ${version}
Branch: ${branch}
Commit: ${commit}
Start Time: ${BUILD_START_TIME}
Commit Message: ${commit_msg}
Status: ⏳ Build in progress..."
  send_telegram "$msg"
}

notify_build_finish() {
  success="${1:-true}"
  end_time=$(date '+%Y-%m-%d %H:%M:%S')
  app_name="${2:-$TELEGRAM_APP_NAME}"
  version="${3:-}"
  platform="${4:-all}"

  branch=$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  commit=$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")
  commit_msg=$(git -C "$PROJECT_ROOT" log -1 --format=%s 2>/dev/null || echo "unknown")
  triggered_by=$(git -C "$PROJECT_ROOT" log -1 --format=%an 2>/dev/null || echo "unknown")

  if [ -n "$BUILD_START_TIME" ]; then
    start_epoch=$(date -j -f '%Y-%m-%d %H:%M:%S' "$BUILD_START_TIME" '+%s' 2>/dev/null || echo 0)
    end_epoch=$(date -j -f '%Y-%m-%d %H:%M:%S' "$end_time" '+%s' 2>/dev/null || echo 0)
    duration_sec=$((end_epoch - start_epoch))
    duration_min=$((duration_sec / 60))
    duration_remain_sec=$((duration_sec % 60))
    duration_str="${duration_min}m ${duration_remain_sec}s"
  else
    duration_str="unknown"
  fi

  emoji=$(platform_emoji "$platform")
  label=$(platform_label "$platform")

  if [ "$success" = "true" ]; then
    title="${emoji} ${app_name} ${label} Build Completed"
    status_line="✅ Build completed"
  else
    title="${emoji} ${app_name} ${label} Build Failed"
    status_line="❌ Build failed"
  fi

  msg="${title}
Source: ${TELEGRAM_SOURCE}
Triggered by: ${triggered_by}
Version: ${version}
Branch: ${branch}
Commit: ${commit}
Start Time: ${BUILD_START_TIME}
End Time: ${end_time}
Duration: ${duration_str}
Commit Message: ${commit_msg}
Status: ${status_line}"
  send_telegram "$msg"
}

on_telegram_error() {
  notify_build_finish "false" "${TELEGRAM_APP_NAME:-ShipFlutter}" "${TELEGRAM_APP_VERSION:-}" "${PLATFORM:-all}"
  exit 1
}
