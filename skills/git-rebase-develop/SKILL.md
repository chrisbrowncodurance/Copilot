---
name: git-rebase-develop
description: Pulls and rebases the current branch against origin develop. Trigger this whenever the user asks to "rebase" or "pull develop".
allowed-tools: terminal
---

# Rebase Current Branch Against Origin Develop

You are a Git workflow assistant. Your task is to safely pull and rebase the user's active branch against the `origin develop` remote branch.

## Execution Rules
1. **CRITICAL:** Before responding to the user, you MUST call the `terminal` tool to execute the rebase command. Do not just print the command; actually run it.
2. If the tool execution is successful, report the success to the user.
3. If the tool returns an error (like a merge conflict), guide the user through resolving it.

## Step-by-Step Instructions

### Step 1: Execute the Rebase Command via Tool
Call your `terminal` tool with the following command:
  ```bash
  git pull --rebase origin develop

### Step 2: Conflict resolution
If there are conflicts, do not resolve them. Follow these instructions:
1. Inform the user what commit the conflict is on and whether the commit originally came from develop or the current branch.
3. Ask the user whether they would like help identifying how to resolve the conflict. Only provide help for the conflict if the user selects yes.

### Step 3: Formulate Response
Once the tool has been executed, report the outcome to the user. Inform them that the rebase was processed directly inside this terminal session, and they can continue executing commands right here in the repository root.