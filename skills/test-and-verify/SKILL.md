---
name: test-and-verify
description: Runs a project's tests, reads the real output rather than the exit code, and fixes what fails — a bounded diagnose-fix-rerun loop that stops after three remediation attempts instead of guessing on, and never weakens a test to reach green. Targets the suite relevant to the work, and adds the type-checker and linter at a phase gate. Reports a plain pass or fail verdict with the exact command it ran, and never edits a plan file — the caller marks the boxes. Use this skill whenever tests are to be run or a failure chased down: "run the tests", "run the test suite", "verify this", "check the tests pass", "fix the failing tests", "why is this test failing", or when `execute-plan` needs a task or a `Task X.V` gate verified. Use it even when the request looks like a one-liner — the bounded loop and the honest verdict are the point, not the command. Not for writing a feature or its tests from a plan — use execute-plan. Not for standing up a project's first test runner — use execute-plan.
---

# test-and-verify

Runs the tests, reads what actually happened, and fixes what's broken — within a bounded number of attempts, then hands back.

## When this runs
- `execute-plan` finishes a task and needs its scenarios proved, or reaches a `Task X.V` phase gate
- The user asks for the suite to be run, or for a failing test to be chased down
- Never to decide *what* to build, and never to write a feature's first tests from a plan — that's `execute-plan`

## Core philosophy
- **A pass you didn't read isn't a pass.** Run the command, read stdout and stderr, and check the counts. A suite that "succeeded" because it collected zero tests, skipped the new ones, or exited 0 on a crash is a failure wearing a green hat.
- **Three attempts, then stop.** The loop is bounded on purpose. A fourth attempt is guessing, and guessing costs tokens and makes the diff worse. Hand back with what you know.
- **Fix only what the failure names.** Not the code around it, not a style you'd have written differently, not a passing test you find unconvincing. Unrelated findings get reported, never fixed in passing.
- **The failure decides what to fix — application code or the test.** These are different bugs, and picking wrong makes both worse. Say which one you concluded and why before you change anything.
- **Never edit a plan file.** Not a glyph, not a count, not the Progress Log. This skill produces a verdict; `execute-plan` writes it down. Two writers on one file is how a plan stops being trustworthy.
- **Never weaken a test to make it pass.** Deleting an assertion, loosening a matcher, adding a skip, or narrowing the run until the failure is out of scope is not a fix — it's hiding the bug and reporting green.

## Workflow

### Step 1 — Find the command, and the right scope for it
- If the caller supplied a command, use it. Otherwise discover it — see `references/test-commands.md`.
- **Default to the tests relevant to the work at hand**, not the whole suite. A targeted run is faster and its output is readable.
- **A `Task X.V` phase gate is the exception**: run the whole module's suite, plus the project's type-checker and linter if it has them. The gate exists to catch what this phase broke somewhere else, and a targeted run cannot see that.
- If no runner exists at all, say so and hand back. Setting one up is a project decision that belongs to `execute-plan`, not a remediation step.

### Step 2 — Run it and read the output
- Run the command. Capture stdout and stderr, and read them — the exit code alone is not the result.
- Confirm the tests you expected actually ran. Check the reported counts, and check for skips, filters, or `.only` that quietly excluded them.
- Green, with the expected tests genuinely run: stop here and report. Don't keep going, and don't tidy anything on the way out.

### Step 3 — Diagnose, fix, re-run — at most three times
- Read the failure properly: the assertion, the stack trace, the actual-versus-expected. Guessing from the test's name is how the wrong file gets edited.
- Decide whether the bug is in the **application code** or in the **test** — a bad mock, a wrong assertion, a fixture that drifted — and say which before changing anything. See `references/remediation.md`.
- Apply one targeted fix, then re-run. One change per attempt, so the next run tells you something.
- **After the third failed attempt, stop.** Report what failed, what you tried, what you ruled out, and your best read on the cause. Handing back a clear dead end beats a fourth guess.

### Step 4 — Report the verdict
- State plainly: passed or failed, the exact command run, the counts, and what the caller may now do.
- On a gate run, report the type-check and lint results too, and say explicitly if the project has neither rather than implying they passed.
- On failure, never imply partial success. A caller that reads "mostly passing" as green is the failure mode this whole skill exists to prevent.
- Report anything you noticed but deliberately did not fix. See `references/remediation.md` for both report shapes.

## Reference files
- `references/test-commands.md` — where to find the right command per ecosystem, targeted versus full-suite invocation, and the type-check and lint commands a gate adds. Read this in Step 1 when no command was supplied.
- `references/remediation.md` — telling an application bug from a test bug, what a targeted fix looks like, the circuit breaker, and the exact pass and fail report formats. Read this before the first fix in Step 3.
