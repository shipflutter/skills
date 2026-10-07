#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
CLIENT_DIR="$ROOT_DIR/client"
DEPLOY_DIR="$ROOT_DIR/dist-deploy"

if [[ ! -d "$BACKEND_DIR/node_modules" ]]; then
  echo "Installing backend dependencies..."
  (cd "$BACKEND_DIR" && npm install)
fi

echo "Type-checking and building backend..."
(cd "$BACKEND_DIR" && npm run check && npm run build)

echo "Preparing deploy artifact at $DEPLOY_DIR"
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR/client" "$DEPLOY_DIR/backend" "$DEPLOY_DIR/backend/data"

cp -R "$CLIENT_DIR/"* "$DEPLOY_DIR/client/"
cp -R "$BACKEND_DIR/dist" "$DEPLOY_DIR/backend/dist"
cp "$BACKEND_DIR/package.json" "$DEPLOY_DIR/backend/package.json"
cp "$BACKEND_DIR/package-lock.json" "$DEPLOY_DIR/backend/package-lock.json"
cp "$BACKEND_DIR/README.md" "$DEPLOY_DIR/backend/README.md"
cp "$BACKEND_DIR/data/db.json" "$DEPLOY_DIR/backend/data/db.json"

cat > "$DEPLOY_DIR/README.md" <<'EOF'
# Skill Store Deploy Artifact

Static UI lives in `client/`.

Backend build lives in `backend/dist/` and runs with:

```bash
cd backend
npm ci --omit=dev
npm start
```
EOF

echo "Build complete. Deploy artifact: $DEPLOY_DIR"
