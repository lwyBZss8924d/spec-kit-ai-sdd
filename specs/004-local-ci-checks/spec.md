# Feature Specification: Local CI Validation & Upstream Compatibility

**Feature Branch**: `004-local-ci-checks`  
**Created**: 2025-09-10  
**Status**: Draft  
**Input**: Define and enforce local CI checks for SDD compliance and upstream compatibility

## Execution Flow (main)
```
1. Parse user description from Input
   → If empty: ERROR "No feature description provided"
2. Extract key concepts from description
   → Identify: actors, actions, data, constraints
3. For each unclear aspect:
   → Mark with clarification-needed notes: specific question
4. Fill User Scenarios & Testing section
   → If no clear user flow: ERROR "Cannot determine user scenarios"
5. Generate Functional Requirements
   → Each requirement must be testable
   → Mark ambiguous requirements
6. Identify Key Entities (if data involved)
7. Run Review Checklist
   → If any clarifications remain: WARN "Spec has uncertainties"
   → If implementation details found: ERROR "Remove tech details"
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers
- 🌐 Written in English (all normative artifacts must be English-only)

### Section Requirements
- **Mandatory sections**: Must be completed for every feature
- **Optional sections**: Include only when relevant to the feature
- When a section doesn't apply, remove it entirely (don't leave as "N/A")

### For AI Generation
When creating this spec from a user prompt:
1. **Mark all ambiguities**: Use clear "clarification-needed" notes for any assumption you'd need to make
2. **Don't guess**: If the prompt doesn't specify something (e.g., "login system" without auth method), mark it
3. **Think like a tester**: Every vague requirement should fail the "testable and unambiguous" checklist item
4. **Common underspecified areas**:
   - User types and permissions
   - Data retention/deletion policies  
   - Performance targets and scale
   - Error handling behaviors
   - Integration requirements
   - Security/compliance needs

---

## User Scenarios & Testing (mandatory)

### Primary User Story
As a maintainer, I want a fast local CI command that validates SDD structure, language policy, and upstream template compatibility so I can catch issues before attempting an upstream sync or opening a PR.

### Acceptance Scenarios
1. Given a clean working tree, when I run `scripts/ci/run-local-ci.sh`, then it executes all configured checks and returns an appropriate exit code.
2. Given incomplete SDD artifacts in old/example folders, when lint runs, then excluded directories do not fail the check (configurable via SDD_LINT_EXCLUDE).
3. Given upstream templates have diverged, when template drift runs, then the check fails with a clear, actionable diff summary.
4. Given non-English characters in normative artifacts, when language check runs, then the check fails with file/line snippets for triage.

### Edge Cases
- Missing upstream remote: template drift should report a configuration error and exit non-zero.
- Large repos: CI should complete in under 60s on typical hardware (soft target).

## Requirements (mandatory)

### Functional Requirements
- **FR-001**: Provide a single entrypoint `scripts/ci/run-local-ci.sh` that orchestrates all CI checks and returns non-zero on any failure.
- **FR-002**: Implement SDD structure lint `scripts/ci/run-sdd-structure-lint.sh` verifying spec.md, plan.md, tasks.md for each feature (with configurable exclusions).
- **FR-003**: Implement language policy check `scripts/ci/check-language-policy.sh` flagging non-English letters in normative artifacts while ignoring emoji/symbols and fenced code blocks.
- **FR-004**: Implement template drift detection `scripts/ci/check-templates-drift.sh` comparing local templates against an upstream ref (default upstream/main) and failing on drift.
- **FR-005**: CI checks MUST print friendly summaries with clear remediation instructions and timing per check.
- **FR-006**: CI MUST integrate with the upstream sync workflow and be callable from `scripts/upstream/sync.sh` after merge/rebase.

### Non-functional Requirements
- **NFR-001**: CI runtime should target < 60s on typical local hardware for this repository size.
- **NFR-002**: Exit codes must be reliable (0 pass, non-zero fail) to support automation.
- **NFR-003**: Scripts must be POSIX-friendly and run on macOS/Linux.

### Out of Scope
- Remote CI provider configuration (e.g., GitHub Actions workflows) is not part of this feature.
- Auto-fixing SDD structure or language violations.

### Key Entities
- **CiRun**: timestamp, checks[], result
- **CiCheck**: name, status, duration, output, remediation

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [ ] Written in English (normative artifacts must be English-only)
- [ ] No implementation details (languages, frameworks, APIs)
- [ ] Focused on user value and business needs
- [ ] Written for non-technical stakeholders
- [ ] All mandatory sections completed

### Requirement Completeness
- [ ] No outstanding clarification markers remain
- [ ] Requirements are testable and unambiguous  
- [ ] Success criteria are measurable
- [ ] Scope is clearly bounded
- [ ] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [ ] User description parsed
- [ ] Key concepts extracted
- [ ] Ambiguities marked
- [ ] User scenarios defined
- [ ] Requirements generated
- [ ] Entities identified
- [ ] Review checklist passed

---
