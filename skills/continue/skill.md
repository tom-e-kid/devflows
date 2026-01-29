---
name: continue
description: Resume work on an existing feature. Alias for /feature-continue.
---

# continue

Resume work on an existing feature.

## What This Skill Does

Runs `/feature-continue` to:
- Check PR status
- Read saved documentation from `docs/sessions/<branch>/`
- Summarize current progress
- Resume implementation

## Procedure

### 1. Run /feature-continue

Execute the `/feature-continue` skill. This will:
- Check if a PR exists and its status
- Read requirements.md, notes.md, plan.md
- Report current progress to user
- Verify build state
- Resume from where work left off

---

## Notes

- This skill is a simple alias for `/feature-continue`
- Use this when returning to an existing feature branch
- Session-start hook will suggest this when `docs/sessions/<branch>/` exists
