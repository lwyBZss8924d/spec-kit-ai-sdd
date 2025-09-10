# Task Breakdown: Local CI Validation & Upstream Compatibility

**Feature Branch**: `004-local-ci-checks`  
**Spec**: specs/004-local-ci-checks/spec.md  
**Plan**: specs/004-local-ci-checks/plan.md  
**Status**: Ready for Execution

## Tasks

### TASK-004-01: Orchestrator Entry Point
- Create/verify `scripts/ci/run-local-ci.sh` with sequential execution, timing, and exit codes
- Acceptance:
  - [ ] Runs structure lint, language policy, template drift
  - [ ] Prints PASS/FAIL and durations
  - [ ] Exits non-zero on any failure

### TASK-004-02: Structure Lint with Exclusions
- Implement `scripts/ci/run-sdd-structure-lint.sh` that validates spec.md, plan.md, tasks.md
- Add default exclusions for example/early directories and support SDD_LINT_EXCLUDE
- Acceptance:
  - [ ] Exclusions honored
  - [ ] Missing files clearly reported

### TASK-004-03: Language Policy Enforcement
- Implement `scripts/ci/check-language-policy.sh` using Python to flag non-ASCII letters while ignoring emoji/symbols and code fences
- Acceptance:
  - [ ] Reports file and first N lines with violations
  - [ ] Exits non-zero on violation

### TASK-004-04: Template Drift Detection
- Implement `scripts/ci/check-templates-drift.sh` to compare templates/ against upstream ref (default upstream/main)
- Acceptance:
  - [ ] Fails on drift with status summary
  - [ ] Handles missing upstream with clear guidance

### TASK-004-05: Sync Integration
- Ensure `scripts/upstream/sync.sh` invokes run-local-ci.sh post-merge/rebase
- Acceptance:
  - [ ] CI runs automatically from sync workflow
  - [ ] Failures abort non-forced sync

### TASK-004-06: Documentation
- Update/author docs:
  - docs/upstream-sync-workflow.md (quickstart references to CI)
  - docs/conflict-resolution-playbook.md (triaging CI failures)
- Acceptance:
  - [ ] Docs reflect latest CI commands and behavior

### TASK-004-07: Agent Context
- Add feature-level `CLAUDE.md` and `AGENTS.md` summarizing CI commands, outputs, and failure handling
- Acceptance:
  - [ ] Files exist under specs/004-local-ci-checks/
  - [ ] Reference project-level WARP.md and root AGENTS.md

### TASK-004-08: Performance Target
- Measure runtime on local machine and capture typical durations
- Acceptance:
  - [ ] run-local-ci.sh completes ~< 60s

## Success Criteria
- [ ] CI entrypoint stable with clear outputs and codes
- [ ] Structure lint and language policy pass on current repo
- [ ] Template drift remains blocking with actionable output
- [ ] Docs/agent files updated

