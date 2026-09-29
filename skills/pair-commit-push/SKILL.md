---
name: pair-commit-push
description: Run staged commit readiness, interactive risk review, commit, pull, and push without persisting requirement or coverage state. Use for commit, push, or ready-for-merge requests handled by the pair-programmer agent.
---

# Pair Commit Push

Run the transient commit, push, and merge-readiness workflow for the pair-programmer.

## Inputs

- Current in-memory checklist snapshot
- Current branch
- User request: readiness only, commit, pull, push, or the complete sequence
- `pair-programmer-coverage-mapper`
- `pair-programmer-risk-reviewer`
- `pair-gap-analyser`
- `pair-done-gate`
- `git-commit-message`

## State machine

`CommitReadinessGate -> FocusedValidation -> Commit -> Pull -> Push -> Idle`

Skip mutation states that the user did not request. Ready-for-merge stops after `FocusedValidation`.

### CommitReadinessGate

- **Input:** staged index only
- **Action:** inspect `git diff --cached` and `git diff --cached --name-only`; run the coverage mapper and risk reviewer in parallel
- **Output:** readiness verdict, coverage reconciliation, and risk findings
- **Exit:** `FocusedValidation`, `Blocked`, or `Idle` with a not-ready result

### FocusedValidation

- **Input:** staged diff, checklist snapshot, coverage reconciliation, and risk findings
- **Action:** run `pair-gap-analyser`, then run `pair-done-gate` when reconciliation is `clean` or `branch-changed`
- **Output:** merged readiness decision and reviewer guidance
- **Exit:** `Commit`, `Blocked`, `AwaitingUserInput`, or `Idle` for readiness-only requests

### Commit

- **Input:** approved staged changes and user-approved commit message
- **Action:** call `git-commit-message` and create the commit
- **Output:** successful commit result
- **Exit:** `Pull`, `Push`, `Idle`, or `Blocked`, according to the user request

### Pull

- **Input:** successful commit result and current branch state
- **Action:** stash non-staged work if needed, then run `git pull` or `git pull --rebase` when requested
- **Output:** updated branch state and optional stash reference
- **Exit:** `Push`, `Idle`, or `Blocked`

### Push

- **Input:** committed and pulled branch state
- **Action:** push the branch to the remote
- **Output:** push result
- **Exit:** `Idle` or `Blocked`

### Idle

- **Input:** completed requested workflow
- **Action:** return the outcome without persisting requirement or coverage state
- **Output:** stable end state

## Execution rules

1. Treat the requested states as one uninterrupted sequence and hold all workflow state in memory.
2. If interrupted, restart from `CommitReadinessGate` next time.
3. Build readiness from the staged index only, using:
   - `git diff --cached`
   - `git diff --cached --name-only`
4. Do not inspect `git status`, unstaged files, or untracked files for commit readiness.
5. Run these independent analyses in parallel:
   - `pair-programmer-coverage-mapper` with:
     - `analysis_scope=staged_index`
     - `baseline_ref=origin/develop`
     - `diff_patch_command=git diff --cached`
     - `diff_names_command=git diff --cached --name-only`
   - `pair-programmer-risk-reviewer`
6. If either analysis is unavailable, fails, or returns unusable output, return:
   - gate decision: `not-ready`
   - blocker: `workflow-blocked`
   - exact action required to restore the missing result
7. Do not run `pair-gap-analyser` or `pair-done-gate` when analysis is blocked.
8. Pass `reconciliation_status`, `current_branch_commit_count`, `recorded_branch_commit_count`, and
   `reassessment_required` to `pair-gap-analyser`.
9. A changed branch commit count is informational:
   - report that persisted branch coverage is stale
   - use staged evidence in memory
   - do not block readiness, commit, or push
   - do not update persisted coverage
10. Run `pair-done-gate` when reconciliation is `clean` or `branch-changed`.
11. Show the updated in-memory checklist and review counts.
12. Treat gating output as advisory; the user decides whether to proceed.
13. Unstaged, untracked, and unrelated dirty-tree files must not block a staged commit.

## Interactive risk review

When the risk reviewer returns findings:

1. Present its findings table.
2. Ask whether the user wants to step through the findings individually.
3. If declined, treat all findings as acknowledged.
4. If accepted, present each finding's title, description, impacted requirements, and suggested fix.
5. Ask the user to choose **Apply fix**, **Fix it myself**, or **Ignore**.
6. Apply the selected action before moving to the next finding.
7. Summarise how many findings were applied, self-fixed, or ignored.

Only show findings returned by `pair-programmer-risk-reviewer`. Uncovered requirements are not code-review findings.

## Git mutation rules

1. Before committing, call `git-commit-message` and obtain user approval for the message.
2. Retain only whether the commit succeeded. Do not record its identifier or coverage.
3. Before pull, stash non-staged work if needed and remember whether a stash was created.
4. If pull fails, restore the stash and stop.
5. If push fails, restore the stash and stop.
6. Restore the stash after the workflow finishes, whether it succeeds or fails.
7. After a successful push, explicitly offer to run `git-rebase-develop`.
8. Do not auto-push after a rebase.

## Persistence boundary

Never update:

- the requirements checklist file
- `## Coverage Snapshot`
- requirement statuses
- `Recorded Commit Count`
- commit coverage
- any workflow state file

Requirement and coverage persistence belongs exclusively to pair-programmer session start and show-checklist flows.

## Output

Return:

- requested workflow outcome
- advisory gate decision
- risk review summary
- validation performed
- Git mutation results for requested mutation states
- exact blocker and recovery action when blocked
