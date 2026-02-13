---
name: pr
description: Create a Pull Request. Alias for /devflows:feature-pr.
---

# pr

Create a Pull Request for the completed feature.

## What This Skill Does

Runs `/devflows:feature-pr` to:
- Verify all tasks are completed
- Create commit with proper message
- Push branch and create PR

## Procedure

### 1. Run /devflows:feature-pr

Execute the `/devflows:feature-pr` skill. This will:
- Check tasks.md for completion status
- Stage and commit changes
- Push to remote
- Create PR with proper template
- Report PR URL

---

## Notes

- This skill is a simple alias for `/devflows:feature-pr`
- Use this when implementation is complete and reviewed
