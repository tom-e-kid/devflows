---
name: validate-review
description: Validate external AI review results. Checks review accuracy, code change correctness, and flags out-of-scope items.
---

# validate-review

Validates external AI review results saved in the session's `review.md`. Acts as a "review of the review" — checking whether each comment is accurate, whether applied fixes are correct, and whether items are in scope.

## Core Principle

**NEVER auto-fix or auto-revert.** Always report findings and wait for explicit user instruction.

---

## Git Root Resolution

**IMPORTANT: Always resolve git root first to ensure .devflows is found at the repository root (monorepo support).**

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
```

All `.devflows/` paths below should be prefixed with `$GIT_ROOT/`.

---

## Session Directory Resolution

Resolve the session directory from the current branch:

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
SESSION_NAME="${BRANCH//\//-}"
SESSION_DIR="$GIT_ROOT/.devflows/sessions/$SESSION_NAME"
```

---

## Procedure

1. **Check for review.md**
   - Look for `$SESSION_DIR/review.md`
   - If not found, report "No review.md found in session directory" and stop

2. **Read review.md in full**
   - Parse all review items and their associated file references

3. **Read plan.md for scope context**
   - Read `$SESSION_DIR/plan.md` to understand the feature scope and goals
   - This determines what is "in scope" vs "out of scope"

4. **Validate each review item**

   For every item in review.md, assess:

   - **Validity of the review comment** — Is the critique accurate? Does the code actually have the described issue? Read the referenced file and verify.
   - **Validity of code changes** — If a fix was applied based on this review item, is the fix correct? Does it introduce regressions or new issues?
   - **Scope assessment** — Is the review point within scope of this branch's feature? If valid but out of scope, flag it.

5. **Classify each item**

   | Classification | Meaning |
   |---------------|---------|
   | `valid` | Review comment is correct, fix (if any) is good |
   | `invalid` | Review comment is wrong — the code is actually fine |
   | `incorrect-fix` | Review comment is valid but the applied fix is wrong or introduces issues |
   | `out-of-scope` | Review comment may be valid but is unrelated to this feature |

6. **Record non-valid items in issues.md** (append-only)

7. **Report to user and wait for decision**

---

## Report Format

```
## External Review Validation

**Source:** review.md
**Items reviewed:** <count>

| # | Category | File | Review Comment | Assessment |
|---|----------|------|---------------|------------|
| 1 | valid | `file.swift:42` | "Missing nil check" | Correct finding, fix looks good |
| 2 | incorrect-fix | `api.ts:15` | "Unsafe type cast" | Valid concern but fix introduced regression |
| 3 | out-of-scope | `auth.swift:88` | "Should use Keychain" | Valid but unrelated to this feature |
| 4 | invalid | `view.swift:20` | "Memory leak" | No leak — ARC handles this correctly |

**Summary:**
- Valid: N (no action needed)
- Invalid: N (review comment was wrong; revert may be needed)
- Incorrect fix: N (fix needs correction)
- Out of scope: N (track separately)

Issues recorded in issues.md.

**What would you like to do?**
- Fix/revert specific items (e.g., "revert #4, fix #2")
- Create issues for out-of-scope items
- Continue
```

---

## issues.md Format

Append a new section with `(Level: validation)`:

```markdown
## Review: <date> <time> (Level: validation)

### Issue V1: <title>
- **Severity:** high / medium / low
- **Category:** invalid / incorrect-fix / out-of-scope
- **File:** `path/to/file:123`
- **External comment:** <what the other agent said>
- **Assessment:** <why this is problematic>
- **Status:** open
- **Fixed in:** N/A
```

**Rules:**
- **APPEND only** — never overwrite existing entries
- Only non-valid items are recorded. Valid items noted in summary only.
- Use `V` prefix for issue numbers (V1, V2, ...) to distinguish from regular review issues

---

## User Actions

| Command | Action |
|---------|--------|
| `"revert #V1"` | Revert changes from an invalid review item |
| `"fix #V2"` | Correct an incorrect fix |
| `"issue #V3"` | Create a GitHub issue for an out-of-scope item |
| `"continue"` | Done with validation |

After user decision:
- If reverted → Update status to `fixed`, note what was reverted
- If fixed → Update status to `fixed`, add commit reference
- If issue created → Update status to `wontfix`, link to GitHub issue

---

## Notes

- **Never auto-fix or auto-revert** — always report and wait for user decision
- issues.md is append-only throughout the development cycle
- Valid items need no action — they confirm the external review was correct
- Invalid items may require reverting changes that were applied based on wrong feedback
- Incorrect fixes need careful correction — the original issue was real but the solution was wrong
- Out-of-scope items are valid findings that belong in a separate feature/issue
