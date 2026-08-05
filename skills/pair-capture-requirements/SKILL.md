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
2. Normalise requirement text to concise, testable statements. **Exception: where an AC contains exact expected user-facing text — notification strings, error messages, labels, banner copy, or any literal string the user sees — quote that text verbatim inside the criterion. Do not paraphrase, summarise, or shorten it. Include it in the criterion text so it can be searched in the codebase exactly as written.**
3. Preserve existing status/notes when normalised text still matches existing rows.
4. When creating new rows, initialise status to `⬜ Not started`.
5. Never delete or rewrite User Requirements unless explicitly requested by the user.
6. After capturing all rows, flag any criterion that contains quoted literal text with `[TEXT VERIFICATION REQUIRED]` in the Notes column so the orchestrator and coverage mapper know a codebase search is mandatory before marking it covered.

## Output

Return structured output with:
- feature description
- work item number (if provided)
- work item requirements rows
- user requirements rows
- rows that retained prior status
