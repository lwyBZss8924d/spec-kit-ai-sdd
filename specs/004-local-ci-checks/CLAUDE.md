# CLAUDE.md - Feature 004: Local CI Validation & Upstream Compatibility

This document guides Claude for implementing and maintaining local CI checks that enforce SDD compliance and upstream compatibility.

## Scope
- CI entrypoint: `scripts/ci/run-local-ci.sh`
- Checks: structure lint, language policy, template drift
- Integration: Called from `scripts/upstream/sync.sh` after merge/rebase

## Commands
```bash
# Run local CI
scripts/ci/run-local-ci.sh

# Provide upstream ref explicitly
scripts/ci/run-local-ci.sh upstream/main

# Sync workflow runs CI automatically
scripts/upstream/sync.sh --ref upstream/main
```

## Failure Modes and Remedies
- STRUCTURE: Fill in missing `spec.md`, `plan.md`, `tasks.md` (or add exclusions via SDD_LINT_EXCLUDE for intentional exceptions)
- LANG: Remove non-English letters from normative artifacts or translate to English; code fences and emoji are tolerated
- DRIFT: Review upstream differences in `templates/` and plan adaptations; drift remains blocking until resolved

## Notes
- Keep runtime < 60s target
- Ensure exit codes are reliable for automation
- Maintain English-only policy for all normative documents

## References
- Spec: specs/004-local-ci-checks/spec.md
- Plan: specs/004-local-ci-checks/plan.md
- Tasks: specs/004-local-ci-checks/tasks.md
- Root: WARP.md, AGENTS.md

