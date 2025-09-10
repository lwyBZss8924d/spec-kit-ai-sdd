# CLAUDE.md

This file provides AI Engineer guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language Policy

All normative specification and task artifacts (PRDs, specifications, implementation plans, issues, task plans) committed to the repository MUST be written in English. Conversational discussions in PRs/issues may occur in other languages, but do not commit non-English content to these artifacts.

## Project Overview

Spec-Kit is a toolkit for Spec-Driven Development (SDD), a methodology that transforms specifications into executable artifacts that generate working implementations. The project provides templates, scripts, and a CLI tool to facilitate the specification → implementation workflow.

## Essential Commands

### Testing and Validation
```bash
# Run all tests
python -m pytest tests/ -v

# Run specific test files
python -m pytest tests/test_sdd_validation.py -v
python -m pytest tests/test_specify_cli.py -v

# Validate SDD structure
python scripts/sdd/validate_structure.py

# Run semantic checks on SDD documents
./scripts/sdd/run_semantic_checks.sh

# Lint documentation (requires markdownlint)
./scripts/sdd/lint_docs.sh

# Test the CLI functionality
python -m specify_cli check

# Verify Python syntax
python -m py_compile src/specify_cli/__init__.py
```

### Code Quality
```bash
# Format Python code
black src/ tests/ scripts/sdd/*.py --line-length 100

# Lint Python code
ruff check src/ tests/ scripts/sdd/*.py

# Install development dependencies
pip install -e ".[dev]"
```

### Running the Project
```bash
# Install and run the Specify CLI
uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>

# Or run locally during development
python -m specify_cli init <PROJECT_NAME>
python -m specify_cli check
```

### Development Workflow Scripts
```bash
# Create a new numbered feature branch and spec
./scripts/create-new-feature.sh "feature description"

# Set up implementation plan structure
./scripts/setup-plan.sh

# Check task prerequisites
./scripts/check-task-prerequisites.sh

# Update AI agent context files
./scripts/update-agent-context.sh
```

## Architecture

### Core Components

1. **Specify CLI** (`src/specify_cli/__init__.py`)
   - Main entry point for project initialization
   - Handles template copying and AI agent configuration
   - Interactive setup with agent selection (Claude/Gemini/Copilot)

2. **Templates System** (`templates/`)
   - `spec-template.md`: Feature specification structure
   - `plan-template.md`: Implementation planning template
   - `tasks-template.md`: Task breakdown template
   - `agent-file-template.md`: AI agent context file template
   - `commands/`: AI command definitions for /specify, /plan, /tasks

3. **Automation Scripts** (`scripts/`)
   - `common.sh`: Shared bash functions and utilities
   - `create-new-feature.sh`: Auto-numbers features, creates branches
   - `setup-plan.sh`: Scaffolds implementation plan structure
   - Scripts use `#!/usr/bin/env bash` for cross-platform compatibility

### Workflow Architecture

The SDD workflow follows this pipeline:
```
Specification (/specify) → Plan (/plan) → Tasks (/tasks) → Implementation → Validation
```

Each phase produces artifacts in `specs/NNN-feature-name/`:
- `spec.md`: User stories and requirements
- `plan.md`: Technical implementation details
- `tasks.md`: Numbered, trackable work items
- `research.md`, `data-model.md`, `contracts/`: Supporting documents

### Key Design Principles

1. **Specification-First**: No code without spec
2. **Template-Driven**: Structured documents guide the process
3. **Feature Isolation**: Each feature in numbered directory
4. **AI-Assisted**: Commands integrate with AI coding assistants
5. **Progressive Refinement**: Iterative clarification at each phase

## Code Conventions

- **Python**: 3.11+ required, Typer for CLI, Rich for terminal UI
- **Bash Scripts**: Use `set -e` for error handling, source `common.sh` for shared functions
- **Feature Naming**: `NNN-feature-name` format (e.g., `001-user-auth`)
- **Git Branches**: Match feature directory names
- **Commit Format**: `type: description [TASK-ID]` for traceability

## Directory Structure

```tree
.
├── src/specify_cli/        # Main CLI tool implementation
├── templates/              # SDD document templates
│   ├── commands/          # AI assistant command definitions
│   └── *.md              # Specification, plan, and task templates
├── scripts/               # Automation and workflow scripts
│   └── sdd/              # SDD validation and linting tools
├── specs/                 # Feature specifications (NNN-feature-name/)
├── dev-docs/              # Development documentation
│   ├── sdd/              # SDD methodology docs (constitution.md, lifecycle.md)
│   ├── agents/           # AI agent guidelines
│   ├── git/              # Git workflow documentation
│   └── cli/              # CLI development docs
├── tests/                 # Test suite
└── .github/workflows/     # CI/CD pipelines
```

## SDD Validation Requirements

- All specifications must not contain `[NEEDS CLARIFICATION]` markers
- Commit messages must follow format: `type(scope): description [TASK-XXX]`
- Feature directories must follow `NNN-feature-name` convention
- Each spec must have corresponding plan.md and tasks.md files
- Task IDs must be sequential and properly tracked

## Important Notes

- The project is primarily for macOS/Linux (WSL2 on Windows)
- Requires `uv` package manager from Astral
- Python 3.11+ required
- Scripts assume bash shell availability
- The CLI checks for AI tool installation but can be bypassed with `--ignore-agent-tools`
- Tests focus on structure validation rather than unit tests
- GitHub Actions CI validates SDD compliance on every PR
