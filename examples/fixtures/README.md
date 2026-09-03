# Runnable fixtures

Every other fixture in `../test-scenarios.md` is prose — a paragraph describing a repo you construct
by hand. `pickup-queue/` is the exception: a real project you can copy and run a skill against.

It exists because a behavioral claim about a skill can't be settled by reading the skill. The rule
that reads as obviously necessary is often the one an agent was already following, and the only way
to tell the difference is to run both texts against the same input.

## What's in it

A dependency-free Node project — `node --test`, no install step, no build, no network. Five tests
pass on a clean copy.

| | |
|---|---|
| `docs/development-roadmap.md` | Module 2 in progress, sub-module 2.1 `done`, 2.2 `planned`. Vocabulary-clean against `scaffold`'s `references/templates.md` |
| `docs/guides/feature_pickup_queue_plan.md` | Phase 1 truthfully closed `[2/2]`; Phase 2 fully open, three development tasks plus its gate |
| `docs/conventions.md` | Binding UI rules a general-purpose design skill will push against — no CSS frameworks, server-rendered strings, and only the three custom properties already in `public/styles.css` |
| `src/`, `test/` | Phase 1's real code and real tests, matching what the plan claims |

This realizes **Fixture I**. It diverges from the prose chain in two ways, both deliberate: the module
is *Pickup queue* rather than *Staff queue*, so the roadmap and plan file agree internally without
needing Fixtures E and F built alongside it; and the code is `.js`, because Fixture G's `.ts` paths
describe files that were never written and a fixture that needs a toolchain is a fixture nobody runs.

Phase 2's three tasks deliberately span three domains — a data query, a view, and an HTTP route — so a
scenario about per-task behavior has somewhere to show itself.

## Deriving the other execution fixtures

- **Fixture H** (a failing suite): change `today < order.pickupDate` to `today <= order.pickupDate`
  in `src/orders.js`. One test fails, the rest pass, and `docs/product.md` states the rule the bug
  breaks.
- **Fixture G** (a plan that disagrees with its repo): mark Phase 2's tasks `[x]`, set its count to
  `[4/4]`, and add paths to `## Files Modified` that don't exist. Don't fix the disagreement — it's
  the point of that fixture.

## Running an A/B eval

To find out whether a change to a `SKILL.md` changes behavior — rather than whether it reads well —
run the old text and the new text against the same fixture and diff the results:

```sh
# stage two arms, each with its own copy of the project and its own skill text
mkdir -p /tmp/ab/{old,new}
cp -R examples/fixtures/pickup-queue /tmp/ab/old/project
cp -R examples/fixtures/pickup-queue /tmp/ab/new/project
git archive HEAD .agents/skills | tar -x -C /tmp/ab/old && mv /tmp/ab/old/.agents/skills /tmp/ab/old/skills
cp -R .agents/skills /tmp/ab/new/skills
```

Then run an agent against each arm with the same prompt, varying only the path, and pointing it at
the checked-out `skills/execute-plan/SKILL.md` rather than any installed copy of the plugin.

Two things this setup is for:

- **The control is the point.** If the old text produces the same result, the change didn't cause
  what you're about to credit it with. Record that outcome rather than discarding it.
- **Use an agent with no knowledge of the change.** An agent holding the new rule in context will
  follow it, which says nothing about whether the text carries the behavior on its own.

And one thing it can't do: each agent reads the skill immediately before acting, with nothing
competing for its attention. That is the easiest case for an instruction to survive, so a null result
here is weak evidence of no effect — not proof of one. A rule aimed at what an agent does *deep* in a
long session needs a fixture that reproduces the depth.
