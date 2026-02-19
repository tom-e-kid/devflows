---
name: memo
description: Save conversation context to session files. Captures goals, decisions, approach, and tasks from the current discussion.
---

# memo

Save the current conversation context to session files. Safe to run multiple times — merges new content without overwriting existing data.

## What This Skill Does

1. Checks for an active session (offers to create the directory if missing)
2. Analyzes the conversation for goal, decisions, approach, and tasks
3. Writes/updates `plan.md` (merges, doesn't overwrite)
4. Writes/updates `tasks.md` if tasks are identified (preserves existing statuses)

## Procedure

### 0. Resolve Git Root and Session

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
BRANCH=$(git branch --show-current)
SESSION_NAME="${BRANCH//\//-}"
SESSION_DIR="$GIT_ROOT/.devflows/sessions/$SESSION_NAME"
```

### 1. Check Session Exists

If `$SESSION_DIR` does **not** exist:

1. Ask user: "No session directory for this branch. Create one?"
   - Yes → `mkdir -p $SESSION_DIR`
   - No → Stop

### 2. Analyze Conversation

Review the current conversation and extract:

| Element | Source | Required |
|---------|--------|----------|
| **Goal** | What the user wants to build/fix/change | Yes (ask if unclear) |
| **Context** | Key decisions, constraints, references, links | No |
| **Approach** | Architecture notes, strategy, design decisions | No |
| **Tasks** | Concrete implementation steps identified | No |

### 3. Update plan.md

Read existing `$SESSION_DIR/plan.md` if it exists.

**If plan.md exists** — merge new content:
- Update Goal only if the existing one is a placeholder ("No context yet" or empty)
- **Append** new context to the Context section (don't remove existing entries)
- **Append** new approach notes to the Approach section (don't remove existing notes)
- Preserve Base Branch

**If plan.md does not exist** — create it:
```markdown
# Plan

## Goal
<extracted goal>

## Base Branch
<current base branch, or "unknown">

## Context
<extracted decisions, constraints, references>

## Approach
<extracted architecture notes, strategy>
```

### 4. Update tasks.md (if tasks identified)

Read existing `$SESSION_DIR/tasks.md` if it exists.

**If tasks.md exists with a task table** — merge:
- Keep existing tasks and their statuses unchanged
- Append new tasks at the end of the table with `pending` status
- Preserve the Log section

**If tasks.md exists but has no task table** (placeholder text) — replace placeholder:
```markdown
# Tasks

| # | Task | Status |
|---|------|--------|
| 1 | <first task> | pending |
| 2 | <second task> | pending |

## Log
- <date>: Tasks captured via memo
```

**If tasks.md does not exist** — create it with tasks if available, or skip.

**If no tasks were identified** — skip tasks.md entirely. Don't create an empty table.

### 5. Report

```
## Memo Saved

**plan.md**: <created / updated>
**tasks.md**: <created / updated / skipped (no tasks identified)>

### What was captured
- Goal: <brief>
- Context: <N items added>
- Approach: <brief or "none">
- Tasks: <N tasks added / none identified>
```

---

## Notes

- Safe to run multiple times — each run appends new content, never overwrites
- Existing task statuses are always preserved
- If the conversation has no clear goal, ask the user before writing
- This skill does NOT start implementation — it only saves context
- Use `/devflows:loop` after memo to start implementing
