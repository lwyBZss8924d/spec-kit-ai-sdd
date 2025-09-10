#!/usr/bin/env bash
# Common functions library for upstream sync scripts
# Provides logging, error handling, and utility functions

set -euo pipefail

# Color codes for terminal output (mutable to allow disabling when terminal lacks color)
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

# Log levels
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3

# Default log level
LOG_LEVEL="${LOG_LEVEL:-$LOG_LEVEL_INFO}"

# Report directory with date
REPORT_DATE="${REPORT_DATE:-$(date +%Y%m%d)}"
REPORT_DIR="${REPORT_DIR:-reports/upstream/$REPORT_DATE}"

# Logging functions
log_debug() {
    [[ $LOG_LEVEL -le $LOG_LEVEL_DEBUG ]] && echo -e "${COLOR_BLUE}[DEBUG]${COLOR_RESET} $*" >&2
    return 0
}

log_info() {
    [[ $LOG_LEVEL -le $LOG_LEVEL_INFO ]] && echo -e "${COLOR_GREEN}[INFO]${COLOR_RESET} $*" >&2
    return 0
}

log_warn() {
    [[ $LOG_LEVEL -le $LOG_LEVEL_WARN ]] && echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $*" >&2
    return 0
}

log_error() {
    [[ $LOG_LEVEL -le $LOG_LEVEL_ERROR ]] && echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
    return 0
}

# Error handling
die() {
    log_error "$@"
    exit 1
}

# Check if terminal supports colors
supports_color() {
    if [[ -t 2 ]] && command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Disable colors if not supported
if ! supports_color; then
    COLOR_RED=''
    COLOR_GREEN=''
    COLOR_YELLOW=''
    COLOR_BLUE=''
    COLOR_RESET=''
fi

# Timestamp functions
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

timestamp_file() {
    date '+%Y%m%d_%H%M%S'
}

# Git helper functions
git_current_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
}

git_is_clean() {
    [[ -z "$(git status --porcelain 2>/dev/null)" ]]
}

git_has_upstream() {
    git remote | grep -q '^upstream$'
}

git_merge_base() {
    local ref="${1:-upstream/main}"
    git merge-base HEAD "$ref" 2>/dev/null || return 1
}

git_commits_behind() {
    local ref="${1:-upstream/main}"
    local base
    base=$(git_merge_base "$ref") || return 1
    git rev-list --count "$base".."$ref" 2>/dev/null || echo "0"
}

git_commits_ahead() {
    local ref="${1:-upstream/main}"
    local base
    base=$(git_merge_base "$ref") || return 1
    git rev-list --count "$ref".."$base" 2>/dev/null || echo "0"
}

# Create backup branch
create_backup_branch() {
    local branch_name
    branch_name="backup/$(git_current_branch)/$(timestamp_file)"
    log_info "Creating backup branch: $branch_name"
    git branch "$branch_name" || die "Failed to create backup branch"
    echo "$branch_name"
}

# Ensure directory exists
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        log_debug "Creating directory: $dir"
        mkdir -p "$dir" || die "Failed to create directory: $dir"
    fi
}

# Write to report file
write_report() {
    local file="$1"
    local content="$2"
    ensure_dir "$REPORT_DIR"
    echo "$content" >> "$REPORT_DIR/$file"
}

# JSON escape string
json_escape() {
    local str="$1"
    echo "$str" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\n/\\n/g; s/\r/\\r/g'
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check git is available
    command -v git >/dev/null 2>&1 || die "git is not installed"
    
    # Check we're in a git repository
    git rev-parse --git-dir >/dev/null 2>&1 || die "Not in a git repository"
    
    # Check upstream remote exists
    if ! git_has_upstream; then
        die "Upstream remote not configured. Run: git remote add upstream https://github.com/github/spec-kit.git"
    fi
    
    log_info "Prerequisites check passed"
}

# Progress indicator
show_progress() {
    local message="$1"
    echo -en "\r${COLOR_BLUE}[PROGRESS]${COLOR_RESET} $message..."
}

clear_progress() {
    echo -en "\r\033[K"
}

# Categorize file by path
categorize_file() {
    local file="$1"
    
    case "$file" in
        templates/*) echo "templates" ;;
        scripts/*) echo "scripts" ;;
        src/specify_cli/*) echo "cli" ;;
        docs/*|*.md) echo "documentation" ;;
        .github/*) echo "ci" ;;
        tests/*) echo "tests" ;;
        pyproject.toml|package.json|requirements*.txt) echo "dependencies" ;;
        *) echo "other" ;;
    esac
}

# Calculate risk level based on file category
calculate_risk_level() {
    local category="$1"
    
    case "$category" in
        templates) echo "high" ;;
        scripts|cli) echo "medium" ;;
        dependencies|ci) echo "medium" ;;
        documentation|tests) echo "low" ;;
        *) echo "low" ;;
    esac
}

# Format file size
format_size() {
    local size="$1"
    if [[ $size -lt 1024 ]]; then
        echo "${size}B"
    elif [[ $size -lt 1048576 ]]; then
        echo "$((size / 1024))KB"
    else
        echo "$((size / 1048576))MB"
    fi
}

# Validate arguments
validate_arg() {
    local arg="$1"
    local valid_values="$2"
    local arg_name="${3:-argument}"
    
    if ! echo "$valid_values" | grep -qw "$arg"; then
        die "Invalid $arg_name: $arg. Valid values: $valid_values"
    fi
}

# Export functions for use in other scripts
export -f log_debug log_info log_warn log_error die
export -f timestamp timestamp_file
export -f git_current_branch git_is_clean git_has_upstream
export -f git_merge_base git_commits_behind git_commits_ahead
export -f create_backup_branch ensure_dir write_report
export -f json_escape check_prerequisites
export -f show_progress clear_progress
export -f categorize_file calculate_risk_level
export -f format_size validate_arg