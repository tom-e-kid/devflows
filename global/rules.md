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

## Workflow Philosophy

devflows ensures quality and traceability in feature development:

1. **Start with a session** - Use `/devflows:start` to create a trackable session
2. **Track progress** - Session files record state; resume anytime
3. **Review every step** - Each implementation step includes review & refactor
4. **Build accountability** - Compare before/after builds; fix regressions
5. **Format consistently** - Platform-specific formatting before commit
6. **Structured PRs** - Follow project PR format conventions

## Feature Development Workflow

devflows integrates with Claude Code's standard plan mode.

### Flow

```
1. User runs /devflows:start → creates branch, session, baseline
2. Planning (optional) → plan mode or direct implementation
3. Implementation (with implementation-loop) → /devflows:pr
```

### Available Commands

| Command | Purpose |
|---------|---------|
| `/devflows:start` | Start a new feature session (branch + session + baseline) |
| `/devflows:memo` | Save conversation context (goals, decisions, tasks) to session files |
| `/devflows:loop` | Start implementing — picks up from current session state |
| `/devflows:issue` | Create a GitHub Issue from the current discussion |
| `/devflows:issues` | List and manage GitHub Issues |
| `/devflows:resume` | Resume existing session |
| `/devflows:status` | Show implementation progress |
| `/devflows:pr` | Create PR with format |

### Auto-Detection

The session-start hook outputs status:

- `STATUS: NO_SESSION` → No active session; use `/devflows:start` to begin, or `/devflows:issues` to browse
- `STATUS: SESSION_EXISTS` → Active session found on current branch
  - Hook also provides `GOAL:` and `PROGRESS:` data
  - **Proactively report** session status to user (branch, goal, progress)
  - Offer to resume (`/devflows:resume`), check status (`/devflows:status`), or start something else
  - Do NOT just echo "run /devflows:resume" — show the info immediately

## Implementation

After starting a session with `/devflows:start`, implement using `/devflows:loop` (or the implementation-loop skill directly):

1. Each task: **Implement** → **Review & Refactor** → **Format** → **Build & Verify** → **Commit** → **Update progress**
2. After all tasks: Final review → Final build → Ready for `/devflows:pr`

## Session Structure

Feature state is stored in `.devflows/sessions/<session_name>/` (branch name with `/` replaced by `-`, e.g., `feature/dark-mode` → `feature-dark-mode`):

| File                 | Purpose                                         |
| -------------------- | ----------------------------------------------- |
| `plan.md`            | Goal, base branch, context, approach            |
| `tasks.md`           | Task list with status + progress log            |
| `issues.md`          | Review issues (append-only)                     |
| `build_baseline.log` | Initial build warnings                          |
| `.branch`            | Actual git branch name (for reverse mapping)    |

### Recovery Paths

| Situation | Action |
|-----------|--------|
| Build fails during implementation | Fix in current session, retry |
| Need to revise plan | Edit `plan.md` and `tasks.md` directly, or use `/devflows:memo` |
| Abandon feature | Delete `.devflows/sessions/<session_name>/`, delete branch |

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

