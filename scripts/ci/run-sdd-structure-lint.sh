#!/usr/bin/env bash
# Validate SDD structure for all feature specifications

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

# Exclusions: example/early folders (can be extended via SDD_LINT_EXCLUDE)
# Default exclusions
EXCLUDES=(
  "specs/000-example/"
  "specs/001-claude-github-integration/"
  "specs/002-language-policy/"
)

# Optional: add more via environment variable (comma-separated paths)
if [[ -n "${SDD_LINT_EXCLUDE:-}" ]]; then
  IFS=',' read -r -a EXTRA_EXCLUDES <<< "$SDD_LINT_EXCLUDE"
  for ex in "${EXTRA_EXCLUDES[@]}"; do
    # Normalize to ensure trailing slash
    [[ "$ex" == */ ]] || ex="$ex/"
    EXCLUDES+=("$ex")
  done
fi

is_excluded_dir() {
  local d="$1"
  for ex in "${EXCLUDES[@]}"; do
    if [[ "$d" == "$ex" ]]; then
      return 0
    fi
  done
  return 1
}

fail=0

for dir in specs/*/ ; do
  # Skip if not a directory
  [[ -d "$dir" ]] || continue

  # Skip excluded directories
  if is_excluded_dir "$dir"; then
    echo "[STRUCTURE] Skipping excluded directory: $dir"
    continue
  fi

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
