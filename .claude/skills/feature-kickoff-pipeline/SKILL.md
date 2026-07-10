---
name: feature-kickoff-pipeline
description: Start and maintain a standard feature documentation pipeline for engineering work. Use when a new feature starts and the input is an engineering doc, a problem description, or both, and you need to produce handoff-ready docs (`feature.yaml`, `MASTER.md`, and `STATUS.md`) that any coding agent can continue from.
tags: [planning, docs, workflow]
---

# Feature Kickoff Pipeline

<overview>
Create and maintain a feature folder with machine-readable metadata plus two core docs:

- `feature.yaml`: canonical feature metadata and tracking links
- `MASTER.md`: source-of-truth feature definition and implementation plan
- `STATUS.md`: engineering milestone tracker using three-state checkboxes (`[ ]`, `[-]`, `[x]`)

Default doc root: `~/agent_docs/active/<feature-name>/`
</overview>

<conventions>
- feature.yaml schema (required fields, milestone metadata, quality block) → `~/.claude/refs/feature-yaml-schema.md`
- MASTER.md structure + decision logging + Reference Docs capture format → `~/.claude/refs/master-md.md`
- STATUS.md format + three-state checkboxes → `~/.claude/refs/status-md.md`
- `note:` / `#NOTE:` resolution convention → `~/.claude/refs/note-markers.md`
</conventions>

<inputs>
Accept any of:

- Engineering doc link/text
- Problem statement
- Both

If both are provided, merge them and call out conflicts in `MASTER.md` decisions/open questions.

**Always capture external reference docs.** Any Google Doc / Confluence page / Slack thread / PRD the user hands you — at kickoff or mid-stream — gets recorded in the `## Reference Docs` section of `MASTER.md` and mirrored into `feature.yaml` `docs.reference_docs`, per `~/.claude/refs/master-md.md`. This keeps source material re-findable from the docs alone, not buried in chat history.
</inputs>

<workflow>

### 1) Initialize folder and files

1. Normalize feature name to kebab-case.
2. Create folder: `~/agent_docs/active/<feature-name>/`.
3. Create or update:
   - `feature.yaml`
   - `MASTER.md` from `assets/master_template.md`
   - `STATUS.md` from `assets/status_template.md`

If files already exist, update in place. Do not throw away checked status items unless user asks.

<feature_yaml_spec>
`feature.yaml` is the canonical machine-readable index. Schema lives in `~/.claude/refs/feature-yaml-schema.md` — populate every required field on kickoff, leave optional fields null until they exist.
</feature_yaml_spec>

### 2) Gather service context before planning

Read enough code/docs to understand how the involved services currently work.

Minimum expected discovery pass:

1. Find involved services/packages with `rg`.
2. Read key service docs (`README.md`, `SCHEMA.md`, service-level docs).
3. Read relevant proto/RPC contracts.
4. Read key write/read paths and data model conversion code.
5. Capture concrete touchpoints (files/areas) in `MASTER.md`.
6. Resolve any `note:` / `#NOTE:` markers in existing feature docs per `~/.claude/refs/note-markers.md`.

Goal: another agent can start implementation from docs only.

### 3) Write `MASTER.md`

Use the template at `assets/master_template.md` and fill in every required section. Section list + decision-logging + Reference Docs capture format are in `~/.claude/refs/master-md.md`. Keep this doc high-signal and implementation-oriented.

Populate `## Reference Docs` with every external doc supplied so far, and mirror those URLs into `feature.yaml` `docs.reference_docs`.

### 4) Write `STATUS.md`

Use the template at `assets/status_template.md`. Format + three-state semantics + tracking-tag prefix conventions are in `~/.claude/refs/status-md.md`. Kickoff-specific rules:

1. Each milestone gets one line. If unscoped, append `(requires scoping)` and do not add placeholder tasks.
2. Keep dependency gates explicit (milestone preconditions, blocking milestones).
3. Prefer stable work-unit IDs that can later map cleanly to PRs.

<example>
- `[Usage Restrictions Interface 1/x] UseCase annotation + request contract`
</example>

### 5) Keep docs synchronized

When plan changes:

1. Update `feature.yaml` tracking metadata and doc index first.
2. Update `MASTER.md` scope/decisions/milestones.
3. Update `STATUS.md` milestone names and gates to match.
4. Preserve completed checkboxes unless scope changed explicitly.

Record `quality` state in `feature.yaml` per the schema in `~/.claude/refs/feature-yaml-schema.md`.

</workflow>

<update_mode>
If the feature folder already exists:

1. Read `feature.yaml`, `MASTER.md`, and `STATUS.md` first.
2. Apply incremental updates only.
3. Keep milestone IDs stable when possible.
4. Add a short dated entry in status history for structural changes.
5. Resolve `note:` / `#NOTE:` markers per `~/.claude/refs/note-markers.md`.
6. Capture any newly-supplied external docs into `## Reference Docs` + `feature.yaml` `docs.reference_docs`.
</update_mode>

<output_standard>
A kickoff is complete when:

- Feature folder exists at `~/agent_docs/active/<feature-name>/`
- `feature.yaml` exists and points at the active docs and trackers
- `MASTER.md` is complete enough for implementation handoff
- `STATUS.md` is milestone-driven and uses the three-state convention
- Docs explicitly identify major gates/preconditions
</output_standard>
