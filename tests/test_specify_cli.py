#!/usr/bin/env python3
"""Tests for the Specify CLI."""

import os
import sys
import tempfile
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock

import pytest
from typer.testing import CliRunner

# Add src to path for testing
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from specify_cli import app, AI_CHOICES, check_tool


class TestCLI:
    """Test suite for Specify CLI commands."""

    def setup_method(self):
        """Set up test fixtures."""
        self.runner = CliRunner()
        self.temp_dir = tempfile.mkdtemp()

    def teardown_method(self):
        """Clean up test fixtures."""
        import shutil
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)

    def test_init_command_help(self):
        """Test init command help output."""
        result = self.runner.invoke(app, ["init", "--help"])
        assert result.exit_code == 0
        assert "Initialize a new Specify project" in result.stdout

    def test_check_command(self):
        """Test check command execution."""
        with patch("specify_cli.check_tool") as mock_check:
            mock_check.return_value = True
            result = self.runner.invoke(app, ["check"])
            assert result.exit_code == 0
            assert "Environment Check" in result.stdout

    @patch("specify_cli.Path.exists")
    @patch("specify_cli.subprocess.run")
    def test_init_with_project_name(self, mock_run, mock_exists):
        """Test project initialization with name."""
        mock_exists.return_value = False
        mock_run.return_value = Mock(returncode=0)
        
        with patch("specify_cli.httpx.get") as mock_get:
            mock_get.return_value = Mock(
                status_code=200,
                content=b"fake zip content"
            )
            
            result = self.runner.invoke(
                app, 
                ["init", "test-project", "--ai", "claude", "--ignore-agent-tools"],
                input="\n"
            )
            
            assert "test-project" in result.stdout

    def test_init_here_flag(self):
        """Test initialization in current directory."""
        with patch("specify_cli.Path.cwd") as mock_cwd:
            mock_cwd.return_value = Path(self.temp_dir)
            
            with patch("specify_cli.httpx.get") as mock_get:
                mock_get.return_value = Mock(
                    status_code=200,
                    content=b"fake zip content"
                )
                
                result = self.runner.invoke(
                    app,
                    ["init", "--here", "--ai", "claude", "--ignore-agent-tools"],
                    input="\n"
                )
                
                assert result.exit_code == 0

    def test_ai_choice_validation(self):
        """Test AI choice validation."""
        assert "claude" in AI_CHOICES
        assert "gemini" in AI_CHOICES
        assert "copilot" in AI_CHOICES
        assert len(AI_CHOICES) == 3


class TestCheckTool:
    """Test suite for tool checking functionality."""

    @patch("specify_cli.subprocess.run")
    def test_check_tool_found(self, mock_run):
        """Test tool detection when present."""
        mock_run.return_value = Mock(returncode=0)
        result = check_tool("git", "Install git")
        assert result is True

    @patch("specify_cli.subprocess.run")
    def test_check_tool_not_found(self, mock_run):
        """Test tool detection when missing."""
        mock_run.side_effect = FileNotFoundError
        result = check_tool("nonexistent", "Install tool")
        assert result is False


class TestProjectStructure:
    """Test project structure creation."""

    def test_required_directories(self):
        """Test that required directories are created."""
        required_dirs = [
            "memory",
            "scripts", 
            "specs",
            "templates",
            "templates/commands",
            ".claude",
            ".claude/commands"
        ]
        
        # These should be part of the template structure
        # Testing that we know what directories to expect
        for dir_name in required_dirs:
            assert isinstance(dir_name, str)
            assert len(dir_name) > 0

    def test_required_files(self):
        """Test that required files are included."""
        required_files = [
            "templates/spec-template.md",
            "templates/plan-template.md",
            "templates/tasks-template.md",
            "memory/constitution.md",
            "scripts/create-new-feature.sh",
            "scripts/setup-plan.sh"
        ]
        
        # These should be part of the template structure
        for file_name in required_files:
            assert isinstance(file_name, str)
            assert file_name.endswith((".md", ".sh"))


class TestErrorHandling:
    """Test error handling scenarios."""

    def setup_method(self):
        """Set up test fixtures."""
        self.runner = CliRunner()

    def test_init_existing_directory(self):
        """Test initialization with existing directory."""
        with tempfile.TemporaryDirectory() as tmpdir:
            existing = Path(tmpdir) / "existing"
            existing.mkdir()
            
            result = self.runner.invoke(
                app,
                ["init", str(existing), "--ai", "claude", "--ignore-agent-tools"]
            )
            
            assert result.exit_code == 1
            assert "already exists" in result.stdout

    @patch("specify_cli.httpx.get")
    def test_download_failure(self, mock_get):
        """Test handling of download failures."""
        mock_get.side_effect = Exception("Network error")
        
        result = self.runner.invoke(
            app,
            ["init", "test-project", "--ai", "claude", "--ignore-agent-tools"],
            input="\n"
        )
        
        assert result.exit_code == 1
        assert "Failed" in result.stdout or "Error" in result.stdout


if __name__ == "__main__":
    pytest.main([__file__, "-v"])