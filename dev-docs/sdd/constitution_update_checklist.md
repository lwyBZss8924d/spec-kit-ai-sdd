# Constitution Update Checklist

When amending the SDD Constitution (`/dev-docs/sdd/constitution.md`), ensure all dependent documents and systems are updated to maintain consistency.

## Pre-Amendment Requirements

### Impact Analysis
- [ ] Document the rationale for the change
- [ ] Identify all affected workflows and processes
- [ ] List impacted templates and documentation
- [ ] Estimate migration effort for existing projects
- [ ] Review with stakeholders

## Templates to Update

### Core SDD Documents
- [ ] `/dev-docs/sdd/lifecycle.md` - Update if lifecycle changes
- [ ] `/templates/spec-template.md` - Update if specification requirements change
- [ ] `/templates/plan-template.md` - Update if planning process changes
- [ ] `/templates/tasks-template.md` - Update if task structure changes

### Agent Context Files
- [ ] `/dev-docs/*/CLAUDE.md` - Update agent instructions
- [ ] `/dev-docs/*/AGENTS.md` - Update multi-agent coordination
- [ ] `/templates/commands/*.md` - Update command definitions

### CI/CD Workflows
- [ ] `.github/workflows/sdd-ci.yml` - Update validation checks
- [ ] `.github/workflows/ai-review.yml` - Update review criteria
- [ ] Validation scripts in `/scripts/sdd/`

## Principle-Specific Updates

### Specification-First Development
- [ ] Ensure templates enforce specification creation
- [ ] Update generation workflows
- [ ] Verify PRD → Code pipeline

### Test-Driven Implementation
- [ ] Update test-first requirements
- [ ] Modify TDD cycle documentation
- [ ] Adjust CI test gates

### Multi-Agent Collaboration
- [ ] Update agent boundaries
- [ ] Modify worktree policies
- [ ] Adjust MCP server permissions

### Continuous Validation
- [ ] Update validation criteria
- [ ] Modify CI/CD checks
- [ ] Adjust traceability requirements

### Observability & Transparency
- [ ] Update logging requirements
- [ ] Modify commit message formats
- [ ] Adjust metrics collection

## Gate-Specific Updates

### When modifying development gates:
- [ ] Update gate definitions in lifecycle
- [ ] Modify CI enforcement rules
- [ ] Update planning templates
- [ ] Document exemption process

## Post-Amendment Tasks

### Documentation
- [ ] Update constitution version number
- [ ] Add entry to CHANGELOG.md
- [ ] Document migration steps
- [ ] Create amendment announcement

### Validation
- [ ] Run through complete SDD cycle with new rules
- [ ] Test all CI/CD workflows
- [ ] Verify agent behaviors
- [ ] Check template consistency

### Communication
- [ ] Notify team of changes
- [ ] Update onboarding documentation
- [ ] Schedule training if needed
- [ ] Monitor adoption metrics

## Common Pitfalls

Watch for these often-missed updates:
- Command documentation in templates/commands/
- Example code snippets in templates
- Hardcoded validation rules in scripts
- Agent memory files
- README and quickstart guides
- Integration test scenarios

## Version Tracking

### Before committing:
- [ ] Constitution version incremented
- [ ] Amendment date updated
- [ ] Changelog entry created
- [ ] Git tag prepared

### Version Format
- MAJOR: Fundamental principle changes
- MINOR: New gates or requirements
- PATCH: Clarifications and fixes

## Rollback Plan

### If amendment causes issues:
1. Revert to previous constitution version
2. Restore dependent documents
3. Rollback CI/CD changes
4. Communicate rollback to team
5. Document lessons learned

## Audit Trail

### Record keeping:
- [ ] Original constitution archived
- [ ] Amendment discussion documented
- [ ] Approval chain recorded
- [ ] Impact assessment saved

---

*Last reviewed: 2025-09-09 | Constitution Version: 3.0.0*