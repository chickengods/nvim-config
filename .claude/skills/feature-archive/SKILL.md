---
name: feature-archive
description: Move a feature folder from `~/agent_docs/active/` to `~/agent_docs/finished/`. Use when a feature ships, is abandoned, or otherwise stops being worked on, so it falls out of the active scope of the doc-sync system.
tags: [docs, workflow]
---

# Feature Archive

<purpose>
Retire a feature from active tracking. Moves its folder, updates `feature.yaml.doc_root`, and stamps a finished marker. Nothing destructive — `finished/<name>/` keeps the full history.
</purpose>

<conventions>
- feature.yaml structure (including the `archived` block) → `~/.claude/refs/feature-yaml-schema.md`
- STATUS.md "Status History" section format → `~/.claude/refs/status-md.md`
</conventions>

<inputs>
- Feature name (kebab-case) — required
- Reason: `shipped`, `abandoned`, or free-form one-liner — recommended
</inputs>

<workflow>

### 1) Resolve the source

1. Confirm `~/agent_docs/active/<name>/` exists. If not:
   - Check `~/agent_docs/finished/<name>/` — if present, report "already archived" and stop.
   - Else report "not found" and stop.

### 2) Move the folder

```bash
mv ~/agent_docs/active/<name> ~/agent_docs/finished/<name>
```

### 3) Update `feature.yaml`

If `feature.yaml` exists in the moved folder:

1. Update `doc_root` from `…/active/<name>/` to `…/finished/<name>/`.
2. Update `quality.last_synced_at` to today's date.
3. Add or update top-level `archived` block:
   ```yaml
   archived:
     at: <YYYY-MM-DD>
     reason: <shipped | abandoned | free-form>
   ```

### 4) Stamp `STATUS.md` (if exists)

Append a line to the "Status History" section (create the section if missing):

```
- [x] <YYYY-MM-DD>: archived (<reason>)
```

Do not flip any other checkboxes.

### 5) Report

One line:

```
Archived <name> → ~/agent_docs/finished/<name>/ (<reason>)
```

</workflow>

<rules>

- Never delete files. Archive = move, not delete.
- If the feature has no `feature.yaml`, just move the folder and report. Skip steps 3–4.
- If the folder is currently a git worktree or has active uncommitted state, stop and ask — don't move silently.
- This skill does not touch PRs or any external tracker. If the feature is tracked elsewhere, close it out separately.

</rules>
