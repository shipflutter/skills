#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
REPORT_PATH="$BACKEND_DIR/coverage/index.html"

if [[ ! -d "$BACKEND_DIR/node_modules" ]]; then
  echo "Installing backend dependencies..."
  (cd "$BACKEND_DIR" && npm install)
fi

echo "Seeding local JSON database before tests..."
(cd "$BACKEND_DIR" && npm run seed)

echo "Running backend unit tests with HTML coverage..."
(cd "$BACKEND_DIR" && npm run test:coverage)

echo ""
echo "Coverage report: $REPORT_PATH"

if command -v open >/dev/null 2>&1; then
  open "$REPORT_PATH"
fi
