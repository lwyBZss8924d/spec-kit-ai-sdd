# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Essential Commands

### Installing the Specify CLI

The `specify` CLI is the primary tool for initializing Spec-Driven Development projects. Install using `uv`:

```bash
# Install directly from the repository
uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>

# Or install globally for repeated use
uv tool install --from git+https://github.com/github/spec-kit.git specify-cli
```

### Core CLI Commands

```bash
# Initialize a new project with templates
specify init my-project                  # Create new project directory
specify init my-project --ai claude      # Specify AI assistant (claude/gemini/copilot)
specify init --here --ai claude          # Initialize in current directory

# Additional flags
--ignore-agent-tools                     # Skip AI tool checks
--no-git                                 # Skip git repository initialization
```

### Feature Development Scripts

The repository provides bash scripts for managing features within an initialized project:

```bash
# Create a new feature with auto-numbered spec directory
./scripts/create-new-feature.sh "user authentication system"
# Output: Creates branch 001-user-authentication and specs/001-user-authentication/spec.md

# Check prerequisites for a task
./scripts/check-task-prerequisites.sh

# Set up implementation plan from spec
./scripts/setup-plan.sh

# Update AI agent context files (CLAUDE.md, GEMINI.md, etc.)
./scripts/update-agent-context.sh
```

## Architecture & Spec-Driven Development (SDD)

### Core Philosophy

Spec-Driven Development **inverts the traditional power structure** - specifications don't serve code, code serves specifications. The methodology transforms specifications into executable artifacts that generate implementation.

### The SDD Lifecycle

```
Specification → Implementation Plan → Tasks → Code Generation → Validation
```

1. **Specification Phase**: Transform ideas into comprehensive Product Requirements Documents (PRDs) using templates
2. **Planning Phase**: Generate implementation plans mapping requirements to technical decisions
3. **Task Generation**: Break down plans into actionable, trackable development tasks
4. **Implementation**: Generate code from specifications, following Test-Driven Development
5. **Validation**: Continuous refinement through feedback loops

### Key Principles

- **Specifications as Lingua Franca**: Specifications are the primary artifact; code is their expression
- **Executable Specifications**: Must be precise and unambiguous enough to generate working systems
- **Continuous Refinement**: AI analyzes specifications for ambiguity and gaps as an ongoing process
- **Research-Driven Context**: Automated gathering of technical context and constraints
- **Bidirectional Feedback**: Production metrics inform specification evolution

## Project Structure

```
spec-kit/
├── src/specify_cli/          # Python CLI implementation
│   └── __init__.py          # Main CLI with init, check commands
├── templates/               # Core templates for SDD workflow
│   ├── spec-template.md    # Feature specification template
│   ├── plan-template.md    # Implementation plan template
│   ├── tasks-template.md   # Task breakdown template
│   ├── agent-file-template.md  # AI agent context template
│   └── commands/           # AI command definitions
│       ├── specify.md      # /specify command template
│       ├── plan.md        # /plan command template
│       └── tasks.md       # /tasks command template
├── scripts/                # Automation scripts for features
│   ├── common.sh          # Shared functions for scripts
│   ├── create-new-feature.sh  # Create numbered feature branches
│   ├── setup-plan.sh      # Initialize implementation plans
│   ├── check-task-prerequisites.sh  # Validate requirements
│   ├── get-feature-paths.sh  # Helper for path resolution
│   └── update-agent-context.sh  # Update AI context files
├── memory/                 # Project constitution and principles
│   ├── constitution.md    # Core principles template
│   └── constitution_update_checklist.md  # Amendment guide
├── specs/                  # Feature specifications (created by workflow)
│   └── NNN-feature-name/  # Auto-numbered feature directories
│       ├── spec.md        # Feature specification
│       ├── plan.md        # Implementation plan
│       ├── tasks.md       # Task breakdown
│       ├── research.md    # Technical research
│       ├── data-model.md  # Data structures
│       ├── quickstart.md  # Quick reference
│       └── contracts/     # API specifications
└── media/                  # Documentation assets
```

### Key Files and Their Purpose

| File/Directory | Purpose | WARP Interaction |
|----------------|---------|------------------|
| `templates/spec-template.md` | Feature specification template with user stories, requirements | Copy and fill for new features |
| `templates/plan-template.md` | Implementation plan with phases, gates, technical details | Generate from completed spec |
| `scripts/create-new-feature.sh` | Auto-number features, create branches, scaffold specs | Run to start new feature |
| `memory/constitution.md` | Project principles and constraints | Read and enforce in all work |
| `specs/NNN-*/` | Feature-specific artifacts | Create/edit during development |

## Development Workflow

### Complete Feature Development Cycle

#### 1. Initialize Project (One-time setup)
```bash
# Install and initialize with your AI assistant
uvx --from git+https://github.com/github/spec-kit.git specify init my-app --ai claude
cd my-app
```

#### 2. Create Feature Specification
Within your AI assistant (Claude Code, Gemini CLI, or Copilot):
```
/specify Build a task management system with projects, team members, 
task assignment, and Kanban boards
```

This automatically:
- Creates branch `001-task-management`
- Generates `specs/001-task-management/spec.md`
- Populates structured requirements

#### 3. Generate Implementation Plan
```
/plan Use React with TypeScript, PostgreSQL database, REST API with Express
```

Creates:
- `specs/001-task-management/plan.md` - Phased implementation plan
- `specs/001-task-management/research.md` - Technology research
- `specs/001-task-management/data-model.md` - Database schemas
- `specs/001-task-management/contracts/` - API specifications

#### 4. Generate Tasks
```
/tasks
```

Produces `specs/001-task-management/tasks.md` with:
- Numbered tasks linked to spec sections
- Acceptance criteria
- Implementation order

#### 5. Implement Following TDD
```
# Implement each task following the plan
# Link commits to task IDs for traceability
git commit -m "feat: implement user authentication [TASK-001]"
```

#### 6. Create Pull Request
```bash
git push -u origin 001-task-management
# Create PR referencing spec, plan, and completed tasks
```

### Template Customization Points

The templates include guided sections marked with:
- `[PLACEHOLDER]` - Required information to fill
- `[NEEDS CLARIFICATION]` - Ambiguities to resolve
- Checklists for completeness validation

## Architectural Constraints

### Constitutional Principles (from memory/constitution.md template)

The project constitution template defines these customizable principles:

1. **[PRINCIPLE_1_NAME]** - Define your primary development principle
2. **[PRINCIPLE_2_NAME]** - Secondary principle (e.g., CLI interfaces)
3. **[PRINCIPLE_3_NAME]** - Testing approach (e.g., TDD mandatory)
4. **[PRINCIPLE_4_NAME]** - Integration requirements
5. **[PRINCIPLE_5_NAME]** - Additional constraints

### Specification Template Constraints

From `templates/spec-template.md`:
- **Focus on WHAT, not HOW**: Specifications describe user needs, not implementation
- **Mark uncertainties explicitly**: Use `[NEEDS CLARIFICATION: question]` markers
- **Testable requirements only**: Every requirement must have measurable acceptance criteria
- **No speculative features**: Include only features with clear user stories

### Implementation Plan Gates

From `templates/plan-template.md`:
- **Pre-Implementation Gates**: Must pass before coding begins
- **Simplicity Gate**: Justify any complexity beyond basics
- **Anti-Abstraction Gate**: Use frameworks directly, avoid unnecessary wrappers
- **Integration-First Gate**: Define contracts before implementation

## Command Cheatsheet

```bash
# Project initialization
uvx --from git+https://github.com/github/spec-kit.git specify init PROJECT
specify init --here --ai claude           # Init in current directory

# Feature development (in AI assistant)
/specify <description>                    # Create specification
/plan <tech stack>                       # Generate implementation plan  
/tasks                                   # Break down into tasks

# Bash scripts (in initialized project)
./scripts/create-new-feature.sh "description"  # Manual feature creation
./scripts/setup-plan.sh                       # Set up plan structure
./scripts/check-task-prerequisites.sh         # Validate requirements

# Git workflow
git checkout -b NNN-feature-name         # Feature branch
git commit -m "type: message [TASK-ID]"  # Link to tasks
git push -u origin NNN-feature-name      # Push feature branch
```

## Working with Different AI Assistants

### Claude Code (VS Code)
- Commands available via `/` in any file
- Automatic branch and spec management
- Integrated terminal for script execution

### Gemini CLI
- Run commands with `gemini /specify`, `gemini /plan`, etc.
- Reference GEMINI.md for context
- Use scripts for branch management

### GitHub Copilot (VS Code)
- Use `/specify`, `/plan`, `/tasks` commands in editor
- Manual branch creation may be needed
- Refer to templates for structure

## Validation and Quality Checks

### Specification Completeness
Each spec includes a review checklist:
- [ ] All user stories have acceptance criteria
- [ ] No `[NEEDS CLARIFICATION]` markers remain
- [ ] Requirements are testable and measurable
- [ ] Edge cases are documented

### Implementation Plan Validation
Plans must pass phase gates:
- [ ] Simplicity gate (≤3 projects initially)
- [ ] Anti-abstraction gate (direct framework usage)
- [ ] Test-first gate (tests before implementation)
- [ ] Integration-first gate (contracts defined)

## Troubleshooting

### Common Issues

1. **Specify CLI not found**: Ensure `uv` is installed and in PATH
2. **Feature numbering conflicts**: Check `specs/` directory for existing features
3. **Template not found**: Verify templates exist in project after init
4. **AI commands not working**: Check correct AI assistant is configured

### Getting Help

- Review `README.md` for detailed setup instructions
- Check `spec-driven.md` for methodology deep-dive
- Examine existing specs in `specs/` for examples
- Run `specify check` to validate environment

## Maintenance

### Updating This Document

When the CLI or methodology changes:
1. Review changes in `src/specify_cli/__init__.py`
2. Update command examples and workflows
3. Verify scripts still function correctly
4. Test initialization process with each AI assistant

### Version Tracking

- CLI version: Check `pyproject.toml` version field
- Template updates: Review git history of `templates/`
- Script changes: Monitor `scripts/` directory

---

*Last updated for spec-kit repository at commit point of this document creation.*
