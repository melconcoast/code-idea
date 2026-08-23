# Writing test scenarios

Every development task in a plan file carries 1–3 scenarios. They exist so `execute-plan` can tell
whether a task is actually done, and so a human reviewing the plan can spot a missing requirement
before any code is written. Read this in Step 3, and again whenever a scenario comes out vague.

## The bar

A scenario is checkable when someone who has never seen the code can read it, exercise the system,
and say yes or no without asking a follow-up question. If confirming it requires opening the
implementation to find out what "correct" means, the scenario is not finished.

State three things: the starting condition, the action, and the observable result. The phrasing
doesn't have to be Given/When/Then, but all three parts have to be recoverable from the sentence.

## Weak and strong pairs

| Weak | Strong |
|---|---|
| Test that assignment works | Assigning an unassigned task to a workspace member sets that member as the assignee and returns the updated task |
| Handles errors properly | Assigning a task to a user who is not a member of the workspace is rejected, the task keeps its previous assignee, and nothing is written |
| Validates input | A status transition request with a status outside `todo`/`in_progress`/`done` is rejected before any write, and the response names the offending value |
| Should be fast | A workspace with 500 tasks returns its task list in one request, without the caller paginating manually |
| Verify the migration ran | After migrating, every existing task has a non-null `status`, and tasks that had no status before read `todo` |

The weak column fails the bar for the same reason each time: "works", "properly", "validates", "fast"
are judgments the reader has to supply themselves.

## Coverage per task

- **At least one happy path.** The task's reason for existing, exercised once, end to end.
- **At least one edge or error case wherever the task can fail** — rejected input, a missing record,
  an unauthorized caller, a boundary value, a concurrent write. Most tasks can fail. A task with only
  a happy path is under-specified, and should be challenged rather than shipped.
- **Stop at three.** More than three scenarios on one task is a signal the task is doing too much;
  split the task instead of stacking scenarios onto it.

## Business rules get their own scenario

If the project's root context file or `docs/product.md` states a rule the module touches — a
forbidden state transition, an authorization boundary, a pricing rule, a retention limit — write a
scenario asserting it directly, in the rule's own words. These are the requirements a coding agent
is most likely to satisfy approximately, and approximately is wrong.

Where a rule is stated as a prohibition, the scenario is the prohibition:

> *Scenario 2.1b:* A request moving a task directly from `todo` to `done` is rejected and the task
> stays `todo`.

## Never write test code

Scenarios are plain English. No assertions, no framework names, no fixture setup, no `expect(...)`,
no describe blocks, no HTTP snippets. `execute-plan` chooses the framework and writes the tests; a
scenario that names one has made that decision early and probably wrongly.

- Wrong: `expect(res.status).toBe(403)` for a non-member
- Right: A non-member's assignment request is refused as unauthorized

Naming a status code, an endpoint path, or a field in prose is fine — that's the behavior. Writing
the call that checks it is not.

## Scenarios are not the same as the gate

Per-task scenarios describe behavior. The phase's `Task X.V` gate is the instruction to actually run
the suite covering them and confirm zero failures. Don't collapse the two: a phase with scenarios but
no gate never gets verified as a whole, and a gate with no scenarios beneath its tasks has nothing
specific to verify.
