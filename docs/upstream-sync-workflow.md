# Upstream Sync Workflow

Language Policy Reminder: All normative artifacts (PRDs, specifications, implementation plans, issues, task plans) must be written in English.

This guide describes how to safely synchronize this fork with the upstream repository.

## Quick Start

1. Ensure upstream remote is configured:
   ```bash
   git remote -v | grep upstream || git remote add upstream https://github.com/github/spec-kit.git
   ```
2. Preview the sync (dry-run):
   ```bash
   scripts/upstream/sync.sh --dry-run
   ```
3. Review reports in `reports/upstream/<YYYYMMDD>/`:
   - `diff.md` – summary of changes
   - `diff.json` – machine-readable details
   - `compatibility.md` – risk assessment & recommendations
   - `sync.log` – execution log
4. Execute the sync (merge by default):
   ```bash
   scripts/upstream/sync.sh
   ```
5. Run local CI validation:
   ```bash
   scripts/ci/run-local-ci.sh
   ```
6. Create a PR with links to reports and specs.

## Options

- Strategy:
  ```bash
  scripts/upstream/sync.sh --strategy rebase
  ```
- Target ref (tag/branch):
  ```bash
  scripts/upstream/sync.sh --ref upstream/v0.0.20
  ```
- Skip CI (not recommended):
  ```bash
  scripts/upstream/sync.sh --no-ci
  ```

## Conflict Resolution

Use the Conflict Resolution Playbook:
- templates: preserve SDD structure
- scripts: preserve fork workflows
- CLI: maintain compatibility (add shims if needed)
- docs: enforce English-only

## CI Checks

- SDD structure lint: spec.md, plan.md, tasks.md exist per feature
- Language policy: normative artifacts contain only English
- Template drift: alerts on differences from upstream templates

## Troubleshooting

- Dirty working tree: commit or stash changes before sync
- Missing upstream: add the upstream remote
- CI failures: open reports and fix issues, then re-run

---
*See specs/003-upstream-sync-sdd for the full SDD.*
