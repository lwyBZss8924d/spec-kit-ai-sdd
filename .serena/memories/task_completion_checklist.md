# Task Completion Checklist for Spec-Kit

## When a Development Task is Completed

### 1. Code Quality Checks
- [ ] All scripts have proper shebang (`#!/usr/bin/env bash`)
- [ ] Python code follows project conventions
- [ ] No hardcoded paths or credentials
- [ ] Error handling implemented

### 2. Testing
- [ ] Manual testing completed for new features
- [ ] Scripts tested on macOS/Darwin (primary platform)
- [ ] CLI commands verified to work as expected

### 3. Documentation Updates
- [ ] Update CLAUDE.md if new commands added
- [ ] Update relevant templates if workflow changed
- [ ] Ensure spec/plan/tasks documents are complete

### 4. Git Operations
- [ ] Changes committed with proper message format: `type: description [TASK-ID]`
- [ ] Feature branch follows naming convention: `NNN-feature-name`
- [ ] All files added to git (check with `git status`)

### 5. Validation Commands
```bash
# Check for uncommitted changes
git status

# Verify scripts are executable
ls -la scripts/*.sh

# Test CLI if modified
specify check

# Ensure no syntax errors in Python
python -m py_compile src/specify_cli/__init__.py
```

### 6. Pre-PR Checklist
- [ ] All specification `[NEEDS CLARIFICATION]` markers resolved
- [ ] Implementation matches specification requirements
- [ ] No `[PLACEHOLDER]` text remains in documents
- [ ] Review checklist in spec completed

## Important Notes
- Do NOT push directly to main branch
- Create PR only when explicitly requested by user
- Keep feature branches up to date with main
- Document any deviations from original spec