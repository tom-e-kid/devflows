---
name: feature-pr
description: Complete a feature branch. Creates PR (if remote exists) or merges locally (if no remote).
---

# feature-pr

Complete a feature branch by creating a Pull Request or merging locally.

## Prerequisites

Before running this skill:
- All steps in `plan.md` should be completed
- User review should be passed
- Build verification should be done via `/devflows:implementation-loop` (this skill does NOT run builds)

## Procedure

### 0. Determine Git Root

**IMPORTANT: Always resolve git root first to ensure .devflows is found at the repository root (monorepo support).**

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
```

All `.devflows/` paths below should be prefixed with `$GIT_ROOT/`.

### 1. Verify Completion

Check `$GIT_ROOT/.devflows/sessions/<current_branch>/plan.md`:
- All steps should be marked as completed
- If not → Report and ask user how to proceed

### 2. PR-Level Review (Deep)

Run comprehensive review before creating PR. Use the `review` skill at PR level:

**Checklist:**
- [ ] All loop-level items
- [ ] Security review (platform-specific)
- [ ] Performance implications considered
- [ ] Breaking changes identified and documented
- [ ] Edge cases handled
- [ ] Error messages are helpful (not exposing internals)

**Platform-specific (iOS):**
- [ ] Info.plist doesn't expose sensitive config
- [ ] Keychain used for sensitive storage (not UserDefaults)
- [ ] No private API usage

**Platform-specific (Web):**
- [ ] Environment variables properly separated (server vs client)
- [ ] Authentication tokens handled securely
- [ ] No SQL/NoSQL injection vectors
- [ ] Dependencies don't have known vulnerabilities

**If issues found:**

1. Record in `$GIT_ROOT/.devflows/sessions/<branch>/issues.md` (append)
2. Report to user - **NEVER auto-fix**
3. Wait for user decision before proceeding

**Blocking rules:**
- High severity open → Cannot create PR (must fix or user override)
- Medium/Low open → Can proceed if user approves (document in PR)

**Check issues.md summary before proceeding:**
```
Open: X | Fixed: Y | Won't fix: Z
```

### 3. Format Before Commit (REQUIRED for Web)

**Web projects**: Run format command before committing.

```bash
# Check CLAUDE.md for the specific command
# Example: bun run format
source $GIT_ROOT/.devflows/build/config.sh 2>/dev/null && eval "$FORMAT_CMD" || true
```

### 4. Create Commit

Stage and commit all changes:

```bash
git add <specific files>
git commit -m "$(cat <<'EOF'
<title>

<description of changes>
EOF
)"
```

Commit message guidelines:
- Follow project conventions (check CLAUDE.md for language preference)
- Title should be concise (50 chars or less)
- Body explains what and why
- Do NOT include Co-Authored-By (check CLAUDE.md for attribution settings)

### 5. Check Remote Repository

```bash
git remote -v
```

- **Has remote** → Continue to Step 6 (Push Branch)
- **No remote** → Go to Step 5a (Local Merge)

### 5a. Local Merge (No Remote)

When no remote repository is configured, merge locally instead of creating a PR.

#### Confirm with User

```
## Local Merge: <branch_name>

No remote repository configured. Will merge locally:

1. Switch to `<base_branch>`
2. Merge `<branch_name>`
3. Delete feature branch
4. Delete `$GIT_ROOT/.devflows/sessions/<branch_name>/`

Proceed?
```

#### Execute Merge

```bash
# Switch to base branch
git checkout <base_branch>

# Merge feature branch
git merge <branch_name>

# Delete feature branch
git branch -d <branch_name>

# Delete feature documentation
rm -rf $GIT_ROOT/.devflows/sessions/<branch_name>/
```

#### Handle Merge Conflicts

If merge fails due to conflicts:
1. Report conflicting files
2. Ask user to resolve manually
3. After resolution: `git add <files>` + `git commit`
4. Then continue with branch cleanup

#### Handle Branch Deletion Failure

If `git branch -d` fails (branch not fully merged):
1. Report the warning
2. Ask user if they want to force delete with `git branch -D`

#### Report Completion (Local Merge)

```
## Merge Complete

- Merged: `<branch_name>` → `<base_branch>`
- Deleted branch: `<branch_name>`
- Deleted: `$GIT_ROOT/.devflows/sessions/<branch_name>/`

Ready for next feature!
```

**END** (do not continue to Step 6)

---

### 6. Push Branch

```bash
git push -u origin <branch_name>
```

### 7. Create Pull Request

#### Template Selection

1. Check if `$GIT_ROOT/.devflows/pr/template.md` exists
2. If exists → Follow its format and rules
3. If not exists → Use default format below

#### Default Format

```markdown
## Summary
<Summarize the goal from requirements.md>

## Changes
<Summarize the steps from plan.md>

## Testing
- [ ] Build verification (Latest OS)
- [ ] Build verification (Minimum OS)

## Notes
<Important decisions from notes.md>
```

#### Create PR Command

```bash
gh pr create --base <base_branch> --title "<title>" --body "$(cat <<'EOF'
<PR body content based on template>
EOF
)"
```

### 8. Report Completion

Report to user:
- PR URL
- Summary of changes
- Reminder about `$GIT_ROOT/.devflows/sessions/<branch_name>/` cleanup (separate instruction)

## Flow Overview

```
┌─────────────────┐
│  Create Commit  │
└────────┬────────┘
         │
┌────────▼────────┐
│  Check Remote   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
no remote   has remote
    │         │
    ▼         ▼
┌────────┐  ┌────────────┐
│ Local  │  │ Push Branch│
│ Merge  │  └─────┬──────┘
└───┬────┘        │
    │       ┌─────▼──────┐
    │       │ Create PR  │
    │       └─────┬──────┘
    │             │
    ▼             ▼
┌─────────────────────┐
│  Report Completion  │
└─────────────────────┘
```

## Notes

- Base branch is recorded in `requirements.md`
- Follow project conventions for PR language (check CLAUDE.md or $GIT_ROOT/.devflows/pr/template.md)
- Write clearly so beginners can understand
- For PR flow: Do NOT automatically delete `$GIT_ROOT/.devflows/sessions/<branch_name>/` - wait for user instruction
- For local merge flow: Session cleanup is included in the flow
- Build verification is handled by `/devflows:implementation-loop`, not this skill
