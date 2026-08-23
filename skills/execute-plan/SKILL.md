---
name: execute-plan
description: Builds a module from the plan file `plan-module` wrote — `docs/guides/feature_<module>_plan.md` — in a strict micro-loop: implement exactly one task, write the test code its plain-English scenarios describe, run it until green, then update the plan file before touching the next task. Stops at every phase verification gate to report and ask. Keeps closed counts, the Progress Log, Files Modified, and `docs/development-roadmap.md` statuses true as it goes. Use this skill when the user says things like "execute the plan", "build task 2.1", "start phase 2", "continue building this module", "implement the next task", "work through the plan", or is ready to write code against a plan file that already exists. Not for creating a project's agent docs or its roadmap — use scaffold. Not for cutting a module into phases or re-planning one — use plan-module.
---

# execute-plan

Builds a module from its plan file one task at a time — real code, real tests, actually run — and keeps the plan file and the roadmap true as it goes.

## When this runs
- A `docs/guides/feature_<module>_plan.md` exists and the user is ready to build it
- Work resumes on a plan already partly closed — pick up at the first open task, never restart
- Never as a project's first step. No plan file means there is nothing to execute: hand off to `plan-module`, or to `scaffold` if there's no `docs/development-roadmap.md` either

## Core philosophy — hold these through every loop
- **One task, then verify, then write.** Implement exactly one development task and the scenarios beneath it, get them green, update the plan file, and only then look at the next task. Batching a phase is how a plan file stops matching the code it claims to describe.
- **`[x]` means verified, not written.** A task whose code exists but whose scenarios never ran is still `[ ]`. Never close an item on inspection, on intent, or on a type-check alone — something has to have actually run.
- **The plan file is updated in the same pass as the code, not at the end.** If the loop is interrupted after code lands and before the file is written, the plan lies about what exists — and the next agent trusts it.
- **A roadblock is a reframe, never a deletion.** When an approach doesn't survive contact, mark the task `[~]` with its reason and the replacement, and say so out loud. Silently dropping a task erases the decision that was made.
- **A task's scope is its *Details* and its scenarios.** Don't widen it mid-loop, don't fix adjacent things you noticed, don't start the next task early. Anything else you find gets reported, not built.
- **Never write a secret into the plan file.** Credentials, tokens, connection strings, private hostnames and IPs, real customer data — this file gets committed. Use a named reference (`DATABASE_URL`), the same rule the plan itself follows.

## Workflow

### Step 0 — Find the plan, then confirm you may start
- Locate the plan file: the one the user named; else the only one in `docs/guides/`; else list them with their progress and ask which.
- Read it whole before touching anything — the header counts, every phase's `Status` and `Dependencies`, every item's glyph. Then read the root context file (`CLAUDE.md` / `AGENTS.md`) and the docs it links: its rules and conventions bind the code you're about to write.
- Select the first phase that isn't closed. **A phase whose `Dependencies:` name a phase that is still open does not start** — name the blocking phase and stop.
- **If the plan disagrees with the repository — a closed task whose code isn't there, a `## Files Modified` path that doesn't exist — stop and report it.** Don't build on a closure that isn't true, and don't quietly repair it either: reopening a phase the file calls done is the user's call, and rewriting the record to match reality erases the evidence of what happened.
- Within that phase select the **first** `[ ]` development task. Don't look ahead, don't reorder, don't take an easier one first.
- Announce that task by number and title before starting work, and re-announce on every pass through the loop.

### Step 1 — Make sure "verified" can mean something
- Establish how this project runs tests before closing the first task. If a runner exists, use it — `test-and-verify` finds it; don't duplicate that search here.
- **If there is none, set one up as part of this first task.** The scaffold chain starts a project with no code, so this is the normal case, not an error. Pick what fits the stack the project's docs already decided; never introduce a language or framework those docs didn't choose.
- Write the real commands back into the root context file's `## Commands` section, replacing the placeholder `scaffold` left there. A project whose docs can't tell the next agent how to run its tests is unfinished.
- Read `references/verification.md` before deciding what counts as green.

### Step 2 — Implement exactly one task
- Write the application code the task's *Details* describes — the endpoints, tables, and data shapes it names, and nothing it doesn't.
- Then write the test code covering that task's scenarios: one test per scenario, in that scenario's own terms. Scenarios are plain English on purpose — picking the framework and the assertions is this skill's job, and the first task's choice binds the rest.
- Follow the project's stated conventions over your own defaults. Where its docs are silent, match the surrounding code.

### Step 3 — Verify, through `test-and-verify`
- **Hand the run to `test-and-verify`**, naming the task and the tests that cover it. It finds the command, runs it, reads the output, and fixes what fails within a bounded loop. Only run the tests inline if that skill isn't available, and then by its rules.
- Take its verdict as given. A pass closes the task; **a fail does not**, and re-invoking it to get around its three-attempt circuit breaker defeats the point of having one — stop and report instead.
- If it reports the scenario wrong rather than the code, stop and confirm before editing the scenario. The scenario is the spec; rewriting it to match a bug is how a suite stops meaning anything.
- If the task can't be built as written, stop the loop: mark it `[~]` with the reason and the replacement approach, report it, and ask before continuing.

### Step 4 — Write the plan file, then loop
- Mark the task and each scenario it covered, recompute that phase's `[<closed>/<total> Tasks Closed]`, append every file you created or changed to `## Files Modified` by real path, and rewrite `Last Updated`.
- Read `references/progress-updates.md` for the exact edits, the counting rules, and the roadmap write-back before the first of these writes.
- Return to Step 0's task selection and take the next `[ ]` task in the same phase.

### Step 5 — The phase gate, then stop
- When every development task in the phase is closed, the one item left is `Task X.V`. Hand it to `test-and-verify` **as a gate run**, which widens it to the whole module's suite plus the project's type-checker and linter — the gate exists to catch what this phase broke elsewhere, and a targeted run can't see that.
- Green: close the gate, set the phase to `Status: [x] Done`, update `Overall Progress`, append one dated Progress Log line saying what the phase delivered, and flip the matching sub-module in `docs/development-roadmap.md`. Status values are bare — a caveat worth recording goes in the Progress Log, never appended to a status.
- Red: the phase does not close. Fix the regression, or mark the offending task `[~]` and report it. A gate that gets closed over failing tests is worse than no gate, and a gate reporting a type-check or lint that never ran is worse still.
- **Stop here.** Report what closed, what's still open, and what the next phase needs, then ask whether to continue. A phase boundary is the user's decision point, not yours.

## Reference files
- `references/verification.md` — bootstrapping a test runner when the project has none, what counts as verified, and what to do when a scenario can't be checked. Read this in Step 1.
- `references/progress-updates.md` — the exact plan-file edits, the counting rules, and how progress flows back to `docs/development-roadmap.md`. Read this before the first write in Step 4.
