# M<ID> Scope - <Milestone Name>

- Feature:
- Milestone ID:
- Last updated:
- Status:
- Parent docs:
  - `MASTER.md`
  - `STATUS.md`

## Goal

## Success Criteria

- [ ] <criterion>

## PR Groups and Tasks (Smallest Change, Stacked)

### PR1: <title>

- Scope: <smallest reviewable unit>
- Depends on: <none or milestone/PR dependency>
- [ ] M<ID>.1 <task>
- [ ] M<ID>.2 <task>
- Validation:
  - `<command>`

### PR2: <title>

- Scope: <next dependent unit>
- Depends on: PR1
- [ ] M<ID>.3 <task>
- [ ] M<ID>.4 <task>
- Validation:
  - `<command>`

## STATUS.md Mapping (PR-Grouped)

Status semantics + transition rules: see `~/.claude/refs/status-md.md`.

- Milestone line: `- [ ] M<ID>: <milestone name>`
- PR title groups:
  - `- [ ] PR1: <title>`
  - `- [ ] PR2: <title>`
- Tasks nested under each PR group:
  - `- [ ] M<ID>.1 <task>`
  - `- [ ] M<ID>.2 <task>`
- PR links added during implementation; no placeholders.

## File Touchpoints

- `<path>`: <change summary>

## Dependencies and Sequencing

1. <dependency or required order>
2. PR stack: `PR1 -> PR2 -> ...`

## Planned Code Sketches (Plan-Mode Style)

### 1) <schema/proto/model sketch>

```<language>
<concrete snippet>
```

### 2) <service/controller/query sketch>

```<language>
<concrete snippet>
```

### 3) <commands/runbook sketch>

```bash
<concrete commands>
```

## Rollout and Verification Plan

- Rollout:
- Verification:

## Architecture Decisions (Locked)

Every architecture-level decision was resolved before this doc was written.
Each row below is a decision the user explicitly answered.

| # | Decision | Rationale |
|---|---|---|
| A1 | <decision> | <why> |
| A2 | <decision> | <why> |

## Open Questions for Review

**Scope of this section is non-architecture only** — rollout ordering, who owns
review, ad-hoc operational concerns. All architecture-level decisions live in
the section above. If an item below feels architectural, move it up and
re-confirm with the user before scope completes.

1. <non-architecture question>
