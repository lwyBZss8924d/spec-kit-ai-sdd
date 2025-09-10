#!/usr/bin/env bash
# Execute upstream sync using merge or rebase strategy
# Usage: merge.sh --strategy <merge|rebase> --ref <target-ref>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

STRATEGY="merge"
TARGET_REF="upstream/main"

usage() {
    cat <<EOF
Usage: $(basename "$0") --strategy <merge|rebase> --ref <target-ref>

Options:
  --strategy   Strategy to use: merge (default) or rebase
  --ref        Target ref to sync against (default: upstream/main)
  -h, --help   Show this help
EOF
}

validate_arg() {
    local value="$1" allowed="$2" name="$3"
    for a in $allowed; do
        if [[ "$a" == "$value" ]]; then return 0; fi
    done
    die "Invalid $name: $value (allowed: $allowed)"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --strategy)
                STRATEGY="$2"; validate_arg "$STRATEGY" "merge rebase" "strategy"; shift 2 ;;
            --ref)
                TARGET_REF="$2"; shift 2 ;;
            -h|--help)
                usage; exit 0 ;;
            *)
                die "Unknown option: $1" ;;
        esac
    done
}

main() {
    parse_args "$@"
    check_prerequisites

    # Verify target ref exists
    git rev-parse --verify "$TARGET_REF" >/dev/null 2>&1 || die "Target ref not found: $TARGET_REF"

    # Ensure clean tree
    git_is_clean || die "Working tree is not clean. Commit or stash changes first."

    local current_branch
    current_branch=$(git_current_branch)

    log_info "Executing $STRATEGY of $TARGET_REF into $current_branch"

    if [[ "$STRATEGY" == "merge" ]]; then
        git merge --no-ff "$TARGET_REF" -m "sync: merge $TARGET_REF into $current_branch

Upstream sync executed at $(timestamp)
Target: $TARGET_REF
Strategy: merge
Reports: $REPORT_DIR" || die "Merge failed"
    else
        git rebase "$TARGET_REF" || die "Rebase failed. Resolve conflicts then run 'git rebase --continue' or abort with 'git rebase --abort'"
    fi

    log_info "Merge step complete"
}

main "$@"
