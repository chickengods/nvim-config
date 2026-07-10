# MASTER.md conventions

Format and rules for `MASTER.md` — the source-of-truth feature plan inside any feature folder under `agent_docs/active/`.

## Purpose

`MASTER.md` is the high-signal, implementation-oriented plan for a feature. Another coding agent should be able to start implementation from `MASTER.md` + `STATUS.md` alone.

Keep it concise. Push detailed task lists into `M<id>_SCOPE.md` files, not MASTER.md.

## Required sections

```markdown
# <Feature Name> - Master Plan

- Owner:
- Last updated:
- Status:
- Scope:
- Related docs:
  - `STATUS.md` (engineering milestone tracker)

## Reference Docs

## Goal

## In Scope / Out of Scope

### In scope

### Out of scope

## Current State (Code-Verified)

## Decisions (Accepted)

## Open Decisions / Blockers

## Existing Baseline PRs / Docs

## Milestones / Phases

### Phase 1

#### Changes

#### Touchpoints

#### Exit criteria

## Rollout / Gates

## Notes for Next Agent
```

## Reference Docs

A persistent index of external source material for the feature (Google Docs, Confluence pages, Slack threads, PRDs, decision logs). The point is durability: once a human hands the agent a doc, it must be re-findable from `MASTER.md` alone — never left only in chat history.

**Capture rule:** whenever the user supplies an external doc as input — at kickoff or mid-stream — append a line here and mirror the URL into `feature.yaml` `docs.reference_docs`. Re-reading an existing doc that is already listed is not a new capture.

One line per doc:
```
- [<title>](<url>) — <one-line of what it is / why it matters>. Captured <YYYY-MM-DD>.
```

Use the doc's real title (not the bare URL) so the index stays scannable. If a doc is the feature's primary design source, also record it as a Decision input under `## Existing Baseline PRs / Docs`.

## Decision logging

When a design decision is made during implementation, append to the appropriate section:

**Accepted decision** → `## Decisions (Accepted)`:
```
- **<YYYY-MM-DD> · <short label>**: <decision in 1–2 lines>. Why: <reason>.
```

**New open question or constraint** → `## Open Decisions / Blockers`:
```
- **<YYYY-MM-DD> · <short label>**: <question or blocker in 1–2 lines>. Resolved by: <milestone or condition>.
```

One line per decision. No prose paragraphs. Keep `Why:` tight — it captures the rationale future readers can't derive from the code.

## Design-doc handling

When MASTER.md or a sibling design doc describes both current and target architecture, distinguish them clearly. Don't conflate landed behavior with target.

## What does NOT belong in MASTER.md

- Per-PR task checklists — those live in `M<id>_SCOPE.md` and `STATUS.md`.
- Run logs, investigation findings, or transient context — those live in `JOURNAL.md`.
- Full code sketches — those live in `M<id>_SCOPE.md` under each PR group.

## Update pattern

When the plan changes:
1. Update MASTER.md first (scope, decisions, milestones).
2. Then sync `STATUS.md` milestone names + gates to match.
3. Then sync `feature.yaml` tracking metadata.
4. Preserve completed `STATUS.md` checkboxes unless the user explicitly resets scope.
