---
name: implementation-loop
description: Step execution cycle for feature development. Implement → Simplify → Build & Verify → Update Progress.
---

# implementation-loop

The standard cycle for executing each step in feature development.

## Step Execution Cycle

For each step, follow this cycle:

### 1. Implement

Write the code for the current step.

### 2. Simplify

Review and refactor the implementation:
- Remove unnecessary complexity
- Follow project conventions
- Keep changes minimal and focused

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
# MUST run format before every commit
source .devflows/build/config.sh
eval "$FORMAT_CMD"
```

For Web projects, formatting is **mandatory** before committing. Check CLAUDE.md for the specific format command (e.g., `bun run format`).

### 4. Build & Verify

**IMPORTANT: Read `.devflows/build/config.sh` to determine the platform and use the appropriate script.**

**iOS**:
```bash
.claude/skills/ios-dev/scripts/ios-build.sh latest --incremental
```

**Web**:
```bash
.claude/skills/web-dev/scripts/web-build.sh
```

Check results:

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

### 1. Final Build Verification (Clean Build)

**iOS**:
```bash
.claude/skills/ios-dev/scripts/ios-build.sh latest
.claude/skills/ios-dev/scripts/ios-build.sh minimum  # if configured
```

**Web**:
```bash
.claude/skills/web-dev/scripts/web-build.sh
.claude/skills/web-dev/scripts/web-verify.sh  # lint, typecheck, tests
```

### 2. Final Simplify Pass

Review all changes holistically:
- Ensure consistency across modified files
- Remove any redundant code
- Verify naming conventions

### 3. Request User Review

```
## Implementation Complete

All steps completed. Ready for review.

**Changes**:
- <summary of what was done>

**Build Status**:
- Build: ✅
- Lint/Format: ✅
- Tests: ✅ (if applicable)

Please review. When approved, run `/pr` to create PR.
```

---

## Error Handling

### Build Fails

1. Analyze the error
2. Fix if straightforward
3. If complex, document in `notes.md` and ask user

### Warning Count Increased

1. Identify new warnings
2. Fix if possible (unused variables, deprecated APIs, etc.)
3. If intentional or cannot fix, report to user for approval

### Cannot Proceed

1. Document the blocker in `notes.md`
2. Update `plan.md` with current status
3. Alert user with clear description of the issue

---

## Notes

- Never proceed to next step if current step has build errors
- Use incremental builds during development for speed (iOS)
- Use clean builds for baseline and final verification
- Keep the cycle tight: implement small, verify often
