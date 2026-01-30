# Global Rules

This file provides cross-project guidance to Claude Code.

## Language

- Documentation: English
- Commit messages: English
- PR descriptions: English
- Code comments: English
- Communication with user: Follow user's language

## Git Conventions

### Branching Strategy

Detect the project's branching strategy:


| Indicator                   | Strategy    | Base Branch |
| --------------------------- | ----------- | ----------- |
| `develop` branch exists     | Git flow    | `develop`   |
| Only `main`/`master` exists | GitHub flow | `main`      |


### Commit Messages

- Use imperative mood ("Add feature" not "Added feature")
- Keep subject line under 50 characters
- Separate subject from body with a blank line
- Explain "what" and "why" in the body, not "how"

### Branch Naming

- Feature: `feature/<description>`
- Bugfix: `fix/<description>`
- Use kebab-case for descriptions

## Pull Requests

### PR Title

- Keep under 70 characters
- Use imperative mood
- Be specific about the change

### PR Description

- Summarize the goal
- List key changes
- Include testing notes
- Reference related issues if any

## Code Quality

### General Principles

- Keep changes minimal and focused
- Follow existing project conventions
- Don't add features beyond what was requested
- Prefer editing existing files over creating new ones

### Before Committing

- Ensure build passes
- Run format/lint commands
- Check for new warnings

## Feature Development Workflow

This repository provides skills for structured feature development. Use the state-based guide below to determine which command to run.

### Workflow States

| State | Indicators |
|-------|------------|
| `no-session` | No `.devflows/sessions/<branch>/` exists |
| `planning` | In CC plan mode, session not yet created |
| `implementing` | Session exists, steps incomplete |
| `pr-ready` | All steps complete, PR not created |
| `pr-open` | PR exists and is open |

### State → Command Mapping

| Current State | Command | Next State |
|---------------|---------|------------|
| `no-session` | `/devflows:plan` | `planning` |
| `planning` (plan approved) | `/devflows:exec` | `implementing` |
| `implementing` | `/devflows:resume` | `implementing` |
| `implementing` (all complete) | `/devflows:pr` | `pr-open` |
| `pr-open` (merged) | cleanup | `no-session` |

### Auto-Detection

The session-start hook outputs status to help you decide:

- `STATUS: NO_SESSION` → suggest `/devflows:plan`
- `STATUS: SESSION_EXISTS` → suggest `/devflows:resume`

### Recovery Paths

| Situation | Action |
|-----------|--------|
| Build fails during implementation | Fix in current session, retry |
| Need to revise plan | Edit `plan.md` directly, continue |
| Abandon feature | Delete `.devflows/sessions/<branch>/`, delete branch |

### /devflows:plan Command Behavior

**CRITICAL:** When the `/devflows:plan` skill is invoked, you MUST call the `EnterPlanMode` tool IMMEDIATELY before doing anything else. Do not ask questions, explore the codebase, or display guidance first. Call EnterPlanMode first, then proceed with the skill.

### .devflows/sessions/ Structure

Feature documentation is stored in `.devflows/sessions/<branch_name>/`:

| File                 | Purpose                                |
| -------------------- | -------------------------------------- |
| `requirements.md`    | Goal, base branch, full plan           |
| `notes.md`           | Key decisions and context              |
| `plan.md`            | Implementation checklist with progress |
| `issues.md`          | Review issues (append-only)            |
| `build_baseline.log` | Initial build warnings                 |

This directory is created by `/devflows:feature-setup` and deleted by `/devflows:feature-cleanup` after PR merge.

## Code Review

- Focus on correctness and maintainability
- Suggest improvements, don't just criticize
- Explain the reasoning behind suggestions
- Respect existing project patterns

## Technical Research

- Always consult official documentation first
- Use WebSearch/WebFetch to verify current behavior
- Do not rely on training data for API specs or library usage

## Skill Discovery

- Observe patterns during conversations that could become reusable skills
- Propose a new skill when you notice:
  - A workflow being repeated across sessions
  - A multi-step procedure that follows a consistent pattern
  - A task that would benefit from standardization
- When proposing, include:
  - Suggested skill name
  - Brief description of what it automates
  - Key steps it would contain

