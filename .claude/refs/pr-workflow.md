# PR workflow conventions

Branch creation, PR title/body composition, stack checklists, draft handling. Applies to any GitHub PR created against `github.com` (or any other GitHub host).

## Branch naming

```
{developer-initials}-{kebab-case-description}
```

- Developer initials = first letter of first name + first letter of last name (usually `$(whoami | cut -c1-2)`).
- Example: `git checkout -b "$(whoami | cut -c1-2)-fix-edge-cap"`.

Per-PR-stack branches: each PR has its own branch. Never put a multi-PR stack on a single branch.

## Branch base selection

When starting a new PR:

1. Check whether the previous PR in the milestone (if any) has merged: `gh pr view <number> --json state`.
2. **If this is PR1, OR the previous PR is merged**: branch from origin/master.
   ```bash
   git fetch origin master && git checkout -b <branch> origin/master
   ```
3. **If the previous PR is NOT merged**: branch from the previous PR's branch (stacked).
4. **Stacked PR updates**: work directly on each existing PR branch in order. Update PR1 on its branch first, then rebase PR2 onto the updated PR1, continue upward one branch at a time.

## Draft PRs

- Default: always create with `--draft`.
- Only mark ready when the engineer explicitly says "ready for review" / "non-draft" / "mark ready". Confirm before un-drafting if the override is ambiguous.

## PR title format

```
[<ISSUE_ID>] [<tracking_tag> n/x] <short title>
```

- The `[<ISSUE_ID>]` prefix is optional — include it only when the work is tracked in an external issue tracker and you have the exact ID. Otherwise omit it and lead with the tracking tag (or the title).
- Use literal `x` for the series total (`1/x`, `2/x`, ...). **Never** a fixed number like `1/4` — the total is unknown and may change.
- Never include milestone/stack markers (`M2`, `G3`, …) anywhere in the title — `[<tracking_tag> n/x]` is the only stack indicator.
- Keep `<short title>` under ~60 chars. Details go in the body.

## PR body composition

Lead with a one-line **Goal:** at the very top of the body — the milestone/stack goal in one sentence — before the TLDR. It always goes first so a reviewer sees the destination before the detail. (For stacked PRs this is the same goal line that anchors the stack; keep it at the top, not at the bottom of the PR Stack section.)

Then two required sections: TLDR paragraph + concise bullet list of code changes.

### Markdown rules
- Use real newlines, not `\n` escape sequences.
- Never mention AI or Claude.
- Don't add a "Ticket" section — if there's an issue ID it's already in the title.

### TLDR
- 1–3 sentences. The *why* of this PR. What problem it solves; what the next reviewer needs to know to give it a useful review.

### Code changes section
- One line per bullet. Two at most.
- Lead each bullet with the file path, then a brief verb phrase.
  - Good: `src/cache/country_policy.go` — single `CountryUsePolicy` parameterized by country set; cache + mutex moved into the loader.
  - Bad: a 4-line bullet walking through every method, parameter rename, and guard clause.
- Describe code changes, not PR-number references. Don't write "as in PR #12345" — describe the actual change.
- **Never mention generated build/dependency files** (lockfiles, generated build manifests, codegen output) in the description — they are implied by the code change and add no reviewer value. Omit them entirely.
- Other trivial regenerations (proto/codegen output, mock regens, mechanical call-site fallout) should also be omitted; only if the mechanical fallout is large and non-obvious, collapse it into a single "plus generated/mechanical fallout" bullet.

## PR Stack checklist (only for stacked PRs)

A "PR Stack" section in the body lists sibling PRs in the stack, with the current PR highlighted.

### When to include

- **Stack mode** (named parallel stacks A/B/C or numbered 13a/13b/13c): include. List only PRs within the **current stack** — never PRs from other stacks.
- **Linear stacked** (each PR branches from the previous unmerged PR): include.
- **Standalone PRs** (each branched independently from master, reviewable in any order): **omit entirely**. The checklist is noise for a standalone PR.

When in doubt, omit.

### Current-PR highlight rule

The bullet for *this PR* MUST satisfy all three:
1. Wrapped in `**...**` (bold).
2. Begin with `👉 ` immediately inside the bold.
3. End with ` ← this PR` outside the bold.

**Per-PR-static**: the pointer marks the PR being viewed, not a global "current in-flight" cursor. PR2's body always shows `👉` on PR2's bullet — even after PR3 is opened. Never edit earlier PRs' bodies to advance the pointer.

### Format

```markdown
## PR Stack

- PR 13a/x · <full PR title>
- **👉 PR 13b/x · <full PR title>** ← this PR
- PR 13c/x · <full PR title>
```

- The stack's one-line goal lives in the top-of-body **Goal:** line (see PR body composition) — do not repeat it under the PR Stack section.
- Plain markdown bullets (no checkboxes — not tracking merged status visually).
- Use full PR titles.
- In stack mode: use `<stack_number><letter>/x` labels (e.g. `13a/x`, `13b/x`).
- Don't include status emojis (✅ / 🟡 / ⚪). The bold + 👉 is the only highlight.

## Stacked PR push order

- Push and open each PR when **that PR** is complete. Don't wait until the full stack is done.
- Each PR's body's stack checklist accurately reflects the stack at the moment of opening.

## Keep the PR description current

After every code change pushed to a PR branch (review feedback, fixes, additions), update the PR body to match the current diff. The description should never drift from the code.

When updating after review comments, include a link to the exact code change and a concise explanation of what was updated.

## PR failure babysit

Prefer spawning the `ci-watcher` subagent to monitor and fix failing checks rather than running `gh pr checks` in a `sleep` loop in the foreground.

When CI fails on a PR you just updated:
1. Push the fix.
2. Poll required checks every 1 minute until they pass.
3. If a check is blocked by an unfixable error or needs major rework, stop and notify the engineer.

## Anti-patterns

- Don't use `1/3`, `1/4`, etc. for series totals. Always `1/x`.
- Don't put the full stack on one branch and split into PRs later.
- Don't include the PR stack checklist on a standalone PR.
- Don't advance the 👉 pointer in earlier PR bodies as later PRs open.
- Don't mention AI / Claude in the body.
- Don't write 4-line bullets that walk through every method change.
- Don't add a "Ticket" section to the body when an issue ID is already in the title.
