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
- Reconciliation summary (`reconciliation_status`, `current_branch_commit_count`, `recorded_branch_commit_count`, `reassessment_required`)

## Rules

1. Choose exactly one next step.
2. Prefer steps that unblock the most uncovered criteria with lowest risk.
3. Include target files/components when possible.
4. If `reassessment_required` is true, use current in-memory branch evidence for the recommendation. Do not persist coverage here; persistence belongs only to session start or show-checklist.
5. Avoid option lists. Commit to one recommendation.

## Output

Return:
- one action sentence
- short rationale linked to requirement IDs
- success signal (what evidence should exist when complete)
