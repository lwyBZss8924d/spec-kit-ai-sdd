#!/usr/bin/env bash
# Generate comprehensive diff reports comparing local and upstream

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Target ref (can be overridden by argument)
TARGET_REF="${1:-upstream/main}"

# Report files
DIFF_MD_FILE="$REPORT_DIR/diff.md"
DIFF_JSON_FILE="$REPORT_DIR/diff.json"

# Initialize reports
initialize_reports() {
    log_info "Initializing diff reports..."
    ensure_dir "$REPORT_DIR"
    
    # Clear existing reports
    > "$DIFF_MD_FILE"
    > "$DIFF_JSON_FILE"
}

# Get merge base
get_merge_base() {
    local base
    base=$(git_merge_base "$TARGET_REF")
    if [[ -z "$base" ]]; then
        die "Cannot find merge base with $TARGET_REF"
    fi
    echo "$base"
}

# Analyze file changes
analyze_file_changes() {
    local merge_base="$1"
    
    log_info "Analyzing file changes..."
    
    # Get changed files with status
    local changes
    changes=$(git diff --name-status --find-renames --find-copies "$merge_base..$TARGET_REF")
    
    # Initialize counters
    local added=0 modified=0 deleted=0 renamed=0
    local categories=()
    
    # Process each change
    while IFS=$'\t' read -r status file rest; do
        case "$status" in
            A) ((added++)) ;;
            M) ((modified++)) ;;
            D) ((deleted++)) ;;
            R*) ((renamed++)); file="$rest" ;;
            C*) ((modified++)); file="$rest" ;;
        esac
        
        # Categorize file
        local category
        category=$(categorize_file "$file")
        categories+=("$category:$file:$status")
    done <<< "$changes"
    
    # Return statistics
    echo "$added|$modified|$deleted|$renamed"
    printf '%s\n' "${categories[@]}"
}

# Generate commit log
generate_commit_log() {
    local merge_base="$1"
    local max_commits=50
    
    log_info "Generating commit log..."
    
    # Get commit count
    local commit_count
    commit_count=$(git rev-list --count "$merge_base..$TARGET_REF")
    
    # Get recent commits
    local commits
    if [[ $commit_count -gt $max_commits ]]; then
        commits=$(git log --oneline "$merge_base..$TARGET_REF" | head -$max_commits)
        commits="$commits\n... and $((commit_count - max_commits)) more commits"
    else
        commits=$(git log --oneline "$merge_base..$TARGET_REF")
    fi
    
    echo "$commits"
}

# Calculate diff statistics
calculate_statistics() {
    local merge_base="$1"
    
    log_info "Calculating diff statistics..."
    
    # Get line changes
    local stats
    stats=$(git diff --shortstat "$merge_base..$TARGET_REF")
    
    # Parse statistics
    local files_changed=0 insertions=0 deletions=0
    if [[ "$stats" =~ ([0-9]+)\ file ]]; then
        files_changed="${BASH_REMATCH[1]}"
    fi
    if [[ "$stats" =~ ([0-9]+)\ insertion ]]; then
        insertions="${BASH_REMATCH[1]}"
    fi
    if [[ "$stats" =~ ([0-9]+)\ deletion ]]; then
        deletions="${BASH_REMATCH[1]}"
    fi
    
    echo "$files_changed|$insertions|$deletions"
}

# Generate Markdown report
generate_markdown_report() {
    local merge_base="$1"
    
    log_info "Generating Markdown diff report..."
    
    # Get statistics
    IFS='|' read -r files_changed insertions deletions <<< "$(calculate_statistics "$merge_base")"
    
    # Get file changes
    local file_stats
    file_stats=$(analyze_file_changes "$merge_base")
    IFS='|' read -r added modified deleted renamed <<< "$(echo "$file_stats" | head -1)"
    
    # Start report
    cat > "$DIFF_MD_FILE" <<EOF
# Upstream Diff Report

**Generated**: $(timestamp)  
**Source**: HEAD ($(git rev-parse --short HEAD))  
**Target**: $TARGET_REF ($(git rev-parse --short "$TARGET_REF"))  
**Merge Base**: $(git rev-parse --short "$merge_base")

## Summary

- **Total Files Changed**: $files_changed
- **Lines Added**: +$insertions
- **Lines Removed**: -$deletions
- **Net Change**: $((insertions - deletions)) lines

## File Changes

- **Added**: $added files
- **Modified**: $modified files
- **Deleted**: $deleted files
- **Renamed**: $renamed files

## Changes by Category

EOF
    
    # Count by category
    for category in templates scripts cli documentation ci tests dependencies other; do
        local count=0
        count=$(analyze_file_changes "$merge_base" | tail -n +2 | grep "^$category:" | wc -l | tr -d ' ')
        if [[ "$count" -gt 0 ]]; then
            # Portable capitalization (avoid bash 4 ${var^})
            cat_name=$(printf '%s' "$category" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
            echo "### ${cat_name} ($count changes)" >> "$DIFF_MD_FILE"
            echo "" >> "$DIFF_MD_FILE"
            analyze_file_changes "$merge_base" | tail -n +2 | grep "^$category:" | while IFS=':' read -r _ file status; do
                echo "- \`$file\` ($status)" >> "$DIFF_MD_FILE"
            done
            echo "" >> "$DIFF_MD_FILE"
        fi
    done
    
    # Add commit log
    cat >> "$DIFF_MD_FILE" <<EOF

## Commit Log

\`\`\`
$(generate_commit_log "$merge_base")
\`\`\`

## Detailed Changes

To view detailed changes for a specific file:
\`\`\`bash
git diff $merge_base..$TARGET_REF -- <filename>
\`\`\`

To view changes in a graphical tool:
\`\`\`bash
git difftool $merge_base..$TARGET_REF
\`\`\`

---
*Report generated by upstream sync workflow*
EOF
    
    log_info "Markdown report saved: $DIFF_MD_FILE"
}

# Generate JSON report
generate_json_report() {
    local merge_base="$1"
    
    log_info "Generating JSON diff report..."
    
    # Get statistics
    IFS='|' read -r files_changed insertions deletions <<< "$(calculate_statistics "$merge_base")"
    IFS='|' read -r added modified deleted renamed <<< "$(analyze_file_changes "$merge_base" | head -1)"
    
    # Start JSON
    cat > "$DIFF_JSON_FILE" <<EOF
{
  "generated": "$(timestamp)",
  "source": {
    "ref": "HEAD",
    "sha": "$(git rev-parse HEAD)",
    "short": "$(git rev-parse --short HEAD)"
  },
  "target": {
    "ref": "$TARGET_REF",
    "sha": "$(git rev-parse "$TARGET_REF")",
    "short": "$(git rev-parse --short "$TARGET_REF")"
  },
  "merge_base": {
    "sha": "$merge_base",
    "short": "$(git rev-parse --short "$merge_base")"
  },
  "statistics": {
    "files_changed": $files_changed,
    "insertions": $insertions,
    "deletions": $deletions,
    "net_change": $((insertions - deletions))
  },
  "file_changes": {
    "added": $added,
    "modified": $modified,
    "deleted": $deleted,
    "renamed": $renamed
  },
  "categories": {
EOF
    
    # Add category counts
    local first=true
    for category in templates scripts cli documentation ci tests dependencies other; do
        local count
        count=$(analyze_file_changes "$merge_base" | tail -n +2 | grep "^$category:" | wc -l | tr -d ' ')
        
        if [[ "$first" == "false" ]]; then
            echo "," >> "$DIFF_JSON_FILE"
        fi
        echo -n "    \"$category\": $count" >> "$DIFF_JSON_FILE"
        first=false
    done
    
    # Add file list
    cat >> "$DIFF_JSON_FILE" <<EOF

  },
  "files": [
EOF
    
    # Add each file
    first=true
    analyze_file_changes "$merge_base" | tail -n +2 | while IFS=':' read -r category file status; do
        if [[ -n "$category" ]]; then
            if [[ "$first" == "false" ]]; then
                echo "," >> "$DIFF_JSON_FILE"
            fi
            cat >> "$DIFF_JSON_FILE" <<EOFILE
    {
      "path": "$(json_escape "$file")",
      "category": "$category",
      "status": "$status",
      "risk": "$(calculate_risk_level "$category")"
    }
EOFILE
            first=false
        fi
    done
    
    # Close JSON
    cat >> "$DIFF_JSON_FILE" <<EOF

  ],
  "commit_count": $(git rev-list --count "$merge_base..$TARGET_REF")
}
EOF
    
    log_info "JSON report saved: $DIFF_JSON_FILE"
}

# Main execution
main() {
    log_info "Starting diff report generation for $TARGET_REF..."
    
    # Check prerequisites
    check_prerequisites
    
    # Initialize reports
    initialize_reports
    
    # Get merge base
    local merge_base
    merge_base=$(get_merge_base)
    log_info "Merge base: $(git rev-parse --short "$merge_base")"
    
    # Generate reports
    generate_markdown_report "$merge_base"
    generate_json_report "$merge_base"
    
    # Summary
    log_info "Diff reports generated successfully:"
    log_info "  - Markdown: $DIFF_MD_FILE"
    log_info "  - JSON: $DIFF_JSON_FILE"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi