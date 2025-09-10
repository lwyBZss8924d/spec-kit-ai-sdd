# Upstream Sync Adaptation Plan

Date: 2025-09-10
Branch: 005-sync-upstream-v0.0.20
Target: upstream/main (latest tag v0.0.20)

## Summary
Upstream adds a new documentation system (docfx) and changes several SDD templates under `templates/`. Template Drift is intentionally blocking. We will adopt upstream templates verbatim to keep drift green, and maintain fork-specific guidance in repository docs (WARP.md/AGENTS.md/feature docs) instead of altering core templates.

## Inputs
- Diff reports: `reports/upstream/20250910/diff.md`, `diff.json`
- Compatibility: `reports/upstream/20250910/compatibility.md`
- Template diffs: `reports/upstream/20250910/templates-diff/*.diff`
- Upstream snapshots: `reports/upstream/20250910/upstream-templates/`

## Policy
- Keep core templates aligned with upstream to minimize future drift.
- Preserve fork-specific SDD rules (English-only, gates) via docs and CI checks, not by modifying templates unless necessary.
- Keep Template Drift as a blocking CI gate.

## File Decisions
1) `templates/agent-file-template.md`
   - Adopt upstream; retain extra guidance in docs/ and AGENTS.md.
2) `templates/plan-template.md`
   - Adopt upstream; our gates remain enforced by CI/docs (003/004), not by template edits.
3) `templates/spec-template.md`
   - Adopt upstream; English-only remains in repository rules/CI.
4) `templates/tasks-template.md`
   - Adopt upstream; TDD-first is documented/enforced by CI and plans.
5) `templates/commands/{plan.md,specify.md,tasks.md}`
   - Adopt upstream wording for parity with releases.

## Execution Plan
1. Replace local templates with upstream snapshots from `reports/upstream/20250910/upstream-templates/`.
2. Run `scripts/ci/run-local-ci.sh` to verify Template Drift passes and other checks remain green.
3. If additional drift appears, iterate until clean.
4. Proceed to `scripts/upstream/sync.sh` (merge by default) once CI is green.

## Acceptance
- Template Drift passes.
- Structure & Language checks pass.
- Docs reflect any fork-specific guidance removed from templates.

