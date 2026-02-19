---
name: review
description: Code review at different depths. Auto-detects platform and applies appropriate checks.
---

# review

Multi-level code review that adapts to context and platform.

## Core Principle

**NEVER auto-fix issues.** Always report to user and wait for explicit instruction.

---

## Usage

Called automatically by `implementation-loop` at different stages, or manually:

```
/devflows:review           # Default: step-level (quick)
/devflows:review --loop    # Loop-level (medium)
/devflows:review --pr      # PR-level (deep)
```

---

## Git Root Resolution

**IMPORTANT: Always resolve git root first to ensure .devflows is found at the repository root (monorepo support).**

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
```

All `.devflows/` paths below should be prefixed with `$GIT_ROOT/`.

---

## Issue Management

### issues.md

All detected issues are recorded in the current session's `issues.md`.

**Location:** Resolve session directory with `SESSION_NAME="${BRANCH//\//-}"`, then `$GIT_ROOT/.devflows/sessions/$SESSION_NAME/issues.md`

**Rules:**
- **APPEND only** - never overwrite existing entries
- Track issues throughout the entire development cycle (until PR merge)
- Each review session adds a new section with timestamp
- Issues persist across multiple loop iterations

### issues.md Format

```markdown
# Issues

## Review: <date> <time> (Level: step/loop/pr)

### Issue 1: <title>
- **Severity:** high / medium / low
- **File:** `path/to/file.swift:123`
- **Description:** Clear explanation of the issue
- **Status:** open / fixed / wontfix
- **Fixed in:** <commit hash or "N/A">

### Issue 2: <title>
...

---

## Review: <previous date> (Level: ...)
...
```

### Status Values

| Status | Meaning |
|--------|---------|
| `open` | Issue detected, not yet addressed |
| `fixed` | User approved fix, issue resolved |
| `wontfix` | User decided to skip (with reason noted) |

---

## When Issues Are Found

### 1. Report to User

Display issues clearly:

```
## Review Found Issues

**Level:** step / loop / pr
**New Issues:** <count>

| # | Severity | File | Issue |
|---|----------|------|-------|
| 1 | high | `file.swift:42` | Hardcoded API key detected |
| 2 | medium | `api.ts:15` | Missing error handling |

These issues have been recorded in the session's `issues.md`.

**What would you like to do?**
- Tell me which issues to fix (e.g., "fix #1 and #2")
- Tell me to skip specific issues (e.g., "skip #2, it's intentional")
- Continue without fixing (issues remain open)
```

### 2. Wait for User Decision

**DO NOT proceed with fixes until user explicitly instructs.**

User can respond with:
- "fix #1" → Fix specific issue
- "fix all" → Fix all issues
- "skip #2" → Mark as wontfix with reason
- "continue" → Leave issues open, proceed

### 3. Update issues.md

After user decision:
- If fixed → Update status to `fixed`, add commit reference
- If skipped → Update status to `wontfix`, add user's reason

---

## Review Levels

### Level 1: Step (Quick)

**When:** After implementing each step
**Focus:** Immediate issues in changed code only
**Time:** Fast - don't slow down the loop

Checklist:
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] No sensitive data in logs or comments
- [ ] No obvious infinite loops or blocking calls
- [ ] No unused imports/variables just added
- [ ] Code follows existing patterns in the file

### Level 2: Loop (Medium)

**When:** After all steps in a cycle complete
**Focus:** Holistic review of all changes in this cycle

Checklist:
- [ ] All Level 1 items
- [ ] Error handling is consistent across changes
- [ ] No duplicate/redundant code introduced
- [ ] Naming is consistent (variables, functions, files)
- [ ] Changes are minimal - no scope creep
- [ ] No leftover debug code or TODOs

### Level 3: PR (Deep)

**When:** Before creating PR (`/devflows:pr` or manual `/devflows:review --pr`)
**Focus:** Comprehensive review ready for external review

Checklist:
- [ ] All Level 1 & 2 items
- [ ] Security review (see Platform-Specific below)
- [ ] Performance implications considered
- [ ] Breaking changes identified and documented
- [ ] Edge cases handled
- [ ] Error messages are helpful (not exposing internals)

---

## Platform Detection

Read `$GIT_ROOT/.devflows/build/config.sh` to determine platform:

```bash
source $GIT_ROOT/.devflows/build/config.sh
echo $PLATFORM  # "ios" or "web"
```

If not available, detect from project files:
- `Package.swift`, `*.xcodeproj` → iOS
- `package.json`, `next.config.*` → Web

---

## Platform-Specific Checks

### iOS

**Level 1 (Step):**
- No force unwraps (`!`) without justification
- No hardcoded bundle IDs or entitlements

**Level 2 (Loop):**
- No retain cycles (check `[weak self]` in closures)
- Async work not blocking main thread
- Proper use of `@MainActor` where needed

**Level 3 (PR):**
- Info.plist doesn't expose sensitive config
- Keychain used for sensitive storage (not UserDefaults)
- App Transport Security exceptions justified
- No private API usage

### Web

**Level 1 (Step):**
- No secrets in client-side code
- User input not directly rendered (XSS)

**Level 2 (Loop):**
- No sensitive data in localStorage/sessionStorage
- API calls have proper error handling
- No console.log with sensitive data

**Level 3 (PR):**
- Environment variables properly separated (server vs client)
- CORS/CSP considerations addressed
- Authentication tokens handled securely
- No SQL/NoSQL injection vectors
- Dependencies don't have known vulnerabilities

---

## Using code-simplifier

If `code-simplifier` agent is available:

1. Run code-simplifier for suggestions
2. **Report suggestions to user** (do not auto-apply)
3. Wait for user approval before applying changes

Only use for Level 2+ reviews to avoid slowing down step-level checks.

---

## PR Readiness Check

Before creating PR, verify issues.md:

```
## Open Issues Summary

**Total issues this cycle:** <count>
**Open:** <count>
**Fixed:** <count>
**Won't fix:** <count>

### Open Issues (require attention):
| # | Severity | Issue |
|---|----------|-------|
| 3 | medium | Missing error handling in api.ts |

**Recommendation:**
- ❌ Cannot proceed - high severity issues open
- ⚠️ Can proceed - only medium/low issues open (document in PR)
- ✅ Ready - all issues resolved
```

---

## Notes

- **Never auto-fix** - always report and wait for user decision
- issues.md is append-only throughout the development cycle
- Step-level reviews should be fast - skip if confident in the change
- Loop-level reviews can take more time - thoroughness matters
- PR-level reviews should be comprehensive - this is the last check
- High severity issues should block PR creation
- Medium/low issues can proceed if documented in PR description
