---
name: milestone-scope-pipeline
description: Scope the next unscoped engineering milestone for an existing feature doc set. Use when `feature.yaml`, `MASTER.md`, and `STATUS.md` already exist and you need to produce a detailed milestone implementation doc, add concrete tasks under that milestone in `STATUS.md`, and return the scoped plan for human review.
tags: [planning, docs, workflow]
---

# Milestone Scope Pipeline

<overview>
Take an existing feature folder and move one milestone from `(requires scoping)` to scoped tasks.

Outputs per run:

1. New milestone detail doc: `M<id>_SCOPE.md`
2. Updated `STATUS.md` with concrete sub-tasks under that milestone
3. Scope doc includes PR-grouped task plan (smallest-change units) with stacked order as needed
4. Scope doc includes plan-mode style code sketches for major implementation work
5. Optional: updated `MASTER.md` touchpoints/phase details if needed for consistency

Default feature-doc root: `~/agent_docs/active/<feature-name>/`
</overview>

<conventions>
- STATUS.md format + three-state checkboxes → `~/.claude/refs/status-md.md`
- feature.yaml schema → `~/.claude/refs/feature-yaml-schema.md`
- `note:` / `#NOTE:` resolution → `~/.claude/refs/note-markers.md`
</conventions>

<inputs>
Accept any of:

- Feature folder path
- Feature name (resolve to `~/agent_docs/active/<feature-name>/`)
- Required milestone ID (for example `M3`) — must be explicitly provided by the user

If milestone ID is not provided, stop and ask the user which milestone to scope — do not auto-select.
</inputs>

<workflow>

### 1) Load docs and choose target milestone

1. Read `feature.yaml`, `MASTER.md`, and `STATUS.md`.
2. Determine target milestone:
   - explicit user milestone if provided
   - else next unscoped unchecked milestone
3. If no unscoped milestone exists, stop and report no-op.

### 2) Gather implementation context

Before tasking, read service code/docs related to the target milestone:

1. Read phase section in `MASTER.md` for that milestone.
2. Read linked touchpoint files.
3. Use `rg` to find adjacent call sites and tests.
4. Resolve any `note:` / `#NOTE:` markers in existing feature docs per `~/.claude/refs/note-markers.md`.
5. Note constraints, rollout gates, and dependencies.

### 2.5) Resolve architecture decisions interactively

**Before writing the scope doc**, surface every architecture-level decision and resolve each one with the user. Do not proceed to step 3 while any architecture question is open.

<architecture_decision_scope>
An "architecture decision" is any choice that:

- Selects a data source (which table, which version, which view)
- Picks an algorithm or query shape (e.g. GROUP BY MAX vs ROW_NUMBER, broadcast vs shuffle join, in-process vs Spark-side aggregation)
- Sets a topology (sharding, parallelism, shared vs isolated infrastructure)
- Defines failure semantics (partial-success, retry policy, fallback behavior)
- Establishes a default for a new user-facing parameter
- Determines whether a new module/file is created vs an existing one extended
- Locks a bound, threshold, or budget (timeouts, lookback windows, byte caps, chunk sizes)
- Decides what an output artifact looks like (column shape, file layout, JSON schema)

NOT architecture (do not block on these):
- Exact line counts or LOC estimates
- Variable/symbol naming nits
- Test framework choice when only one is obvious from the codebase
- Code-style choices the linter already enforces
</architecture_decision_scope>

<resolution_loop>
The loop runs until all architecture decisions are locked:

1. Enumerate every architecture decision the milestone requires. Phrase each as a concrete question with a default proposal.
2. Send the list to the user in one batch. Use a numbered table with `Question | Default | Tradeoff` columns when there are >3 items.
3. The user replies with answers, partial answers, or counter-questions. Treat counter-questions as new decisions to resolve.
4. Re-enumerate any remaining open decisions. Repeat from step 2 until the user's response leaves no architecture question unresolved.
5. Only after every architecture question has an explicit user answer, proceed to step 3 of this skill.

Defaults you propose should be the recommendation, not a placeholder. If the user accepts a default without comment, treat that as a locked answer. If the user pushes back, integrate their preference and re-confirm any downstream decisions that depend on it.
</resolution_loop>

<anti_patterns>
- Don't leave architecture decisions in the scope doc's "Open Questions" section — that section is for non-architecture concerns only (e.g. "should this ship behind a flag or land directly").
- Don't bundle questions with implementation tasks. Resolve architecture first; tasks second.
- Don't auto-resolve by picking the default silently. The user must see the choice. If they reply "use your defaults," that's an explicit answer.
- Don't ask one question at a time unless there's only one. Batch them so the user can answer in a single round.
</anti_patterns>

### 3) Create milestone scope doc

Create `M<id>_SCOPE.md` from `assets/milestone_scope_template.md`.

<scope_doc_requirements>
Doc requirements:

1. Milestone goal and success criteria
2. Concrete implementation tasks grouped by PR group (not random task lists)
3. PR stacking/dependency order (`PR1 -> PR2 -> ...`) for dependent changes
4. File-level touchpoints
5. Dependencies and sequencing
6. Rollout and verification plan
7. Suggested code samples under each PR group they relate to; do not leave all sketches in one detached section when PR-local placement is clearer
8. **Architecture Decisions section** that lists every locked decision from step 2.5 in a numbered table (`#`, `Decision`, `Rationale`). This section replaces the older "Open Questions" pattern for architecture matters.
9. "Open Questions" section, if present, contains **only non-architecture concerns** (e.g. rollout ordering, who owns review). All architecture matters must be resolved before the doc is written.
10. Do NOT restate STATUS.md checkbox semantics inside `M<id>_SCOPE.md`. Status meaning lives in the status-md ref and `STATUS.md` itself; the scope doc only references it.
</scope_doc_requirements>

Keep it implementation-ready so another coding agent can execute directly.

<tracking_rules>
1. Keep milestone IDs and PR-group IDs stable.
2. Scope tasks so the eventual PR mapping can be 1:1 where practical (when PR-group granularity is opted into).
3. If one PR will intentionally cover multiple doc tasks, call that out explicitly in the scope doc notes.
4. If a design-oriented doc is created or updated during scoping, separate landed state from target state.
</tracking_rules>

<pr_grouping_rules>
1. Optimize for smallest reviewable change per PR.
2. Separate schema/model/generated/codepath enforcement/query behavior when practical.
3. Use stacked PRs only when a later PR depends on earlier diffs.
4. Each PR group must include:
   - scope statement
   - concrete checklist tasks
   - main file touchpoints
   - validation commands/checks
5. If a task can be isolated safely, keep it in an earlier/smaller PR instead of bundling.
</pr_grouping_rules>

<code_sketch_standard>
1. Include at least 3 concrete sketches tied to milestone tasks.
2. Place each sketch under the PR group it belongs to when the milestone is PR-grouped.
3. Prefer snippets for:
   - schema/proto/model deltas
   - service/controller/query logic
   - migration/generation/test command runbook
4. Use realistic file paths and symbols from the codebase, not pseudonyms.
5. If a user already answered a prior open question in notes, inline the answer and remove that open question.
</code_sketch_standard>

### 4) Update `STATUS.md`

<status_update_rules>
Scope-specific rules (general STATUS.md format is in `~/.claude/refs/status-md.md`):

1. Remove `(requires scoping)` from the milestone line.
2. Add PR-title checklist groups under the milestone (`PR1: <title>`, `PR2: <title>`, ...).
3. Add indented task checklists under each PR-title group.
4. Keep milestone unchecked (`[ ]`) — scoping doesn't advance state.
5. Leave other unscoped milestones as `(requires scoping)`.
6. Keep PR group titles aligned with PR group titles in `M<id>_SCOPE.md`.
7. Keep milestone names engineering-deliverable oriented (no process/admin-only milestones).
8. Use stacked order when dependencies exist (`PR1`, then `PR2`, etc.).

Task format:
- Use short verb-led tasks.
- Prefer stable IDs (`M3.1`, `M3.2`, ...).
- Do not rely on inline `[PRx]` tags when PR-title grouping exists.
- Keep wording durable enough to match against PR titles later.
</status_update_rules>

### 5) Sync `MASTER.md` if needed

If scoping introduces concrete file touchpoints or sequencing changes not reflected in `MASTER.md` or `feature.yaml`:

1. Update the matching phase section in `MASTER.md`.
2. Add the milestone scope doc to related docs list.
3. Update `feature.yaml.docs.scope_docs`.
4. Update `feature.yaml.milestones.<id>` if milestone metadata exists there.

Keep `MASTER.md` high-level; avoid duplicating full task lists.

### 6) Handback for review

Return:

1. Which milestone was scoped
2. New doc path (`M<id>_SCOPE.md`)
3. Summary of added tasks in `STATUS.md`
4. PR grouping + stack summary (`PR1`, `PR2`, ...)
5. Summary of notes addressed (if any)
6. Explicit request for review/approval before implementation starts

</workflow>

<output_standard>
A scope pass is complete when:

1. One milestone moved from unscoped to scoped tasks
2. `M<id>_SCOPE.md` exists with implementation detail
3. Scope doc tasks are grouped into explicit PR groups with stack order
4. `STATUS.md` has PR-title groups with concrete indented tasks under each PR group
5. Scope doc includes plan-mode style code sketches for key implementation paths
6. **Architecture Decisions section in the scope doc lists every locked decision from step 2.5. The "Open Questions" section, if present, contains zero architecture-level entries — only non-architecture concerns like rollout ordering or review-ownership questions.**
7. User receives review-ready summary
</output_standard>
