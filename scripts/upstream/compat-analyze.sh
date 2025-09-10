#!/usr/bin/env bash
# Analyze compatibility and assess risk of upstream changes

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Target ref (can be overridden by argument)
TARGET_REF="${1:-upstream/main}"

# Report file
COMPAT_REPORT="$REPORT_DIR/compatibility.md"

# Risk thresholds
HIGH_RISK_THRESHOLD=5
MEDIUM_RISK_THRESHOLD=2

# Risk weight function (avoid associative arrays for macOS bash compatibility)
get_risk_weight() {
    case "$1" in
        templates) echo 5 ;;
        cli) echo 4 ;;
        scripts|dependencies) echo 3 ;;
        ci) echo 2 ;;
        documentation|tests|other|*) echo 1 ;;
    esac
}

# Breaking change patterns
BREAKING_PATTERNS=(
    "BREAKING CHANGE"
    "BREAKING:"
    "breaking change"
    "incompatible"
    "removed"
    "deprecated"
    "renamed"
    "moved"
)

# Initialize report
initialize_report() {
    log_info "Initializing compatibility report..."
    ensure_dir "$REPORT_DIR"
    > "$COMPAT_REPORT"
}

# Check for breaking changes in commits
check_breaking_commits() {
    local merge_base="$1"
    local breaking_commits=()
    
    log_info "Checking for breaking changes in commits..."
    
    # Check commit messages for breaking patterns
    while IFS= read -r commit; do
        local message
        message=$(git log -1 --format=%B "$commit")
        
        for pattern in "${BREAKING_PATTERNS[@]}"; do
            if echo "$message" | grep -qi "$pattern"; then
                breaking_commits+=("$commit: $(git log -1 --format=%s "$commit")")
                break
            fi
        done
    done < <(git rev-list "$merge_base..$TARGET_REF")
    
    if [[ ${#breaking_commits[@]} -gt 0 ]]; then
        log_warn "Found ${#breaking_commits[@]} commits with potential breaking changes"
    fi
    
    printf '%s\n' "${breaking_commits[@]}"
}

# Analyze template changes
analyze_template_changes() {
    local merge_base="$1"
    local template_changes=()
    
    log_info "Analyzing template changes..."
    
    # Get changed template files
    while IFS=$'\t' read -r status file rest; do
        if [[ "$file" =~ ^templates/ ]]; then
            case "$status" in
                D) template_changes+=("DELETED: $file") ;;
                A) template_changes+=("ADDED: $file") ;;
                M) template_changes+=("MODIFIED: $file") ;;
                R*) template_changes+=("RENAMED: $file -> $rest") ;;
            esac
        fi
    done < <(git diff --name-status --find-renames "$merge_base..$TARGET_REF")
    
    if [[ ${#template_changes[@]} -gt 0 ]]; then
        log_warn "Found ${#template_changes[@]} template changes"
    fi
    
    printf '%s\n' "${template_changes[@]}"
}

# Analyze CLI interface changes
analyze_cli_changes() {
    local merge_base="$1"
    local cli_changes=()
    
    log_info "Analyzing CLI interface changes..."
    
    # Check for changes in CLI files
    local cli_files
    cli_files=$(git diff --name-only "$merge_base..$TARGET_REF" | grep -E "(src/specify_cli|pyproject\.toml)" || true)
    
    if [[ -n "$cli_files" ]]; then
        # Check for command changes
        while IFS= read -r file; do
            if [[ "$file" == "src/specify_cli/__init__.py" ]]; then
                cli_changes+=("CRITICAL: Main CLI file modified")
            elif [[ "$file" == "pyproject.toml" ]]; then
                cli_changes+=("Dependencies or entry points may have changed")
            else
                cli_changes+=("CLI component modified: $file")
            fi
        done <<< "$cli_files"
    fi
    
    printf '%s\n' "${cli_changes[@]}"
}

# Analyze script changes
analyze_script_changes() {
    local merge_base="$1"
    local script_changes=()
    
    log_info "Analyzing script changes..."
    
    # Get changed script files
    local scripts
    scripts=$(git diff --name-only "$merge_base..$TARGET_REF" | grep -E "^scripts/.*\.(sh|py)$" || true)
    
    if [[ -n "$scripts" ]]; then
        while IFS= read -r script; do
            # Check if script was deleted
            if ! git cat-file -e "$TARGET_REF:$script" 2>/dev/null; then
                script_changes+=("DELETED: $script")
            else
                # Check for function signature changes
                local diff_output
                diff_output=$(git diff "$merge_base..$TARGET_REF" -- "$script" | grep -E "^[+-](function |def )" || true)
                if [[ -n "$diff_output" ]]; then
                    script_changes+=("Function signatures changed in $script")
                else
                    script_changes+=("Modified: $script")
                fi
            fi
        done <<< "$scripts"
    fi
    
    printf '%s\n' "${script_changes[@]}"
}

# Calculate overall risk score
calculate_risk_score() {
    local merge_base="$1"
    local total_score=0
    local risk_details=()
    
    log_info "Calculating risk score..."
    
    # Count changes by category
    while IFS=$'\t' read -r status file rest; do
        local category
        category=$(categorize_file "$file")
        local score
        score=$(get_risk_weight "$category")
        
        # Increase score for deletions
        if [[ "$status" == "D" ]]; then
            score=$((score * 2))
        fi
        
        total_score=$((total_score + score))
        risk_details+=("$category:$score:$file:$status")
    done < <(git diff --name-status --find-renames "$merge_base..$TARGET_REF")
    
    # Check for breaking commits
    local breaking_count
    breaking_count=$(check_breaking_commits "$merge_base" | wc -l)
    if [[ $breaking_count -gt 0 ]]; then
        total_score=$((total_score + breaking_count * 3))
    fi
    
    echo "$total_score"
    printf '%s\n' "${risk_details[@]}"
}

# Determine risk level
determine_risk_level() {
    local score="$1"
    
    if [[ $score -ge $HIGH_RISK_THRESHOLD ]]; then
        echo "high"
    elif [[ $score -ge $MEDIUM_RISK_THRESHOLD ]]; then
        echo "medium"
    else
        echo "low"
    fi
}

# Generate recommendations
generate_recommendations() {
    local risk_level="$1"
    local template_changes="$2"
    local cli_changes="$3"
    local script_changes="$4"
    
    local recommendations=()
    
    case "$risk_level" in
        high)
            recommendations+=("⚠️  High-risk sync - careful review required")
            recommendations+=("Create feature branch for sync")
            recommendations+=("Run comprehensive test suite")
            recommendations+=("Review all template changes for SDD impact")
            ;;
        medium)
            recommendations+=("Medium-risk sync - standard review process")
            recommendations+=("Test affected components")
            recommendations+=("Update documentation as needed")
            ;;
        low)
            recommendations+=("Low-risk sync - routine update")
            recommendations+=("Run basic validation tests")
            ;;
    esac
    
    # Specific recommendations
    if [[ -n "$template_changes" ]]; then
        recommendations+=("Review template changes for SDD workflow impact")
        recommendations+=("Update template documentation")
    fi
    
    if [[ -n "$cli_changes" ]]; then
        recommendations+=("Test CLI commands thoroughly")
        recommendations+=("Verify AI agent integrations")
    fi
    
    if [[ -n "$script_changes" ]]; then
        recommendations+=("Review script changes for workflow impact")
        recommendations+=("Update script documentation")
    fi
    
    printf '%s\n' "${recommendations[@]}"
}

# Generate compatibility report
generate_report() {
    local merge_base="$1"
    
    log_info "Generating compatibility report..."
    
    # Get analyses
    local breaking_commits template_changes cli_changes script_changes
    breaking_commits=$(check_breaking_commits "$merge_base")
    template_changes=$(analyze_template_changes "$merge_base")
    cli_changes=$(analyze_cli_changes "$merge_base")
    script_changes=$(analyze_script_changes "$merge_base")
    
    # Calculate risk
    local risk_data
    risk_data=$(calculate_risk_score "$merge_base")
    local risk_score
    risk_score=$(echo "$risk_data" | head -1)
    local risk_level
    risk_level=$(determine_risk_level "$risk_score")
    
    # Determine if adaptation is required
    local adaptation_required="false"
    if [[ "$risk_level" == "high" ]] || [[ -n "$template_changes" ]] || [[ -n "$cli_changes" ]]; then
        adaptation_required="true"
    fi
    
    # Generate recommendations
    local recommendations
    recommendations=$(generate_recommendations "$risk_level" "$template_changes" "$cli_changes" "$script_changes")
    
    # Write report
    cat > "$COMPAT_REPORT" <<EOF
# Compatibility Analysis Report

**Generated**: $(timestamp)  
**Target**: $TARGET_REF  
**Risk Level**: **${risk_level^^}**  
**Risk Score**: $risk_score  
**Adaptation Required**: **$adaptation_required**

## Risk Assessment

### Overall Risk: ${risk_level^^}

- Total risk score: $risk_score
- Threshold: Low (<$MEDIUM_RISK_THRESHOLD), Medium ($MEDIUM_RISK_THRESHOLD-$HIGH_RISK_THRESHOLD), High (>$HIGH_RISK_THRESHOLD)

### Risk Breakdown by Category

| Category | Risk Weight | Changes | Impact |
|----------|------------|---------|--------|
EOF
    
    # Add category breakdown
    for category in templates scripts cli dependencies ci documentation tests other; do
        local count
        count=$(printf '%s\n' "$risk_data" | tail -n +2 | awk -F: -v c="$category" 'BEGIN{n=0} $1==c {n++} END{print n}')
        local weight
        weight=$(get_risk_weight "$category")
        local impact="Low"
        if [[ "$weight" -ge 4 ]]; then
            impact="High"
        elif [[ "$weight" -ge 3 ]]; then
            impact="Medium"
        fi
        
        if [[ "${count:-0}" -gt 0 ]]; then
            echo "| $category | $weight | $count | $impact |" >> "$COMPAT_REPORT"
        fi
    done
    
    # Add detailed findings
    cat >> "$COMPAT_REPORT" <<EOF

## Detailed Findings

### Breaking Changes
EOF
    
    if [[ -n "$breaking_commits" ]]; then
        echo "" >> "$COMPAT_REPORT"
        echo "⚠️  **Commits with breaking change indicators:**" >> "$COMPAT_REPORT"
        echo "" >> "$COMPAT_REPORT"
        echo "$breaking_commits" | while read -r commit; do
            echo "- $commit" >> "$COMPAT_REPORT"
        done
    else
        echo "" >> "$COMPAT_REPORT"
        echo "✅ No breaking change indicators found in commit messages" >> "$COMPAT_REPORT"
    fi
    
    cat >> "$COMPAT_REPORT" <<EOF

### Template Changes
EOF
    
    if [[ -n "$template_changes" ]]; then
        echo "" >> "$COMPAT_REPORT"
        echo "⚠️  **Template modifications detected:**" >> "$COMPAT_REPORT"
        echo "" >> "$COMPAT_REPORT"
        echo "$template_changes" | while read -r change; do
            echo "- $change" >> "$COMPAT_REPORT"
        done
    else
        echo "" >> "$COMPAT_REPORT"
        echo "✅ No template changes detected" >> "$COMPAT_REPORT"
    fi
    
    cat >> "$COMPAT_REPORT" <<EOF

### CLI Interface Changes
EOF
    
    if [[ -n "$cli_changes" ]]; then
        echo "" >> "$COMPAT_REPORT"
        echo "⚠️  **CLI modifications detected:**" >> "$COMPAT_REPORT"
        echo "" >> "$COMPAT_REPORT"
        echo "$cli_changes" | while read -r change; do
            echo "- $change" >> "$COMPAT_REPORT"
        done
    else
        echo "" >> "$COMPAT_REPORT"
        echo "✅ No CLI interface changes detected" >> "$COMPAT_REPORT"
    fi
    
    cat >> "$COMPAT_REPORT" <<EOF

### Script Changes
EOF
    
    if [[ -n "$script_changes" ]]; then
        echo "" >> "$COMPAT_REPORT"
        echo "ℹ️  **Script modifications detected:**" >> "$COMPAT_REPORT"
        echo "" >> "$COMPAT_REPORT"
        echo "$script_changes" | while read -r change; do
            echo "- $change" >> "$COMPAT_REPORT"
        done
    else
        echo "" >> "$COMPAT_REPORT"
        echo "✅ No script changes detected" >> "$COMPAT_REPORT"
    fi
    
    cat >> "$COMPAT_REPORT" <<EOF

## Recommendations

EOF
    
    echo "$recommendations" | while read -r rec; do
        echo "- $rec" >> "$COMPAT_REPORT"
    done
    
    cat >> "$COMPAT_REPORT" <<EOF

## Metadata

- **Merge Base**: $(git rev-parse --short "$merge_base")
- **Analysis Date**: $(timestamp)
- **adaptation-required**: $adaptation_required
- **risk-level**: $risk_level
- **risk-score**: $risk_score

---
*Generated by upstream sync compatibility analyzer*
EOF
    
    log_info "Compatibility report saved: $COMPAT_REPORT"
}

# Main execution
main() {
    log_info "Starting compatibility analysis for $TARGET_REF..."
    
    # Check prerequisites
    check_prerequisites
    
    # Initialize report
    initialize_report
    
    # Get merge base
    local merge_base
    merge_base=$(git_merge_base "$TARGET_REF")
    if [[ -z "$merge_base" ]]; then
        die "Cannot find merge base with $TARGET_REF"
    fi
    log_info "Merge base: $(git rev-parse --short "$merge_base")"
    
    # Generate report
    generate_report "$merge_base"
    
    # Read final assessment
    local adaptation_required risk_level
    adaptation_required=$(grep "adaptation-required:" "$COMPAT_REPORT" | tail -1 | awk '{print $2}' || true)
    risk_level=$(grep "risk-level:" "$COMPAT_REPORT" | tail -1 | awk '{print $2}' || true)
    
    log_info "Compatibility analysis complete:"
    log_info "  Risk level: ${risk_level:-unknown}"
    log_info "  Adaptation required: ${adaptation_required:-unknown}"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi