---
name: feature-pr
description: Create a Pull Request for the completed feature. Commits changes and creates PR with proper template.
---

# feature-pr

Create a Pull Request for the completed feature.

## Prerequisites

Before running this skill:
- All steps in `plan.md` should be completed
- User review should be passed
- Build verification should be done via `/implementation-loop` (this skill does NOT run builds)

## Procedure

### 1. Verify Completion

Check `.devflows/sessions/<current_branch>/plan.md`:
- All steps should be marked as completed
- If not → Report and ask user how to proceed

### 2. Format Before Commit (REQUIRED for Web)

**Web projects**: Run format command before committing.

```bash
# Check CLAUDE.md for the specific command
# Example: bun run format
source .devflows/build/config.sh 2>/dev/null && eval "$FORMAT_CMD" || true
```

### 3. Create Commit

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

### 4. Push Branch

```bash
git push -u origin <branch_name>
```

### 5. Create Pull Request

#### Template Selection

1. Check if `.devflows/pr/template.md` exists
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

### 6. Report Completion

Report to user:
- PR URL
- Summary of changes
- Reminder about `.devflows/sessions/<branch_name>/` cleanup (separate instruction)

## Notes

- Base branch is recorded in `requirements.md`
- Follow project conventions for PR language (check CLAUDE.md or .devflows/pr/template.md)
- Write clearly so beginners can understand
- Do NOT automatically delete `.devflows/sessions/<branch_name>/` - wait for user instruction
- Build verification is handled by `/implementation-loop`, not this skill
