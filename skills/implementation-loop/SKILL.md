---
name: implementation-loop
description: Step execution cycle for feature development. Implement → Review → Format → Build → Update Progress.
---

# implementation-loop

The standard cycle for executing each step in feature development.

## Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    STEP EXECUTION CYCLE                         │
│                                                                 │
│   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   │
│   │Implement │ → │ Review   │ → │ Format   │ → │  Build   │   │
│   │          │   │ (step)   │   │          │   │ & Verify │   │
│   └──────────┘   └──────────┘   └──────────┘   └──────────┘   │
│                                                      │          │
│                                        ┌─────────────┘          │
│                                        ▼                        │
│                                 ┌─────────────┐                 │
│                                 │   Update    │                 │
│                                 │  Progress   │                 │
│                                 └─────────────┘                 │
│                                        │                        │
│                    ┌───────────────────┴───────────────────┐   │
│                    ▼                                       ▼   │
│             More Steps?                              All Done  │
│                    │                                       │   │
│                    └──► Next Step              Review(loop)◄┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Step Execution Cycle

For each step, follow this cycle:

### 1. Implement

Write the code for the current step.

### 2. Review (Step-Level)

Run quick review on the changes just made. Use the `review` skill at step level:

**Checklist (fast - don't slow down the loop):**
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] No sensitive data in logs or comments
- [ ] No obvious infinite loops or blocking calls
- [ ] No unused imports/variables just added
- [ ] Code follows existing patterns in the file

Skip detailed review if confident in the change. Save thorough review for loop-level.

### 3. Format (REQUIRED before commit)

Run the project's format command before building.

**iOS (swift-format)**:
```bash
if command -v swift-format &> /dev/null; then
    git diff --name-only --diff-filter=AM | grep '\.swift$' | xargs -I {} swift-format -i {}
fi
```

**Web (Prettier)**:
```bash
source .devflows/build/config.sh
eval "$FORMAT_CMD"
```

### 4. Build & Verify

**IMPORTANT: Read `.devflows/build/config.sh` to determine the platform.**

**iOS**:
```bash
.claude/skills/ios-dev/scripts/ios-build.sh latest --incremental
```

**Web**:
```bash
.claude/skills/web-dev/scripts/web-build.sh
```

| Result | Action |
|--------|--------|
| Build error | Fix immediately |
| New warnings | Compare with `build_baseline.log`, fix or escalate |
| No issues | Continue |
| Cannot fix | Stop and alert user |

### 5. Update Progress

- Mark step as `completed` in `plan.md`
- Add entry to Progress Log with date
- Proceed to next step

---

## After All Steps Complete

### 1. Review (Loop-Level)

Run comprehensive review on all changes in this cycle. Use the `review` skill at loop level:

**Checklist:**
- [ ] All step-level items across all changes
- [ ] Error handling is consistent
- [ ] No duplicate/redundant code introduced
- [ ] Naming is consistent (variables, functions, files)
- [ ] Changes are minimal - no scope creep
- [ ] No leftover debug code or TODOs

**Platform-specific (iOS):**
- [ ] No retain cycles (check `[weak self]` in closures)
- [ ] Async work not blocking main thread

**Platform-specific (Web):**
- [ ] No sensitive data in client-side storage
- [ ] API calls have proper error handling

**Use code-simplifier if available:**
```
If code can be simplified, use Task tool with subagent_type="code-simplifier"
```

### 2. Final Build Verification (Clean Build)

**IMPORTANT: Run builds in parallel using subagents for efficiency.**

**iOS** (parallel):

Use Task tool to spawn 2 Bash subagents **in a single message** (parallel execution):

| Agent | Description | Command |
|-------|-------------|---------|
| 1 | iOS latest build | `.claude/skills/ios-dev/scripts/ios-build.sh latest` |
| 2 | iOS minimum build | `.claude/skills/ios-dev/scripts/ios-build.sh minimum` |

Skip Agent 2 if `MINIMUM_OS` is not configured in `config.sh`.

**Web** (parallel):

Use Task tool to spawn 2 Bash subagents **in a single message** (parallel execution):

| Agent | Description | Command |
|-------|-------------|---------|
| 1 | Web build | `.claude/skills/web-dev/scripts/web-build.sh` |
| 2 | Web verify | `.claude/skills/web-dev/scripts/web-verify.sh` |

Wait for both agents to complete, then aggregate results.

### 3. Request User Review

```
## Implementation Complete

All steps completed. Ready for review.

**Review Status:**
- Step reviews: ✅ All passed
- Loop review: ✅ Complete
- Build: ✅
- Lint/Format: ✅
- Tests: ✅ (if applicable)

**Changes:**
- <summary of what was done>

Please review. When approved, run `/pr` to create PR.
```

---

## Review Levels Summary

| Level | When | Focus | Depth |
|-------|------|-------|-------|
| Step | After each step | Just-added code | Quick |
| Loop | After all steps | All changes holistically | Medium |
| PR | Before PR (via `/pr`) | Comprehensive + security | Deep |

The `/pr` skill will automatically run PR-level review before creating the pull request.

---

## Error Handling

### Build Fails

1. Analyze the error
2. Fix if straightforward
3. If complex, document in `notes.md` and ask user

### Review Finds Issues

**NEVER auto-fix.** Follow this flow:

1. Record issues in `.devflows/sessions/<branch>/issues.md` (append)
2. Report issues to user with clear table format
3. Wait for user decision:
   - "fix #1" → Fix specific issue
   - "fix all" → Fix all issues
   - "skip #2" → Mark as wontfix
   - "continue" → Leave open, proceed
4. Update issues.md with status after user decision

### Cannot Proceed

1. Document the blocker in `notes.md`
2. Update `plan.md` with current status
3. Alert user with clear description of the issue

---

## Notes

- Never proceed to next step if current step has build errors
- Step reviews should be fast - thoroughness comes at loop level
- Use incremental builds during development for speed (iOS)
- Use clean builds for baseline and final verification
- Keep the cycle tight: implement small, verify often
