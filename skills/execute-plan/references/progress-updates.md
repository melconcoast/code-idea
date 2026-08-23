# Progress updates

Every write this skill makes to a plan file or the roadmap. Read it before the first write in Step 4.

**This file is subordinate, not a second specification.** The plan file's format, its four-state
checkbox vocabulary, and its counting rules are specified once, in `plan-module`'s
`references/plan-template.md`. The roadmap's `Status` vocabulary is specified once, in `scaffold`'s
`references/templates.md`. This file only says how to *apply* them while executing, and adds nothing
to either. Where it appears to disagree with one of them, that file wins and this one is the bug.

Two consequences worth stating plainly: **never introduce a glyph or a status word the plan file and
roadmap don't already use**, and **never write a percentage** — counts are closed-over-total so that
adding a task mid-flight doesn't silently rewrite history.

## When a task closes

Four edits, in the same pass as the code — never deferred to the end of the phase:

1. **The task's glyph**, plus the glyph on each scenario the tests covered. A scenario whose test
   didn't run stays open, even when the task around it is finished — that gap is information.
2. **The phase's `Progress:` count.** Recount from the file rather than incrementing what's there; a
   stale count is how the arithmetic drifts. An item is closed unless it is `[ ]`, the phase's `X.V`
   gate is counted in its total, and scenarios are never counted — they're evidence for a task, not
   units of progress.
3. **`## Files Modified`** — every file created or changed, by real path, appended. Not summarized,
   not globbed, not "various test files". This list is how the next agent finds the work.
4. **`Last Updated`** in the header, to today's date.

The `## Progress Log` is not touched per task — it gets one line per phase, at the gate.

## When a phase closes

At the `X.V` gate, after the whole module's suite is green:

- Close the gate item and set the phase's `Status:` line to `[x] Done`.
- Recompute `Overall Progress` across phases by the same closed-over-total rule.
- Append **one** dated `## Progress Log` line: what the phase delivered, and anything a later reader
  would otherwise have to reconstruct — a reframe and why, a scenario that couldn't be verified, a
  decision forced along the way. The log is append-only. Earlier lines are the record of what
  happened and are never rewritten, edited, or tidied, even when they turn out to have been wrong.
- Set the header `Status:` to `Done` only when every phase in the file is closed.

Good log lines are specific about consequence:

> - 2026-08-24: Phase 1 closed. Queue endpoint and page built and verified against three seeded
>   orders. Task 1.2 reframed — the ordering belongs in the query, not the view, so pagination later
>   doesn't reorder rows.

Not `- 2026-08-24: Did Phase 1.`

## Writing back to the roadmap

The plan file tracks tasks; `docs/development-roadmap.md` is the index of what's built. Nothing else
updates it, so an unsynced roadmap sends the next `plan-module` run at a module that's already done.

- **When a phase starts**, its sub-module becomes the in-progress status.
- **When a phase closes**, its sub-module becomes the done status.
- **When every phase in the file is closed**, the module itself becomes done.
- Match a phase to its sub-module through the `**Tasks:**` pointer `plan-module` wrote — that pointer
  names the plan file and the phase. If a phase has no matching sub-module, or a sub-module's pointer
  names a phase that isn't in the file, say so instead of guessing; that mismatch is a real problem
  in the handoff, not noise to route around.

Use the status words already in the roadmap. That vocabulary is closed and it isn't this skill's to
extend — a status the file has never used is a sign you're inventing one.

**Change status and nothing else.** Not `In scope:`, not `Out of scope:`, not `Depends on:`, not the
`**Tasks:**` pointer, and never a task table — task detail lives in the plan file only. Discovering
that a module's scope was wrong is a finding to report, and a roadmap edit the user makes.

## What never enters either file

- Implementation code, test code, schemas, migrations, or function signatures. The plan file names
  what exists; the repository holds it.
- Credentials, tokens, connection strings, private hostnames or IPs, or real customer data — including
  inside a Progress Log line or a `## Files Modified` path. Both files get committed.
- A fifth glyph, a free-text status, or a percentage.
