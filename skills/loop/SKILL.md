---
name: loop
description: Smart implementation entry point. Picks up from current session state with graceful degradation — always usable regardless of session completeness.
---

# loop

Smart entry point for implementation. Detects session state and proceeds accordingly — always usable.

## What This Skill Does

1. Detects current session state (session exists? plan exists? tasks exist?)
2. Picks the right mode based on what's available
3. Hands off to implementation-loop when ready

## Procedure

### 0. Resolve Git Root and Session

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
BRANCH=$(git branch --show-current)
SESSION_DIR="$GIT_ROOT/.devflows/sessions/$BRANCH"
```

### 1. Detect State

Check what exists:

```
HAS_SESSION  = $SESSION_DIR directory exists
HAS_PLAN     = $SESSION_DIR/plan.md exists AND has content beyond placeholders
HAS_TASKS    = $SESSION_DIR/tasks.md exists AND has a task table (| # | pattern)
```

### 2. Select Mode

| HAS_SESSION | HAS_TASKS | HAS_PLAN | Mode |
|-------------|-----------|----------|------|
| yes | yes | - | **A**: Pick up from current task |
| yes | no | yes | **B**: Propose tasks from plan |
| yes | no | no | **C**: Ask user for direction |
| no | - | - | **D**: No session |

### 3. Execute Mode

#### Mode A: Session + Tasks (full context)

Read `$SESSION_DIR/tasks.md` and find the next pending task.

If all tasks are completed:
```
All tasks completed! Ready for `/devflows:pr`.
```
Stop.

If there's a next pending task:
1. Show brief status: "Picking up Task N: <description>"
2. Read `$SESSION_DIR/plan.md` for context
3. Proceed to `/devflows:implementation-loop`

#### Mode B: Session + Plan, No Tasks

Read `$SESSION_DIR/plan.md` for the approach.

1. Propose a task breakdown based on the plan's Approach section
2. Ask user to confirm or adjust the tasks
3. Write confirmed tasks to `$SESSION_DIR/tasks.md`:
```markdown
# Tasks

| # | Task | Status |
|---|------|--------|
| 1 | <task> | pending |
| 2 | <task> | pending |

## Log
- <date>: Tasks created from plan
```
4. Proceed to `/devflows:implementation-loop`

#### Mode C: Session, No Plan

The session directory exists but has no meaningful plan or tasks.

1. Ask user: "What would you like to work on?"
2. Based on response:
   - If user describes work → capture it with `/devflows:memo`, then re-run `/devflows:loop`
   - If user has a plan in mind → suggest using plan mode first, or `/devflows:memo`

#### Mode D: No Session

No session directory exists for the current branch.

Ask user:
```
No session found for branch: <branch>

- Start a session → /devflows:start
- Work without a session → I can help directly (no tracking)
```

If user chooses to work without a session, just help them directly — don't force the workflow.

---

## Notes

- This skill is the recommended way to start implementing — it handles all states gracefully
- Never blocks the user — always offers a path forward
- Pairs with `/devflows:memo` for context capture
- Does NOT create sessions or branches — use `/devflows:start` for that
