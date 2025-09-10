# AGENTS.md

This file provides guidance to AI agents (Claude, Gemini, Copilot, Warp) when working with the spec-kit-ai-sdd repository. It complements the existing CLAUDE.md and WARP.md files with cross-agent compatibility information.

## Language Policy

**CRITICAL**: All normative specification and task artifacts (PRDs, specifications, implementation plans, issues, task plans) committed to the repository MUST be written in English. Conversations with developers may use other languages, but do not commit non-English content for these artifacts.

## Repository Overview

This is a fork of github/spec-kit enhanced with:
- Spec-Driven Development (SDD) workflows
- AI agent integration configurations
- Upstream synchronization processes
- Local CI/CD validation
- SDD structure validation

## Available Commands

### Specification Commands
- `/specify <description>` - Create a new feature specification
- `/plan <tech stack>` - Generate implementation plan from spec
- `/tasks` - Break down plan into actionable tasks

### Upstream Sync Commands
```bash
# Full sync workflow
scripts/upstream/sync.sh [--dry-run] [--strategy=merge|rebase] [--ref=<ref>]

# Individual components
scripts/upstream/fetch.sh           # Fetch upstream changes
scripts/upstream/diff-report.sh     # Generate diff reports
scripts/upstream/compat-analyze.sh  # Assess compatibility
scripts/upstream/merge.sh           # Execute merge/rebase
scripts/upstream/sync-dry-run.sh    # Preview without changes
```

### CI/CD Commands
```bash
# Run full CI suite
scripts/ci/run-local-ci.sh

# Individual checks
scripts/ci/run-sdd-structure-lint.sh    # Validate SDD structure
scripts/ci/check-language-policy.sh     # Enforce English-only
scripts/ci/check-templates-drift.sh     # Detect template changes
```

### Feature Development Scripts
```bash
# Create new feature with auto-numbering
./scripts/create-new-feature.sh "feature description"

# Set up implementation plan
./scripts/setup-plan.sh

# Check task prerequisites
./scripts/check-task-prerequisites.sh

# Update agent context files
./scripts/update-agent-context.sh
```

## Working with Features

### Feature Structure
Each feature follows the pattern `NNN-feature-name`:
```
specs/
└── NNN-feature-name/
    ├── spec.md         # What to build
    ├── plan.md         # How to build it
    ├── tasks.md        # Breakdown of work
    ├── CLAUDE.md       # Claude-specific context
    └── AGENTS.md       # Cross-agent context
```

### Git Workflow
1. Create feature branch: `NNN-feature-name`
2. Develop following SDD methodology
3. Commit with format: `type(NNN): description [TASK-ID]`
4. Create PR referencing specs

## SDD Principles

1. **Specification First**: No code without spec
2. **Testable Requirements**: Every requirement must be measurable
3. **English Only**: All artifacts in English
4. **No Speculation**: Include only features with clear user stories
5. **Progressive Refinement**: Mark uncertainties with `[NEEDS CLARIFICATION]`

## Upstream Synchronization

### Process Overview
1. Fetch upstream changes
2. Analyze differences and compatibility
3. Review reports (dry-run)
4. Execute merge/rebase
5. Resolve conflicts per playbook
6. Run CI validation
7. Create PR with reports

### Conflict Resolution Categories
- **Templates**: Preserve SDD structure
- **Scripts**: Maintain fork enhancements
- **CLI**: Ensure backward compatibility
- **Documentation**: Enforce language policy

## CI/CD Integration

### Pre-merge Checks
- SDD structure validation
- Language policy enforcement
- Template drift detection
- Test suite execution

### Report Generation
All reports saved to `reports/upstream/{date}/`:
- `diff.md` - Human-readable changes
- `diff.json` - Machine-readable data
- `compatibility.md` - Risk assessment
- `sync.log` - Execution log

## Agent-Specific Notes

### Claude (claude.ai/code)
- Primary agent for this repository
- See CLAUDE.md for detailed guidance
- Supports all /specify, /plan, /tasks commands

### Warp (warp.dev)
- Terminal-based AI agent
- See WARP.md for terminal-specific guidance
- Excellent for script execution and debugging

### Gemini CLI
- Command-line interface
- Reference GEMINI.md if present
- Run commands with `gemini /specify`, etc.

### GitHub Copilot
- VS Code integration
- Manual branch creation may be needed
- Use command palette for /specify, /plan, /tasks

## Testing and Validation

### Before Committing
1. Run SDD structure lint
2. Check language policy
3. Validate templates
4. Execute test suite
5. Verify CI passes

### Command Examples
```bash
# Validate SDD structure
./scripts/ci/run-sdd-structure-lint.sh

# Check language policy
./scripts/ci/check-language-policy.sh

# Run full CI suite
./scripts/ci/run-local-ci.sh
```

## Common Scenarios

### Starting a New Feature
```bash
./scripts/create-new-feature.sh "user authentication"
# Creates branch 004-user-authentication
# Scaffolds specs/004-user-authentication/
```

### Syncing with Upstream
```bash
# Dry run first
./scripts/upstream/sync.sh --dry-run

# Review reports
cat reports/upstream/$(date +%Y%m%d)/compatibility.md

# Execute sync
./scripts/upstream/sync.sh
```

### Resolving Merge Conflicts
1. Categorize conflict type
2. Follow resolution playbook
3. Test resolution
4. Document adaptations
5. Update relevant specs

## Best Practices

1. **Always dry-run first** when syncing upstream
2. **Document all decisions** in specs
3. **Link commits to tasks** using [TASK-ID]
4. **Review reports** before merging
5. **Keep specs updated** as implementation evolves

## Troubleshooting

### Common Issues
- **Dirty working tree**: Commit or stash changes before sync
- **Missing upstream remote**: `git remote add upstream https://github.com/github/spec-kit.git`
- **Language policy violations**: Review and translate to English
- **Template drift**: Run compatibility analyzer

### Getting Help
- Review existing specs in `specs/` for examples
- Check `docs/` for detailed documentation
- Run scripts with `--help` for usage information
- Consult playbooks for conflict resolution

## Version Information

- Fork base: github/spec-kit
- Current upstream: v0.0.20
- SDD version: 1.0.0
- Last updated: 2025-09-10

---

*This document is maintained in English per repository language policy. It serves as the primary reference for all AI agents working with this codebase.*
