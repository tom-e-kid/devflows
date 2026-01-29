---
name: review
description: Code review at different depths. Auto-detects platform and applies appropriate checks.
---

# review

Multi-level code review that adapts to context and platform.

## Usage

Called automatically by `implementation-loop` at different stages, or manually:

```
/review           # Default: step-level (quick)
/review --loop    # Loop-level (medium)
/review --pr      # PR-level (deep)
```

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

**When:** Before creating PR (`/pr` or manual `/review --pr`)
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

Read `.devflows/build/config.sh` to determine platform:

```bash
source .devflows/build/config.sh
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

If `code-simplifier` agent is available, invoke it for refactoring suggestions:

```
After completing checks, if code can be simplified:
1. Use Task tool with subagent_type="code-simplifier"
2. Apply suggested improvements
3. Re-run build verification
```

Only use for Level 2+ reviews to avoid slowing down step-level checks.

---

## Output Format

After review, report:

```
## Review Complete (Level: [step/loop/pr])

**Platform:** iOS / Web
**Files Reviewed:** <count>

**Issues Found:**
- [ ] Issue 1 (severity: high/medium/low)
- [ ] Issue 2

**Suggestions:**
- Suggestion 1
- Suggestion 2

**Status:** ✅ Pass / ⚠️ Pass with warnings / ❌ Needs fixes
```

---

## Notes

- Step-level reviews should be fast - skip if confident in the change
- Loop-level reviews can take more time - thoroughness matters
- PR-level reviews should be comprehensive - this is the last check
- When in doubt about severity, ask the user
- Don't block on style preferences - focus on correctness and security
