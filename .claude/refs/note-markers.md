# note: / #NOTE: marker convention

User feedback embedded in feature docs is left as a marker the agent must resolve on the next pass.

## Markers

- `note:` (lowercase, at start of a line or list item) — inline reviewer comment
- `#NOTE:` (uppercase, anywhere on a line) — same meaning, alternate style

Either marker, in any feature doc (`MASTER.md`, `STATUS.md`, `M*_SCOPE.md`, etc.), means: "this is user feedback the next agent must address."

## Resolution rules

When an agent reads a feature doc that contains `note:` or `#NOTE:` lines:

1. Treat each marker as an actionable review comment.
2. Resolve the comment during the same edit pass (don't defer).
3. After resolving, **remove the marker line** or replace it with the addressed content.
4. If the comment cannot be resolved in this pass, leave it but state explicitly in the handback that it was deferred and why.

## Examples

**Before** (user added during review):
```
- [ ] M3.2: Add usage_policy enforcement to BFS
  note: should we also add a metric counter here?
```

**After** (agent resolved, then removed marker):
```
- [ ] M3.2: Add usage_policy enforcement to BFS
- [ ] M3.3: Add `event_graph.usage_policy_denied_total` Prom counter
```

## Anti-patterns

- Don't ignore `note:` / `#NOTE:` lines and ship the next change.
- Don't preserve a marker after resolving it — that creates phantom feedback for future agents.
- Don't auto-resolve silently; record the resolution in the relevant doc section (decisions, tasks, etc.).
