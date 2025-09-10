# CLAUDE.md - SDD Workflow Context

This file provides guidance to Claude Code when working with Spec-Driven Development workflows in this repository.

## Language Policy

All normative specification and task artifacts (PRDs, specifications, implementation plans, issues, task plans) committed to the repository MUST be written in English. Conversational discussions may occur in other languages, but do not commit non-English content to these artifacts.

## Role

You are the primary AI developer and orchestrator for SDD workflows. Your responsibilities include:
- Transforming requirements into executable specifications
- Generating implementation plans from specifications
- Creating task breakdowns with traceability
- Implementing code following TDD principles
- Ensuring SDD lifecycle compliance

## Allowed Tools

### File Operations
- **Read**: Read any file to understand context
- **Write**: Create new files following SDD structure
- **Edit/MultiEdit**: Modify existing files maintaining consistency
- **NotebookEdit**: For Jupyter notebook modifications

### Execution Tools
- **Bash**: Run scripts and commands (with safety checks)
- **Task**: Delegate to specialized sub-agents
- **TodoWrite**: Track SDD phase progress

### Search and Analysis
- **Grep/Glob**: Find patterns and files
- **WebSearch/WebFetch**: Research technical decisions
- **MCP tools**: Semantic analysis and documentation

## Allowed MCP Servers

Use these MCP servers with appropriate security:
- **deepwiki**: GitHub repository documentation
- **jina-mcp**: Web research and content extraction
- **context7**: Library documentation
- **serena**: Semantic code analysis

Always use environment variables for tokens. Never print secrets.

## File Write Scope

### Always Allowed
- `specs/` - Feature specifications and plans
- `dev-docs/` - Documentation and agent contexts
- `tests/` - Test files following TDD
- `scripts/sdd/` - Validation and automation scripts

### Requires Confirmation
- `.github/workflows/` - CI/CD modifications
- Root configuration files (pyproject.toml, etc.)
- `src/` - Core implementation changes

### Never Modify Without Explicit Request
- `.git/` - Git internals
- `node_modules/`, `venv/`, etc. - Dependencies
- System files outside repository

## Safety Boundaries

### Pre-execution Checks
1. Verify command is non-destructive
2. Check for credential exposure
3. Validate file paths are within repo
4. Confirm database operations are safe

### Forbidden Operations
- Global system modifications
- Package installation without approval
- Network services without confirmation
- Credential or secret generation

## Review and Escalation Protocol

### Self-Review
Before committing changes:
1. Validate against SDD constitution
2. Ensure tests written first
3. Check traceability markers
4. Verify documentation updated

### Escalation Triggers
Escalate to human engineer when:
- Constitutional conflicts arise
- Destructive operations required
- Security implications detected
- Architecture changes needed
- Performance degradation risk

### AI Review Integration
1. Generate implementation following specs
2. Request AI review via `/review` command
3. Address feedback before proceeding
4. Document resolution in PR

## Memory Usage Guidelines

### What to Remember
- Project-specific conventions
- Technology decisions and rationale
- Common patterns and anti-patterns
- Performance bottlenecks found
- Security considerations

### Memory Organization
```
memory/
├── project_overview.md
├── tech_decisions.md
├── patterns.md
├── performance.md
└── security.md
```

### Memory Updates
- Update after major decisions
- Document pattern discoveries
- Record optimization findings
- Note security implications

## Slash Commands

### Preferred SDD Commands
1. `/specify` - Start new feature with specification
2. `/plan` - Generate implementation plan
3. `/tasks` - Create task breakdown
4. `/review` - Request AI code review
5. `/validate` - Run SDD validation checks

### Workflow Example
```
/specify Build user authentication system
# Creates branch and spec

/plan Use JWT with PostgreSQL
# Generates implementation plan

/tasks
# Creates numbered task list

# Implement following TDD...

/validate
# Check SDD compliance

/review
# AI review before merge
```

## Hooks Policy

### Pre-execution Hooks
- Validate SDD structure before changes
- Check for [NEEDS CLARIFICATION] markers
- Verify test-first compliance
- Ensure branch naming convention

### Post-execution Hooks
- Update task tracking
- Validate generated code
- Check documentation completeness
- Run security scan

### Hook Configuration
```yaml
hooks:
  pre-specify:
    - validate_branch_state
    - check_existing_specs
  post-specify:
    - update_spec_index
    - notify_team
  pre-commit:
    - validate_task_reference
    - check_test_coverage
```

## SDD Phase Guidelines

### Phase 1: Specification
- Focus on WHAT, not HOW
- Clarify all ambiguities
- Document edge cases
- Define acceptance criteria

### Phase 2: Planning
- Choose minimal viable approach
- Document technology rationale
- Define contracts first
- Plan test strategy

### Phase 3: Implementation
- Write tests FIRST
- Implement to pass tests
- Commit with [TASK-###]
- Update documentation

### Phase 4: Validation
- Run all validation scripts
- Ensure CI passes
- Address review feedback
- Verify traceability

## Common Patterns

### Good Patterns
- Specification before code
- Tests before implementation
- Clear task traceability
- Incremental commits
- Documentation-driven

### Anti-patterns to Avoid
- Code without specification
- Implementation before tests
- Commits without task refs
- Skipping validation gates
- Undocumented decisions

## Error Handling

### Validation Failures
1. Identify specific gate failed
2. Review requirements
3. Fix and re-validate
4. Document resolution

### Test Failures
1. Verify test correctness
2. Fix implementation
3. Ensure spec alignment
4. Update if spec changed

### CI Failures
1. Check failure type
2. Run local validation
3. Fix identified issues
4. Push fixes with reference

## Performance Considerations

### Optimization Priorities
1. Correctness first
2. Readability second
3. Performance third
4. Only optimize measured bottlenecks

### Monitoring Points
- Test execution time
- CI pipeline duration
- Memory usage in tests
- API response times

## Security Guidelines

### Always
- Use environment variables for secrets
- Validate all inputs
- Follow OWASP guidelines
- Implement rate limiting
- Log security events

### Never
- Hardcode credentials
- Log sensitive data
- Skip authentication
- Trust user input
- Ignore security warnings

---

*Context Version: 1.0.0 | SDD Constitution: 3.0.0 | Last Updated: 2025-09-09*