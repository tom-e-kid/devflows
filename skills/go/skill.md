---
name: go
description: Approve the plan and start implementation. Runs /feature-setup to create branch and docs.
---

# go

Approve the current plan and begin implementation.

## Prerequisites

- Should be in Plan Mode (after running `/start`)
- Plan discussion should be complete
- User is ready to proceed with implementation

## What This Skill Does

1. Runs `/feature-setup` to:
   - Create feature branch
   - Save plan to `docs/sessions/<branch>/`
   - Run initial build and save baseline
2. Proceeds to implementation

## Procedure

### 1. Run /feature-setup

Execute the `/feature-setup` skill. This will:
- Propose a branch name based on the plan
- Create the branch after user confirmation
- Save requirements, notes, and plan to `docs/sessions/<branch>/`
- Check build configuration
- Run initial build and save baseline
- Ask user how to continue (same session or /clear)

### 2. Follow feature-setup Flow

Let `/feature-setup` handle the rest of the flow, including:
- Branch creation
- Documentation setup
- Build verification
- Transition to `/implementation-loop`

---

## Notes

- This skill is a simple wrapper that triggers `/feature-setup`
- All the actual work is done by `/feature-setup`
- User should run this after planning is complete
