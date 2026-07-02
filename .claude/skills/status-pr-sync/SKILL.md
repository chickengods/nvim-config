---
name: status-pr-sync
description: Sync a feature `STATUS.md` checklist against live GitHub pull request state. Use when `STATUS.md` includes PR URL lines (for example `PR: https://.../pull/<n>`) and you need checklist states updated to `[ ]` (not done), `[-]` (pending/open PR), or `[x]` (merged).
tags: [planning, github, workflow]
---

# Status PR Sync

<overview>
Reconcile milestone/task checklist state in a feature `STATUS.md` with the real state of linked PRs on GitHub.
</overview>

<conventions>
- STATUS.md format + three-state checkboxes → `~/.claude/refs/status-md.md`
</conventions>

<inputs>
- Feature folder path (for example `~/agent_docs/active/<feature-name>/`)
- Or direct `STATUS.md` path

Expected `STATUS.md` format includes PR lines under PR groups:
- `- PR: https://github.com/<org>/<repo>/pull/<number>`
</inputs>

<state_model>
PR-to-checkbox mapping (three-state semantics in `~/.claude/refs/status-md.md`):
- PR `open` → `[-]`
- PR `merged` → `[x]`
- PR `closed` and not merged → `[ ]`
</state_model>

<workflow>
1. Resolve `STATUS.md` path for the requested feature.
2. Verify GitHub CLI auth: `gh auth status`.
3. Run a dry run first:
   - `python3 scripts/sync_status_pr_states.py <STATUS.md> --dry-run`
4. Apply updates:
   - `python3 scripts/sync_status_pr_states.py <STATUS.md>`
5. Review and report exact changes with file links.

Script: `scripts/sync_status_pr_states.py`
- Reads PR URLs from `PR:` lines
- Updates nearest parent PR checklist line and nested tasks
- Rolls up parent checklist states (for example milestone lines) from child states
</workflow>

<guardrails>
1. Do not mark anything `[x]` unless PR is actually merged.
2. Keep PR URLs unchanged; only update checklist state markers.
3. If a PR URL cannot be queried, stop and report the exact URL + error.
4. Prefer dry-run before write on first pass in a feature.
</guardrails>
