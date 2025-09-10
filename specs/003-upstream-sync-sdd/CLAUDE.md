# CLAUDE.md - Feature 003: Upstream Sync SDD

This file provides Claude-specific guidance for the upstream synchronization feature.

## Feature Overview

This feature implements a comprehensive workflow for synchronizing the spec-kit-ai-sdd fork with its upstream source (github/spec-kit). The implementation ensures safe integration of upstream changes while preserving fork-specific enhancements.

## Language Policy

All specifications, plans, tasks, and documentation for this feature MUST be written in English.

## Feature Status

- **Branch**: `003-upstream-sync-sdd`
- **Spec**: Complete
- **Plan**: Complete
- **Tasks**: Ready for execution
- **Implementation**: Pending

## Available Commands

### Sync Workflow
```bash
# Main orchestrator
scripts/upstream/sync.sh [options]
  --dry-run              # Preview without changes
  --strategy=merge       # Use merge (default)
  --strategy=rebase      # Use rebase
  --ref=<ref>           # Target specific ref

# Component scripts
scripts/upstream/fetch.sh           # Fetch upstream
scripts/upstream/diff-report.sh     # Generate reports
scripts/upstream/compat-analyze.sh  # Assess compatibility
scripts/upstream/merge.sh          # Execute sync
scripts/upstream/sync-dry-run.sh   # Dry run
```

### CI Validation
```bash
scripts/ci/run-local-ci.sh              # Full CI suite
scripts/ci/run-sdd-structure-lint.sh    # SDD validation
scripts/ci/check-language-policy.sh     # Language check
scripts/ci/check-templates-drift.sh     # Template drift
```

## Implementation Tasks

Key tasks to implement (see tasks.md for full list):
- TASK-003-01: Create directory structure
- TASK-003-02: Implement main orchestrator
- TASK-003-03: Create common functions library
- TASK-003-04: Implement fetch script
- TASK-003-05: Implement diff report generator
- TASK-003-06: Implement compatibility analyzer
- TASK-003-07: Implement merge script
- TASK-003-08: Create conflict resolution playbook
- TASK-003-09: Implement dry-run validator

## Conflict Resolution

When conflicts occur, categorize and resolve:

### Template Conflicts
1. Analyze structural changes
2. Preserve SDD enhancements
3. Merge improvements
4. Update placeholders
5. Validate instantiation

### Script Conflicts
1. Identify functional vs refactoring
2. Preserve fork scripts
3. Merge improvements
4. Update documentation
5. Test execution

### CLI Conflicts
1. Analyze interface changes
2. Maintain compatibility
3. Add shims if needed
4. Update docs
5. Test all agents

### Documentation Conflicts
1. Merge factual updates
2. Preserve fork sections
3. Enforce English policy
4. Update references
5. Validate markdown

## Testing Strategy

### Unit Tests
- Argument parsing
- Function libraries
- Error conditions
- Report generation

### Integration Tests
- End-to-end dry-run
- Conflict scenarios
- Large diffs
- CI pipeline

### Acceptance Tests
- Real upstream sync
- Conflict resolution
- Report accuracy
- Rollback procedures

## Report Structure

Reports generated in `reports/upstream/{date}/`:
```
diff.md              # Human-readable changes
diff.json            # Machine-readable data
compatibility.md     # Risk assessment
sync.log            # Execution log
```

## Common Scenarios

### First-Time Sync
```bash
# Ensure upstream configured
git remote -v | grep upstream

# Run dry-run
./scripts/upstream/sync.sh --dry-run

# Review reports
cat reports/upstream/$(date +%Y%m%d)/compatibility.md

# Execute if safe
./scripts/upstream/sync.sh
```

### Handling Conflicts
```bash
# Sync detects conflicts
./scripts/upstream/sync.sh

# Follow playbook
cat docs/conflict-resolution-playbook.md

# Resolve per category
# ... manual resolution ...

# Validate resolution
./scripts/ci/run-local-ci.sh

# Commit resolution
git add -A
git commit -m "fix: resolve upstream sync conflicts"
```

### High-Risk Changes
```bash
# Compatibility reports high risk
cat reports/upstream/$(date +%Y%m%d)/compatibility.md

# Create adaptation plan
# Document in specs/005-execute-upstream-sync/

# Implement adaptations
# ... code changes ...

# Re-run sync
./scripts/upstream/sync.sh
```

## Best Practices

1. **Always dry-run first** - Never sync without preview
2. **Review all reports** - Understand impacts before merging
3. **Document resolutions** - Update playbook with new scenarios
4. **Test thoroughly** - Run full CI after sync
5. **Tag successful syncs** - Create version tags for rollback

## Troubleshooting

### Common Issues

**Dirty working tree**
```bash
git status
git stash  # or commit changes
```

**Missing upstream remote**
```bash
git remote add upstream https://github.com/github/spec-kit.git
```

**Network timeout during fetch**
```bash
# Retry with increased timeout
GIT_HTTP_LOW_SPEED_TIME=600 ./scripts/upstream/fetch.sh
```

**Merge conflicts in templates**
```bash
# Use fork version, then adapt
git checkout --ours templates/
# Manually integrate upstream improvements
```

## Notes for Claude

- Prioritize safety over speed
- Preserve all fork enhancements
- Document every decision
- Create comprehensive reports
- Maintain English-only policy
- Link commits to task IDs
- Update specs as needed

## Related Documentation

- [Specification](spec.md)
- [Implementation Plan](plan.md)
- [Task Breakdown](tasks.md)
- Root [CLAUDE.md](../../CLAUDE.md)
- Root [AGENTS.md](../../AGENTS.md)
- Root [WARP.md](../../WARP.md)

---

*Feature-specific guidance for Claude. Refer to root documentation for general repository guidance.*
