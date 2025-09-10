#!/usr/bin/env bash
# Main orchestrator for upstream synchronization workflow
# Coordinates all sync operations with safety checks and reporting

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common functions
# Prefer global shim if present
if [[ -f "$SCRIPT_DIR/../common.sh" ]]; then
    # shellcheck source=../common.sh
    source "$SCRIPT_DIR/../common.sh"
else
    # shellcheck source=lib/common.sh
    source "$SCRIPT_DIR/lib/common.sh"
fi

# Default values
DRY_RUN=false
STRATEGY="merge"
TARGET_REF="upstream/main"
VERBOSE=false
FORCE=false
NO_CI=false

# Script version
readonly VERSION="1.0.0"

# Usage information
usage() {
    cat <<EOF
Upstream Sync Orchestrator v$VERSION

Usage: $(basename "$0") [OPTIONS]

Synchronize the forked repository with upstream changes safely.

OPTIONS:
    -h, --help              Show this help message
    -d, --dry-run           Preview changes without modifying repository
    -s, --strategy STRATEGY Use merge (default) or rebase strategy
    -r, --ref REF           Target ref to sync (default: upstream/main)
    -v, --verbose           Enable verbose logging
    -f, --force             Skip safety checks (use with caution)
    --no-ci                 Skip CI validation after sync
    --version               Show version information

EXAMPLES:
    # Preview sync with upstream/main
    $(basename "$0") --dry-run

    # Sync with specific tag
    $(basename "$0") --ref upstream/v0.0.20

    # Use rebase strategy
    $(basename "$0") --strategy rebase

    # Verbose dry-run
    $(basename "$0") --dry-run --verbose

ENVIRONMENT VARIABLES:
    LOG_LEVEL               Set log level (0=DEBUG, 1=INFO, 2=WARN, 3=ERROR)
    REPORT_DATE             Override report date (format: YYYYMMDD)

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -s|--strategy)
                STRATEGY="$2"
                validate_arg "$STRATEGY" "merge rebase" "strategy"
                shift 2
                ;;
            -r|--ref)
                TARGET_REF="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                LOG_LEVEL=$LOG_LEVEL_DEBUG
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            --no-ci)
                NO_CI=true
                shift
                ;;
            --version)
                echo "Upstream Sync Orchestrator v$VERSION"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Initialize sync environment
initialize() {
    log_info "Initializing upstream sync workflow..."
    
    # Change to project root
    cd "$PROJECT_ROOT" || die "Failed to change to project root"
    
    # Create report directory
    ensure_dir "$REPORT_DIR"
    
    # Start sync log
    local log_file="$REPORT_DIR/sync.log"
    exec 1> >(tee -a "$log_file")
    exec 2>&1
    
    log_info "Sync session started at $(timestamp)"
    log_info "Report directory: $REPORT_DIR"
    log_info "Target ref: $TARGET_REF"
    log_info "Strategy: $STRATEGY"
    log_info "Dry-run: $DRY_RUN"
}

# Perform safety checks
safety_checks() {
    if [[ "$FORCE" == "true" ]]; then
        log_warn "Force mode enabled - skipping safety checks"
        return 0
    fi
    
    log_info "Performing safety checks..."
    
    # Check prerequisites
    check_prerequisites
    
    # Check working tree is clean
    if ! git_is_clean; then
        die "Working tree is not clean. Commit or stash changes before syncing."
    fi
    
    # Check current branch
    local current_branch
    current_branch=$(git_current_branch)
    if [[ "$current_branch" == "main" ]] || [[ "$current_branch" == "master" ]]; then
        log_warn "You are on the main branch. Consider creating a sync branch first."
        if [[ "$DRY_RUN" != "true" ]]; then
            read -p "Continue on main branch? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                die "Aborted by user"
            fi
        fi
    fi
    
    log_info "Safety checks passed"
}

# Fetch upstream changes
fetch_upstream() {
    log_info "Fetching upstream changes..."
    
    if [[ -x "$SCRIPT_DIR/fetch.sh" ]]; then
        "$SCRIPT_DIR/fetch.sh" || die "Fetch failed"
    else
        # Fallback to direct fetch
        log_warn "fetch.sh not found, using direct fetch"
        git fetch upstream --tags --prune || die "Failed to fetch upstream"
    fi
    
    # Verify target ref exists
    if ! git rev-parse --verify "$TARGET_REF" >/dev/null 2>&1; then
        die "Target ref not found: $TARGET_REF"
    fi
    
    log_info "Upstream fetch completed"
}

# Generate diff reports
generate_reports() {
    log_info "Generating diff reports..."
    
    if [[ -x "$SCRIPT_DIR/diff-report.sh" ]]; then
        "$SCRIPT_DIR/diff-report.sh" "$TARGET_REF" || log_warn "Diff report generation failed"
    else
        log_warn "diff-report.sh not found, skipping diff reports"
    fi
    
    # Show summary
    local commits_behind
    commits_behind=$(git_commits_behind "$TARGET_REF")
    log_info "Commits behind $TARGET_REF: $commits_behind"
}

# Analyze compatibility
analyze_compatibility() {
    log_info "Analyzing compatibility..."
    
    if [[ -x "$SCRIPT_DIR/compat-analyze.sh" ]]; then
        "$SCRIPT_DIR/compat-analyze.sh" "$TARGET_REF" || log_warn "Compatibility analysis failed"
        
        # Check if adaptation is required
        local compat_file="$REPORT_DIR/compatibility.md"
        if [[ -f "$compat_file" ]] && grep -q "adaptation-required: true" "$compat_file"; then
            log_warn "Adaptation required for upstream changes"
            if [[ "$DRY_RUN" != "true" ]] && [[ "$FORCE" != "true" ]]; then
                read -p "Adaptation required. Continue? (y/N) " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    die "Sync aborted due to required adaptations"
                fi
            fi
        fi
    else
        log_warn "compat-analyze.sh not found, skipping compatibility analysis"
    fi
}

# Execute merge or rebase
execute_sync() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "DRY-RUN: Would execute $STRATEGY with $TARGET_REF"
        
        # Preview merge
        log_info "Checking for potential conflicts..."
        if git merge --no-commit --no-ff "$TARGET_REF" >/dev/null 2>&1; then
            log_info "No conflicts detected"
            git merge --abort 2>/dev/null || true
        else
            log_warn "Potential conflicts detected"
            git merge --abort 2>/dev/null || true
        fi
        
        return 0
    fi
    
    log_info "Executing $STRATEGY with $TARGET_REF..."
    
    # Create backup branch
    local backup_branch
    backup_branch=$(create_backup_branch)
    log_info "Backup branch created: $backup_branch"
    
    if [[ -x "$SCRIPT_DIR/merge.sh" ]]; then
        "$SCRIPT_DIR/merge.sh" --strategy "$STRATEGY" --ref "$TARGET_REF" || {
            log_error "Merge failed. Backup branch: $backup_branch"
            die "Sync failed during merge phase"
        }
    else
        # Fallback to direct merge/rebase
        log_warn "merge.sh not found, using direct $STRATEGY"
        
        if [[ "$STRATEGY" == "merge" ]]; then
            git merge --no-ff "$TARGET_REF" -m "sync: merge $TARGET_REF into $(git_current_branch)

Upstream sync executed at $(timestamp)
Target: $TARGET_REF
Strategy: merge
Reports: $REPORT_DIR" || {
                log_error "Merge failed. Backup branch: $backup_branch"
                die "Merge failed"
            }
        else
            git rebase "$TARGET_REF" || {
                log_error "Rebase failed. Run 'git rebase --abort' to abort"
                log_error "Backup branch: $backup_branch"
                die "Rebase failed"
            }
        fi
    fi
    
    log_info "Sync executed successfully"
}

# Run CI validation
run_ci_validation() {
    if [[ "$NO_CI" == "true" ]]; then
        log_info "Skipping CI validation (--no-ci specified)"
        return 0
    fi
    
    log_info "Running CI validation..."
    
    if [[ -x "$PROJECT_ROOT/scripts/ci/run-local-ci.sh" ]]; then
        "$PROJECT_ROOT/scripts/ci/run-local-ci.sh" || {
            log_error "CI validation failed"
            if [[ "$FORCE" != "true" ]]; then
                die "CI validation failed. Use --force to ignore."
            fi
        }
    else
        log_warn "CI validation script not found"
    fi
}

# Generate summary report
generate_summary() {
    log_info "Generating summary report..."
    
    local summary_file="$REPORT_DIR/summary.md"
    
    cat > "$summary_file" <<EOF
# Upstream Sync Summary

**Date**: $(date '+%Y-%m-%d %H:%M:%S')  
**Target**: $TARGET_REF  
**Strategy**: $STRATEGY  
**Dry-run**: $DRY_RUN  
**Status**: ${1:-Success}

## Changes Summary

- Commits behind: $(git_commits_behind "$TARGET_REF" || echo "N/A")
- Files changed: $(git diff --name-only "$(git_merge_base "$TARGET_REF")..$TARGET_REF" 2>/dev/null | wc -l || echo "N/A")

## Reports Generated

- [Diff Report](diff.md)
- [Compatibility Analysis](compatibility.md)
- [Sync Log](sync.log)

## Next Steps

1. Review the changes carefully
2. Run tests locally
3. Update documentation if needed
4. Create pull request for review

---
*Generated by upstream sync workflow v$VERSION*
EOF
    
    log_info "Summary report: $summary_file"
}

# Cleanup function
cleanup() {
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        generate_summary "Success"
        log_info "Upstream sync completed successfully"
    else
        generate_summary "Failed"
        log_error "Upstream sync failed with exit code: $exit_code"
    fi
    
    log_info "Sync session ended at $(timestamp)"
}

# Main execution
main() {
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Parse arguments
    parse_args "$@"
    
    # Initialize environment
    initialize
    
    # Run workflow phases
    safety_checks
    fetch_upstream
    generate_reports
    analyze_compatibility
    execute_sync
    run_ci_validation
    
    # Success
    log_info "All sync phases completed successfully"
}

# Execute main function
main "$@"