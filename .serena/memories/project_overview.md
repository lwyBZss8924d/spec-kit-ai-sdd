# Spec-Kit Project Overview

## Purpose
Spec-Kit is a toolkit for Spec-Driven Development (SDD), a methodology that inverts traditional software development by making specifications executable artifacts that generate working implementations rather than just guiding them.

## Core Concept
- Specifications become the primary artifact; code serves specifications
- Focuses on the "what" and "why" before the "how"
- Multi-step refinement process: Specification → Implementation Plan → Tasks → Code Generation → Validation
- Heavy reliance on AI model capabilities for specification interpretation

## Tech Stack
- **Language**: Python 3.11+
- **CLI Framework**: Typer with Rich for terminal UI
- **Package Management**: uv (Astral's package manager)
- **Build System**: Hatchling
- **Dependencies**: httpx, platformdirs, readchar

## Project Structure
- `src/specify_cli/`: Python CLI implementation
- `templates/`: Core templates for SDD workflow (spec, plan, tasks, agent files)
- `scripts/`: Bash automation scripts for feature management
- `memory/`: Project constitution and principles templates
- `specs/`: Feature specifications (created during workflow)
- `media/`: Documentation assets