#!/usr/bin/env bash
# Local CI orchestrator for upstream sync workflow
# Runs structure lint, language policy check, and template drift detection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

REF="${1:-upstream/main}"

run_check() {
  local name="$1"; shift
  local start end
  start=$(date +%s)
  echo "[CI] Running: $name"
  if "$@"; then
    end=$(date +%s)
    echo "[CI] PASS: $name ($((end-start))s)"
  else
    end=$(date +%s)
    echo "[CI] FAIL: $name ($((end-start))s)" >&2
    return 1
  fi
}

main() {
  cd "$PROJECT_ROOT"
  local failed=0

  run_check "SDD Structure Lint" "$SCRIPT_DIR/run-sdd-structure-lint.sh" || failed=1
  run_check "Language Policy Check" "$SCRIPT_DIR/check-language-policy.sh" || failed=1
  run_check "Template Drift ($REF)" "$SCRIPT_DIR/check-templates-drift.sh" "$REF" || failed=1

  if [[ $failed -ne 0 ]]; then
    echo "[CI] One or more checks failed" >&2
    exit 1
  fi
  echo "[CI] All checks passed"
}

main "$@"
