---
name: issues
description: List and manage GitHub Issues
---

# issues

List open GitHub Issues and take action on them.

## What This Skill Does

1. Lists open issues from the current repository
2. Lets user select an issue to view details
3. Offers next steps: plan, close, comment, or go back

## Prerequisites

- `gh` CLI installed and authenticated
- Current directory is inside a GitHub repository

## Procedure

### 1. List Open Issues

```bash
gh issue list --state open --limit 20
```

If no issues found, display:

```
No open issues.

To create an issue: /devflows:issue
```

And stop.

### 2. Display Issues

Format the output as a table:

```
## Open Issues

| # | Labels | Title |
|---|--------|-------|
| 42 | idea | Add dark mode support |
| 38 | bug | Login fails on Safari |
| 35 | improvement | Improve search performance |

Select an issue number to view details, or cancel.
```

### 3. Handle Selection

Use AskUserQuestion to let user select:

- Options: Issue numbers (show title alongside)
- Include "Cancel" option

### 4. Show Selected Issue

Fetch and display the full issue:

```bash
gh issue view <number>
```

Display the issue content in a readable format.

### 5. Offer Next Steps

Use AskUserQuestion to ask what to do:

| Option | Description |
|--------|-------------|
| Start planning | Use the issue content as context and enter plan mode |
| Close issue | Close the issue via `gh issue close <number>` |
| Add comment | Prompt for comment text, then `gh issue comment <number> --body "<text>"` |
| Back to list | Return to step 1 |

#### Start Planning

If the user chooses to start planning:
- Use the issue title and body as context for the planning discussion
- Enter plan mode naturally with the issue content as the starting point

#### Close Issue

```bash
gh issue close <number>
```

Confirm closure and return to the list.

#### Add Comment

Ask the user for comment text, then:

```bash
gh issue comment <number> --body "<text>"
```

Confirm the comment was added and return to the issue detail.

---

## Notes

- Issues are sorted by most recently updated (default `gh` behavior)
- This skill works with any GitHub Issues, not just ones created by `/devflows:issue`
- Starting planning from an issue provides useful context for the discussion
