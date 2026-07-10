# CLAUDE.md — global agent guidance

Personal working guidelines for Claude Code across all projects. Ported from my
work setup and genericized: no employer-specific tooling, hosts, trackers, or
absolute paths. Machine-specific locations use `~` / `$HOME`.

Start: say hi + 1 motivating line. Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

<mechanical_overrides>

- **Step 0 rule**: Before ANY structural refactor on a file >300 LOC, first remove all dead props, unused exports, unused imports, and debug logs. Commit this cleanup separately before starting the real work. Dead code accelerates context compaction.
- **Phased execution**: Never attempt multi-file refactors in a single response. Break into explicit phases; complete Phase 1, run verification, wait for explicit approval before Phase 2. Each phase touches no more than 5 files.
- **Senior dev override**: Override default "avoid improvements beyond what was asked" / "try simplest approach." If architecture is flawed, state is duplicated, or patterns are inconsistent — propose and implement structural fixes. Ask: "What would a senior, experienced, perfectionist dev reject in code review?" Fix all of it.
- **Forced verification**: File writes may report success even if code doesn't compile. NEVER report a task complete until you have:
  - Go: run `go build ./...`, `go vet ./...`, and `go test ./...` for changed packages
  - Python: run `mypy` or `pyright` (if configured) and `ruff check` or `flake8` for changed files
  - Fixed ALL resulting errors
  - If no type-checker/linter is configured, state that explicitly instead of claiming success.
- **Sub-agent swarming**: For tasks touching >5 independent files, MUST launch parallel sub-agents (5–8 files per agent). Sequential processing of large tasks guarantees context decay.
- **Context decay awareness**: After 10+ messages in a conversation, MUST re-read any file before editing it. Do not trust memory of file contents — auto-compaction may have silently destroyed context.
- **File read budget**: Each file read capped at 2,000 lines. For files >500 LOC, MUST use offset/limit to read in sequential chunks. Never assume a complete file from a single read.
- **Tool result blindness**: Tool results >50,000 chars are silently truncated to 2,000-byte preview. If any search/command returns suspiciously few results, re-run with narrower scope. State when truncation is suspected.
- **Edit integrity**: Before EVERY file edit, re-read the file. After editing, read again to confirm the change applied. The Edit tool fails silently when old_string doesn't match due to stale context. Never batch >3 edits to same file without a verification read.
- **No semantic search**: You have grep, not an AST. When renaming or changing any function/type/variable, search separately for: direct calls/references, type-level references (interfaces, generics), string literals containing the name, dynamic imports/require() calls, re-exports/barrel file entries, test files and mocks. Do not assume a single grep caught everything.

</mechanical_overrides>

<working_style>

- Keep responses concise, direct, and execution-oriented.
- Use short status updates while working; avoid filler and cheerleading.
- Prefer concrete actions over long planning unless asked for a plan.

</working_style>

<execution_protocol>

- Fix root causes over surface patches.
- Keep diffs focused; avoid unrelated refactors.
- Keep files <~500 LOC; split/refactor as needed.
- "Make a personal note" (or "make a note") => edit `~/.claude/CLAUDE.md` (this file). Do not edit repo-local `AGENTS.md`/`CLAUDE.md` files unless explicitly asked.
- Feature docs live under `~/agent_docs/{active,finished,daily}/`. Use the `feature-kickoff-pipeline` → `milestone-scope-pipeline` → `milestone-implement-pipeline` → `feature-archive` skill chain. Ad-hoc work not tied to a feature → `daily/YYYY-MM-DD.md`. The Stop hook prompts `/port-to-feature-docs` at the end of substantive turns.
- Task tracking: when the user mentions a TODO ("I need to do X", "remind me about Y", "track Z"), capture it in the project's issue tracker or a personal TODO list. Convert relative dates to absolute.
- Prefer `rg`/`rg --files` for search.
- When the user asks for latest/current/external info, use web search and cite sources.
- Use MCP tools proactively before guessing, especially for project- or org-specific context.
- When you generate a URL or short text artifact the user will hand off (dashboard link, prompt for another tool, SQL query, etc.), copy it to the clipboard with `pbcopy` and tell the user it's there.
- When dumping scratch/output files (JSON dumps, CSVs, query results), default the path to the repo root unless told otherwise — don't write into obscure tmp paths the user has to grep for.

</execution_protocol>

<github_workflow>

<branch_naming>

All branch names MUST follow: `{developer-initials}-{description}`

- Developer initials are first and last initial of username (usually `$USER`).
- Description is a brief kebab-case description of branch purpose.
- Example: `git checkout -b $(whoami | cut -c1-2)-here-goes-description`

</branch_naming>

</github_workflow>

<pull_request_rules>

For any PR work (creating, updating bodies, stacking, draft/ready handling, review-comment responses, CI babysit) → follow `~/.claude/refs/pr-workflow.md`. That ref is the single source of truth for title format, body composition, stack checklist (👉 highlight), and the keep-description-current rule.

Default to `--draft`. Only open a non-draft / mark-ready PR when the user explicitly asks, and confirm before overriding the draft default.

</pull_request_rules>

<git_safety>

- Never run destructive git/file commands without explicit user request.
- Do not amend commits unless explicitly requested.
- If unexpected local changes appear, stop and ask before proceeding.

</git_safety>

<code_comment_rules>

**Pre-write check.** Before writing any code comment, scan the draft for: (a) a name from another file, (b) a ticket ID, (c) an issue/PR number. If present, rewrite without it. This is the most common rule violation.

**Stability test + pre-commit scan.** A comment must stay true if other files change. Before every commit, scan the diff's added comment lines against these rules; delete violations before committing.

Default: write NO comment. Code should be self-documenting through clear method and variable names. The bar for adding a comment is high — it must encode a non-obvious WHY a future reader cannot derive from the code itself (a hidden constraint, a load-bearing invariant, a workaround for a specific bug, a generics or ordering gotcha).

**Prefer concise.** Push comments to be as short as they can be while still carrying the WHY — most fit in 1-2 lines. Longer is fine when genuinely necessary; if it's long because it narrates or restates, cut it instead.

**Forbidden patterns** (these are the bulky-comment anti-patterns):
- Restating the signature — naming parameters, listing return values, describing what callbacks do. The type and identifier already carry that.
- Narrating the function body step by step.
- "Used by X" / "added for the Y flow" / "handles the case from issue Z" — these belong in the PR description and rot in code.
- **Cross-file/cross-repo references** ("Mirrors `funcName` in path/to/other.go", "see services/X/Y.py"). The referenced code can rename, move, or change semantics without anyone updating the comment. Keep code comments self-contained; put cross-file context in the PR description or commit message instead.
- **External ticket / issue IDs**. Same rot problem — tickets get closed, renamed, or made private. Use the PR description, not the source file.
- Multi-paragraph descriptions of how a struct's fields fit together.
- Tutorial-style explanations of how to use the API.

**When lint forces a doc comment** on an exported symbol: write ONE short line. Lead with the identifier name. State only the WHY-bit, or the most compact one-clause summary if there is no WHY.

**When in doubt, delete the comment.** Let the symbol name carry the meaning. If a reviewer flags a comment as bulky, treat it as a bug and trim it on the spot.

</code_comment_rules>

<validation>

- Run targeted tests/lint first for changed scope; broaden if needed.
- For bug fixes, add a regression test when practical.
- Prefer end-to-end verify; if blocked, say what's missing.
- If validation cannot be run, state what was blocked and why.

</validation>

<research_and_context>

Use MCP tools proactively before guessing. Prefer MCP over generic web search for anything project- or org-specific.

- **`ide__getDiagnostics`**: editor diagnostics for the currently open files.
- **WebSearch**: external/current info and third-party library docs.

Add project-specific MCP servers per machine as needed; keep this file free of any employer-specific tooling.

</research_and_context>

<skill_authoring_style>

Skills are orchestrators, not convention repositories. When creating or editing skills:

- **Skill body** = workflow steps, inputs/outputs, orchestration logic, skill-specific anti-patterns.
- **Shared conventions, format specs, style guides, schemas** = a markdown file under `~/.claude/refs/` that any skill can point at. Do not inline this content in a SKILL.md.
- Each SKILL.md leads with a `<conventions>` block listing the refs it depends on (path + one-line purpose). Inside the workflow, point at refs by absolute path (e.g. "follow `~/.claude/refs/status-md.md`") rather than restating their content.

**Before creating a new ref or skill**: list `~/.claude/refs/` and `~/.claude/skills/` and read the descriptions/frontmatter of anything plausibly related. Prefer extending or referencing an existing ref/skill over creating a new one. Only create new when nothing fits.

**When to extract a new ref**: when 2+ skills would otherwise duplicate the same convention/format content. Single-consumer content stays inline in the consuming skill.

**Skill DAG rule**: skills may reference refs (cheap, just an inline file read on demand) and may invoke other skills (heavier — a full Skill-tool call). Prefer references over invocations unless the downstream piece has side effects (file writes, git, gh).

</skill_authoring_style>
