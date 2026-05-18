#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${NODE_AUTH_TOKEN:-}" ]]; then
  echo "Error: NODE_AUTH_TOKEN is required."
  echo "Usage: NODE_AUTH_TOKEN='<npm-token>' ./scripts/publish-npm.sh"
  exit 1
fi

npm publish --access public
