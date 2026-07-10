---
name: skill-refiner
description: Analyze your past sessions to surface improvements to your existing skills, refs, and user-level instructions file (CLAUDE.md / AGENTS.md). Also detects repeated workflows that should become new skills. Default: scans only since the previous run (state lives at `~/agent_docs/state/skill-refiner.json`); falls back to 1 day if no prior run. Output: a self-critiqued approval plan as a markdown table.
tags: [meta, retrospective, workflow]
---

# Skill Refiner

<purpose>
Mine your own session history to find improvements to your config. Produce a self-critiqued, approval-ready plan. Never edit anything without explicit user approval.

What you're looking for, across many sessions:
- Repeated user corrections you keep making the same mistake on
- Common workflows the user manually orchestrates that should be a skill
- Existing skills that should have fired but didn't (description / trigger issue)
- Conventions referenced multiple times that belong in a ref
- Stale or unused skills that should be retired

What you should improve:
- Your existing skills (SKILL.md instructions, descriptions, triggers)
- Your existing refs (`~/.claude/refs/*.md` or `~/.codex/refs/*.md`)
- Your user-level instructions file (`~/.claude/CLAUDE.md` or `~/.codex/AGENTS.md`)
- Propose new skills where a clear repeated-workflow pattern exists
</purpose>

<conventions>
- Skill-authoring style (orchestrators vs refs, when to extract) → see the `<skill_authoring_style>` block in your user-level instructions file.
</conventions>

<inputs>
Optional time range. **Default: scan only since the previous run** — read `last_run_iso` from `~/agent_docs/state/skill-refiner.json`. If the file is missing, fall back to 1 day ago.

Overrides:
- `1d` / `7d` / `2w` / `30d` (relative — overrides the state file for this run)
- `--since=2026-05-15` (absolute start — overrides the state file for this run)
- `--from=<date> --to=<date>` (explicit range — overrides the state file for this run)
- `--reset-state` (delete the state file, then run with the 1-day fallback)
- `--dry-run` (produce the plan but do NOT update the state file)

Parse to a start timestamp. If unparseable, fall back to state file → 1 day, and tell the user what you used.
</inputs>

<workflow>

### 1. Determine time window

State file path: `~/agent_docs/state/skill-refiner.json`.

1. If `--reset-state` was passed, delete the state file first.
2. Compute `since`:
   - If the user passed `--since`, `--from/--to`, or a relative duration (`1d` / `7d` / `2w` / `30d`) → use that (the state file is ignored for this run).
   - Else read `last_run_iso` from the state file. If present, `since = last_run_iso`.
   - Else (file missing or unreadable), `since = now - 1d` and tell the user "no prior run found, falling back to 1 day".
3. `now` = end of the window (current UTC time).
4. Echo the resolved window to the user before scanning: `Time window: <since> → <now> (source: state file | --since | fallback)`.

### 2. Enumerate session JSONL files

Session history lives at `~/.claude/projects/<project-slug>/<session-uuid>.jsonl` (this path holds your session JSONLs regardless of which agent invoked this skill). Each line in a JSONL is one event (user message, assistant message, tool use, tool result, etc.).

Walk all project directories under `~/.claude/projects/` and find `.jsonl` files whose mtime is within the time window. Build a list of `(path, project_slug, mtime, line_count)` tuples.

```bash
find ~/.claude/projects -name '*.jsonl' -type f -newermt "<since>" 2>/dev/null
```

If the count is 0, stop and report "no sessions in window."

### 3. Chunk and dispatch sub-agents in parallel

Group sessions into chunks. Default chunking: aim for ~5 sessions per sub-agent, with up to 8 sub-agents in parallel. Adjust if total session count is very small (1 agent) or very large (cap at 8 in parallel, queue the rest as additional waves).

Generate a unique run id: `skill-refiner-<unix-timestamp>`.

Create the temp dir: `/tmp/<run-id>/`.

For each chunk, dispatch a sub-agent **in parallel** (multiple `Agent` tool calls in a single message). Each sub-agent receives:

- The list of JSONL paths in its chunk
- The path to its temp output file: `/tmp/<run-id>/agent-<N>.md`
- These exact instructions:

```
You are analyzing session JSONL files for the skill-refiner skill.

Files to analyze (paths absolute):
<list>

Output file (write findings here in markdown):
/tmp/<run-id>/agent-<N>.md

For each session JSONL:
1. Each line is one event. Skip `type: file-history-snapshot` and `type: summary` lines.
2. Look at `type: user` and `type: assistant` events. The actual text is in `message.content` (may be a string or a list of content blocks; extract text from text blocks).
3. Ignore content that begins with `<local-command-caveat>`, `<command-name>`, `<system-reminder>` — that's framework noise, not real user instructions.

For each session, extract signals into 5 categories:

  a) Repeated corrections — user messages like "no, don't do that", "stop X", "instead of Y", "actually...". Quote the user message + give the assistant action it was correcting.
  b) Manual orchestrations — sequences where the user typed multi-step instructions (3+ explicit steps) and the assistant executed them one by one. Quote the orchestration. If this looks like a recurring pattern, flag it as a NEW SKILL candidate.
  c) Skill misses — the user described work that an existing skill should have done, but the assistant did it manually instead. Quote the user prompt.
  d) "Remember this" / "make a note" / "from now on" — explicit memory requests from the user.
  e) Workarounds — places the assistant hit a tool failure, then the user worked around it manually. Quote both the failure and the workaround.

Write your findings to your output file in this format:

# Agent <N> findings — sessions: <count>

## Session <session-uuid> (<project-slug>, <iso-timestamp>)
- **<category>**: <one-line summary>. User said: "<quote>". Context: <one line>.
- **<category>**: ...

(Repeat per session. Skip sessions with zero findings entirely.)

Rules:
- Be terse. One line per finding.
- Quote user messages exactly (truncate to ~100 chars).
- Don't paraphrase. Don't editorialize about whether the finding is important — the top level judges that.
- Don't load full session content into your context — read JSONL line by line via shell tools or jq.
- If a JSONL file is huge (>10k lines), sample the first 500, the last 500, and 200 from the middle.
```

### 4. Wait for all sub-agents, read findings

Each sub-agent finishes and writes its temp file. Read every `/tmp/<run-id>/agent-*.md` file. Aggregate the raw findings into one buffer in your context.

### 5. Cross-reference with existing config

List existing config:

- `ls ~/.claude/skills/` (or `~/.codex/skills/` depending on which agent you are) — the set of existing skills.
- For each skill of interest, read `SKILL.md` description + frontmatter.
- `ls ~/.claude/refs/` (or `~/.codex/refs/`) — existing refs.
- Read the user-level instructions file (`~/.claude/CLAUDE.md` or `~/.codex/AGENTS.md`).

You'll need this context when deciding the right target for each finding.

### 6. Cluster signals and build proposals

Group findings into proposals. Rules:

- **Repeated correction** appearing in 2+ sessions → propose update to user-level instructions file (CLAUDE.md / AGENTS.md). If the correction relates to a specific skill's behavior, propose updating that skill's SKILL.md instead.
- **Manual orchestration** appearing in 2+ sessions OR a single very-long manual orchestration → propose new skill (or augment an existing one if there's a close match).
- **Skill miss** (existing skill should have fired but didn't) → propose updating that skill's `description` / triggers.
- **"Remember this"** events → propose update to user-level instructions file (these are explicit memory requests the user already wants captured).
- **Workaround** appearing in 2+ sessions → propose a new skill or a ref note documenting the workaround.
- **Convention referenced repeatedly** that isn't already in a ref → propose new ref or addition to existing ref.

Drop proposals with only 1 supporting session UNLESS the user message contains an explicit "from now on" / "always" / "remember" trigger.

### 7. Self-critique pass

This step is **mandatory** — do not skip it.

For each proposal, ask yourself out loud (in your scratch reasoning):

1. **Is the evidence strong?** How many sessions support this? Multiple sessions on different days = strong. Single session = weak (drop unless explicitly memorable).
2. **Is this the right target file?** Did I pick CLAUDE.md when this is really skill-specific? Or vice versa?
3. **Will applying this actually improve future runs?** Or am I just logging noise that future-me will trip over?
4. **Does this conflict with something already in your config?** Read the relevant section first.
5. **Is the proposed change tight?** A long verbose addition is worse than no addition. If the proposed text is >3 lines, can it be 1?
6. **Is there a simpler version of this change?** Could I delete an existing instruction instead of adding a new one?
7. **The honest question: is this the right thing to do?**

Drop weak proposals. Tighten remaining ones. Annotate each surviving proposal with: confidence (high/medium/low), evidence (count of supporting sessions), critique notes.

### 8. Produce approval plan

Write a markdown file at:

```
~/agent_docs/daily/<YYYY-MM-DD>-skill-refiner-plan.md
```

Format:

```markdown
# Skill Refiner Plan — <YYYY-MM-DD HH:MM>

- Time window: <since> → <now>
- Sessions analyzed: <count>
- Sub-agent runs: <count>
- Run ID: <run-id>

## Proposed changes

| # | Item (file) | What to edit | Why |
|---|---|---|---|
| 1 | `~/.claude/CLAUDE.md` (`<section>`) | Add "<exact text>" | User corrected this 4× across sessions on 2026-05-19, 2026-05-20 (sessions a1b2..., c3d4...) |
| 2 | `~/.claude/skills/<x>/SKILL.md` (description) | Append ", or when user asks about Y" | Skill didn't auto-trigger on 3 user prompts about Y (sessions...) |
| 3 | NEW: `~/.claude/skills/<new-skill>/SKILL.md` | Create skill for <workflow-name> | User manually orchestrated this 3-step sequence 3× (sessions...) |
| ... | ... | ... | ... |

## Self-critique notes

- **Proposal #1**: confidence high, 4 sessions. The change is 1 line. Conflict check: existing `<git_safety>` already covers the spirit but not the specific phrasing — addition is justified.
- **Proposal #2**: confidence medium, 3 sessions. The skill is close to the user intent but its description undersells the trigger surface.
- **Proposal #3**: confidence low, dropped on self-critique. The "3-step sequence" wasn't actually identical across sessions — different services. Logging this as evidence not yet ready.
- ...

## Dropped (with reason)

- "User asked me to <X>" — only 1 session, no "from now on" trigger.
- ...
```

### 8.5. Update state file

Unless `--dry-run` was passed, write `~/agent_docs/state/skill-refiner.json` (create the `state/` dir if missing):

```json
{
  "last_run_iso": "<now>",
  "last_run_summary": {
    "window_since": "<since>",
    "sessions_analyzed": <count>,
    "proposals_surfaced": <count>,
    "plan_file": "<path>"
  }
}
```

This advances the scan cursor regardless of whether the user later applies any proposals — the "what session data has been reviewed" question is settled by producing the plan, not by acting on it. If the user wants to redo the same window, they pass `--since` or `--reset-state` on the next run.

### 9. Hand back for approval

Display ONLY the **`## Proposed changes`** table inline in the chat — render it as a markdown table with the same `# | Item (file) | What to edit | Why` columns as written in the plan file. Keep cells substantive (multi-sentence Why allowed; quote source sessions).

Do **NOT** display the self-critique notes or dropped sections inline — those live in the plan file for reference, not in the terminal output. They bloat the handback and the user has asked to keep the chat output to "the proposed change at the end" only.

After the table, print exactly three lines:

```
Plan file: <path>
Reply with `apply <N>` / `apply all` / `reject all` / `drop <N>` to proceed.
<gated-proposal confirmation question, only if any proposal is gated on user confirmation>
```

### 10. Apply approved proposals

When the user replies with their approval:

1. Parse the approval list.
2. For each approved proposal:
   - Read the target file
   - Apply the exact edit specified in the table
   - Verify the edit landed
3. Stamp a record at the bottom of the plan file under `## Applied at <timestamp>`:
   ```
   - Proposal #1 → applied to `~/.claude/CLAUDE.md`
   - Proposal #2 → applied to `~/.claude/skills/<x>/SKILL.md`
   - Proposal #3 → rejected
   ```
4. Report one-line summary of what landed.

</workflow>

<rules>

- **Never edit without explicit approval.** The output is a *proposal*, not an action.
- **Sub-agents must write to disk.** Never load full session content into top-level context.
- **The top level synthesizes from temp files**, not from raw JSONL.
- **Skip aggressively** — better 5 strong proposals than 20 weak ones.
- **Cite source sessions** for every proposal (session UUID + ISO timestamp).
- **Self-critique is mandatory** (step 7). Never skip.
- **Don't propose changes that already exist** in the target file. Read first.
- **Don't auto-mirror Claude→Codex** (or vice versa) — propose changes for the agent currently running, not both. (The user can run skill-refiner separately under each agent.)
- **Tight changes only.** Three-line additions are usually wrong — they should be one line, or they should be a new ref, not inline.
- **Honest evaluation.** If after the sub-agent pass there are no strong findings, report "nothing worth proposing this run" and stop.

</rules>

<anti_patterns>

- Don't write proposals to CLAUDE.md for things that only fire in one specific skill's context. Per-skill issues → per-skill SKILL.md.
- Don't propose adding "always do X" rules from a single occurrence.
- Don't propose new skills for one-off workflows. Look for 2+ recurrences.
- Don't try to be exhaustive. The signal-to-noise ratio of the surfaced proposals is the metric. Quality over quantity.
- Don't synthesize across users — this is single-user only.
- Don't write to `~/agent_docs/active/<feature>/` from this skill; this is meta-config work, not feature work. Plan files go to `daily/`.

</anti_patterns>

<output>

End with exactly:

- Plan file path: `<path>`
- Top 3 proposals (one line each)
- "Reply with `apply <numbers>` / `apply all` / `reject all` to proceed."

If nothing worth proposing:
- "Reviewed <N> sessions in window <since>→<now>. Nothing worth proposing this run."

</output>
