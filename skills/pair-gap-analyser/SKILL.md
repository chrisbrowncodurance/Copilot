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
- Coverage reconciliation block (`reconciliation_status`, `unlogged_commits`)

## Rules

1. Mark requirements as:
   - `✅ Covered` when concrete evidence exists
   - `🔄 In progress` when partial evidence exists
   - `⬜ Not started` when no evidence exists
   - `❌ Regression` when previously covered evidence is now absent
2. Prefer tests + implementation evidence over implementation-only evidence.
3. Flag weak evidence explicitly (for example, only TODO comments or renamed files with no behavioural proof).
4. If reconciliation reports `missing-log-entries`, add a top-priority gap: `commit-log-out-of-sync`.
5. For each unlogged commit, include the inferred intent and requirement impact in the gap notes.
6. Do not persist file updates; return an in-memory snapshot only.
7. Do not let unrelated unstaged or untracked files change requirement status or gap priority.

## Output

Return:
- updated in-memory checklist rows with status and notes
- explicit gap list ordered by highest delivery risk first
- regression list with prior vs current evidence summary
- reconciliation gap summary, including all unlogged commits
