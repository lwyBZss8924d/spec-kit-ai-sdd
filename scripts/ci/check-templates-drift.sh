#!/usr/bin/env bash
# Detect drift between local templates and upstream

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

REF="${1:-upstream/main}"

if ! git remote | grep -q '^upstream$'; then
  echo "[DRIFT] Upstream remote not configured" >&2
  exit 1
fi

echo "[DRIFT] Fetching upstream..."
git fetch upstream --tags --prune >/dev/null 2>&1 || true

echo "[DRIFT] Comparing templates against $REF"
if ! git rev-parse --verify "$REF" >/dev/null 2>&1; then
  echo "[DRIFT] Ref not found: $REF" >&2
  exit 1
fi

diff_output=$(git diff --name-status "$REF" -- templates/ || true)
if [[ -n "$diff_output" ]]; then
  echo "[DRIFT] Template differences detected against $REF:" >&2
  echo "$diff_output" >&2
  exit 1
fi

echo "[DRIFT] No template drift detected against $REF"
