---
name: milestone-implement-pipeline
description: "Implement a scoped engineering milestone one PR at a time. Each invocation reads state, implements one PR, creates a draft, and hands back. Loops on approval via UserPromptSubmit hook. Supports optional stack ID (e.g. 'A', 'B') for milestones with parallel PR stacks. Use when feature.yaml, MASTER.md, STATUS.md, and M<ID>_SCOPE.md are ready. Also routes on PR-creation phrasings like 'create PR N' / 'go to the next PR' / 'go work on PR N' once a milestone is scoped."
tags: [planning, workflow, github]
---

# Milestone Implement Pipeline

<overview>
Execute one PR at a time from a scoped milestone. Implements exactly one PR, then stops and waits for user approval. A UserPromptSubmit hook detects approval and re-invokes for the next PR.

Supports two modes:
1. **Linear mode** — single ordered PR sequence (default)
2. **Stack mode** — milestone has parallel named stacks (e.g. A, B, C, D); each stack is run independently with its own state file

Loop (both modes):
```
[invoke skill] -> read state -> load docs -> implement PR -> create draft -> update docs/state -> "ready for review" -> [stop]
   ^                                                                                                                       |
   |   user says "PR is good" -> hook advances state -> system message re-invokes skill                                   |
   +-----------------------------------------------------------------------------------------------------------<----------+
```
</overview>

<conventions>
- Branch naming, base detection, PR title format, PR body composition, PR Stack checklist (👉 highlight), draft PR creation, keep-description-current rule → `~/.claude/refs/pr-workflow.md`
- STATUS.md format + three-state checkboxes → `~/.claude/refs/status-md.md`
</conventions>

<inputs>
Accept any of:
- Feature name (resolves to `~/agent_docs/active/<feature-name>/`)
- Feature folder path
- Required milestone ID (`M1`, `M2`, ...) — must be explicitly provided by the user
- Optional stack number (`13`, `14`, `15`, ...) — required when the milestone has parallel numbered stacks. Each stack number owns a sub-series of PRs labeled `<N>a`, `<N>b`, `<N>c`, etc. Adding a new sub-PR to a stack (e.g. `13d`) never affects other stacks' numbers.

Examples:
- `event-store-usage-restrictions M5 13` — run Stack 13 (Verify) of milestone M5
- `event-store-usage-restrictions M5 15` — run Stack 15 (Account) of milestone M5 (independently, in parallel)
- `event-store-usage-restrictions M5` — linear milestone, no stacks

If no arguments provided, read state from `.claude/milestone-implement.local.md` (or stack-specific file if `stack_id` is set).
</inputs>

<state_file>
State persists across invocations. File path depends on mode:

- **Linear mode**: `.claude/milestone-implement.local.md`
- **Stack mode**: `.claude/milestone-implement-<stack_id>.local.md` (e.g. `.claude/milestone-implement-A.local.md`)

This allows multiple stacks to run independently without clobbering each other's state.

### Format

```yaml
---
enabled: true
feature_name: <name>
feature_dir: ~/agent_docs/active/<name>/
milestone_id: M1
stack_id: A          # omit for linear mode
total_prs: 3
current_pr_index: 1
awaiting_review: false
completed_prs: []
---

# Handoff Context

## Milestone
M1: <milestone title>
Stack: A (Verify Event Ingestion)   # omit for linear mode
Scope doc: ~/agent_docs/active/<name>/M1_SCOPE.md

## PR Stack
- [ ] PR A1: <title>
- [ ] PR A2: <title>
- [ ] PR A3: <title>

## Notes for Next PR
<any context the next invocation needs to pick up seamlessly>
```

### State Transitions

- `awaiting_review: false` + `current_pr_index: N` -> work on PR N in this stack
- After PR created -> set `awaiting_review: true`, stop and wait
- Hook detects approval -> increments `current_pr_index`, sets `awaiting_review: false`
- When `current_pr_index > total_prs` -> hook reports **this stack** complete (not the whole milestone)
</state_file>

<workflow>

### 1) Bootstrap or resume from state

**First invocation** (arguments provided, no state file):
1. Read `feature.yaml`, `MASTER.md`, `STATUS.md`, and `M<ID>_SCOPE.md` from the feature dir
2. If no milestone ID was provided by the user, stop and ask — do not auto-select
3. If the specified milestone has no scope doc, stop and hand off to `milestone-scope-pipeline`
4. **Detect stacks**: scan the scope doc for named parallel stacks (e.g. "Stack A:", "Stack B:"). If stacks exist and no `stack_id` was provided, stop and ask which stack to work on — do not auto-select
5. Parse PR groups for the selected stack (or all PRs if linear), including titles, tasks, dependencies, validation commands, file touchpoints
6. Create the state file (stack-specific path if `stack_id` set) with parsed state
7. Proceed to step 2

**Subsequent invocations** (state file exists):
1. Determine state file path: if `stack_id` provided as argument, use `.claude/milestone-implement-<stack_id>.local.md`; otherwise use `.claude/milestone-implement.local.md`
2. Read the state file
3. Read `feature.yaml`, `STATUS.md`, and `M<ID>_SCOPE.md`
4. Identify current PR group from `current_pr_index` within the active stack
5. Read the "Notes for Next PR" section for handoff context
6. Proceed to step 2

### 2) Load context for current PR

Load what's needed for the current PR group:
1. **Read previous PRs in this milestone** for context on what already landed or is in-flight:
   - For each completed/pending PR listed in the state file's PR Stack, read its diff via `gh pr diff <number>`
   - This gives the agent full awareness of the milestone's cumulative changes so far
2. Read file touchpoints listed in the scope doc for this PR group
3. Use `rg` to find adjacent call sites and existing tests for those touchpoints
4. Read related proto/schema/model files as needed
5. Identify unit tests to add/update

### 3) Resolve unknowns

Before coding, run a knowledge checkpoint:
1. List unresolved codebase-specific questions (conventions, infra, ownership, policies)
2. Query available docs/MCP tools for answers
3. If a blocking question remains unresolved, stop and ask the user

### 4) Implement the current PR

1. Create/switch branch using base-selection + naming rules in `~/.claude/refs/pr-workflow.md`. Summary: branch from origin/master when PR1 or prior PR merged; otherwise branch from prior PR's branch (stacked).
2. Implement only the tasks scoped to this PR group (smallest safe diff)
3. Add/update unit tests for changed behavior
4. Run targeted validation:
   - PR-group-specific commands from scope doc
   - Impacted unit tests
   - `make test-bazel` if broader confidence needed
5. If validation fails, fix and rerun — do not proceed with failures
6. Commit with concise message
7. Push branch

### 5) Create draft PR

Follow `~/.claude/refs/pr-workflow.md` for title format, body composition, draft default, stack checklist (👉 highlight), and keep-description-current rule. Skill-specific orchestration:

1. Base selection: master when branched from master; previous PR's branch when stacked.
2. Stack-mode checklist: list only PRs within the current stack (e.g. 13a/13b/13c). Do not include PRs from other stacks (14x, 15x, 16x) — those are independent and reviewed separately.
3. Record the PR URL in state.
4. After every push to the branch during review, re-read the diff and update the PR body to match per the keep-description-current rule.

### 6) Adversarial review (before handback)

After the draft PR exists and before handing back, invoke the `adversarial-review` skill in `fix` mode, passing the PR number and the `M<ID>_SCOPE.md` path. It spawns a fresh-context reviewer agent on the diff, verifies its findings, and fixes verified blocking/major issues (re-running validation and re-syncing the PR body per the keep-description-current rule). Carry the review summary into the handback.

### 7) Update docs and state

After the PR is created:

1. Update `STATUS.md`:
   - Mark implemented tasks as `[-]` (pending)
   - Mark PR-title line as `[-]`
   - Add `PR: <url>` under the PR group
2. Update `feature.yaml` tracking metadata if applicable
3. Add PR link in scope doc execution notes if section exists
4. Update `.claude/milestone-implement.local.md`:
   - Set `awaiting_review: true`
   - Update PR Stack section (mark current PR as `[-]` with URL)
   - Write "Notes for Next PR" with:
     - What was done in this PR
     - What the next PR needs to do
     - Branch lineage (so next PR knows its base)
     - Any context the next invocation needs

### 8) Hand back and STOP

<stop_rule>
Every PR — including the very first one — MUST stop here and wait for user approval. Do not continue to the next PR automatically.

This applies within a stack too. Even if PRs 15a → 15b → 15c are tightly related, you MUST stop after each one and wait for the user to say "PR is good" before starting the next. Never implement 15b while 15a is still under review.
</stop_rule>

Return to the user:
1. PR title + URL
2. Brief summary of what this PR contains
3. Tests run and results
4. Adversarial review summary: findings fixed, remaining minor findings (or "clean review" with what was checked)
5. "Ready for your review. Say **'PR is good'** to continue to the next PR."

Stop here. Do NOT proceed to the next PR — even within the same stack.

When the user says "PR is good" (or similar), the `milestone-pr-approved` UserPromptSubmit hook:
- Determines which state file to update (checks for stack-specific files first, falls back to default)
- Advances `current_pr_index` in the state file
- Sets `awaiting_review: false`
- If more PRs remain in this stack: outputs system message to re-invoke this skill with the same stack ID
- If all PRs in this stack are done: outputs "Stack <ID> complete!" message and disables that stack's state file (other stacks are unaffected)

### 9) Sync docs on approval (runs at start of next invocation)

When resuming after a PR approval, **before implementing the next PR**:

1. **Verify PR description**: Read the current PR diff and description. If the description is stale or doesn't match the actual code, update it before proceeding. The description must accurately reflect what the PR contains at approval time.
2. **Capture review feedback**: Check the conversation since the last PR was created for any instructions, corrections, or decisions the user made. Record these as notes in `M<ID>_SCOPE.md` under a `## Review Notes` section for the relevant PR group so they persist for future PRs.
3. **Sync status**:
   - Update `STATUS.md`: mark the approved PR's tasks and PR-title line as `[-]` (pending/open)
   - Update `feature.yaml` tracking metadata
   - Reconcile any linked PR state from GitHub
4. Only after the sync and notes capture are complete, proceed to implement the next PR (step 2 onward)

</workflow>

<rules>

### PR Group Rules
1. One PR per invocation. Never batch.
2. Do not pull tasks from later PR groups.
3. If cross-PR coupling appears, document it and update scope/status docs.
4. Keep diffs minimal and reviewable.
5. Do not open the next PR until the current one is approved.
6. PR Stack checklist + 👉 highlight requirements live in `~/.claude/refs/pr-workflow.md`. Apply them every PR (when in stack/linear-stacked mode).

### STATUS.md Rules
1. PR URL added immediately after draft PR creation.
2. Task IDs from scope doc (`M<ID>.<n>`) stay stable.
3. State transitions follow `~/.claude/refs/status-md.md` (three-state semantics, when to flip).

### State File Rules
1. The "Notes for Next PR" section captures key context for the next PR
2. Include branch lineage, completed PR URLs, and any decisions made during implementation
4. Keep the state file under 100 lines — it's a handoff doc, not a log
5. In stack mode, each stack has its own state file (`.claude/milestone-implement-<stack_id>.local.md`). Never share state between stacks.

### Feedback Sync Rules
1. If review feedback changes scope, update STATUS.md and scope doc in the same pass
2. If PR lineage changes, record a supersession note in the state file
3. When a PR merges, update `[-]` to `[x]` in STATUS.md

</rules>

<milestone_completion>
**Linear mode** — when `current_pr_index > total_prs`:
1. Hook disables the state file (`enabled: false`)
2. Hook outputs "Milestone complete!" system message
3. User should update milestone line in STATUS.md to `[-]` (all PRs open) or `[x]` (all merged)

**Stack mode** — when `current_pr_index > total_prs` for a given stack:
1. Hook disables that stack's state file only (`enabled: false` in `.claude/milestone-implement-<stack_id>.local.md`)
2. Hook outputs "Stack <ID> complete!" system message
3. Other stacks continue independently — their state files are unaffected
4. The full milestone is complete only when all stacks' state files are disabled
</milestone_completion>
