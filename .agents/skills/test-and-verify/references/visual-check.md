# Visual check

How a visual scenario gets verified. Read this in Step 1 whenever the caller names visual scenarios,
or a gate covers a phase that built a screen. The tooling notes are **expected to age**; the rules
under them are not.

## What's being checked

A visual scenario names a screen, a width or state, and what must be on screen — checked against the
screen's mockup under `docs/design/mockups/` and, where they exist, the reference screenshots under
`docs/design/reference/`. Data tests passing says the right orders arrived; it says nothing about
whether they look like the design. That gap is the whole reason this check exists.

## Running it

1. **Start the app** the way the project's root context file says to run it. No documented way to
   run it? Say so and report the visual scenarios as not checked — inventing a start command is a
   project decision, not a verification step.
2. **Render the screen** in a real browser at each width the scenario names — 375px and 1280px when
   it doesn't say — in each state it names. Reach a state through the app's real behavior (no open
   orders, a failing request), never by editing the markup to fake one.
3. **Screenshot it**, and look at the screenshot beside the mockup or its reference screenshot.
4. **Compare what the scenario claims**, one claim at a time — layout, hierarchy, which token a color
   comes from, what the state shows, no horizontal scroll. Where a claim is measurable, measure it in
   the page (an element's width, the computed color) rather than judging it by eye.

Use whatever browser capability the environment offers — a browser-automation tool or server, a
headless browser on the command line, an agent's built-in browser. Detect it; never assume one, and
never install one as part of a verification pass.

## What counts as a match

- **The claims in the scenario, not pixel identity.** Fonts render differently across machines, and
  the build isn't the mockup's markup. A scenario that says "pickup time is the largest text in the
  row" passes when it is, whatever the anti-aliasing does.
- **Every claim, not most of them.** A screen that matches the layout but shows the accent color on
  every row has failed the scenario that reserved it for overdue orders.
- **Look at the screenshot.** A comparison reported without a screenshot having been taken and read
  is a pass you didn't read — the same failure as trusting an exit code.

## Fixing a mismatch

It goes through the same loop as any failure — one targeted fix per attempt, three attempts, then
stop.

- **Application code** is the usual cause: a token not applied, a state never rendered, a layout that
  collapses at one width. Fix the code to match the mockup, within `DESIGN.md` and the project's
  conventions.
- **The mockup itself** may be what's wrong — it contradicts `docs/conventions.md`, or shows something
  `docs/product.md` forbids. Stop and report; the mockup is the spec, and changing it is `design-ui`'s
  job and the user's call.
- **Never weaken the comparison to reach a match** — dropping a claim, checking only the width that
  passes, or calling a visible difference "close enough". That is the visual form of loosening an
  assertion.

## When it can't run

No browser capability, or an app that can't be started here: report each visual scenario as
`not checked`, with the reason and what would check it. Verify what can be checked without
rendering — that the state exists in the code, that the styles use `DESIGN.md`'s tokens rather than
hardcoded values — and say that's all it is. Never report a visual scenario as passed on reading the
code alone.
