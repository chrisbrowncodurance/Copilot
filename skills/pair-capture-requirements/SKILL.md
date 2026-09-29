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

### Complete acceptance-criterion coverage

7. **All acceptance criterion must be covered by the work item requirements.** Read every acceptance criterion clause-by-clause (split on "and", "then", "when", semicolons, and enumerated sub-bullets) and produce requirements that together will cover every distinct clause. Every clause of that AC must be reproced by one or more requirement — dropping, merging away, or silently summarising a clause is a capture defect, not a simplification.
8. Before returning output, run a **completeness self-check** per AC: list the clauses you identified, confirm each is covered by one or more corresponding rows, and confirm no row was invented that isn't traceable to the source AC, description, or an explicit user requirement. If any clause has no row, add the missing row rather than reporting the gap unresolved.
9. If an AC is genuinely ambiguous or under-specified (e.g. it references a behaviour without stating the expected outcome), do not guess and do not drop it — capture the row with status `⬜ Not started` and a Notes entry `[CLARIFICATION NEEDED: <what is missing>]` so the gap surfaces instead of disappearing.

### UI notes and displayed text

10. **Every UI note and every piece of displayed text mentioned anywhere in the work item or user description must become its own explicit, verbatim requirement row** — this is not limited to notifications and error messages. It includes (non-exhaustively): field labels, button/link text, placeholder text, tooltips/help text, validation/inline messages, confirmation/dialog copy, banner/toast copy, empty-state copy, column headers, and any screenshot/mock-up caption or annotation describing what must appear on screen. Quote the exact text verbatim per rule 2 and flag it per rule 6.
11. If the work item includes a mock-up, screenshot, or design annotation, treat every annotated label or callout as an implied acceptance criterion in its own right, even if the narrative text does not restate it.

### Effects and side effects

12. **Every effect or side effect implied by an action in an AC must be covered by one or more requirement row.** For any AC describing a user action or system trigger, consider and capture requirement rows that cover: state/status transitions, persisted data changes, emitted domain events/messages (e.g. MassTransit contracts), downstream consumers/notifications triggered (email, SMS, Slack, audit log), cache/UI refreshes, and any explicitly stated "should not happen" negative side effect (e.g. "must not send a duplicate notification").
13. Do not fold a side effect into the notes column of an unrelated row as an aside — if it is independently testable, it gets its own row so the coverage mapper can verify it with its own evidence.

## Output

Return structured output with:
- feature description
- work item number (if provided)
- work item requirements rows
- user requirements rows
- rows that retained prior status
- the completeness self-check summary (clauses identified vs rows produced, and any `[CLARIFICATION NEEDED]` rows raised)
