---
name: read-ado-user-story
description: Read the Description and Acceptance Criteria for an Azure DevOps user story from its work item ID. Use when the user asks for story details, requirements, or acceptance criteria from Azure DevOps.
---

# Read Azure DevOps User Story Details

Read the **Description** and **Acceptance Criteria** for an Azure DevOps user story from its work item ID.

## When to use

Use this skill when the user asks to:

- read a user story description
- read acceptance criteria
- summarise work item details from Azure DevOps

## Prerequisites

- Azure CLI (`az`) must be installed.
- The `azure-devops` extension must be available.
- The CLI must be authenticated to the `Marken-Maestro` Azure DevOps organisation.

## How to execute

Set the default organisation and project if they are not already configured:

```powershell
az devops configure -d organization=https://dev.azure.com/Marken-Maestro project=Maestro
```

Fetch the work item using the user story number:

```powershell
az boards work-item show --id <USER_STORY_ID> --expand fields --output json
```

Read these fields from the response:

- `System.Title`
- `System.Description`
- `Microsoft.VSTS.Common.AcceptanceCriteria`

## Output guidance

- Show the story number and title first.
- Present the description and acceptance criteria separately.
- Preserve the original HTML if the user wants the raw content.
- If the user wants readable text, strip the HTML tags before presenting it.

## Notes

- Do **not** combine `--fields` with `--expand fields`.
- If the work item cannot be found, report that the ID may be invalid or inaccessible.
- This skill is for Azure DevOps user stories, but it can be used with other work item IDs if the same fields exist.
