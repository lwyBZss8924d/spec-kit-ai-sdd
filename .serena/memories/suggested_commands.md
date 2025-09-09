# Suggested Commands for Spec-Kit Development

## Installation and Setup
```bash
# Install the Specify CLI from repository
uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>

# Install globally for repeated use
uv tool install --from git+https://github.com/github/spec-kit.git specify-cli

# Initialize in current directory
specify init --here --ai claude
```

## Core Script Commands
```bash
# Create a new feature with auto-numbered spec directory
./scripts/create-new-feature.sh "feature description"

# Check prerequisites for a task
./scripts/check-task-prerequisites.sh

# Set up implementation plan from spec
./scripts/setup-plan.sh

# Update AI agent context files
./scripts/update-agent-context.sh

# Get feature paths helper
./scripts/get-feature-paths.sh
```

## Git Commands
```bash
# Standard git operations for feature branches
git checkout -b NNN-feature-name
git add .
git commit -m "type: message [TASK-ID]"
git push -u origin NNN-feature-name
```

## Python Development
```bash
# Run the CLI directly (development)
python -m specify_cli init <project>

# Check environment
python --version  # Should be 3.11+
uv --version

# Install dependencies for development
uv pip install typer rich httpx platformdirs readchar
```

## Testing and Validation
```bash
# Run the check command to validate environment
specify check

# Check if required tools are installed
which uv
which git
```

## System Utils (macOS/Darwin specific)
```bash
# Standard Unix commands available on macOS
ls -la        # List files with details
find . -name "*.md"  # Find files
grep -r "pattern" .  # Search in files
chmod +x script.sh   # Make script executable
```