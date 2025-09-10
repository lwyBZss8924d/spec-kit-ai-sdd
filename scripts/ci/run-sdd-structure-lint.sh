#!/usr/bin/env bash
# Validate SDD structure for all feature specifications

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

fail=0

for dir in specs/*/ ; do
  # Skip if not a directory
  [[ -d "$dir" ]] || continue

  # Require spec.md, plan.md, tasks.md
  for f in spec.md plan.md tasks.md; do
    if [[ ! -f "$dir/$f" ]]; then
      echo "[STRUCTURE] Missing $f in $dir" >&2
      fail=1
    fi
  done

done

if [[ $fail -ne 0 ]]; then
  echo "[STRUCTURE] SDD structure validation failed" >&2
  exit 1
fi

echo "[STRUCTURE] SDD structure validation passed"
