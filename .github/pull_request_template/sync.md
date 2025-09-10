# Upstream Sync PR

Reminder: All normative artifacts (PRDs, specifications, implementation plans, issues, task plans) must be written in English.

## Summary
- Strategy: merge/rebase
- Target ref: upstream/<branch-or-tag>
- Reports: `reports/upstream/<date>/`

## Checklist
- [ ] Language policy: All normative artifacts in this PR are written in English
- [ ] Template Drift: templates/ match upstream snapshots (verbatim except allowed manual markers)
- [ ] Dry-run executed and reviewed
- [ ] Reports generated (`summary.md`, `diff.md`, `diff.json`, `compatibility.md`, `fetch-summary.txt`)
- [ ] CI passed (`scripts/ci/run-local-ci.sh`)
- [ ] Conflicts resolved per playbook
- [ ] Documentation updated as needed

## Links
- Spec: specs/003-upstream-sync-sdd/spec.md
- Plan: specs/003-upstream-sync-sdd/plan.md
- Tasks: specs/003-upstream-sync-sdd/tasks.md
- Playbook: docs/conflict-resolution-playbook.md

## Notes
- Risks and mitigations:
- Adaptations required:
- Follow-up tasks:

