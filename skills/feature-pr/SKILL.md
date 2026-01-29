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

1. Record in `.devflows/sessions/<branch>/issues.md` (append)
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
source .devflows/build/config.sh 2>/dev/null && eval "$FORMAT_CMD" || true
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

### 5. Push Branch

```bash
git push -u origin <branch_name>
```

### 6. Create Pull Request

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

### 7. Report Completion

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
