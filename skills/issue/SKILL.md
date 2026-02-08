---
name: issue
description: Create a GitHub Issue from the current discussion
---

# issue

Create a GitHub Issue from the current conversation context.

## What This Skill Does

1. Extracts a title and description from the current conversation
2. Lets the user choose an issue type (label)
3. Resolves issue body template (if customized)
4. Creates the issue via `gh issue create`
5. Reports the issue URL

## Prerequisites

- `gh` CLI installed and authenticated
- Current directory is inside a GitHub repository

## Procedure

### 0. Determine Git Root

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
```

### 1. Extract Issue Content

From the current conversation, extract:

- **Title**: A concise, actionable title for the issue
- **Description**: A clear description including context, motivation, and any relevant details from the discussion

### 2. Ask User for Issue Type

Use AskUserQuestion to let the user select a type:

| Type | Description |
|------|-------------|
| `idea` | A new feature idea or concept to explore |
| `bug` | Something that's broken or not working as expected |
| `refactor` | Code improvement without changing behavior |
| `improvement` | Enhancement to an existing feature |

### 3. Resolve Template

#### Template Selection

1. Check if `$GIT_ROOT/.devflows/templates/issue.md` exists
2. If exists → use the section matching the selected type as the body format
3. If not exists → use default formats below

#### Using a Template

The template file contains sections headed by type name (e.g., `## idea`, `## bug`).
Find the section matching the selected type and use its subsections as the body format.
Fill in placeholders from the extracted conversation content.

#### Default Formats (No Template)

For **idea**:
```markdown
## Summary
<description>

## Context
<relevant context from discussion>
```

For **bug**:
```markdown
## Description
<what's happening>

## Expected Behavior
<what should happen>

## Steps to Reproduce
<if available from discussion>
```

For **refactor** / **improvement**:
```markdown
## Summary
<description>

## Motivation
<why this change is needed>
```

### 4. Ensure Label Exists

Create the label if it doesn't already exist (ignore errors if it does):

```bash
gh label create "<type>" --force
```

### 5. Create the Issue

```bash
gh issue create --title "<title>" --body "<body>" --label "<type>"
```

### 6. Confirm

Display:

```
Issue created: <issue URL>

To list open issues: /devflows:issues
```

---

## Notes

- Issues are meant to be quick captures — keep the description focused
- The user can later browse issues with `/devflows:issues`
- Labels are created with `--force` so it's safe to run repeatedly
- Customize issue format by creating `$GIT_ROOT/.devflows/templates/issue.md` (run `/devflows:init` to scaffold)
