# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Complete SDD (Spec-Driven Development) bootstrap system
- SDD governance documentation in `dev-docs/sdd/`
  - Constitution defining core principles and gates
  - Lifecycle documentation with 8-phase process
  - Amendment checklist for constitution updates
- Multi-agent support documentation
  - CLAUDE.md context files for Claude Code
  - AGENTS.md following agents.md specification
  - MCP server integration guide
- Git worktree documentation for parallel development
- Python testing infrastructure
  - Test suite for CLI functionality
  - SDD validation tests
  - Pytest configuration in pyproject.toml
- CI/CD workflows
  - `sdd-ci.yml` for automated validation
  - `ai-review.yml` for AI code review
- SDD validation scripts
  - `validate_structure.py` for structure checking
  - `run_semantic_checks.sh` for consistency validation
  - `lint_docs.sh` for documentation linting
- Development configuration files
  - `.editorconfig` for consistent formatting
  - `.markdownlint.json` for documentation style
  - `.gitattributes` for file handling

### Changed

- Updated pyproject.toml with dev dependencies and tool configurations
- Enhanced CLAUDE.md with SDD-specific guidance

### Security

- Added security validation in CI workflows
- Implemented secret detection in validation scripts
- Documented token management best practices

## [0.0.2] - 2024-09-08

### Added

- Initial Specify CLI implementation
- Project initialization command
- Environment checking functionality
- Template system for SDD workflows

### Changed

- Improved CLI user experience with Rich UI
- Enhanced error messages and progress tracking

## [0.0.1] - 2024-09-01

### Added

- Initial project structure
- Basic CLI scaffolding
- Core templates for specifications

[Unreleased]: https://github.com/github/spec-kit/compare/v0.0.2...HEAD
[0.0.2]: https://github.com/github/spec-kit/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/github/spec-kit/releases/tag/v0.0.1