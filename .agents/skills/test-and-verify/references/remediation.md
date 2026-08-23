# Remediation and reporting

Read this before the first fix in Step 3.

## Application bug or test bug

Every failure is one or the other, and picking wrong makes both worse — a real bug gets papered over
by "fixing" the test, or a correct implementation gets bent to satisfy a broken assertion. Decide
before editing, and say which you concluded.

**It's the application code when** the test states the behavior the project's own docs or the plan's
scenario describe, and the code does something else. The test is the specification here; it wins.

**It's the test when** the behavior is right and the check is wrong — a mock that no longer matches
the real signature, a hard-coded date or ID that drifted, an assertion on incidental output like key
order or whitespace, a fixture that was never updated after a deliberate change.

**When you can't tell, it's the application code.** That default fails safe: a real bug stays visible
instead of being erased.

**When the test contradicts the project's stated rules** — `docs/product.md`, the root context file, a
plan scenario — that's neither. Stop and report it. A scenario is a decision someone made, and
overruling it is not a remediation.

## What a targeted fix looks like

- **One change per attempt.** Change two things and a green run tells you nothing about which mattered.
- **The smallest edit that addresses the diagnosed cause.** Not a refactor that happens to include it.
- **Nothing outside the failure's blast radius.** A passing test you find unconvincing, a helper you'd
  have written differently, a type you'd tighten — report those, don't touch them.

Never do these, whatever the pressure to get to green:

- Delete or comment out an assertion, or loosen a matcher until it stops discriminating
- Add a skip, an `.only`, or a filter that removes the failure from the run
- Rewrite the expected value to whatever the code currently produces
- Widen a timeout to hide a race rather than fixing the race

Each turns a red suite green while leaving the bug in the codebase, and the report that follows is
then false. If the honest outcome is "still failing", that is the outcome.

## The circuit breaker

Three remediation attempts, then stop — the run itself plus at most three fixes.

The bound is not arbitrary: past three, the failure almost always means the diagnosis was wrong rather
than the fix was, and further attempts edit more files on a premise that was never true. Handing back
a clear dead end is more useful than a fourth guess and a wider diff.

If an attempt makes things worse — new failures that weren't there before — revert that change before
handing back. The caller should receive the codebase no worse than you found it.

## Report formats

Both are terminal output for a caller. Be exact about the command and the counts; those are what the
caller acts on.

**Passing:**

```text
✅ Verification Passed
- Target:   Task 2.1  (or: Phase 2 Gate)
- Executed: npm test -- test/mark-done.test.js
- Result:   3 passed, 0 failed, 0 skipped
- Checks:   type-check clean · lint clean     (gate runs only)
- Action:   Task 2.1 and its scenarios may be marked [x].
```

**Failing:**

```text
❌ Verification Failed — circuit breaker after 3 attempts
- Target:   Task 2.2
- Executed: npm test -- test/mark-done-endpoint.test.js
- Result:   2 passed, 1 failed
- Failing:  Scenario 2.2b — refusal does not name the pickup date
- Diagnosed: application code — the 409 body carries a generic message
- Attempted: (1) returned the date in the body  (2) ... (3) ...
- Ruled out: the test's assertion matches docs/product.md's wording
- Action:   Task 2.2 stays [ ]. Handing back — the remaining failure looks like
            <best read on the cause>.
```

Two rules about the wording:

- **Never imply partial success on a failing run.** "Mostly passing", "just one left", "nearly there"
  all get read as green by a caller deciding whether to close a box.
- **Name what you noticed and left alone.** An unrelated bug, a test you think is weak, a skipped
  suite you didn't own — the caller needs those, and they are not yours to fix silently.

If the project has no type-checker or linter, write that rather than omitting the `Checks` line. An
absent line reads as a check that passed.
