---
name: idea
description: Save current discussion as an idea for later implementation
---

# idea

Save the current discussion as an idea for future reference.

## What This Skill Does

1. Extracts a title and summary from the current conversation
2. Saves the idea to `.devflows/ideas/<timestamp>-<slug>.md`
3. Confirms the idea was saved

## Procedure

### 1. Determine Git Root

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
```

### 2. Create Ideas Directory

```bash
mkdir -p "$GIT_ROOT/.devflows/ideas"
```

### 3. Extract Idea Content

From the current conversation, extract:

- **Title**: A concise title for the idea (used in filename slug)
- **Summary**: Brief description of what this idea is about
- **Details**: Key points, requirements, or context from the discussion

### 4. Generate Filename

Format: `<timestamp>-<slug>.md`

- Timestamp: `YYYYMMDD-HHMMSS` (e.g., `20250130-143052`)
- Slug: kebab-case from title (e.g., `add-dark-mode-support`)

Example: `20250130-143052-add-dark-mode-support.md`

### 5. Save Idea File

Create the file with this structure:

```markdown
# <Title>

## Summary
<Summary>

## Details
<Details from conversation>

## Context
- Created: <date>
- Discussion highlights: <key points>

## Next Steps (optional)
- <suggested next steps if any>
```

### 6. Confirm

Display:

```
Idea saved: .devflows/ideas/<filename>

To list all ideas: /devflows:ideas
```

---

## Notes

- Ideas are meant to be quick captures, not detailed specs
- The user can later retrieve ideas with `/devflows:ideas`
- Ideas can be used as starting points for plan mode discussions
