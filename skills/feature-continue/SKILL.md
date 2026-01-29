---
name: feature-continue
description: Resume work on an existing feature. Auto-detects when docs/sessions/<branch>/ exists. Reads saved state and continues from last progress.
---

# feature-continue

Resume work on an existing feature.

## Auto-detection

This skill can be triggered automatically on session start when:
- Current branch has `docs/sessions/<current_branch>/` directory

## Procedure

### 1. Check PR Status First

Before resuming work, check if a PR already exists:

```bash
gh pr list --head <branch_name> --state all --json number,state,reviewDecision,url
```

| PR State | Action |
|----------|--------|
| No PR | Continue to step 2 |
| open (pending review) | Report "PR pending review", ask if user wants to continue work |
| open (approved) | Report "PR approved, ready to merge" |
| merged | Report "PR merged", offer to cleanup `docs/sessions/<branch>/` |
| closed | Report and discuss with user |

If PR is merged, skip to cleanup flow instead of resuming development.

### 2. Read Feature Documentation

Read all files in `docs/sessions/<current_branch>/`:
- `requirements.md` - Understand the goal
- `notes.md` - Review context and decisions
- `plan.md` - Check current progress
- `build_baseline.log` - Get baseline warning count

### 3. Summarize Status to User

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
source docs/build/config.sh
$BUILD_CMD_LATEST
```

- If build fails → Report and investigate
- Compare warnings with `build_baseline.log`
- If warnings increased → Report to user

### 5. Continue Work

After user confirms, resume using `/implementation-loop`.

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
