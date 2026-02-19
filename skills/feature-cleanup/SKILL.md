---
name: feature-cleanup
description: Clean up sessions from .devflows/sessions/. Shows status report (PR state, progress) and confirms before deleting session files and local branch.
---

# feature-cleanup

Clean up completed or abandoned sessions by selecting from the session list.

## Prerequisites

- Working tree should be clean (no uncommitted changes)

## Procedure

### 0. Resolve Git Root

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
```

All `.devflows/` paths below should be prefixed with `$GIT_ROOT/`.

### 1. List Sessions

Scan `$GIT_ROOT/.devflows/sessions/` for subdirectories.

```bash
ls -1 $GIT_ROOT/.devflows/sessions/
```

- If **no sessions found** → report "No sessions to clean up." and stop.
- If **one or more found** → display the list and ask user which session to clean up using `AskUserQuestion`.

### 2. Gather Status for Selected Session

For the chosen session `<session_name>`, first read the actual branch name:

```bash
BRANCH_NAME=$(cat $GIT_ROOT/.devflows/sessions/<session_name>/.branch 2>/dev/null || echo "<session_name>")
```

If `.branch` file doesn't exist (older sessions), fall back to using the directory name as the branch name.

Gather the following information. Each check may fail (missing files, missing branch, no remote) — that's fine. Record what you can and mark the rest as unknown/absent.

#### a) Session files

- Check if `$GIT_ROOT/.devflows/sessions/<session_name>/` exists
- If exists, read `plan.md` → extract **Goal** and **Base Branch**
- Read `tasks.md` → count completed vs total tasks from the Tasks table

#### b) PR status

Use the actual branch name (from `.branch` file) for git and GitHub operations:

```bash
gh pr list --head $BRANCH_NAME --state all --json number,url,state,mergedAt
```

Determine one of:
- **No PR** — no results returned
- **Open** — state is OPEN (include PR number and URL)
- **Merged** — state is MERGED (include PR number)
- **Closed** — state is CLOSED without merge (include PR number)

If `gh` is not available or no remote exists, skip and note "PR status: unknown (no remote or gh CLI)".

#### c) Local branch

```bash
git branch --list "$BRANCH_NAME"
```

- **Exists** — branch is present locally
- **Already deleted** — branch not found

If the branch exists and a base branch is known, check for unmerged local changes:

```bash
git log --oneline <base_branch>..$BRANCH_NAME
```

Report the number of commits that haven't been merged into the base branch (0 = clean, N = has unmerged work).

#### d) Remote branch

Check if the remote tracking branch still exists (read-only):

```bash
git branch -r --list "origin/$BRANCH_NAME"
```

- **Exists** — remote branch is still present
- **Not found** — already deleted or never pushed

### 3. Report Status & Confirm

Present the status report (use actual branch name from `.branch` file):

```
## Session: <actual_branch_name>

- Goal: <from plan.md, or "unknown">
- Base branch: <from plan.md, or "unknown">
- Progress: <X/Y tasks completed, or "unknown">
- PR: <not created / open #N (URL) / merged #N / closed #N / unknown>
- Local branch: <exists / already deleted>
- Unmerged commits: <N commits ahead of base / clean / N/A>
- Remote branch: <exists on origin / not found>
- Session files: <exist / already deleted>
```

Then ask user to confirm cleanup using `AskUserQuestion`:

```
Proceed with cleanup?
- Yes
- No (abort)
```

### 4. Execute Cleanup

Only operate on what actually exists. Track what was done for the final report.

**Step 1: Delete session files**

If `$GIT_ROOT/.devflows/sessions/<session_name>/` exists:

```bash
rm -rf $GIT_ROOT/.devflows/sessions/<session_name>/
```

**Step 2: Switch branch (if needed)**

If currently on `$BRANCH_NAME`:
- If base branch is known → `git checkout <base_branch>`
- If base branch is unknown → ask user which branch to switch to using `AskUserQuestion`

**Step 3: Delete local branch**

If the local branch exists:

```bash
git branch -d "$BRANCH_NAME"
```

If this fails (branch not fully merged):
1. Report the warning
2. Ask user if they want to force delete with `git branch -D "$BRANCH_NAME"`

### 5. Report Completion

Report exactly what was done:

```
## Cleanup Complete

- Session files: <deleted / already absent> (.devflows/sessions/<session_name>/)
- Local branch: <deleted / force deleted / already absent> (<actual_branch_name>)
- Switched to: <base_branch>
```

## Edge Cases

### No Sessions

If `.devflows/sessions/` is empty or doesn't exist, report and stop. Nothing to clean up.

### Session Files Missing

If the session directory for the selected branch doesn't exist but the branch name was listed (race condition or manual deletion), skip file deletion and note "already absent" in the report. Continue with branch cleanup.

### plan.md Missing

If `plan.md` doesn't exist within the session directory, report base branch as "unknown". When it's time to switch branches, ask user which branch to switch to.

### Local Branch Already Deleted

Skip branch deletion. Report "already absent".

### Currently on Target Branch

Must switch to another branch before deleting. Use base branch from `plan.md`, or ask user.

### Uncommitted Changes

If there are uncommitted changes in the working tree:
1. Report what files are modified
2. **IMPORTANT**: Only `.devflows/sessions/<session_name>/` is a cleanup target. Other files are NOT cleanup targets and should NOT be discarded.
3. Ask user how to proceed:
   - Stash changes
   - Abort cleanup (recommended if unsure)

### Branch Not Fully Merged

If `git branch -d` fails:
1. Report the warning — this means there are commits on the branch that haven't been merged
2. Ask user if they want to force delete with `git branch -D`

## Notes

- Session list (`.devflows/sessions/`) is the source of truth, not the current branch
- Always show status report before cleanup so user can make an informed decision
- Never force-delete without explicit user confirmation
- **This skill NEVER modifies remote state** — no `git push`, no remote branch deletion, no remote operations of any kind. PR status check via `gh` is read-only and acceptable.
- Handle partial state gracefully — some artifacts may already be gone
