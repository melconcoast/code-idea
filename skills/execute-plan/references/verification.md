# Verification

`[x]` means *verified*, not *written*. This file is what that costs. Read it in Step 1, before the
first task closes, and again whenever a scenario resists being checked.

## Finding the test runner

Look in this order and stop at the first real answer:

1. The root context file's `## Commands` section — `CLAUDE.md` or `AGENTS.md`. This is where a
   previous pass of this skill records what it set up.
2. The project manifest — `package.json` scripts, `pyproject.toml`, `Makefile`, `go.mod`, `Cargo.toml`.
3. A CI workflow. What CI runs is what the project considers a pass, whatever the docs say.
4. An existing test directory. If tests exist, something runs them; find it before writing more.

A command you found is better than one you invented, even when yours is tidier.

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

## What counts as green

- The suite ran, you read its output, and it reported zero failures.
- The scenarios for *this* task are among the tests that ran. A suite that passes because it skipped
  them is not a pass — check for skips, `.only`, and filters that quietly excluded new tests.
- Type-checks and linters pass where the project has them. Neither substitutes for a test run.

A pass you inferred, assumed, or reconstructed from a partial log is not a pass. If you can't see the
output, you can't close the item.

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
