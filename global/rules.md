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

1. **Plan before code** - Use standard plan mode; no code changes without a plan
2. **Track progress** - Session files record state; resume anytime
3. **Review every step** - Each implementation step includes review & refactor
4. **Build accountability** - Compare before/after builds; fix regressions
5. **Format consistently** - Platform-specific formatting before commit
6. **Structured PRs** - Follow project PR format conventions

## Feature Development Workflow

devflows integrates with Claude Code's standard plan mode. No special commands needed to start planning.

### Flow

```
1. User describes a feature → Claude enters plan mode naturally
2. Planning discussion → ExitPlanMode → User approves
3. "Implement the following plan:" triggers Implementation Protocol
4. Session setup → Implementation loop → Ready for PR
```

### Available Commands

| Command | Purpose |
|---------|---------|
| `/devflows:issue` | Create a GitHub Issue from the current discussion |
| `/devflows:issues` | List and manage GitHub Issues |
| `/devflows:resume` | Resume existing session |
| `/devflows:status` | Show implementation progress |
| `/devflows:pr` | Create PR with format |

### Auto-Detection

The session-start hook outputs status:

- `STATUS: NO_SESSION` → No active session; start planning or use `/devflows:issues`
- `STATUS: SESSION_EXISTS` → Active session found on current branch
  - Hook also provides `GOAL:` and `PROGRESS:` data
  - **Proactively report** session status to user (branch, goal, progress)
  - Offer to resume (`/devflows:resume`), check status (`/devflows:status`), or start something else
  - Do NOT just echo "run /devflows:resume" — show the info immediately

## Implementation Protocol

**CRITICAL:** When you receive "Implement the following plan:" after plan approval, follow this protocol.

### 1. Session Setup (First Time Only)

If `.devflows/sessions/<branch>/` doesn't exist:

1. **Determine base branch** (see Git Conventions > Branching Strategy)
2. **Create feature branch** if not already on one
3. **Create session directory** with:
   - `requirements.md` - Goal, base branch, full plan
   - `plan.md` - Implementation checklist
   - `notes.md` - Key decisions from planning
4. **Run baseline build** using platform skill (ios-dev, web-dev, etc.)
5. **Save baseline** to `build_baseline.log`

### 2. Implementation Loop

For each step in the plan:

1. **Implement** the step
2. **Review & Refactor** (run review skill)
3. **Update progress** in `plan.md` (mark step complete)
4. **Format code** (platform-specific)
5. **Commit** with descriptive message

### 3. Completion

After all steps:

1. **Run final build**
2. **Compare to baseline** - fix any new errors/warnings
3. **Announce** ready for `/devflows:pr`

## Session Structure

Feature state is stored in `.devflows/sessions/<branch_name>/`:

| File                 | Purpose                                |
| -------------------- | -------------------------------------- |
| `requirements.md`    | Goal, base branch, full plan           |
| `notes.md`           | Key decisions and context              |
| `plan.md`            | Implementation checklist with progress |
| `issues.md`          | Review issues (append-only)            |
| `build_baseline.log` | Initial build warnings                 |

### Recovery Paths

| Situation | Action |
|-----------|--------|
| Build fails during implementation | Fix in current session, retry |
| Need to revise plan | Edit `plan.md` directly, continue |
| Abandon feature | Delete `.devflows/sessions/<branch>/`, delete branch |

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

