---
name: resume
description: Resume work on an existing feature session
---

# resume

Resume work on an existing feature.

## What This Skill Does

Runs `/devflows:feature-continue` to:
- Check PR status
- Read saved documentation from `.devflows/sessions/<branch>/`
- Summarize current progress
- Resume implementation from the next incomplete step

## Procedure

### 1. Run /devflows:feature-continue

Execute the `/devflows:feature-continue` skill. This will:
- Check if a PR exists and its status
- Read requirements.md, notes.md, plan.md
- Report current progress to user
- Verify build state
- Resume from first incomplete step using implementation loop

---

## Notes

- This skill delegates to `/devflows:feature-continue` for the actual work
- Use this when returning to an existing feature branch
- Session-start hook suggests this when `.devflows/sessions/<branch>/` exists
