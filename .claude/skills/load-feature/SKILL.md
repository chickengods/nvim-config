---
name: load-feature
description: Orient on an existing feature under `~/agent_docs/active/` so the agent can pick up cold and answer "what's going on with X" / "load up Y" / "catch me up on milestone Z". Reads the canonical docs in order, optionally reconciles live PR state, and returns a concise summary of where the feature stands and what's next. Use when the user names a feature, points at a feature file in the IDE, or asks to load / look at / catch up on a feature or milestone.
tags: [docs, workflow, planning]
---

# Load Feature

<purpose>
Bootstrap context on an existing feature in `~/agent_docs/active/<feature>/` so the agent can continue work without the user re-explaining anything. This skill is the entry-point sibling of the kickoff/scope/implement/archive pipeline — those skills create and advance feature state; this one reads it.
</purpose>

<conventions>
- Feature folder layout + canonical docs → see `<doc_layout>` below
- `feature.yaml` schema → `~/.claude/refs/feature-yaml-schema.md`
- `MASTER.md` structure + decision logging → `~/.claude/refs/master-md.md`
- `STATUS.md` three-state checkboxes + tracking-tag conventions → `~/.claude/refs/status-md.md`
- PR workflow (titles, stack callout, descriptions) → `~/.claude/refs/pr-workflow.md`
</conventions>

<doc_layout>

A standard active feature folder contains these files. Canonical docs always exist; topical docs only when warranted.

| File | Required | Purpose |
|---|---|---|
| `feature.yaml` | yes | Machine-readable index: tracking links, doc paths, milestones with shipped PRs, quality/sync state |
| `MASTER.md` | yes | High-level plan, in-scope / out-of-scope, decisions (accepted), open blockers, milestone plans |
| `STATUS.md` | yes | Engineering checklist with three-state checkboxes (`[ ]` not done, `[-]` pending/open PR, `[x]` merged) |
| `M<N>_SCOPE.md` | per milestone | Detailed scope doc for one milestone (PR breakdown, test plan, exit criteria). Created by `milestone-scope-pipeline`. |
| `JOURNAL.md` | optional | Investigation findings, what was tried/ruled out, useful links/queries |
| `DISCOVERY-<topic>.md` | optional | Standalone deep-dive on one question (e.g. `DISCOVERY-inserted-at.md`). **Never bare `DISCOVERY.md`** — feature can spawn multiple. |
| Other topical docs | optional | `REVIEW-<topic>.md`, `RESEARCH-<topic>.md`, etc. Same naming rule: encode the topic. |

`~/agent_docs/finished/` mirrors `active/` for archived features. `~/agent_docs/daily/<YYYY-MM-DD>.md` captures ad-hoc work not tied to a feature.

</doc_layout>

<sibling_skills>

The agent_docs workflow is a chain of skills. This skill is the read-only orientation entry point. The others mutate state:

| Skill | When to invoke |
|---|---|
| `feature-kickoff-pipeline` | Starting a brand-new feature from an eng doc / problem description. Creates `feature.yaml`, `MASTER.md`, `STATUS.md`. |
| `milestone-scope-pipeline` | A milestone is in `STATUS.md` but has no `M<N>_SCOPE.md` yet. Produces the scope doc and concrete tasks. |
| `milestone-implement-pipeline` | A milestone is scoped and the user wants to ship the next PR. Implements one PR at a time. |
| `feature-archive` | Feature shipped, abandoned, or otherwise done. Moves folder `active/` → `finished/`. |
| `port-to-feature-docs` | End-of-turn: route substantive findings into the right doc. Stop hook prompts this automatically. |
| `status-pr-sync` | Reconcile `STATUS.md` PR checkbox states against live GitHub. Fast read-only sync. |

</sibling_skills>

<workflow>

### 1) Resolve the feature folder

- User named a feature (e.g. "load event-store-testing") → `~/agent_docs/active/<name>/`.
- User pointed at a file under `active/<feature>/` in the IDE → use that feature's folder.
- User said "this feature" with no other signal → check the most recently opened file from IDE state, or ask.
- Folder missing → suggest `feature-kickoff-pipeline`. Folder lives in `finished/` → read-only mode; warn the user it's archived.

### 2) Read canonical docs in order

Always in this order; each builds context for the next:

1. **`feature.yaml`** — gives doc paths, milestone list, tracking links (GitHub), shipped PRs, quality metadata.
2. **`MASTER.md`** — goal, scope, decisions, open blockers, milestone narratives.
3. **`STATUS.md`** — current engineering state, blockers, history.
4. **Active milestone's `M<N>_SCOPE.md`** — if the user named a milestone, or if STATUS.md shows exactly one in-progress milestone with a scope doc.

### 3) Read topical docs selectively

Topical docs listed under `feature.yaml.docs.reference_docs` (or named explicitly in MASTER.md) are deep-dives. Read them only when:
- The user named a topic that matches one (e.g. "what did we decide about inserted_at" → `DISCOVERY-inserted-at.md`).
- An open decision in MASTER.md cites one as the rationale.
- The current milestone scope references one for context.

Don't read every reference doc by default — they can be long.

### 4) Optional live-state reconciliation

`STATUS.md` may be stale. Before reporting current state, decide if a sync is warranted:

- If the user asked "what's the latest" / "what's currently merged" / specifically referenced PRs → run `status-pr-sync` against this feature's `STATUS.md` first.
- For pure orientation ("what is this feature about") → skip the sync; report from docs and note the `last_synced_at` date so the user knows the freshness.

### 5) Return a concise summary

Default summary shape — adapt to what the user asked:

- **Goal** (1 sentence from `MASTER.md` § Goal).
- **Current milestone** + status + the milestone's stated objective.
- **Recent activity:** last 2–3 merged PRs (with #).
- **Next:** the next unchecked task or PR in `STATUS.md`.
- **Open blockers / decisions:** anything unresolved in MASTER.md § Open Decisions.
- **Stale signal:** `quality.last_synced_at` date and any drift you spotted.
- **Suggested next step:** which sibling skill to invoke (e.g. "next PR is scoped — invoke `milestone-implement-pipeline`").

Keep it tight. 8–15 lines is usually right. If the user asked a specific question ("what's left on M2?"), answer that directly first, then offer the summary only if useful.

</workflow>

<rules>

- **Never write to `finished/`.** If a finished feature is the target, treat the folder as read-only and tell the user.
- **Don't run mutating syncs without asking.** `status-pr-sync` writes to `STATUS.md`. For pure orientation, prefer reading + reporting drift over silently fixing it.
- **Don't read every reference doc.** They're deep-dives. Use the conventions block above to pick.
- **Trust but verify dates.** `feature.yaml.quality.last_synced_at` and `STATUS.md`'s "Last updated" line tell you how stale the file-based view is. If they're more than ~a week old and the user is about to act, suggest a sync first.
- **One skill at a time.** Don't auto-chain into `milestone-implement-pipeline` after loading — load, summarize, hand control back. The user decides the next step.

</rules>

<output>

End with a short summary block matching the workflow §5 shape, plus one explicit next-action recommendation (which sibling skill if any, or "ready for your direction").

</output>
