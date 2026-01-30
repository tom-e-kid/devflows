---
name: feature-status
description: Check the current status of a feature branch - whether PR exists, is pending review, approved, or merged.
---

# feature-status

Check the current status of a feature branch and determine next actions.

## Behavior

1. Get current branch name
2. Check if `.devflows/sessions/<branch>/` exists
3. Check PR status using `gh` command
4. Report status and suggest next action

## Status Detection

### Step 1: Check for existing PR

```bash
gh pr list --head <branch_name> --state all --json number,state,reviewDecision,mergeable,url
```

### Step 2: Determine status

| PR State | Review Decision | Status | Suggested Action |
|----------|-----------------|--------|------------------|
| No PR found | - | **Work in progress** | Continue development or run `/devflows:pr` |
| open | REVIEW_REQUIRED | **PR pending review** | Wait for reviewer |
| open | CHANGES_REQUESTED | **Changes requested** | Address review comments |
| open | APPROVED | **PR approved** | Ready to merge |
| merged | - | **PR merged** | Cleanup available |
| closed | - | **PR closed** | Discuss with user |

### Step 3: Report to user

Format:
```
## Feature Status: <branch_name>

**Status**: <status>
**PR**: <url or "Not created">
**Review**: <review status>

### Suggested Action
<what to do next>

### Cleanup
<if merged: remind about .devflows/sessions/<branch>/ deletion>
```

## Integration with feature-continue

When `feature-continue` detects `.devflows/sessions/<branch>/` exists:
1. First run feature-status check
2. If PR merged → Ask user if they want to cleanup
3. If PR pending/approved → Report status, ask if they want to continue work
4. If no PR → Resume normal development flow

## Example Output

```
## Feature Status: feature/add-dark-mode

**Status**: PR approved
**PR**: https://github.com/org/repo/pull/123
**Review**: Approved by @reviewer

### Suggested Action
PR is ready to merge. After merging, run `/devflows:feature-status` again to cleanup.
```

```
## Feature Status: feature/fix-login-bug

**Status**: PR merged
**PR**: https://github.com/org/repo/pull/456

### Suggested Action
PR has been merged. You can delete the feature documentation:
- `.devflows/sessions/feature-fix-login-bug/`

Would you like me to delete these files?
```

## Notes

- Requires `gh` CLI to be authenticated
- Works with GitHub only (not GitLab, Bitbucket, etc.)
- Does not automatically delete files - always asks user first
