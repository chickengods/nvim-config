# feature.yaml schema

Canonical machine-readable index for every feature folder under `agent_docs/active/` and `agent_docs/finished/`.

## Required fields

```yaml
name: <kebab-case>
title: <human-readable title>
owner: <username | "<full name>">  # string or object with name/team
doc_root: ~/agent_docs/active/<name>/   # or finished/
```

## Tracking links

Tracking is optional and GitHub-oriented. The feature docs (`MASTER.md` / `STATUS.md`) are the source of truth; GitHub PRs are the external record.

```yaml
tracking:
  repo: <owner/repo>            # optional; the primary GitHub repo for this feature
  issues: [<url>, ...]          # optional; free-form external issue links — docs don't depend on these
  related_incident: <id>        # optional
  postmortem_doc: <url>         # optional
```

## Doc index

```yaml
docs:
  master: MASTER.md
  status: STATUS.md
  scope_docs: [M1_SCOPE.md, M2_SCOPE.md, ...]
  design_docs: [<paths or URLs>]
  reference_docs: [<paths or URLs>]   # optional; external source docs mirrored from MASTER.md "## Reference Docs"
```

## Milestone tracking metadata

For milestones expected to ship as a stacked PR series:

```yaml
milestones:
  M1:
    title: <milestone title>
    status: pending | active | done | cancelled | reverted
    completed_at: <YYYY-MM-DD>           # only when status=done
    tracking_tag: <Short Tag>            # used in PR-group titles
    tracking_series_total: <N | x>       # number when known, literal `x` for open-ended
    scope_doc: M1_SCOPE.md               # optional pointer
    shipped_prs: [<github url>, ...]     # optional
    blockers: [{id, summary, details}]   # optional
    related_external_work: [...]         # optional
```

`tracking_series_total: x` preserves literally in doc titles and PR titles. Never replace with a fixed number.

## Quality state

Recorded on every sync pass:

```yaml
quality:
  last_synced_at: <YYYY-MM-DD>
  pr_parity: unknown | partial | aligned | synced
  notes:
    - <free-form note>
```

## Archived block

When a feature is archived (moved to `finished/`):

```yaml
archived:
  at: <YYYY-MM-DD>
  reason: shipped | abandoned | <one-line>
```

## Hierarchy convention

```
Feature   = one feature.yaml + doc folder
Milestone = one engineering deliverable   (M1, M2, ...)
PR group  = one reviewable PR             (one per PR, ideally)
```

Milestones live in `STATUS.md` as top-level checkboxes; PR groups nest under a scoped milestone once it is scoped. `shipped_prs` records the GitHub URLs as PRs open.
