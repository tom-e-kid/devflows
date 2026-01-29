# CLAUDE.md

This file provides guidance to Claude Code when working on the devflows repository.

## About This Repository

devflows is a collection of reusable Claude Code skills and global rules for cross-project development workflows.

## Repository Structure

```
devflows/
├── CLAUDE.md           # This file (rules for devflows itself)
├── README.md           # User documentation
│
├── global/
│   └── rules.md        # Cross-project common rules
│
└── skills/             # Workflow skills
    ├── plan/
    ├── go/
    ├── continue/
    ├── pr/
    ├── ios-dev/
    ├── web-dev/
    └── ...
```

## Writing Skills

### Skill File Structure

Each skill is a directory containing a markdown file:

```
skill-name/
├── skill.md        # or SKILL.md
└── scripts/        # Optional helper scripts
    └── helper.sh
```

### Skill Frontmatter

```markdown
---
name: skill-name
description: Brief description shown in skill list
---
```

### Skill Content Guidelines

1. **Clear Purpose**: State what the skill does upfront
2. **Prerequisites**: List what's needed before running
3. **Procedure**: Step-by-step instructions
4. **Examples**: Show expected output or behavior
5. **Notes**: Edge cases, warnings, tips

### Script Conventions

- Use `#!/bin/bash` with `set -euo pipefail`
- Include usage comment at the top
- Define clear exit codes
- Use portable commands when possible

## Editing Global Rules

### File Naming

- Use `rules.md` (not `CLAUDE.md`) to prevent auto-loading in this repo
- Users symlink as `CLAUDE.md` at destination

### Content Guidelines

- Keep rules generic (no project-specific info)
- Focus on workflow and conventions
- Let skills handle platform-specific logic

## Testing Changes

### Manual Testing

1. Create a test project
2. Symlink the changed files
3. Run relevant skills
4. Verify behavior

### Skill Testing Checklist

- [ ] Skill loads without errors
- [ ] Procedure steps are clear
- [ ] Scripts execute correctly
- [ ] Path references resolve correctly

## Git Conventions

- Branch: `feature/<description>` or `fix/<description>`
- Commit messages: English, imperative mood
- Keep changes focused and minimal

## Language

- All documentation: English
- Code comments: English
