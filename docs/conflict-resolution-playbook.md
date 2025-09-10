# Conflict Resolution Playbook

This playbook provides deterministic, category-based guidance for resolving conflicts when syncing upstream changes into this fork.

## Principles
- Preserve fork-specific SDD enhancements
- Prefer minimal diffs and clarity
- Document decisions and rationale
- Validate with CI before finalizing

## Categories & Procedures

### 1) Template Conflicts (templates/)
1. Identify structural changes (sections, placeholders, checklists)
2. Preserve fork-specific SDD structure and language policy notes
3. Merge upstream improvements (clarity, new sections) into fork templates
4. Update any references in docs and scripts if template names change
5. Validate by instantiating templates in a scratch feature dir

Acceptance:
- SDD validation passes
- New templates render without errors
- Language policy still enforced

### 2) Script Conflicts (scripts/)
1. Determine whether upstream change is functional vs. refactor
2. Preserve fork-specific workflows and flags
3. Incorporate upstream bug fixes and improvements
4. Update inline help and docs to reflect merged behavior
5. Re-run local CI and dry-run sync

Acceptance:
- run-local-ci.sh passes
- sync-dry-run.sh produces expected reports

### 3) CLI Conflicts (src/specify_cli/)
1. Review interface changes and breaking behaviors
2. Maintain backward compatibility; add shims if needed
3. Update documentation and agent files (AGENTS.md, CLAUDE.md)
4. Add tests for new/changed commands

Acceptance:
- CLI commands behave as documented
- Agent workflows unaffected

### 4) Documentation Conflicts (docs/, README.md)
1. Merge factual updates and corrections
2. Retain fork-specific sections and examples
3. Enforce English-only for normative artifacts
4. Verify links and references

Acceptance:
- Docs build cleanly (if applicable)
- No language policy violations

## Escalation
- If conflicts span multiple categories with ambiguity, split into smaller commits
- When unsure, open a short PR for focused review
- If breaking template changes are required, create a feature branch and adaptation plan

## Post-Resolution Checklist
- [ ] All conflicts resolved by category
- [ ] CI suite passes
- [ ] Reports updated and archived
- [ ] Documentation updated (specs/003 & 004 if applicable)
- [ ] PR description explains decisions
