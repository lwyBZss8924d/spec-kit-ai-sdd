# Spec Kit SDD Constitution

## Core Principles

### I. Specification-First Development
Every feature begins with a comprehensive specification that serves as the source of truth. Specifications are executable artifacts that generate implementation, not mere documentation. The PRD (Product Requirements Document) drives code generation, not the reverse.

### II. Test-Driven Implementation
Test-First Development is **NON-NEGOTIABLE**. The cycle follows:
1. Write tests based on specifications
2. Tests reviewed and approved
3. Tests fail (red phase)
4. Implementation generated to pass tests (green phase)
5. Refactor for clarity and performance

### III. Multi-Agent Collaboration
Development leverages multiple AI agents working in parallel through git worktrees. Each agent operates with defined boundaries, tools, and responsibilities documented in AGENTS.md files. Human engineers maintain product and engineering authority while AI agents execute implementation.

### IV. Continuous Validation
Every change validates against:
- SDD lifecycle compliance
- Task-to-commit traceability
- Specification completeness (no [NEEDS CLARIFICATION] in production)
- Test coverage requirements
- Documentation standards

### V. Observability & Transparency
All development activities must be observable:
- Structured logging at multiple tiers
- Clear commit messages with [TASK-###] references
- Agent actions logged and traceable
- Performance metrics captured

## Development Gates

### Simplicity Gate
Start with the minimal viable approach. Complexity must be justified with documented rationale linking back to requirements. YAGNI (You Aren't Gonna Need It) principles apply.

### Anti-Abstraction Gate
Use frameworks and libraries directly. Avoid creating wrapper abstractions unless they provide demonstrable value. Prefer composition over inheritance.

### Integration-First Gate
Define contracts and interfaces before implementation. API specifications, data models, and integration points must be documented in the planning phase.

### Security Gate
Never commit secrets or credentials. Use environment variables and secret management. All agent interactions must respect least-privilege principles.

## SDD Lifecycle Enforcement

### 1. Specification Phase
- Raw requirements → PRD using templates
- User stories with acceptance criteria
- Non-functional requirements defined
- Edge cases documented

### 2. Planning Phase
- PRD → Implementation Plan
- Technology choices with rationale
- Data models and contracts defined
- Task breakdown with dependencies

### 3. Implementation Phase
- Tasks → Code following TDD
- Commits reference tasks [TASK-###]
- Continuous integration validates changes
- Agent code reviewed before merge

### 4. Validation Phase
- Automated tests pass
- SDD structure validated
- Documentation complete
- Performance benchmarks met

## Agent Governance

### Agent Boundaries
- Agents operate within defined file scopes
- MCP servers used with explicit permissions
- No global system modifications without approval
- Destructive operations require confirmation

### Review Protocol
1. AI agents generate implementation
2. AI reviewers validate against specs
3. Human engineers approve critical changes
4. Automated CI enforces standards

## Amendment Process

Constitutional changes require:
1. Documented rationale in ISSUE
2. Impact analysis on existing workflows
3. Update all dependent templates and documentation
4. Migration plan for existing projects
5. Version increment with changelog entry

## Compliance Verification

All pull requests must:
- Pass SDD validation checks
- Include test coverage
- Reference originating tasks/issues
- Update relevant documentation
- Pass AI code review

Non-compliance results in:
- PR blocked from merge
- Actionable feedback provided
- Requirement to address gaps

## Governance Authority

This constitution supersedes all other practices. In case of conflict:
1. Constitution principles take precedence
2. Documented exceptions require approval
3. Patterns that violate principles must be refactored

**Version**: 3.0.0 | **Ratified**: 2025-09-09 | **Last Amended**: 2025-09-09