# AGENTS.md - Feature 003: Upstream Sync SDD

Cross-agent guidance for the upstream synchronization feature. All agents should follow these guidelines when working on this feature.

## Feature Context

**Purpose**: Synchronize fork with upstream github/spec-kit  
**Branch**: `003-upstream-sync-sdd`  
**Priority**: Critical for fork maintenance  
**Language**: English only for all artifacts

## Quick Command Reference

```bash
# Sync workflow
scripts/upstream/sync.sh --dry-run      # Always start here
scripts/upstream/sync.sh                # Execute sync
scripts/upstream/sync.sh --strategy=rebase  # Alternative strategy

# Validation
scripts/ci/run-local-ci.sh              # Full validation
scripts/ci/check-templates-drift.sh     # Template changes

# Reports
ls reports/upstream/$(date +%Y%m%d)/    # Today's reports
cat reports/upstream/$(date +%Y%m%d)/compatibility.md
```

## Agent-Specific Instructions

### Claude (claude.ai/code)
- Primary agent for implementation
- Use CLAUDE.md for detailed guidance
- Focus on comprehensive documentation

### Warp (warp.dev)
- Execute scripts and debug issues
- Terminal-based workflow preferred
- Use for testing and validation

### Gemini CLI
- Alternative implementation agent
- Run with `gemini` prefix for commands
- Cross-check Claude's implementation

### GitHub Copilot
- Code completion for scripts
- Suggest improvements to existing code
- Help with bash syntax

## Implementation Checklist

### Phase 1: Infrastructure
- [ ] Directory structure created
- [ ] Main orchestrator functional
- [ ] Common library complete

### Phase 2: Analysis
- [ ] Fetch script working
- [ ] Diff reports generating
- [ ] Compatibility assessment accurate

### Phase 3: Execution
- [ ] Merge script functional
- [ ] Conflict playbook documented
- [ ] Dry-run validation complete

### Phase 4: Validation
- [ ] CI checks implemented
- [ ] Language policy enforced
- [ ] Template drift detected

### Phase 5: Documentation
- [ ] Quickstart guide written
- [ ] PR template created
- [ ] Agent files updated

## Safety Guidelines

1. **Never sync without dry-run**
2. **Always create backup branches**
3. **Document all conflicts**
4. **Test before committing**
5. **Tag successful syncs**

## Report Interpretation

### Compatibility Report
- **Low Risk**: Proceed normally
- **Medium Risk**: Review carefully
- **High Risk**: Plan adaptations first

### Diff Report
- Check categories: templates, scripts, CLI, docs
- Note file counts and line changes
- Identify removed features

## Conflict Resolution Quick Guide

| Conflict Type | Priority | Strategy |
|--------------|----------|----------|
| Templates | High | Preserve SDD structure |
| Scripts | Medium | Merge functionality |
| CLI | High | Maintain compatibility |
| Docs | Low | Enforce English |

## Testing Requirements

Before marking complete:
1. Dry-run executes without errors
2. Reports generate correctly
3. CI validation passes
4. Conflicts resolvable
5. Rollback tested

## Common Commands

```bash
# Check status
git status
git remote -v

# Run sync
./scripts/upstream/sync.sh --dry-run
./scripts/upstream/sync.sh

# Validate
./scripts/ci/run-local-ci.sh

# Review
cat reports/upstream/*/compatibility.md
cat reports/upstream/*/diff.md

# Troubleshoot
tail -f reports/upstream/sync.log
```

## Error Recovery

### Sync Failed
```bash
git status
git reset --hard HEAD
git checkout main
```

### Conflicts Unresolvable
```bash
git merge --abort
# or
git rebase --abort
```

### Reports Missing
```bash
mkdir -p reports/upstream/$(date +%Y%m%d)
./scripts/upstream/diff-report.sh
```

## Success Criteria

Feature is complete when:
- [ ] All tasks in tasks.md completed
- [ ] Scripts executable and documented
- [ ] Dry-run successful
- [ ] Reports generating
- [ ] CI passing
- [ ] Documentation complete

## Links

- [Full Specification](spec.md)
- [Implementation Plan](plan.md)
- [Task Breakdown](tasks.md)
- [Root AGENTS.md](../../AGENTS.md)

---

*Cross-agent feature guidance. All agents should coordinate using this document.*
