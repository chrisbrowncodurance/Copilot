---
name: pair-gap-analyser
description: Analyse requirement coverage output and identify uncovered, weakly evidenced, or regressed requirements.
---

# Pair Gap Analyser

Identify what is missing between requirements and implementation evidence.

## Inputs

- Merged requirement list (`WI-*`, `UR-*`)
- Evidence map from coverage analysis
- Previous checklist state

## Rules

1. Mark requirements as:
   - `✅ Covered` when concrete evidence exists
   - `🔄 In progress` when partial evidence exists
   - `⬜ Not started` when no evidence exists
   - `❌ Regression` when previously covered evidence is now absent
2. Prefer tests + implementation evidence over implementation-only evidence.
3. Flag weak evidence explicitly (for example, only TODO comments or renamed files with no behavioural proof).
4. Do not persist file updates; return an in-memory snapshot only.

## Output

Return:
- updated in-memory checklist rows with status and notes
- explicit gap list ordered by highest delivery risk first
- regression list with prior vs current evidence summary
