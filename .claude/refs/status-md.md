# STATUS.md conventions

Format and rules for `STATUS.md` files inside any feature folder under `agent_docs/active/` or `agent_docs/finished/`.

## Three-state checkbox semantics

Every checklist item uses exactly one of three states. No percentages, no invented states.

| State | Meaning |
|---|---|
| `[ ]` | Not done — no PR opened yet, or a PR was closed without merging |
| `[-]` | Pending — implementation in progress, or a PR is open but not merged |
| `[x]` | Done — work landed on master, or explicitly closed-as-not-needed with a note |

Transition rules:
- Never flip `[ ]` → `[x]` directly without going through `[-]`, except when explicitly closing as not-needed (and document why).
- Only mark `[x]` when the PR is actually merged. Not when CI passes; not when the PR is approved.
- A milestone may be `[x]` only when every child PR group is `[x]`.
- Preserve already-checked items unless the user explicitly resets scope.

## Document structure

```markdown
# <feature-name> - Engineering Status

- Owner: <name>
- Last updated: <YYYY-MM-DD>
- Master plan: `MASTER.md`
- Purpose: Track engineering milestone completion using three states.

## Status Legend

- `[ ]` Not done
- `[-]` Pending (implemented / active PR, not merged)
- `[x]` Done (merged/landed)

## Milestones

- [ ] M1: <milestone name>
  - [ ] PR1: <PR title>
    - PR: <url>
    - [ ] M1.1: <task>
    - [ ] M1.2: <task>

- [ ] M2: <milestone name> (requires scoping)

## Open Blockers / Decisions

- [ ] B1: <blocker>

## Status History

- [x] <YYYY-MM-DD>: <event>
```

## Nesting rules

- Milestones are top-level. Each maps to one engineering deliverable.
- Under a scoped milestone, group tasks by **PR title** (one bullet per PR), then nest leaf tasks under each PR group.
- Under each PR group bullet, add a `PR: <url>` line as soon as the draft PR exists. Do not add placeholder URLs.
- Task IDs (`M3.1`, `M3.2`, ...) stay stable from scope doc through completion.

## When a milestone is unscoped

- Append `(requires scoping)` to the milestone line.
- Do not add placeholder tasks underneath.
- The milestone stays `[ ]` until scoped.

## Tracking-tag prefix

When a milestone in `feature.yaml` defines `tracking_tag` and `tracking_series_total`, prefix each PR-group title with:

```
[<tracking_tag> <index>/<tracking_series_total>] <short PR title>
```

`tracking_series_total` may be a concrete number or `x` for an open-ended stack. Preserve `x` literally.

## Updating `Last updated`

When STATUS.md changes substantively (checkbox flip, scope change, PR URL added), update the `Last updated:` line at the top to today's date in `YYYY-MM-DD`.

## Status History entries

Use for non-checkbox events that future readers should see:
- structural scope changes (renamed milestones, dropped/added phases)
- major reconciliations (PR backfill, sync passes)
- archive events

Format: `- [x] <YYYY-MM-DD>: <one-line event>`

## Anti-patterns

- Don't add placeholder URLs (`PR: TBD`). Add the line only when a real URL exists.
- Don't reset existing `[x]` checkboxes unless the user explicitly says scope changed.
- Don't invent intermediate states (no `[~]`, no `[?]`).
- Don't add percentages or progress bars.
- Don't redundantly tag tasks with `[PR1]` when PR-title grouping already exists.
