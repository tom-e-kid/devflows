---
name: plan
description: Start a new feature. Enters Plan Mode for requirements discussion and planning.
---

# plan

Start a new feature development session.

## What This Skill Does

1. Enters Plan Mode (using EnterPlanMode tool)
2. Displays guidance for the planning phase

## Procedure

### 1. Enter Plan Mode

**CRITICAL: You MUST call the EnterPlanMode tool IMMEDIATELY before doing anything else.**

Do NOT:
- Ask questions first
- Explore the codebase first
- Display any guidance first

Simply call `EnterPlanMode` now. The guidance will be displayed AFTER plan mode is active.

### 2. Display Guidance

After plan mode is active, display:

```
## Plan Mode Started

You're now in Plan Mode. Let's discuss and plan your feature.

**What to do now:**
- Describe what you want to implement
- I'll explore the codebase and ask clarifying questions
- We'll create an implementation plan together

**When the plan is ready:**
- Run `/devflows:exec` to approve the plan and start implementation
- This will create a feature branch and save the plan

**Tips:**
- Take your time to clarify requirements
- Ask me to investigate specific code if needed
- The more we discuss now, the smoother implementation will be
```

### 3. Wait for User

Wait for user to describe their requirements. Begin the planning discussion.

---

## Notes

- This skill only enters Plan Mode, it does NOT create branches or files
- Branch creation happens later when user runs `/devflows:exec`
- Keep the planning phase flexible and conversational
