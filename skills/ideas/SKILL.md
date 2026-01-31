---
name: ideas
description: List all saved ideas and optionally view details
---

# ideas

List and browse saved ideas.

## What This Skill Does

1. Lists all ideas in `.devflows/ideas/`
2. Lets user select an idea to view details
3. Optionally starts planning from a selected idea

## Procedure

### 1. Determine Git Root

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
```

### 2. Check for Ideas

```bash
ls -1 "$GIT_ROOT/.devflows/ideas/"*.md 2>/dev/null
```

If no ideas found, display:

```
No ideas saved yet.

To save an idea: /devflows:idea
```

And stop.

### 3. List Ideas

Display ideas in a numbered list:

```
## Saved Ideas

| # | Date | Title |
|---|------|-------|
| 1 | 2025-01-30 | Add dark mode support |
| 2 | 2025-01-28 | Refactor authentication |
| 3 | 2025-01-25 | Add export to PDF feature |

Enter a number to view details, or press Enter to cancel.
```

Extract date from filename (`YYYYMMDD` portion) and title from the file's `# Title` line.

### 4. Handle Selection

Use AskUserQuestion to let user select:

- Options: Numbers 1-N for each idea
- Include "Cancel" option

### 5. Show Selected Idea

Read the selected idea file and display its full content.

### 6. Offer Next Steps

After showing the idea, ask:

```
What would you like to do?
1. Start planning this feature (enters plan mode)
2. Delete this idea
3. Back to list
4. Done
```

If user chooses to start planning:
- Use the idea content as context
- Claude naturally enters plan mode to discuss implementation

---

## Notes

- Ideas are sorted by date (newest first)
- Deleted ideas are removed from filesystem
- Starting planning from an idea provides useful context for the discussion
