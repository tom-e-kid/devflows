---
name: feature-cleanup
description: Clean up after a merged PR. Deletes feature documentation and local branch, switches to base branch.
---

# feature-cleanup

Clean up after a PR has been merged.

## Prerequisites

- PR should be merged (skill will verify)
- Working tree should be clean (no uncommitted changes)

## Procedure

### 1. Verify PR is Merged

```bash
gh pr list --head <branch_name> --state merged --json number,url
```

- If not merged → Report and abort
- If merged → Continue

### 2. Get Base Branch

Read `docs/sessions/<branch_name>/requirements.md` to find the base branch.

### 3. Confirm with User

```
## Cleanup: <branch_name>

PR has been merged. Ready to clean up:

1. Delete `docs/sessions/<branch_name>/`
2. Switch to `<base_branch>`
3. Delete local branch `<branch_name>`

Proceed?
```

### 4. Execute Cleanup

**Only delete `docs/sessions/<branch_name>/`. Do NOT delete or discard any other files.**

```bash
# Delete feature documentation (ONLY this directory)
rm -rf docs/sessions/<branch_name>/

# Switch to base branch
git checkout <base_branch>
git pull origin <base_branch>

# Delete local feature branch
git branch -d <branch_name>
```

### 5. Report Completion

```
## Cleanup Complete

- Deleted: `docs/sessions/<branch_name>/`
- Switched to: `<base_branch>`
- Deleted local branch: `<branch_name>`

Ready for next feature!
```

## Edge Cases

### Uncommitted Changes

If there are uncommitted changes:
1. Report what files are modified
2. **IMPORTANT**: Only `docs/sessions/<branch_name>/` is a cleanup target. Other files (CLAUDE.md, source code, etc.) are NOT cleanup targets and should NOT be discarded.
3. Ask user how to proceed:
   - Stash changes (for non-feature-docs changes)
   - Abort cleanup (recommended if unsure)

### Branch Not Fully Merged

If `git branch -d` fails (branch not fully merged):
1. Report the warning
2. Ask user if they want to force delete with `git branch -D`

### Remote Branch Still Exists

After cleanup, the remote branch may still exist. Inform user:
```
Note: Remote branch `origin/<branch_name>` still exists.
Delete manually with: git push origin --delete <branch_name>
```

## Notes

- Always verify PR is merged before cleanup
- Never force delete without user confirmation
- Keep the remote branch deletion manual (safety)
