#!/usr/bin/env bash
set -euo pipefail

BACKEND_BASE_URL="${BACKEND_BASE_URL:-http://127.0.0.1:8787}"
DROP_PENDING_UPDATES="${DROP_PENDING_UPDATES:-false}"

curl --fail --silent --show-error \
  -X POST \
  -H 'content-type: application/json' \
  -d "{\"dropPendingUpdates\":${DROP_PENDING_UPDATES}}" \
  "${BACKEND_BASE_URL}/api/v1/integrations/telegram/delete-webhook"
echo
