# Plan file template

The exact shape of `docs/guides/feature_<module_name>_plan.md`. Read this before drafting in Step 3.
`execute-plan` parses this file, so the structure is a contract — the headings, the checkbox glyphs,
and the counting format are fixed. Prose inside a *Details* line or a scenario is free.

## Filename

`docs/guides/feature_<module_name>_plan.md`, snake_case, derived from the roadmap module title with
the `Module <n> — ` prefix dropped.

| Roadmap module | Plan file |
|---|---|
| `## Module 1 — Task core` | `docs/guides/feature_task_core_plan.md` |
| `## Module 3 — Assignment` | `docs/guides/feature_assignment_plan.md` |
| `## Module 4 — Billing & invoicing` | `docs/guides/feature_billing_invoicing_plan.md` |

Drop punctuation, lowercase everything, join words with underscores. One file per module.

## Checkbox vocabulary — exactly four states

| Glyph | State | Meaning | Required annotation |
|---|---|---|---|
| `[ ]` | Open | Pending, not started | none |
| `[x]` | Done | Completed **and verified** — test output, build log, or smoke test | none |
| `[~]` | Reframed | Changed mid-flight | `(reframed: <reason or replacement>)` |
| `[-]` | Skipped | Deliberately omitted | `(skipped: <reason>)` |

No fifth state, and no free-text substitutes. `[x]` means verified, not "written" — a task whose code
exists but whose scenarios never ran is still `[ ]`. `execute-plan` relies on that distinction to
know what it still owes.

## Counting rules — closed items, never percentages

- An item is **Closed** when it is `[x]`, `[~]`, or `[-]`. Only `[ ]` is open.
- Write counts as `[<closed>/<total> Tasks Closed]` and `[<closed>/<total> Phases Closed]`.
- Never write a percentage. `3/7` survives a task being added mid-flight; `43%` silently becomes a lie.
- A phase's task total **includes** its `X.V` gate task. The 3–4 task cap in Step 2 is on development
  tasks only, so a full phase counts 4 or 5.
- Scenarios carry their own checkboxes and are **not** counted in the task totals. They are evidence
  that a task is done, not units of progress on their own.

## Template

```markdown
# <Module Name> Plan
Status: In Progress | Last Updated: <YYYY-MM-DD> | Overall Progress: [0/<Total Phases> Phases Closed]

## Progress Log
- <YYYY-MM-DD>: Plan initialized via plan-module skill.

## Files Modified
*(Accumulated during execution)*

---

## Phase 1: <Phase Title>
- Status: [ ] Open
- Dependencies: None
- Progress: [0/<Total Tasks> Tasks Closed]

### Tasks & Test Scenarios
- [ ] **Task 1.1: <Development Task Title>**
  - *Details:* <What gets created or changed — endpoints, tables, data shapes, by name>
  - [ ] *Scenario 1.1a:* <Happy-path behavior>
  - [ ] *Scenario 1.1b:* <Edge case or error handling>

- [ ] **Task 1.2: <Development Task Title>**
  - *Details:* <What gets created or changed>
  - [ ] *Scenario 1.2a:* <Happy-path behavior>

### Phase Completion Gate
- [ ] **Task 1.V: Run test-and-verify suite for Phase 1**
  - *Details:* Execute the tests covering Phase 1, confirm zero failures, confirm type-checks pass, then mark Phase 1 complete.

---

## Phase 2: <Phase Title>
- Status: [ ] Open
- Dependencies: Phase 1
- Progress: [0/<Total Tasks> Tasks Closed]

### Tasks & Test Scenarios
- [ ] **Task 2.1: <Development Task Title>**
  - *Details:* <What gets created or changed>
  - [ ] *Scenario 2.1a:* <Happy-path behavior>

### Phase Completion Gate
- [ ] **Task 2.V: Run test-and-verify suite for Phase 2**
  - *Details:* Execute the tests covering Phase 2, confirm zero failures, then mark Phase 2 complete.
```

Phases repeat this shape. Separate every phase with a `---` rule.

## The living sections

**`## Progress Log`** starts with one dated initialization line and is append-only during execution.
A re-plan appends a line naming what was re-cut; it never rewrites earlier lines. This is the same
append-only discipline `docs/decisions.md` uses, and for the same reason — the log is the record of
what happened, not a summary of the current state.

**`## Files Modified`** starts as the literal italic line `*(Accumulated during execution)*` and is
filled in by `execute-plan` as it touches files. `plan-module` never populates it — at plan time
nothing has been modified, and guessing which files a task will touch is exactly the invented
implementation detail this file forbids.

## Header fields

- **Status** — `In Progress` from the moment the plan is written, since planning a module is the
  start of working on it. It becomes `Done` when every phase is closed.
- **Last Updated** — today's date, rewritten on every edit including each execution pass.
- **Overall Progress** — phases closed over total phases, by the counting rules above.

A **phase's** own `Status:` line takes the same two words and carries a glyph: `[ ] Open` while any
item in it is open, `[x] Done` once every item including the `X.V` gate is closed. `execute-plan`
flips it at the gate; nothing else writes it.

Those are the whole line — nothing is appended to either. `[x] Done (server-side only)` or
`[x] Done (rebuilt 2026-08-22)` is a free-text status wearing a glyph, and it breaks the same parse a
fifth glyph would. A phase that closed with something worth saying says it in the Progress Log, which
is what that section is for.

## What never appears in this file

- Implementation code, test code, schemas, migrations, or function signatures. Naming an endpoint or
  a table in *Details* is right; writing it out is not.
- Credentials, tokens, connection strings, private hostnames or IPs, or real customer data. Use a
  named reference (`DATABASE_URL`, `<internal-host>`).
- Percentages, free-text statuses, or a fifth checkbox glyph.
- Any scope the roadmap block marks `Out of scope:`.
