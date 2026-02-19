---
name: resume
description: Resume work on an existing feature session. Auto-detects current branch session or lets user select from session list.
---

# resume

Resume work on an existing feature session.

## Modes

This skill operates in two modes depending on context:

- **Mode A (Auto-detected)**: Current branch has a session in `.devflows/sessions/` → skip selection, resume directly
- **Mode B (Session selection)**: Current branch has no session → list all sessions, let user pick, switch branch, then resume

## Procedure

### 0. Resolve Git Root

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
```

All `.devflows/` paths below should be prefixed with `$GIT_ROOT/`.

### 1. Check for Auto-Detected Session

```bash
CURRENT_BRANCH=$(git branch --show-current)
```

```bash
SESSION_NAME="${CURRENT_BRANCH//\//-}"
```

Check if `$GIT_ROOT/.devflows/sessions/$SESSION_NAME/` exists.

- If **exists** → Mode A. Skip to step 3.
- If **not exists** → Mode B. Continue to step 2.

### 2. List Sessions and Select (Mode B)

Scan `$GIT_ROOT/.devflows/sessions/` for subdirectories.

```bash
ls -1 $GIT_ROOT/.devflows/sessions/
```

- If **no sessions found** → report "No sessions to resume." and stop.
- If **one or more found** → gather brief info for each session, then ask user to select.

#### Gather Brief Info

For each session directory `<session_name>`:

**Branch name** — read from `.branch` file:
```bash
# Read actual branch name from .branch file
BRANCH_NAME=$(cat $GIT_ROOT/.devflows/sessions/<session_name>/.branch 2>/dev/null || echo "<session_name>")
```

If `.branch` file doesn't exist (older sessions), fall back to using the directory name as the branch name.

**Goal** — read from `plan.md`:
```bash
# Extract first non-empty line after ## Goal
```
If `plan.md` doesn't exist or has no goal, show "unknown".

**Progress** — read from `tasks.md`:
```bash
# Count completed vs total tasks from the Tasks table
```
If `tasks.md` doesn't exist, show "unknown".

#### Present List

Display sessions with their info (use the actual branch name from `.branch` file):

```
## Available Sessions

| # | Branch | Goal | Progress |
|---|--------|------|----------|
| 1 | feature/dark-mode | Add dark mode toggle | 3/5 tasks |
| 2 | feature/auth | Implement OAuth login | 0/4 tasks |
```

Ask user which session to resume using `AskUserQuestion`.

#### Switch to Selected Branch

After user selects a session, use the actual branch name (from `.branch` file) to switch:

```bash
git checkout <actual_branch_name>
```

If checkout fails (branch doesn't exist locally):

1. Check if remote branch exists:
   ```bash
   git branch -r --list origin/<selected_branch>
   ```
2. If remote exists:
   ```bash
   git checkout -b <selected_branch> origin/<selected_branch>
   ```
3. If remote doesn't exist either:
   - Report error: session files exist but the branch is gone
   - Suggest running `/devflows:cleanup` to remove the orphaned session
   - Stop

### 3. Run feature-continue

Execute `/devflows:feature-continue` to resume work on the now-current branch.

---

## Edge Cases

### No Sessions Exist

If `.devflows/sessions/` is empty or doesn't exist, report "No sessions to resume." and stop.

### Uncommitted Changes When Switching

If there are uncommitted changes and a branch switch is needed (Mode B):

1. Report what files are modified
2. Ask user how to proceed:
   - Stash changes and switch
   - Abort (stay on current branch)

### Branch Deleted But Session Exists

If the selected session's branch doesn't exist locally or remotely:
- Report the situation
- Suggest `/devflows:cleanup` to remove the orphaned session files
- Stop (don't try to resume without a branch)

### plan.md or tasks.md Missing

Show "unknown" for the missing info. The session can still be resumed — `feature-continue` will handle incomplete session files.

## Notes

- Session list (`.devflows/sessions/`) is the source of truth for available sessions
- Mode A is the fast path — no interaction needed, just resume
- Mode B handles the case where user is on a different branch (e.g., `main`) and wants to return to a session
- This skill delegates the actual resume work to `/devflows:feature-continue`
