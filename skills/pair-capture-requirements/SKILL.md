---
name: pair-capture-requirements
description: Capture and normalise work-item and user-entered requirements into checklist-ready rows while preserving source separation.
---

# Pair Requirement Capture

Capture requirements into two separate lists:
- Work Item Requirements
- User Requirements

## Inputs

- Optional Azure DevOps work item details (title, description, acceptance criteria)
- Optional manual user-entered feature description and acceptance criteria
- Existing checklist rows (optional, for status preservation by text match)

## Rules

1. Keep source separation strict. Never mix Work Item and User requirements.
2. Normalise requirement text to concise, testable statements.
3. Preserve existing status/notes when normalised text still matches existing rows.
4. When creating new rows, initialise status to `⬜ Not started`.
5. Never delete or rewrite User Requirements unless explicitly requested by the user.

## Output

Return structured output with:
- feature description
- work item number (if provided)
- work item requirements rows
- user requirements rows
- rows that retained prior status
