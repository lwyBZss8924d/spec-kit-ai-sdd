#!/usr/bin/env python3
"""Tests for SDD validation functionality."""

import os
import re
from pathlib import Path
import tempfile
import json

import pytest


class TestSDDStructure:
    """Test SDD structure validation."""

    def test_constitution_exists(self):
        """Test that SDD constitution exists."""
        constitution = Path("dev-docs/sdd/constitution.md")
        assert constitution.exists()
        assert constitution.stat().st_size > 0

    def test_lifecycle_exists(self):
        """Test that SDD lifecycle document exists."""
        lifecycle = Path("dev-docs/sdd/lifecycle.md")
        assert lifecycle.exists()
        assert lifecycle.stat().st_size > 0

    def test_agent_contexts_exist(self):
        """Test that agent context files exist."""
        contexts = [
            "dev-docs/sdd/CLAUDE.md",
            "dev-docs/sdd/AGENTS.md",
            "dev-docs/cli/CLAUDE.md",
            "dev-docs/cli/AGENTS.md"
        ]
        
        for context_file in contexts:
            path = Path(context_file)
            assert path.exists(), f"Missing: {context_file}"
            assert path.stat().st_size > 0

    def test_required_directories(self):
        """Test that required SDD directories exist."""
        required_dirs = [
            "dev-docs/sdd",
            "dev-docs/agents",
            "dev-docs/git",
            "dev-docs/cli",
            "scripts",
            "templates",
            "specs"
        ]
        
        for dir_path in required_dirs:
            path = Path(dir_path)
            assert path.exists(), f"Missing directory: {dir_path}"
            assert path.is_dir()


class TestSpecificationValidation:
    """Test specification validation rules."""

    def test_no_unresolved_clarifications(self):
        """Test that no [NEEDS CLARIFICATION] markers remain."""
        specs_dir = Path("specs")
        if not specs_dir.exists():
            pytest.skip("No specs directory")
        
        for spec_file in specs_dir.rglob("*.md"):
            content = spec_file.read_text()
            matches = re.findall(r"\[NEEDS CLARIFICATION[^\]]*\]", content)
            assert len(matches) == 0, f"Unresolved clarifications in {spec_file}: {matches}"

    def test_spec_structure(self):
        """Test that specs follow required structure."""
        template = Path("templates/spec-template.md")
        if not template.exists():
            pytest.skip("No spec template")
        
        template_content = template.read_text()
        required_sections = [
            "## Feature Overview",
            "## User Stories", 
            "## Functional Requirements",
            "## Non-Functional Requirements",
            "## Acceptance Criteria"
        ]
        
        for section in required_sections:
            assert section in template_content, f"Missing section: {section}"


class TestTaskTraceability:
    """Test task-to-commit traceability."""

    def test_task_id_format(self):
        """Test that task IDs follow correct format."""
        # Task ID format: TASK-### or T###
        valid_formats = [
            "TASK-001",
            "TASK-999", 
            "T001",
            "T999"
        ]
        
        invalid_formats = [
            "TASK001",  # Missing hyphen
            "Task-001",  # Wrong case
            "TASK-",     # Missing number
            "T"          # Missing number
        ]
        
        task_pattern = re.compile(r"(TASK-\d{3}|T\d{3})")
        
        for valid in valid_formats:
            assert task_pattern.match(valid), f"Should match: {valid}"
        
        for invalid in invalid_formats:
            assert not task_pattern.match(invalid), f"Should not match: {invalid}"

    def test_commit_message_format(self):
        """Test commit message format validation."""
        # Format: type(scope): message [TASK-###]
        commit_pattern = re.compile(
            r"^(feat|fix|docs|style|refactor|test|chore)(\([^)]+\))?: .+ \[TASK-\d{3}\]$"
        )
        
        valid_commits = [
            "feat: add authentication [TASK-001]",
            "fix(api): correct validation [TASK-002]",
            "docs: update README [TASK-003]"
        ]
        
        invalid_commits = [
            "add authentication",  # Missing type and task
            "feat: add auth",      # Missing task reference
            "fixed bug [TASK-001]" # Invalid type
        ]
        
        for valid in valid_commits:
            assert commit_pattern.match(valid), f"Should match: {valid}"
        
        for invalid in invalid_commits:
            assert not commit_pattern.match(invalid), f"Should not match: {invalid}"


class TestDocumentationStandards:
    """Test documentation standards compliance."""

    def test_markdown_files_exist(self):
        """Test that required markdown files exist."""
        required_files = [
            "README.md",
            "CONTRIBUTING.md",
            "LICENSE"
        ]
        
        for file_name in required_files:
            path = Path(file_name)
            assert path.exists(), f"Missing: {file_name}"

    def test_no_placeholder_text(self):
        """Test that no placeholder text remains."""
        placeholders = [
            "[PLACEHOLDER]",
            "[TODO]",
            "{{VARIABLE}}",
            "[PRINCIPLE_1_NAME]"
        ]
        
        # Check in dev-docs for now
        docs_dir = Path("dev-docs")
        if not docs_dir.exists():
            pytest.skip("No dev-docs directory")
        
        for doc_file in docs_dir.rglob("*.md"):
            content = doc_file.read_text()
            for placeholder in placeholders:
                # Skip checking in example/template sections
                if "example" not in str(doc_file).lower():
                    assert placeholder not in content, f"Placeholder '{placeholder}' found in {doc_file}"


class TestCIConfiguration:
    """Test CI/CD configuration validation."""

    def test_workflow_files_valid(self):
        """Test that workflow files are valid YAML."""
        workflows_dir = Path(".github/workflows")
        if not workflows_dir.exists():
            pytest.skip("No workflows directory")
        
        for workflow_file in workflows_dir.glob("*.yml"):
            content = workflow_file.read_text()
            # Basic YAML validation
            assert content.startswith("name:"), f"Invalid workflow: {workflow_file}"
            assert "on:" in content, f"Missing trigger in: {workflow_file}"
            assert "jobs:" in content, f"Missing jobs in: {workflow_file}"

    def test_no_hardcoded_secrets(self):
        """Test that no secrets are hardcoded."""
        secret_patterns = [
            r"ghp_[a-zA-Z0-9]{36}",  # GitHub token
            r"sk-[a-zA-Z0-9]{48}",    # OpenAI key
            r"api[_-]?key\s*=\s*['\"][^'\"]+['\"]",  # API keys
            r"password\s*=\s*['\"][^'\"]+['\"]"      # Passwords
        ]
        
        exclude_dirs = {"venv", "node_modules", ".git", "__pycache__"}
        
        for root, dirs, files in os.walk("."):
            dirs[:] = [d for d in dirs if d not in exclude_dirs]
            
            for file in files:
                if file.endswith((".py", ".yml", ".yaml", ".json", ".md", ".sh")):
                    file_path = Path(root) / file
                    try:
                        content = file_path.read_text()
                        for pattern in secret_patterns:
                            matches = re.findall(pattern, content, re.IGNORECASE)
                            assert len(matches) == 0, f"Potential secret in {file_path}: {matches}"
                    except (UnicodeDecodeError, PermissionError):
                        # Skip binary or inaccessible files
                        continue


class TestGitWorktrees:
    """Test git worktree documentation."""

    def test_worktree_docs_exist(self):
        """Test that worktree documentation exists."""
        worktree_doc = Path("dev-docs/git/worktrees.md")
        assert worktree_doc.exists()
        
        content = worktree_doc.read_text()
        required_sections = [
            "## Basic Commands",
            "## Naming Conventions",
            "## Safety Guidelines",
            "## Agent Integration"
        ]
        
        for section in required_sections:
            assert section in content, f"Missing section: {section}"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])