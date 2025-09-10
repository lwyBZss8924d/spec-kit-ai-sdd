# Implementation Plan: Upstream Sync SDD

**Feature Branch**: `003-upstream-sync-sdd`  
**Spec**: [specs/003-upstream-sync-sdd/spec.md](spec.md)  
**Status**: Ready for Implementation

## Technical Overview

This plan implements a comprehensive upstream synchronization workflow for the spec-kit-ai-sdd fork. The implementation focuses on safety, traceability, and maintainability while preserving fork-specific enhancements.

## Architecture

### Component Structure
```
scripts/
├── upstream/                 # Upstream sync components
│   ├── sync.sh              # Main orchestrator
│   ├── fetch.sh             # Fetch upstream changes
│   ├── diff-report.sh       # Generate diff reports
│   ├── compat-analyze.sh    # Compatibility analysis
│   ├── merge.sh             # Merge execution
│   └── sync-dry-run.sh      # Dry-run validation
├── ci/                      # CI/CD components
│   ├── run-local-ci.sh      # CI orchestrator
│   ├── run-sdd-structure-lint.sh
│   ├── check-language-policy.sh
│   └── check-templates-drift.sh
reports/
└── upstream/                 # Generated reports
    ├── {date}/              # Date-stamped reports
    │   ├── diff.md          # Human-readable diff
    │   ├── diff.json        # Machine-readable diff
    │   ├── compatibility.md # Compatibility assessment
    │   └── sync.log         # Execution log
    └── index.json           # Historical index
```

### Data Flow
```
1. User invokes sync.sh
2. fetch.sh retrieves upstream changes
3. diff-report.sh analyzes differences
4. compat-analyze.sh assesses compatibility
5. User reviews reports (dry-run mode)
6. merge.sh executes sync (if approved)
7. CI validation runs
8. Reports archived
```

## Implementation Phases

### Phase 1: Core Infrastructure (Foundation)
**Duration**: 2 days  
**Dependencies**: None

#### Deliverables
1. **Script Scaffolding**
   - Create directory structure: `scripts/upstream/`, `scripts/ci/`, `reports/upstream/`
   - Initialize all script files with headers and documentation
   - Set up common functions library (`scripts/upstream/lib/common.sh`)

2. **Main Orchestrator** (`scripts/upstream/sync.sh`)
   ```bash
   #!/usr/bin/env bash
   # Main orchestrator for upstream synchronization
   # Usage: sync.sh [--dry-run] [--strategy=merge|rebase] [--ref=<ref>]
   ```
   - Parse command-line arguments
   - Validate prerequisites (clean tree, upstream configured)
   - Orchestrate sub-scripts
   - Handle errors and rollback

3. **Logging Framework**
   - Structured logging with levels (INFO, WARN, ERROR)
   - Color-coded output for terminals
   - Log rotation for reports directory

#### Phase 1 Gates
- [ ] **Simplicity Gate**: Scripts use standard bash without exotic dependencies
- [ ] **Anti-abstraction Gate**: Direct git commands, no wrapper libraries
- [ ] **Test-first Gate**: Unit tests for argument parsing and validation

### Phase 2: Analysis Components
**Duration**: 3 days  
**Dependencies**: Phase 1

#### Deliverables
1. **Fetch Script** (`scripts/upstream/fetch.sh`)
   - Fetch all upstream refs (branches, tags)
   - Validate network connectivity
   - Handle authentication if needed
   - Cache fetch results for efficiency

2. **Diff Report Generator** (`scripts/upstream/diff-report.sh`)
   - Generate file-level diff statistics
   - Categorize changes by type
   - Produce both Markdown and JSON outputs
   - Include commit log summary

3. **Compatibility Analyzer** (`scripts/upstream/compat-analyze.sh`)
   - Pattern matching for high-risk changes
   - Risk scoring algorithm
   - Adaptation requirement detection
   - Breaking change identification

#### Phase 2 Gates
- [ ] **Integration-first Gate**: Define JSON schema for reports
- [ ] **Test-first Gate**: Test fixtures for diff analysis
- [ ] **Performance Gate**: Handle 1000+ file diffs efficiently

### Phase 3: Merge Execution
**Duration**: 2 days  
**Dependencies**: Phase 2

#### Deliverables
1. **Merge Script** (`scripts/upstream/merge.sh`)
   - Support merge and rebase strategies
   - Implement conflict detection
   - Create backup branches
   - Atomic operations with rollback

2. **Conflict Resolution Playbook**
   - Template conflict handler
   - Script conflict handler
   - CLI conflict handler
   - Documentation merger

3. **Dry-run Validator** (`scripts/upstream/sync-dry-run.sh`)
   - Simulate merge without commits
   - Predict conflicts
   - Generate preview reports
   - Validate CI readiness

#### Phase 3 Gates
- [ ] **Safety Gate**: All operations reversible
- [ ] **Atomicity Gate**: No partial states possible
- [ ] **Documentation Gate**: Every edge case documented

### Phase 4: Quality Validation
**Duration**: 2 days  
**Dependencies**: Phase 3

#### Deliverables
1. **CI Orchestrator** (`scripts/ci/run-local-ci.sh`)
   - Sequential execution of checks
   - Aggregate results
   - Generate CI report
   - Exit with appropriate codes

2. **SDD Structure Lint** (`scripts/ci/run-sdd-structure-lint.sh`)
   - Validate spec/plan/tasks presence
   - Check file naming conventions
   - Verify cross-references
   - Ensure completeness

3. **Language Policy Check** (`scripts/ci/check-language-policy.sh`)
   - Scan normative artifacts
   - Detect non-English content
   - Allow code blocks and examples
   - Generate violations report

4. **Template Drift Detector** (`scripts/ci/check-templates-drift.sh`)
   - Compare templates with upstream
   - Identify structural changes
   - Flag incompatibilities
   - Suggest adaptations

#### Phase 4 Gates
- [ ] **Coverage Gate**: All validation types implemented
- [ ] **Accuracy Gate**: No false positives in lint
- [ ] **Speed Gate**: CI completes in < 1 minute

### Phase 5: Documentation & Integration
**Duration**: 1 day  
**Dependencies**: Phase 4

#### Deliverables
1. **Quickstart Guide** (`docs/upstream-sync-workflow.md`)
   - Step-by-step instructions
   - Common scenarios
   - Troubleshooting guide
   - FAQ section

2. **AI Agent Updates**
   - Update CLAUDE.md with sync commands
   - Update WARP.md with workflow
   - Add AGENTS.md at root
   - Feature-specific context files

3. **PR Template**
   - Sync summary template
   - Checklist for reviewers
   - Links to reports
   - Rollback instructions

#### Phase 5 Gates
- [ ] **Completeness Gate**: All docs cross-referenced
- [ ] **Clarity Gate**: Instructions testable by new user
- [ ] **Integration Gate**: Works with existing workflows

## Technical Decisions

### Choice: Bash over Python
**Rationale**: 
- Universal availability on Unix systems
- Direct git integration
- Lower complexity for maintainers
- No dependency management

**Trade-offs**:
- (+) Simple, portable, fast
- (-) Limited data structures
- (-) Error handling more verbose

### Choice: Merge over Rebase (default)
**Rationale**:
- Preserves fork history
- Safer for collaborative work
- Easier conflict resolution
- Clear audit trail

**Trade-offs**:
- (+) Non-destructive
- (+) Reversible
- (-) More merge commits
- (-) Complex history graph

### Choice: JSON for Machine-Readable Reports
**Rationale**:
- Universal parsing support
- Schema validation possible
- Direct jq integration
- GitHub API compatible

**Trade-offs**:
- (+) Structured data
- (+) Tool ecosystem
- (-) Verbose for simple data
- (-) Requires jq dependency

## Risk Mitigation

### Risk: Upstream Force Push
**Mitigation**:
- Detect ref changes before merge
- Create backup branches
- Warn user prominently
- Require manual confirmation

### Risk: Breaking Template Changes
**Mitigation**:
- Pre-merge template analysis
- Compatibility shims
- Gradual migration path
- Rollback procedure

### Risk: Merge Conflict Cascade
**Mitigation**:
- Categorized resolution
- Incremental merging
- Conflict isolation
- Clear escalation path

## Testing Strategy

### Unit Tests
- Script argument parsing
- Function libraries
- Error conditions
- Report generation

### Integration Tests
- End-to-end dry-run
- Multi-file conflicts
- Large diff handling
- CI pipeline execution

### Acceptance Tests
- Sync with real upstream
- Conflict resolution flow
- Report accuracy
- Rollback procedures

## Success Metrics

### Implementation Success
- [ ] All scripts executable and documented
- [ ] Dry-run mode fully functional
- [ ] Reports generating correctly
- [ ] CI validation passing

### Operational Success
- [ ] First sync completed successfully
- [ ] < 10 minute execution time
- [ ] Zero data loss incidents
- [ ] Team can operate independently

## Dependencies

### External Tools
- git 2.30+
- bash 4.0+
- jq 1.6+
- GNU coreutils

### Repository State
- Upstream remote configured
- Clean working tree
- Write access to reports/

### Knowledge Requirements
- Git branching concepts
- Merge conflict resolution
- Bash scripting basics
- JSON structure

## Rollback Plan

### Sync Failure
1. Restore from backup branch
2. Reset to pre-sync commit
3. Clean working tree
4. Review failure logs

### Script Errors
1. Revert script changes
2. Restore previous version
3. Document issue
4. Implement fix

## Phase Gates Summary

### Pre-Implementation Gate
- [ ] Specification approved
- [ ] Dependencies available
- [ ] Team alignment achieved

### Simplicity Gate
- [ ] No unnecessary abstractions
- [ ] Direct tool usage
- [ ] Clear code structure

### Anti-Abstraction Gate
- [ ] No wrapper libraries
- [ ] Direct git commands
- [ ] Minimal indirection

### Test-First Gate
- [ ] Tests before implementation
- [ ] Coverage targets defined
- [ ] Fixtures prepared

### Integration-First Gate
- [ ] Interfaces defined
- [ ] Contracts specified
- [ ] Schemas documented

## Next Steps

1. Create script directories and files
2. Implement Phase 1 foundation
3. Write unit tests for core functions
4. Begin Phase 2 analysis components
5. Document progress in tasks.md

## Approvals

- [ ] Technical Lead Review
- [ ] Security Review (if handling credentials)
- [ ] Documentation Review
- [ ] Ready for Implementation
