#!/usr/bin/env bash
# Fetch upstream changes with progress indication and caching

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
# Prefer global shim if present
if [[ -f "$SCRIPT_DIR/../common.sh" ]]; then
  # shellcheck source=../common.sh
  source "$SCRIPT_DIR/../common.sh"
else
  # shellcheck source=lib/common.sh
  source "$SCRIPT_DIR/lib/common.sh"
fi

# Configuration
UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
FETCH_TIMEOUT="${FETCH_TIMEOUT:-300}"  # 5 minutes default
FETCH_CACHE_FILE="/tmp/spec-kit-fetch-cache-$(date +%Y%m%d)"

# Check if recent fetch exists (within last hour)
check_cache() {
    if [[ -f "$FETCH_CACHE_FILE" ]]; then
        local cache_age
        cache_age=$(($(date +%s) - $(stat -f %m "$FETCH_CACHE_FILE" 2>/dev/null || stat -c %Y "$FETCH_CACHE_FILE" 2>/dev/null || echo 0)))
        if [[ $cache_age -lt 3600 ]]; then
            log_info "Using cached fetch from $(( cache_age / 60 )) minutes ago"
            return 0
        fi
    fi
    return 1
}

# Validate upstream remote
validate_upstream() {
    log_info "Validating upstream remote..."
    
    if ! git remote | grep -q "^${UPSTREAM_REMOTE}$"; then
        die "Upstream remote '$UPSTREAM_REMOTE' not found. Run: git remote add $UPSTREAM_REMOTE https://github.com/github/spec-kit.git"
    fi
    
    local upstream_url
    upstream_url=$(git remote get-url "$UPSTREAM_REMOTE")
    log_info "Upstream URL: $upstream_url"
    
    # Verify URL is correct
    if [[ ! "$upstream_url" =~ github\.com[:/]github/spec-kit ]]; then
        log_warn "Upstream URL doesn't match expected pattern: github.com/github/spec-kit"
    fi
}

# Fetch with progress
fetch_with_progress() {
    log_info "Fetching from $UPSTREAM_REMOTE..."
    
    # Set up timeout
    local fetch_cmd="timeout $FETCH_TIMEOUT git fetch $UPSTREAM_REMOTE"
    
    # Add verbose flag if debug logging
    if [[ $LOG_LEVEL -le $LOG_LEVEL_DEBUG ]]; then
        fetch_cmd="$fetch_cmd --verbose"
    else
        fetch_cmd="$fetch_cmd --progress"
    fi
    
    # Fetch all refs
    fetch_cmd="$fetch_cmd --tags --prune"
    
    # Execute fetch
    if eval "$fetch_cmd" 2>&1 | while IFS= read -r line; do
        if [[ "$line" =~ "Receiving objects" ]] || [[ "$line" =~ "Resolving deltas" ]]; then
            show_progress "$line"
        else
            log_debug "$line"
        fi
    done; then
        clear_progress
        touch "$FETCH_CACHE_FILE"
        log_info "Fetch completed successfully"
        return 0
    else
        clear_progress
        die "Fetch failed or timed out after ${FETCH_TIMEOUT} seconds"
    fi
}

# List new tags
list_new_tags() {
    log_info "Checking for new tags..."
    
    # Get latest tags
    local latest_tags
    latest_tags=$(git tag -l --sort=-version:refname | head -5)
    
    if [[ -n "$latest_tags" ]]; then
        log_info "Latest tags:"
        echo "$latest_tags" | while read -r tag; do
            log_info "  - $tag"
        done
    fi
    
    # Check for new tags since last fetch
    local new_tags
    new_tags=$(git log --tags --simplify-by-decoration --pretty="format:%d" HEAD..FETCH_HEAD 2>/dev/null | grep -o 'tag: [^,)]*' | sed 's/tag: //' || true)
    
    if [[ -n "$new_tags" ]]; then
        log_info "New tags since last sync:"
        echo "$new_tags" | while read -r tag; do
            log_info "  - $tag"
        done
    fi
}

# Show fetch summary
show_summary() {
    log_info "Fetch summary:"
    
    # Count new commits
    local new_commits
    new_commits=$(git rev-list --count HEAD.."$UPSTREAM_REMOTE/main" 2>/dev/null || echo "0")
    log_info "  New commits on $UPSTREAM_REMOTE/main: $new_commits"
    
    # Show branch tips
    log_info "  Branch tips:"
    git for-each-ref --format='%(refname:short)' "refs/remotes/$UPSTREAM_REMOTE/*" | head -5 | while read -r branch; do
        local commit
        commit=$(git rev-parse --short "$branch" 2>/dev/null || echo "unknown")
        log_info "    $branch -> $commit"
    done
    
    # Report to file
    write_report "fetch-summary.txt" "Fetch completed at $(timestamp)
Upstream: $UPSTREAM_REMOTE
New commits: $new_commits
Cache file: $FETCH_CACHE_FILE"
}

# Handle network errors
handle_network_error() {
    local exit_code=$1
    
    case $exit_code in
        124)
            die "Fetch timed out after $FETCH_TIMEOUT seconds. Check network connection."
            ;;
        128)
            die "Git error during fetch. Check repository configuration."
            ;;
        *)
            die "Fetch failed with exit code $exit_code"
            ;;
    esac
}

# Main execution
main() {
    log_info "Starting upstream fetch..."
    
    # Check prerequisites
    check_prerequisites
    
    # Validate upstream
    validate_upstream
    
    # Check cache
    if check_cache; then
        log_info "Skipping fetch (recent cache exists)"
    else
        # Perform fetch
        fetch_with_progress || handle_network_error $?
    fi
    
    # List new tags
    list_new_tags
    
    # Show summary
    show_summary
    
    log_info "Fetch operation completed"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi