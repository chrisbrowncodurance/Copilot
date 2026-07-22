---
name: pair-done-gate
description: Evaluate whether work is ready for commit/push using checklist completion and review-risk thresholds.
---

# Pair Done Gate

Apply deterministic readiness checks before commit and push.

## Inputs

- In-memory checklist snapshot derived from staged changes
- Review findings summary
- User decisions on unresolved review items
- Commit message guidance from `git-commit-message`

## Rules

1. Report unresolved high-severity review issues and their impact; do not block commit flow.
2. Return `ready-to-commit` only as an advisory status when gating criteria pass.
3. Return `ready-to-push` only as an advisory status after commit succeeds and pull/push preconditions pass.
4. Before recommending a commit, consult `git-commit-message` and use its suggested subject as the commit message.
5. If `git-commit-message` says not to add a body or trailer, preserve that instruction.
6. Ignore unstaged, untracked, and unrelated dirty-tree findings when deciding whether the staged work is ready.

## Output

Return:
- gate decision (`not-ready`, `ready-to-commit`, `ready-to-push`)
- blocking items list
- exact next command/action to clear the top blocker
- commit-message skill status and whether its no-trailer instruction was respected
