# CLAUDE.md - CLI Development Context

This file provides guidance to Claude Code when working with the Specify CLI in this repository.

## Language Policy

CLI-generated normative artifacts must be English-only. When generating templates or specifications, ensure all content is in English. Fail with a clear error if non-English content is detected in normative artifacts.

## Role

You are responsible for developing and maintaining the Specify CLI tool that bootstraps SDD projects. Your focus areas include:
- CLI command implementation
- Template management
- Project initialization logic
- Integration with AI assistants
- User experience optimization

## Allowed Tools

### File Operations
- **Read/Write/Edit**: Full access to src/, tests/, templates/
- **Bash**: Execute CLI commands and scripts
- **TodoWrite**: Track development progress

### Search Tools
- **Grep/Glob**: Find patterns in codebase
- **WebSearch/WebFetch**: Research CLI patterns

## Safety Boundaries

- Never modify system files outside repository
- Validate all user input before processing
- Check file permissions before operations
- No execution of untrusted code
- Clear error messages without exposing internals

## CLI Architecture

### Core Module
- `src/specify_cli/__init__.py` - Main CLI implementation
- Uses Typer for command parsing
- Rich for terminal UI
- Httpx for network operations

### Commands
- `init` - Initialize new SDD project
- `check` - Validate environment setup
- Future: `validate`, `update`, `migrate`

## Development Guidelines

### Code Style
- Python 3.11+ with type hints where beneficial
- Follow PEP 8 with 100-char line limit
- Use docstrings for public functions
- Keep functions focused and testable

### Error Handling
- Provide clear, actionable error messages
- Use Rich panels for important messages
- Exit codes: 0 (success), 1 (error), 2 (warning)
- Log verbose output with --verbose flag

### User Experience
- Interactive prompts for missing options
- Progress indicators for long operations
- Colored output for clarity
- Keyboard navigation where appropriate

## File Operations

### Template Management
```python
# Copy templates preserving structure
templates/
├── spec-template.md
├── plan-template.md
├── tasks-template.md
└── commands/
    ├── specify.md
    ├── plan.md
    └── tasks.md
```

### Project Structure Creation
```
new-project/
├── .claude/
│   └── commands/
├── memory/
├── scripts/
├── specs/
└── templates/
```

## Testing Requirements

### Unit Tests
- Test each CLI command
- Mock file operations
- Validate argument parsing
- Check error conditions

### Integration Tests
- Full project initialization
- Template copying verification
- Git operations
- AI tool detection

## Common Tasks

### Adding New Command
1. Define command function with Typer decorator
2. Add argument validation
3. Implement core logic
4. Add progress tracking
5. Write tests
6. Update documentation

### Modifying Templates
1. Update template files
2. Test template copying
3. Verify variable substitution
4. Update related commands
5. Document changes

## Dependencies

### Core Dependencies
```toml
[project]
dependencies = [
    "typer",
    "rich", 
    "httpx",
    "platformdirs",
    "readchar",
]
```

### Development Dependencies
```toml
[project.optional-dependencies]
dev = [
    "pytest",
    "pytest-cov",
    "black",
    "ruff",
]
```

## Security Considerations

- Never hardcode API keys
- Validate all file paths
- Sanitize user input
- Check file permissions
- Avoid shell injection

## Performance Guidelines

- Lazy load heavy imports
- Stream large file operations
- Cache network responses
- Minimize startup time
- Profile with large projects

## Error Messages

### Good Examples
```python
# Clear and actionable
"Error: Python 3.11+ required. Current version: 3.9.0"
"Error: Directory 'my-project' already exists. Use --force to overwrite."

# With suggestions
"Error: 'uv' not found. Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
```

### Bad Examples
```python
# Vague
"Error: Operation failed"
"Something went wrong"

# Too technical
"Error: OSError errno 13"
```

## Version Management

### Semantic Versioning
- MAJOR: Breaking CLI changes
- MINOR: New commands/features
- PATCH: Bug fixes

### Release Process
1. Update version in pyproject.toml
2. Update CHANGELOG.md
3. Tag release
4. GitHub Actions builds and publishes

---

*Context Version: 1.0.0 | CLI Version: 0.0.2 | Last Updated: 2025-09-09*