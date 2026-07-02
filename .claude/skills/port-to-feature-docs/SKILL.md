---
name: port-to-feature-docs
description: Port substantive findings from the current turn into the right feature doc, or into the daily backfill file when no feature is in scope. Use when the Stop hook asks for a doc-sync check, or invoke manually via /port-to-feature-docs when something noteworthy happened mid-session.
tags: [docs, workflow, journal]
---

# Port to Feature Docs

<purpose>
One pass at the end of a turn: decide if anything from this turn belongs in the agent_docs system, route it to the right file, write idempotently, return a one-line summary.

This skill is not a brain-dump. Most turns produce nothing worth porting. Skip aggressively.
</purpose>

<conventions>
- STATUS.md format + three-state checkboxes → `~/.claude/refs/status-md.md`
- MASTER.md structure + decision logging format → `~/.claude/refs/master-md.md`
</conventions>

<routing>

### Step 1 — Is a feature in scope?

A feature is in scope when **any** of the following is true for this turn:

- You read or edited files under `~/agent_docs/active/<feature>/`
- You read or edited code files that the conversation tied to a specific feature in `active/`
- The user named a feature, or the work clearly maps to one active feature

If yes → route updates to that feature's docs (Step 2).
If no → backfill to `~/agent_docs/daily/<YYYY-MM-DD>.md` (Step 3).

**Never write to `~/agent_docs/finished/<feature>/`.** If a finished feature came up, route to daily instead.

### Step 2 — Which doc within a feature?

A single turn may write to multiple docs. Use this routing:

| What happened this turn | Destination |
|---|---|
| PR drafted / marked ready / merged / blocked; milestone task done / blocked; a checkbox should flip | `STATUS.md` — follow status-md ref |
| Accepted design decision; constraint discovered; plan changed; "we picked X over Y because Z" | `MASTER.md` → `## Decisions (Accepted)` |
| New open question / unresolved blocker | `MASTER.md` → `## Open Decisions / Blockers` |
| Investigation finding; what was tried + ruled out; useful link, query, or data point; subagent dispatched with a result worth keeping | `JOURNAL.md` (create if missing) |
| Standalone deep-dive worth preserving as its own doc (discovery pass, design exploration, post-merge review) | Topical doc — see naming rule below |

**Topical-doc naming rule.** Any non-canonical doc inside a feature folder MUST encode the specific topic in its filename: `DISCOVERY-<kebab-topic>.md`, `REVIEW-<kebab-topic>.md`, `RESEARCH-<kebab-topic>.md`, etc. Never write a bare `DISCOVERY.md` / `REVIEW.md` / `RESEARCH.md` — a feature can spawn multiple of each class and the bare filename collides on the second one. When you create a new topical doc, also add it to `feature.yaml.docs.reference_docs`.

### Step 3 — Daily backfill

Append to `~/agent_docs/daily/<YYYY-MM-DD>.md`. Create the file if it doesn't exist with header `# <YYYY-MM-DD>`.

</routing>

<formats>

### JOURNAL.md / daily entry (this skill owns this format)

```
## HH:MM — <one-line summary>
- did: <bullets, terse>
- found: <key insight, only if any>
- touched: <files / PRs / URLs>
```

### MASTER.md decision / STATUS.md checkbox

Follow the formats defined in `~/.claude/refs/master-md.md` and `~/.claude/refs/status-md.md`. Don't restate them here.

</formats>

<rules>

- **Skip aggressively.** If the turn was chit-chat, a question answered without action, planning that didn't conclude, or research with no useful finding → write nothing. Better to no-op than to log noise.
- **No user paraphrase.** Only record what *was done* or *was decided*. "User asked about X" is not a journal entry.
- **Idempotent.** If an entry with the same summary line already exists for today, don't duplicate.
- **Tight.** 2–4 lines per journal entry. One line per decision. No prose paragraphs.
- **Don't restate identifiers.** "Updated `parseFoo` in foo.go" — the diff has the rest.
- **Multi-feature turns are rare.** If a turn genuinely spans two active features, write to both. If it spans an active feature + ad-hoc work, write to the feature only.
- **Never create `STATUS.md` or `MASTER.md`** — they should already exist for any active feature. If they don't, that's a different problem (run the feature-kickoff skill).

</rules>

<output>

End with exactly one line in one of these forms:

- `Ported: <comma-separated list of doc paths updated>`
- `Nothing to port.`

</output>
