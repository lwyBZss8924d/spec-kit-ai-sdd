# AGENTS.md - Feature 004: Local CI Validation & Upstream Compatibility

Cross-agent guidance for running local CI checks and interpreting results.

## Entry Points
- `scripts/ci/run-local-ci.sh` (orchestrator)
- `scripts/upstream/sync.sh` (invokes CI after merge/rebase)

## Checks
- Structure Lint: verifies `spec.md`, `plan.md`, `tasks.md` per feature; exclude example/early directories by default
- Language Policy: flags non-English letters in normative artifacts; ignores emoji/symbols/code fences
- Template Drift: compares `templates/` with upstream ref (default `upstream/main`), fails on drift

## Usage
```bash
# Full CI
scripts/ci/run-local-ci.sh

# Target a specific upstream ref
scripts/ci/run-local-ci.sh upstream/main
```

## Interpreting Results
- PASS: All checks green; safe to proceed
- FAIL (Structure): fill missing SDD files or adjust exclusions
- FAIL (Language): remove/translate non-English letters
- FAIL (Drift): review diff and plan adaptation before merging upstream

## References
- Spec: specs/004-local-ci-checks/spec.md
- Plan: specs/004-local-ci-checks/plan.md
- Tasks: specs/004-local-ci-checks/tasks.md
- Root: WARP.md, AGENTS.md
