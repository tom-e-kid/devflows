---
name: feature-continue
description: Resume work on an existing feature. Auto-detects when session directory exists. Reads saved state and continues from last progress.
---

# feature-continue

Resume work on an existing feature.

## Auto-detection

This skill can be triggered automatically on session start when:
- Current branch has a session directory in `.devflows/sessions/` at git root (branch name with `/` replaced by `-`)

## Procedure

### 0. Determine Git Root

**IMPORTANT: Always resolve git root first to ensure .devflows is found at the repository root (monorepo support).**

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
BRANCH=$(git branch --show-current)
SESSION_NAME="${BRANCH//\//-}"
SESSION_DIR="$GIT_ROOT/.devflows/sessions/$SESSION_NAME"
```

All `.devflows/` paths below should be prefixed with `$GIT_ROOT/`.

### 1. Gather Context (Parallel)

**IMPORTANT: Run PR check and file reads in parallel using subagents for efficiency.**

Use Task tool to spawn 4 subagents **in a single message** (parallel execution):

| Agent | Type | Task |
|-------|------|------|
| 1 | Bash | `gh pr list --head $BRANCH --state all --json number,state,reviewDecision,url` |
| 2 | Bash | `cat $SESSION_DIR/plan.md` |
| 3 | Bash | `cat $SESSION_DIR/tasks.md` |
| 4 | Bash | `cat $SESSION_DIR/build_baseline.log` |

Wait for all agents to complete, then process results.

### 2. Evaluate PR Status

Based on Agent 1 result:

| PR State | Action |
|----------|--------|
| No PR | Continue to step 3 |
| open (pending review) | Report "PR pending review", ask if user wants to continue work |
| open (approved) | Report "PR approved, ready to merge" |
| merged | Report "PR merged", offer to cleanup `.devflows/sessions/$SESSION_NAME/` |
| closed | Report and discuss with user |

If PR is merged, skip to cleanup flow instead of resuming development.

### 3. Summarize Status to User

Use Agents 2-4 results to understand the feature:

Report:
- What the feature is about (from `plan.md` Goal)
- What tasks are completed (from `tasks.md`)
- What task is next
- Any important context (from `plan.md` Context section)

Example:
```
## Resuming: <branch_name>

**Goal**: <from plan.md>

**Progress**: 3/5 tasks completed
- ✅ Task 1: ...
- ✅ Task 2: ...
- ✅ Task 3: ...
- ⬜ Task 4: ... (next)
- ⬜ Task 5: ...

**Context**: <key decisions from plan.md>

Continue with Task 4?
```

### 4. Verify Build State

Run build to ensure current state is valid:

```bash
source $GIT_ROOT/.devflows/build/config.sh
$BUILD_CMD_LATEST
```

- If build fails → Report and investigate
- Compare warnings with `build_baseline.log`
- If warnings increased → Report to user

### 5. Continue Work

After user confirms, resume using `/devflows:implementation-loop`.

---

## Edge Cases

### Uncommitted Changes Exist

If there are uncommitted changes:
1. Report what files are modified
2. Ask user how to proceed:
   - Continue with changes
   - Stash changes
   - Discard changes

### Plan Needs Revision

If user wants to modify the plan:
1. Discuss changes
2. Update `plan.md` and `tasks.md`
3. Proceed with revised plan

## Notes

- Always read ALL session files before starting
- Keep `tasks.md` updated with progress
- Document any new decisions in `plan.md` Context section
- Each task must result in a successful clean build
