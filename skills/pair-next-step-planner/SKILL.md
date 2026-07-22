---
name: pair-next-step-planner
description: Recommend exactly one highest-value next action from checklist gaps and current branch evidence.
---

# Pair Next Step Planner

Recommend one concrete action.

## Inputs

- In-memory checklist snapshot
- Gap list and regressions
- Current diff summary
- Reconciliation summary (`reconciliation_status`, `unlogged_commits`)

## Rules

1. Choose exactly one next step.
2. Prefer steps that unblock the most uncovered criteria with lowest risk.
3. Include target files/components when possible.
4. If `unlogged_commits` is not empty, the next step must be reconciling and logging those commits first.
5. Avoid option lists. Commit to one recommendation.

## Output

Return:
- one action sentence
- short rationale linked to requirement IDs
- success signal (what evidence should exist when complete)
