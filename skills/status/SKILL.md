---
name: status
description: Show current implementation progress
---

# status

Show the current progress of the feature implementation.

## What This Skill Does

1. Reads the current session's `tasks.md` for progress and `plan.md` for summary
2. Displays progress (completed/total tasks)
3. Lists pending tasks

## Procedure

### 1. Determine Git Root and Branch

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
BRANCH=$(git branch --show-current)
```

### 2. Check for Session

```bash
SESSION_DIR="$GIT_ROOT/.devflows/sessions/$BRANCH"
```

If session directory doesn't exist, display:

```
No active session for branch: <branch>

To start a new feature, run /devflows:start or describe what you want to implement.
```

And stop.

### 3. Read Session Files

Read `$SESSION_DIR/tasks.md` for progress and `$SESSION_DIR/plan.md` for goal/summary.

### 4. Display Progress

```
## Feature Status: <branch>

**Goal**: <from plan.md>

**Progress**: <completed>/<total> tasks

### Completed
- ✅ Task 1: <description>
- ✅ Task 2: <description>

### Pending
- ⬜ Task 3: <description> ← Next
- ⬜ Task 4: <description>
```

### 5. Offer Actions

```
What would you like to do?
- Continue implementation (run /devflows:resume)
- View full plan details
- Check build status
```

---

## Notes

- This is a quick status check, not a full resume
- Use `/devflows:resume` to actually continue work
- Progress is determined by task status in tasks.md (completed vs pending)
