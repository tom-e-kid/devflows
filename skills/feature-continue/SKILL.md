---
name: feature-continue
description: Resume work on an existing feature. Auto-detects when .devflows/sessions/<branch>/ exists. Reads saved state and continues from last progress.
---

# feature-continue

Resume work on an existing feature.

## Auto-detection

This skill can be triggered automatically on session start when:
- Current branch has `.devflows/sessions/<current_branch>/` directory

## Procedure

### 1. Gather Context (Parallel)

**IMPORTANT: Run PR check and file reads in parallel using subagents for efficiency.**

Use Task tool to spawn 5 subagents **in a single message** (parallel execution):

| Agent | Type | Task |
|-------|------|------|
| 1 | Bash | `gh pr list --head <branch_name> --state all --json number,state,reviewDecision,url` |
| 2 | Bash | `cat .devflows/sessions/<branch>/requirements.md` |
| 3 | Bash | `cat .devflows/sessions/<branch>/notes.md` |
| 4 | Bash | `cat .devflows/sessions/<branch>/plan.md` |
| 5 | Bash | `cat .devflows/sessions/<branch>/build_baseline.log` |

Wait for all agents to complete, then process results.

### 2. Evaluate PR Status

Based on Agent 1 result:

| PR State | Action |
|----------|--------|
| No PR | Continue to step 3 |
| open (pending review) | Report "PR pending review", ask if user wants to continue work |
| open (approved) | Report "PR approved, ready to merge" |
| merged | Report "PR merged", offer to cleanup `.devflows/sessions/<branch>/` |
| closed | Report and discuss with user |

If PR is merged, skip to cleanup flow instead of resuming development.

### 3. Summarize Status to User

Use Agents 2-5 results to understand the feature:

Report:
- What the feature is about
- What steps are completed
- What step is next
- Any blockers or questions noted

Example:
```
## Resuming: <branch_name>

**Goal**: <from requirements.md>

**Progress**: 3/5 steps completed
- ✅ Step 1: ...
- ✅ Step 2: ...
- ✅ Step 3: ...
- ⬜ Step 4: ... (next)
- ⬜ Step 5: ...

**Notes**: <any important context>

Continue with Step 4?
```

### 4. Verify Build State

Run build to ensure current state is valid:

```bash
source .devflows/build/config.sh
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
2. Update `plan.md` and `notes.md`
3. Proceed with revised plan

## Notes

- Always read ALL documentation files before starting
- Keep `plan.md` updated with progress
- Document any new decisions in `notes.md`
- Each step must result in a successful clean build
