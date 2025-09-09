# MCP Server Integration Guide

Model Context Protocol (MCP) servers enhance AI agents with specialized capabilities. This guide covers configuration, security, and usage patterns for SDD workflows.

## Available MCP Servers

### GitHub MCP
**Purpose**: Repository operations, issue management, PR automation
**Use Cases**: 
- Creating and updating issues
- PR reviews and comments
- Branch management
- Workflow triggers

**Configuration**:
```bash
# Start server (IDs resolved at runtime)
warp-preview mcp start github

# Environment setup
export GITHUB_TOKEN="${GITHUB_TOKEN:-$(gh auth token)}"
```

**Security Notes**:
- Use fine-grained personal access tokens
- Limit scope to required repositories
- Rotate tokens regularly

### Context7
**Purpose**: Library documentation and code examples
**Use Cases**:
- Framework documentation lookup
- API reference
- Code examples
- Version-specific guidance

**Configuration**:
```bash
# Start server
warp-preview mcp start context7

# Configure libraries
export CONTEXT7_LIBRARIES="fastapi,react,postgresql"
```

**Security Notes**:
- Read-only access
- Caches documentation locally
- No authentication required

### DeepWiki
**Purpose**: Technical documentation aggregation
**Use Cases**:
- Research technical decisions
- Find implementation patterns
- Discover best practices
- Architecture references

**Configuration**:
```bash
# Start server
warp-preview mcp start deepwiki

# Set search depth
export DEEPWIKI_DEPTH=2
export DEEPWIKI_SOURCES="github,stackoverflow"
```

**Security Notes**:
- Public data only
- Rate limiting applied
- No credentials required

### Jina MCP
**Purpose**: Web research and content extraction
**Use Cases**:
- Current technology trends
- Security advisories
- Performance benchmarks
- Compatibility research

**Configuration**:
```bash
# Start server
warp-preview mcp start jina

# API configuration
export JINA_API_KEY="${JINA_API_KEY}"
export JINA_RATE_LIMIT=100
```

**Security Notes**:
- API key required
- Usage tracked and limited
- No PII in queries

### Serena
**Purpose**: Semantic code analysis and search
**Use Cases**:
- Code pattern detection
- Refactoring opportunities
- Dependency analysis
- Symbol resolution

**Configuration**:
```bash
# Start server
warp-preview mcp start serena

# Project configuration
export SERENA_PROJECT_ROOT="."
export SERENA_LANGUAGES="python,javascript,typescript"
```

**Security Notes**:
- Local analysis only
- No code uploaded
- Respects .gitignore

### Playwright MCP
**Purpose**: Browser automation and testing
**Use Cases**:
- E2E test generation
- UI validation
- Screenshot capture
- Performance testing

**Configuration**:
```bash
# Start server
warp-preview mcp start playwright

# Browser setup
export PLAYWRIGHT_BROWSERS="chromium,firefox"
export PLAYWRIGHT_HEADLESS=true
```

**Security Notes**:
- Sandbox browser execution
- No credential storage
- Clear session data

## Starting MCP Servers

### Manual Start
```bash
# List available servers
warp-preview mcp list

# Start specific server
warp-preview mcp start {{SERVER_NAME}}

# Start with configuration
warp-preview mcp start {{SERVER_NAME}} --config config.json

# Stop server
warp-preview mcp stop {{SERVER_NAME}}
```

### Automatic Start (Warp)
```bash
# In .warp/config.yml
mcp_servers:
  auto_start:
    - github
    - serena
    - context7
```

### Profile-based Start
```bash
# Development profile
warp-preview agent run --profile dev --mcp-auto

# Review profile  
warp-preview agent run --profile review --mcp github,serena
```

## Security Guidelines

### Token Management
```bash
# Never hardcode tokens
# Bad
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"

# Good - Use secret manager
export GITHUB_TOKEN=$(security find-generic-password -s github -w)

# Good - Use environment file
source ~/.env.mcp

# Good - Use tool integration
export GITHUB_TOKEN=$(gh auth token)
```

### Permission Scoping
```yaml
# Minimal permissions per server
github:
  scopes: [repo:read, issues:write]
  repos: [owner/spec-kit]
  
jina:
  rate_limit: 100
  allowed_domains: [*.github.io, docs.*.com]
  
serena:
  read_only: false
  paths: [src/, tests/, specs/]
```

### Audit Logging
```bash
# Enable MCP audit logging
export MCP_AUDIT_LOG=~/.mcp/audit.log
export MCP_LOG_LEVEL=INFO

# Review audit log
tail -f ~/.mcp/audit.log | grep -E "(ERROR|WARN|AUTH)"
```

## Usage Patterns

### Research Phase
```bash
# Start research servers
warp-preview mcp start deepwiki jina context7

# Run research agent
warp-preview agent run --profile research \
  --prompt "Research JWT implementation patterns"
```

### Development Phase
```bash
# Start development servers
warp-preview mcp start serena context7 github

# Run development agent
warp-preview agent run --profile dev \
  --prompt "Implement authentication using researched patterns"
```

### Review Phase
```bash
# Start review servers
warp-preview mcp start github serena

# Run review agent
warp-preview agent run --profile review \
  --prompt "Review PR #123 for SDD compliance"
```

## Troubleshooting

### Server Won't Start
```bash
# Check if port is in use
lsof -i :{{PORT}}

# Check server logs
warp-preview mcp logs {{SERVER_NAME}}

# Reset server state
warp-preview mcp reset {{SERVER_NAME}}
```

### Authentication Issues
```bash
# Verify token is set
echo $GITHUB_TOKEN | head -c 10

# Test authentication
warp-preview mcp test github --auth

# Refresh token
gh auth refresh
```

### Performance Issues
```bash
# Check server metrics
warp-preview mcp stats

# Limit concurrent servers
export MCP_MAX_SERVERS=3

# Increase timeout
export MCP_TIMEOUT=30
```

## Best Practices

### Do's
- Start only needed servers
- Use profiles for consistency
- Monitor token usage
- Cache when possible
- Clean up after sessions

### Don'ts
- Share MCP sessions between agents
- Hardcode credentials
- Ignore rate limits
- Skip authentication
- Leave servers running idle

## Server Selection Matrix

| Task | Primary | Secondary | Optional |
|------|---------|-----------|----------|
| New Feature | Serena | Context7 | DeepWiki |
| Bug Fix | Serena | GitHub | - |
| Research | DeepWiki | Jina | Context7 |
| Testing | Playwright | Serena | - |
| Documentation | Context7 | DeepWiki | Jina |
| Code Review | Serena | GitHub | - |

## Integration Examples

### With Claude Code
```python
# In CLAUDE.md configuration
mcp_servers:
  required: [serena, context7]
  optional: [github, deepwiki]
  forbidden: []  # Explicitly blocked
```

### With Warp Agent
```bash
# Command line
warp-preview agent run \
  --mcp serena,github \
  --mcp-config ~/.mcp/profiles/dev.json
```

### With CI/CD
```yaml
# In GitHub Actions
- name: Start MCP Servers
  run: |
    warp-preview mcp start github serena
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

*Version: 1.0.0 | MCP Protocol: 2.0 | Last Updated: 2025-09-09*