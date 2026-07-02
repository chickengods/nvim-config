---
name: adversarial-review
description: Spin up a fresh-context agent to adversarially review a PR — no shared session context, just the diff, the PR intent, and the repo. Use when the user asks for an adversarial / fresh-eyes / deep review of a PR, and invoked automatically by milestone-implement-pipeline after each draft PR is created. Returns verified findings (blocking / major / minor); in fix mode, applies the blocking/major fixes.
---

<purpose>
The implementing agent is biased toward its own code — it reviews to confirm, not to break. This skill packages the PR for a reviewer agent that has none of the implementing conversation's context and is instructed to assume something is wrong and hunt for it.
</purpose>

<inputs>
- PR number or URL (required). Repo via `gh repo view --json nameWithOwner` if not in the URL.
- Optional: feature dir / `M<ID>_SCOPE.md` path for intent context (pipeline passes this).
- Mode: `report` (default — findings only) or `fix` (apply verified blocking/major fixes after the review).
</inputs>

<workflow>

1. **Package the PR**: `gh pr view <n> --json title,body,baseRefName,headRefName,files` and `gh pr diff <n>`. If a feature is in scope, extract only this PR's group section from `M<ID>_SCOPE.md` as the intent summary.

2. **Spawn one fresh-context reviewer** (Agent tool, general-purpose). The prompt contains: PR title/body, intent summary, the full diff, repo path — and adversarial instructions:
   - Assume there is at least one real problem; your job is to find it, not to approve.
   - Hunt: correctness bugs, broken invariants, missed call sites (grep for every renamed/changed symbol — direct refs, type-level refs, string literals, tests/mocks), edge cases, concurrency/ordering issues, convention violations (file placement vs team precedent, comment rules), test gaps.
   - Read the surrounding repo code yourself — the diff alone is not enough context.
   - Return findings as structured lines: `severity (blocking|major|minor) | file:line | claim | evidence`.
   - Zero findings is a valid outcome — but list what was checked.

3. **Verify before accepting**: re-check each blocking/major finding against the actual code in the main context. Drop findings that don't reproduce — reviewer agents hallucinate too.

4. **Output**: findings table (severity, location, claim, status: verified/dropped). In `fix` mode: fix verified blocking/major findings, run validation for the changed scope, push, and re-verify PR title/body still match (`~/.claude/refs/pr-workflow.md`).

</workflow>

<rules>
- The reviewer must NOT receive the implementing conversation's reasoning, plans, or self-assessment — fresh context is the whole point. Facts only: diff, intent, repo.
- Never let the reviewer push or comment on the PR directly; all writes happen in the main context after verification.
- Minor findings are reported, not auto-fixed — the user decides.
</rules>
