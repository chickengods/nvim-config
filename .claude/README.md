# Claude Code config

Portable, version-controlled copy of my global [Claude Code](https://claude.ai/code)
setup: the **agent-docs feature workflow** (skills + refs + hooks) plus a
genericized global `CLAUDE.md` and a minimal `settings.json`.

Ported from a work machine and stripped of all employer-specific tooling,
hosts, trackers, and absolute paths. Tracking is **docs + GitHub only** — no
Linear/Jira integration. Paths use `~` / `$HOME`.

## Layout

```
.claude/
  CLAUDE.md          # global agent guidance (working style, PR rules, agent-docs routing)
  settings.json      # env, safety deny-rules, doc-sync hooks, statusline
  skills/            # agent-docs workflow skills (see below)
  refs/              # shared conventions the skills point at
  scripts/           # hook + statusline scripts
```

### Skills

| Skill | Role |
|---|---|
| `feature-kickoff-pipeline` | Start a feature: create `feature.yaml`, `MASTER.md`, `STATUS.md`. |
| `milestone-scope-pipeline` | Scope one milestone into a `M<N>_SCOPE.md` + concrete tasks. |
| `milestone-implement-pipeline` | Implement a milestone one PR at a time (loops via approval hook). |
| `feature-archive` | Move a finished feature `active/` → `finished/`. |
| `load-feature` | Orient on an existing feature and summarize where it stands. |
| `port-to-feature-docs` | End-of-turn: route findings into the right doc (Stop hook prompts this). |
| `status-pr-sync` | Reconcile `STATUS.md` checkbox states against live GitHub PRs. |
| `adversarial-review` | Fresh-context reviewer over a PR diff (used by the implement pipeline). |
| `render-doc-html` | Render a markdown/feature doc to a styled HTML page. |
| `skill-refiner` | Analyze past sessions to suggest improvements to these skills/refs. |

### Refs

`feature-yaml-schema.md`, `master-md.md`, `status-md.md`, `note-markers.md`,
`pr-workflow.md` — shared format/convention docs the skills reference by path.

## Activating on a machine

No installer. These files are meant to live at `~/.claude/`. Symlink them (edits
in the repo stay live) or copy them:

```bash
# symlink (recommended — repo stays the source of truth)
ln -s "$PWD/.claude/skills"/*        ~/.claude/skills/
ln -s "$PWD/.claude/refs"/*          ~/.claude/refs/
ln -s "$PWD/.claude/scripts"/*       ~/.claude/scripts/
ln -s "$PWD/.claude/CLAUDE.md"       ~/.claude/CLAUDE.md
# settings.json: merge by hand if you already have one, else symlink/copy
```

The `settings.json` hooks and statusline resolve scripts from
`$HOME/.claude/scripts/` — so the three scripts must land there.

## Feature docs

The workflow reads/writes feature folders under `~/agent_docs/`:

```
~/agent_docs/active/<feature>/     # in-flight features (feature.yaml, MASTER.md, STATUS.md, ...)
~/agent_docs/finished/<feature>/   # archived
~/agent_docs/daily/<YYYY-MM-DD>.md # ad-hoc work not tied to a feature
```

## Note on dual role

Because these files also sit in this repo's `.claude/`, Claude Code will treat
them as **project** settings when you work inside this repo (in addition to the
global copy at `~/.claude/`). That's usually fine; if you don't want the
doc-sync hooks firing while editing this config, rely only on the `~/.claude/`
copy and remove `settings.json` from the project checkout.
