#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
CLIENT_DIR="$ROOT_DIR/client"
API_PORT="${API_PORT:-5174}"
UI_PORT="${UI_PORT:-4173}"

cleanup() {
  if [[ -n "${API_PID:-}" ]]; then kill "$API_PID" 2>/dev/null || true; fi
  if [[ -n "${UI_PID:-}" ]]; then kill "$UI_PID" 2>/dev/null || true; fi
}
trap cleanup EXIT INT TERM

# --------------- resolve static server ---------------
SERVE_CMD=""
SERVE_NAME=""
if command -v python3 &>/dev/null; then
  SERVE_CMD="python3 -m http.server $UI_PORT"
  SERVE_NAME="python3 http.server"
elif command -v python &>/dev/null; then
  SERVE_CMD="python -m http.server $UI_PORT"
  SERVE_NAME="python http.server"
elif command -v npx &>/dev/null; then
  SERVE_CMD="npx --yes serve -l $UI_PORT"
  SERVE_NAME="npx serve"
else
  echo "ERROR: No static server found. Install python3, python, or Node.js (npx)."
  exit 1
fi

# --------------- install / seed ---------------
if [[ ! -d "$BACKEND_DIR/node_modules" ]]; then
  echo "Installing backend dependencies..."
  (cd "$BACKEND_DIR" && npm install)
fi

if [[ ! -f "$BACKEND_DIR/data/db.json" ]]; then
  echo "Seeding local JSON database..."
  (cd "$BACKEND_DIR" && npm run seed)
fi

# --------------- start backend ---------------
echo "Starting Skill Store API on http://localhost:$API_PORT"
(cd "$BACKEND_DIR" && PORT="$API_PORT" npm run dev) &
API_PID=$!

# wait for backend to become healthy
echo -n "Waiting for backend"
for i in $(seq 1 30); do
  if curl -s "http://localhost:$API_PORT/health" &>/dev/null; then
    echo " ready."
    break
  fi
  echo -n "."
  sleep 1
done

# --------------- start frontend ---------------
echo ""
echo "Starting UI on http://localhost:$UI_PORT (via $SERVE_NAME)"
(cd "$CLIENT_DIR" && $SERVE_CMD) &
UI_PID=$!

echo ""
echo "Local URLs:"
echo "  Store: http://localhost:$UI_PORT/store.html"
echo "  Home:  http://localhost:$UI_PORT"
echo "  API:   http://localhost:$API_PORT/health"
echo ""
echo "Press Ctrl+C to stop both servers."
wait
