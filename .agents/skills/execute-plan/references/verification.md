# Verification

`[x]` means *verified*, not *written*. This file is what that costs. Read it in Step 1, before the
first task closes, and again whenever a scenario resists being checked.

## Finding the test runner

`test-and-verify` owns that search and the discovery order it follows — see its
`references/test-commands.md`. Don't run a second, divergent search here; hand it the run and take
its answer.

What matters at this level is only the fork: a runner exists, or none does. If one exists, this skill
never needs to know the command. If none does, the next section is yours.

## Bootstrapping one when there is none

In the `scaffold` → `plan-module` → `execute-plan` chain the project starts with no code at all, so
"no test runner" is the normal state of a first module, not a broken project. Set one up as part of
the first task rather than stopping.

- **Fit the stack the project already chose.** The root context file and `docs/decisions.md` decided
  the language, framework, and database. Pick the runner that stack's ecosystem defaults to. Never
  introduce a language or framework those docs didn't choose — that's a decision, and it isn't yours.
- **A `Status: Pending` decision in `docs/decisions.md` is not yours to settle either.** If the
  pending choice genuinely blocks testing, follow whatever "meanwhile" instruction that entry carries;
  if it has none, say what you assumed and why.
- **Smallest thing that runs.** A runner and one command. Not coverage thresholds, not a CI pipeline,
  not fixtures for tasks that don't exist yet. Tooling nobody asked for is scope you added.
- **Then record it.** Write the real commands into the root context file's `## Commands` section,
  replacing the placeholder. `scaffold` writes "not yet established" precisely because it can't know
  this yet — this is the step that closes that loop, and it belongs in `## Files Modified` like any
  other change.

## What counts as green, for closing a plan item

`test-and-verify` decides whether the run passed. This skill decides whether that pass closes a
checkbox — a narrower question, and the two can differ.

- The verdict is a pass, and the scenarios for *this* task are among the tests that actually ran. A
  green run that skipped them closes nothing.
- A failing verdict closes nothing, however close it looked. Re-invoking the verifier to get past its
  circuit breaker is not a second opinion, it's the same attempt with the safety removed.
- Type-checks and linters passing is not a substitute for a test run, and neither is a build.

A pass you inferred, assumed, or reconstructed from a partial log is not a pass. If you can't see the
verdict, you can't close the item.

## One test per scenario, in the scenario's own terms

Each scenario beneath a task gets its own test, checking the behavior that scenario names — not a
neighbouring behavior that happens to be easier to assert.

> *Scenario 2.1b:* Marking an order done before its pickup date is rejected, the order stays open,
> and nothing is written.

Three observable claims: rejected, still open, nothing written. A test asserting only the rejection
leaves two-thirds of the scenario unchecked, and the scenario's checkbox would be a lie.

Name the tests after the behavior, not the function under test. The scenario is the specification the
next reader compares against.

## When a scenario is wrong

Sometimes the code is right and the scenario is mistaken — it contradicts the project's own rules,
describes behavior the roadmap put out of scope, or is simply impossible.

**Stop and confirm before changing it.** Say what the scenario claims, what the code does, and which
you believe is wrong. Rewriting a scenario to match the code you just wrote turns the suite into a
description of whatever exists, which is exactly the thing it was written to prevent.

Once confirmed, the scenario is a `[~]` reframe with its reason — never a silent edit.

## When a scenario can't be checked here

Some behavior genuinely can't be verified in the environment you have — it needs a live third-party
service, real payment credentials, or hardware.

Say so explicitly rather than closing the item on faith. Verify the part you can — that the call is
made, with the right shape, and that failures are handled — and leave the rest visible: `[~]` with
the reason and what would verify it. An unverifiable scenario marked `[x]` is the one failure mode
this whole vocabulary exists to prevent.
