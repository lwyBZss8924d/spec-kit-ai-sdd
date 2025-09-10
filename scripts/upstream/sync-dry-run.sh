#!/usr/bin/env bash
# Dry-run validator for upstream sync
# Runs fetch, diff report, compatibility analysis, and conflict preview

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

TARGET_REF="${1:-upstream/main}"

main() {
    check_prerequisites
    ensure_dir "$REPORT_DIR"

    log_info "Starting upstream sync dry-run for $TARGET_REF"

    # Fetch
    if [[ -x "$SCRIPT_DIR/fetch.sh" ]]; then
        "$SCRIPT_DIR/fetch.sh"
    else
        git fetch upstream --tags --prune
    fi

    # Reports
    [[ -x "$SCRIPT_DIR/diff-report.sh" ]] && "$SCRIPT_DIR/diff-report.sh" "$TARGET_REF" || log_warn "diff-report.sh not found"
    [[ -x "$SCRIPT_DIR/compat-analyze.sh" ]] && "$SCRIPT_DIR/compat-analyze.sh" "$TARGET_REF" || log_warn "compat-analyze.sh not found"

    # Conflict preview
    log_info "Previewing potential conflicts..."
    if git merge --no-commit --no-ff "$TARGET_REF" >/dev/null 2>&1; then
        log_info "No conflicts detected in preview"
        git merge --abort >/dev/null 2>&1 || true
    else
        log_warn "Conflicts likely; see git status for details (preview only)"
        git merge --abort >/dev/null 2>&1 || true
    fi

    log_info "Dry-run complete. Review reports in $REPORT_DIR"
}

main "$@"
