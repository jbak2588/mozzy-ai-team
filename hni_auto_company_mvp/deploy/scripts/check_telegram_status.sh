#!/usr/bin/env bash
set -euo pipefail

BACKEND_BASE_URL="${BACKEND_BASE_URL:-http://127.0.0.1:8787}"

curl --fail --silent --show-error \
  "${BACKEND_BASE_URL}/api/v1/integrations/telegram/status"
echo
