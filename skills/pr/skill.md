---
name: pr
description: Create a Pull Request. Alias for /feature-pr.
---

# pr

Create a Pull Request for the completed feature.

## What This Skill Does

Runs `/feature-pr` to:
- Verify all steps are completed
- Create commit with proper message
- Push branch and create PR

## Procedure

### 1. Run /feature-pr

Execute the `/feature-pr` skill. This will:
- Check plan.md for completion status
- Stage and commit changes
- Push to remote
- Create PR with proper template
- Report PR URL

---

## Notes

- This skill is a simple alias for `/feature-pr`
- Use this when implementation is complete and reviewed
