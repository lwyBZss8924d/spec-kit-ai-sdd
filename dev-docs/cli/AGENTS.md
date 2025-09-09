# AGENTS.md - CLI Development Agent Support

Multi-agent configuration for Specify CLI development following the agents.md specification.

## Supported Agents

### Claude Code
**Role**: Primary CLI developer
**Capabilities**: Full implementation and testing
**Access**: Read/write src/, tests/, templates/

### Warp Agent
**Role**: CLI testing and debugging
**Capabilities**: Command execution, UX testing
**Access**: Execute CLI, read-only code

### Codex CLI
**Role**: Code optimization
**Capabilities**: Performance and security analysis
**Access**: Read-only analysis

## Agent Roles

### Claude Code
**Primary Role**: CLI implementation and testing
**Permissions**: Full read/write on src/, tests/
**Focus**: Python development, Typer framework, Rich UI

### Warp Agent
**Primary Role**: CLI testing and debugging
**Permissions**: Execute CLI commands, read-only code
**Focus**: User experience testing, error reproduction

### Codex CLI
**Primary Role**: Code optimization and security
**Permissions**: Read-only analysis
**Focus**: Performance profiling, security scanning

## Development Workflows

### Feature Addition
1. Claude Code: Implement new command
2. Warp Agent: Test command execution
3. Codex CLI: Security review
4. Claude Code: Write tests
5. Warp Agent: Validate UX

### Bug Fix
1. Warp Agent: Reproduce issue
2. Claude Code: Debug and fix
3. Warp Agent: Verify fix
4. Claude Code: Add regression test

### Release Preparation
1. Codex CLI: Security audit
2. Claude Code: Version bump
3. Warp Agent: Full test suite
4. Claude Code: Update docs

## Testing Matrix

| Test Type | Primary Agent | Support |
|-----------|--------------|---------|
| Unit | Claude Code | - |
| Integration | Claude Code | Warp |
| CLI UX | Warp Agent | Claude |
| Performance | Codex CLI | - |
| Security | Codex CLI | Claude |

## MCP Configuration

### CLI Development
```yaml
mcp_servers:
  - serena: # Code analysis
      scope: src/specify_cli/
  - context7: # Library docs
      libraries: [typer, rich, httpx]
```

---

*Specification Version: 1.0.0 | Last Updated: 2025-09-09*