---
name: pair-gap-analyser
description: Analyse requirement coverage output and identify uncovered, weakly evidenced, or regressed requirements.
---

# Pair Gap Analyser

Identify what is missing between requirements and implementation evidence.

## Inputs

- Merged requirement list (`WI-*`, `UR-*`) from staged analysis
- Evidence map from staged coverage analysis
- Previous checklist state
- Coverage reconciliation block (`reconciliation_status`, `current_branch_commit_count`, `recorded_branch_commit_count`, `reassessment_required`)

## Rules

1. Mark requirements as:
   - `✅ Covered` when concrete evidence exists
   - `🔄 In progress` when partial evidence exists
   - `⬜ Not started` when no evidence exists
   - `❌ Regression` when previously covered evidence is now absent
   - **For any requirement that contains quoted literal text (notification strings, error messages, labels, or verbatim user-facing copy), `✅ Covered` requires confirmed code search evidence that the exact string (or its resource key value) exists in the codebase. A file reference alone is not sufficient. If a `TEXT NOT FOUND` flag appears in the coverage mapper evidence, the requirement must remain `🔄 In progress` or `⬜ Not started` regardless of other evidence.**
2. Prefer tests + implementation evidence over implementation-only evidence.
3. Flag weak evidence explicitly (for example, only TODO comments or renamed files with no behavioural proof).
4. If `reassessment_required` is true, report `branch-coverage-snapshot-out-of-date` as informational during commit-readiness and ready-for-merge flows.
5. Do not block those flows or request checklist persistence. The snapshot is refreshed only during session start or show-checklist.
6. Do not persist file updates; return an in-memory snapshot only.
7. Do not let unrelated unstaged or untracked files change requirement status or gap priority.
8. Treat any `[CLARIFICATION NEEDED: ...]` note left by capture as an open gap, never as implicitly resolved — surface it every time until the checklist note is replaced with real content.
9. If a requirement row describes an action but has no sibling row for its stated side effect (emitted event, notification, audit entry, state transition), or a UI-text requirement has no verbatim quoted string, flag `incomplete-decomposition` as a gap so it routes back to `pair-capture-requirements` rather than being silently scored against weak evidence.

## Output

Return:
- updated in-memory checklist rows with status and notes
- explicit gap list ordered by highest delivery risk first
- regression list with prior vs current evidence summary
- reconciliation gap summary, including recorded and current branch commit counts
