# AGENTS.md - Multi-Agent SDD Support

This document follows the [agents.md](https://github.com/openai/agents.md) convention to define supported AI agents and their configurations for Spec-Driven Development workflows.

## Supported Agents

### Claude Code (Primary)
**Role**: Lead developer and orchestrator
**Capabilities**: Full-stack development, architectural decisions, code generation
**Access Level**: Read/write within defined scopes
**MCP Servers**: All available with security boundaries
**Invocation**: Native VS Code integration

### Warp Agent
**Role**: CLI reviewer and executor
**Capabilities**: Command execution, log analysis, debugging
**Access Level**: Read-only with selective execution
**MCP Servers**: GitHub MCP, Serena
**Invocation**:
```bash
# List available profiles
warp-preview agent profile list

# Run with profile and MCP
warp-preview agent run \
  --profile {{PROFILE_UUID}} \
  --mcp-server {{MCP_UUID}} \
  -C /path/to/repo \
  --prompt "Review @dev-docs/sdd/lifecycle.md"

# GUI mode for interactive review
warp-preview agent run --gui \
  --prompt "Validate SDD compliance for PR #123"
```

### Codex CLI
**Role**: Code analysis and optimization
**Capabilities**: Performance profiling, security scanning
**Access Level**: Read-only
**MCP Servers**: Context7
**Invocation**:
```bash
codex-cli analyze --spec specs/001-feature/spec.md
codex-cli optimize --file src/module.py
```

### Gemini CLI
**Role**: Research and documentation
**Capabilities**: Technical research, API exploration
**Access Level**: Read-only
**MCP Servers**: DeepWiki, Jina
**Invocation**:
```bash
gemini research "JWT implementation best practices"
gemini document --spec specs/001-feature/
```

### Cursor Agent
**Role**: Pair programming assistant
**Capabilities**: Real-time code suggestions, refactoring
**Access Level**: Editor integration only
**MCP Servers**: Context7, Serena
**Invocation**: Integrated in Cursor IDE

## Agent Coordination

### Task Distribution
```yaml
specification_phase:
  lead: claude_code
  support: [gemini_cli]
  
planning_phase:
  lead: claude_code
  reviewers: [warp_agent, codex_cli]
  
implementation_phase:
  lead: claude_code
  pair: cursor_agent
  reviewers: [warp_agent]
  
validation_phase:
  lead: warp_agent
  support: [codex_cli, claude_code]
```

### Communication Channels
- **Git branches**: Isolated work streams
- **PR comments**: Review feedback
- **Issue tracking**: Task coordination
- **Slack/Discord**: Real-time collaboration

## MCP Server Configuration

### GitHub MCP
**Purpose**: Repository operations
**Agents**: All
**Config**:
```json
{
  "auth": "$GITHUB_TOKEN",
  "repo": "owner/repo",
  "permissions": ["read", "write:issues"]
}
```

### Context7
**Purpose**: Library documentation
**Agents**: Claude Code, Cursor, Codex
**Config**:
```json
{
  "libraries": ["react", "fastapi", "postgresql"],
  "cache": true
}
```

### DeepWiki
**Purpose**: Technical documentation
**Agents**: Gemini, Claude Code
**Config**:
```json
{
  "sources": ["github", "stackoverflow"],
  "depth": 2
}
```

### Jina MCP
**Purpose**: Web research and extraction
**Agents**: Gemini, Claude Code
**Config**:
```json
{
  "api_key": "$JINA_API_KEY",
  "rate_limit": 100
}
```

### Serena
**Purpose**: Semantic code analysis
**Agents**: Claude Code, Cursor, Warp
**Config**:
```json
{
  "project_root": ".",
  "languages": ["python", "javascript"]
}
```

## Profiles

### Development Profile
```yaml
name: sdd-development
agents:
  - claude_code: primary
  - cursor_agent: pair
mcp_servers:
  - serena
  - context7
permissions:
  - read: all
  - write: [specs/, tests/, src/]
  - execute: [scripts/]
```

### Review Profile
```yaml
name: sdd-review
agents:
  - warp_agent: primary
  - codex_cli: analyzer
mcp_servers:
  - github_mcp
  - serena
permissions:
  - read: all
  - write: none
  - execute: [scripts/sdd/validate_*]
```

### Research Profile
```yaml
name: sdd-research
agents:
  - gemini_cli: primary
  - claude_code: support
mcp_servers:
  - deepwiki
  - jina_mcp
permissions:
  - read: all
  - write: [dev-docs/, specs/*/research.md]
  - execute: none
```

## Security Boundaries

### Agent Isolation
- Each agent runs in isolated environment
- No shared state between agents
- Separate credential stores
- Audit logs per agent

### Permission Model
```
Level 0: No access
Level 1: Read public docs
Level 2: Read repository
Level 3: Write documentation
Level 4: Write code
Level 5: Execute safe commands
Level 6: Execute with confirmation
Level 7: Full access (human only)
```

### Token Management
```bash
# Never hardcode tokens
export GITHUB_TOKEN=$(security find-generic-password -s github)
export JINA_API_KEY=$(security find-generic-password -s jina)
export ANTHROPIC_API_KEY=$(security find-generic-password -s anthropic)
```

## Workflows

### New Feature Workflow
1. **Claude Code**: Create specification
2. **Gemini CLI**: Research technical options
3. **Claude Code**: Generate plan
4. **Warp Agent**: Validate plan
5. **Claude Code + Cursor**: Implement
6. **Codex CLI**: Optimize
7. **Warp Agent**: Final review

### Bug Fix Workflow
1. **Warp Agent**: Reproduce issue
2. **Codex CLI**: Analyze root cause
3. **Claude Code**: Implement fix
4. **Warp Agent**: Validate fix

### Documentation Workflow
1. **Gemini CLI**: Research topic
2. **Claude Code**: Write documentation
3. **Warp Agent**: Review accuracy

## Best Practices

### Do's
- Use appropriate agent for task
- Maintain clear boundaries
- Document agent decisions
- Review agent output
- Use version control

### Don'ts
- Share credentials between agents
- Skip validation steps
- Ignore agent warnings
- Mix agent workspaces
- Bypass security checks

## Monitoring

### Metrics
- Agent utilization
- Task completion time
- Error rates
- Token usage
- MCP server calls

### Logging
```json
{
  "timestamp": "2025-09-09T10:00:00Z",
  "agent": "claude_code",
  "action": "generate_plan",
  "spec": "001-auth",
  "duration": 45,
  "tokens": 2500,
  "status": "success"
}
```

### Alerts
- Excessive token usage
- Security boundary violations
- Repeated failures
- Performance degradation
- Credential exposure attempts

## Troubleshooting

### Common Issues

**Agent not responding**
```bash
# Check agent status
warp-preview agent status
# Restart agent
warp-preview agent restart --profile sdd-development
```

**MCP server connection failed**
```bash
# Verify MCP configuration
warp-preview mcp test {{MCP_UUID}}
# Check credentials
echo $GITHUB_TOKEN | head -c 10
```

**Permission denied**
```bash
# Verify agent profile
warp-preview agent profile show
# Check file permissions
ls -la specs/
```

## Version Compatibility

| Agent | Min Version | Recommended | Notes |
|-------|------------|-------------|-------|
| Claude Code | 0.5.0 | Latest | Primary agent |
| Warp | 2024.1 | Latest | CLI required |
| Codex CLI | 1.0.0 | 1.2+ | Optional |
| Gemini CLI | 0.3.0 | Latest | Research focus |
| Cursor | 0.8.0 | Latest | IDE integration |

---

*Specification Version: 1.0.0 | agents.md Format: 1.0 | Last Updated: 2025-09-09*