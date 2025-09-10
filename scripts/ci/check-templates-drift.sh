#!/usr/bin/env bash
# Detect drift between local templates and upstream

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

REF="${1:-upstream/main}"

if ! git remote | grep -q '^upstream$'; then
  echo "[DRIFT] Upstream remote not configured. Run:" >&2
  echo "[DRIFT]   git remote add upstream <git-url-of-upstream>" >&2
  exit 1
fi

echo "[DRIFT] Fetching upstream..."
git fetch upstream --tags --prune >/dev/null 2>&1 || true

echo "[DRIFT] Comparing templates against $REF"
if ! git rev-parse --verify "$REF" >/dev/null 2>&1; then
  echo "[DRIFT] Ref not found: $REF" >&2
  exit 1
fi

# Ignore pure whitespace/EOF-newline differences when deciding pass/fail
if git diff -w --ignore-blank-lines --quiet "$REF" -- templates/; then
  echo "[DRIFT] No template drift detected against $REF"
  exit 0
fi

# When there are real differences, show a precise list without whitespace suppression
echo "[DRIFT] Template differences detected against $REF:" >&2
git diff --name-status "$REF" -- templates/ >&2
exit 1
