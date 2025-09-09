# Code Style and Conventions for Spec-Kit

## Python Code Style
- **Python Version**: 3.11+ required
- **Type Hints**: Not extensively used in current codebase
- **Docstrings**: Module-level docstrings present, function docstrings minimal
- **Imports**: Standard library first, then third-party packages
- **CLI Framework**: Typer for command-line interfaces with Rich for terminal UI

## Shell Script Conventions
- **Shebang**: Use `#!/usr/bin/env bash` (not `/bin/bash`)
- **Error Handling**: Use `set -e` for strict error handling
- **Functions**: Defined in `common.sh` and sourced by other scripts
- **Variable Naming**: UPPER_CASE for constants, lower_case for variables
- **Script Organization**: Common functions separated, feature-specific logic isolated

## File Naming Conventions
- **Features**: Numbered format `NNN-feature-name/` (e.g., `001-user-auth/`)
- **Branches**: Match feature directory names
- **Templates**: Use `-template.md` suffix
- **Scripts**: Use kebab-case with `.sh` extension

## Documentation Style
- **Markdown**: GitHub Flavored Markdown
- **Templates**: Include `[PLACEHOLDER]` markers for required information
- **Checklists**: Use `- [ ]` format for validation steps
- **Code Blocks**: Use triple backticks with language hints

## Project Structure Patterns
- **Specifications First**: Always create spec before implementation
- **Template-Driven**: Use provided templates, don't create from scratch
- **Feature Isolation**: Each feature in its own numbered directory
- **Incremental Refinement**: Spec → Plan → Tasks → Implementation

## Git Conventions
- **Commit Messages**: Format: `type: description [TASK-ID]`
- **Branch Naming**: `NNN-feature-name` matching spec directory
- **PR References**: Link to spec, plan, and completed tasks

## AI Agent Integration
- **Command Format**: Use `/command` syntax (e.g., `/specify`, `/plan`, `/tasks`)
- **Context Files**: CLAUDE.md, GEMINI.md, or appropriate agent file
- **Auto-generation**: Scripts handle branch creation and file scaffolding