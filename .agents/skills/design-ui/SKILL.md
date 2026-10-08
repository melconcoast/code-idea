---
name: design-ui
description: Use this skill when the user says things like "design the UI", "make mockups", "mock up the screens", "import my prototype", "bring my design handoff in", "redesign the queue screen", "set up DESIGN.md", or when scaffold or plan-module hands off because a project has screens but no visual reference. Not for writing a project's agent docs or roadmap — use scaffold. Not for building a screen from a plan file — use execute-plan. Settles how a project looks before it is built, so the coding agent works to a reference, not its own defaults. Imports an existing prototype, handoff bundle, design file, or screenshots — or proposes two or three distinct visual directions when there is none — and gets each choice explicitly confirmed. Writes DESIGN.md (design tokens plus the reasons behind them), a screen inventory covering every state, and one static HTML mockup per key screen under docs/design/, which plan-module and execute-plan then plan and verify against.
license: MIT
metadata:
  version: "5.0.0"
---

# design-ui

Settles how the product looks — in files a coding agent can read and check its work against — before a single screen is built.

## When this runs
- After `scaffold`, on a project with a UI, before the first module with a visible surface is planned
- When `plan-module` finds a module whose screens have no entry in `docs/design/screens.md` and hands off here rather than planning UI against nothing
- A new screen, a redesign, or a prototype made elsewhere — a chat artifact, a design tool's handoff bundle — that should become the target
- A project scaffolded before 5.0, with a `docs/design-system.md` or UI already built but no `DESIGN.md` — see Step 0
- Never for a project with no UI, and never as a project's first step: no `docs/development-roadmap.md` means hand off to `scaffold`

## Core philosophy
- **Without a reference, a coding agent builds the average of what it has seen.** The generic font, the safe palette, three cards in a row — that's the default when nothing steers it, not a lack of ability. This skill exists so a reference is in the repo before anything is built.
- **Design is its own step, before code.** The look is decided here, against mockups the user has actually seen — never discovered task by task inside `execute-plan`.
- **The repo is the source of truth; a preview is not.** Mockups are files under `docs/design/mockups/`. A rendered artifact, a published page, or a screenshot in chat is how the user reviews one — never the only copy, because the next agent can't read it.
- **The look and the stack are separate decisions.** A prototype's look can be the confirmed target while its libraries are not — those were often forced by the sandbox it was made in. Confirm the look here; the stack belongs to `scaffold` and `docs/decisions.md`.
- **Nothing is settled until the user says so.** An imported prototype, a legacy `design-system.md`, CSS already in the repo — each is a recommendation to confirm, never a fact to carry over. One decision at a time; a single "looks good" against a bundle confirms nothing.
- **The project's conventions bind the design.** If `docs/conventions.md` forbids a CSS framework or new colors, the mockups obey it. Design inside the rules, or name the conflict and ask — never quietly design past them.
- **Every screen has more than a happy state.** Empty, loading, error, and a lot of data get designed here, because whatever isn't designed gets invented at build time.

## Workflow

### Step 0 — Read the project, and check what exists
- Read the root context file, `docs/development-roadmap.md`, `docs/product.md`, `docs/conventions.md`, and `docs/decisions.md`. The screens come from the roadmap's modules; who uses them, and on what device, comes from `product.md`.
- Look for `DESIGN.md`, `docs/design/`, a legacy `docs/design-system.md`, and UI already built — stylesheets, theme config, view templates. Any of these makes this a re-run or a migration: say which, and that what's there will be confirmed rather than assumed. Tokens or faces that `docs/conventions.md` makes binding are the exception — state them as constraints the design works inside, don't re-ask them as choices.
- Surface a `Status: Pending` design decision in `docs/decisions.md` first — decide it now, or stop here and leave it parked.

### Step 1 — Find the reference
Read `references/visual-direction.md` first. Then ask what exists, and take the first that applies:
- **A prototype or handoff** — a chat artifact's code, a design tool's export bundle, a design file reachable through a connector the environment offers, or screenshots. Save it under `docs/design/reference/` as-is, and extract from the file, never from memory of it.
- **Screens already built** — read its tokens out of the stylesheets and config, screenshot its screens if a browser tool exists, and save those as the current reference.
- **Nothing** (a stylesheet with no screens counts as nothing, designed inside its tokens) — write a one-sentence visual thesis grounded in the product's domain and users, then propose two or three genuinely distinct directions, each a small static HTML mockup of the same key screen under `docs/design/directions/`. The user picks one, or mixes.

### Step 2 — Confirm the look, separately from the stack
- Show the reference or the chosen direction and confirm it as the visual target. Use whatever preview the environment offers — a rendered artifact, a published page, a browser screenshot — and always give the file path too. The file is written either way.
- If the reference came from a sandboxed prototype, name which of its choices (component library, icon set, framework) the sandbox forced, and leave those to `scaffold` and `docs/decisions.md`.
- Every choice gets three exits — accept, override, or defer. A deferred look becomes a dated pending decision, in the shape the context file's `## Pending decisions` and `docs/decisions.md` already use (creating either if absent), and no `DESIGN.md` — a half-empty one is worse than none.

### Step 3 — Write DESIGN.md and the screen inventory
- Read `references/design-files.md` for both formats before writing.
- `DESIGN.md` at the repo root: tokens in its YAML front matter, the reasoning in its body, and a `## Do's and Don'ts` naming the defaults this product must not fall back to. Only what was confirmed.
- `docs/design/screens.md`: every screen the roadmap implies — purpose, user and device, layout, key components, each state, and the mockup that shows it.
- If the format's linter can run here, run it and fix what it reports — asking first if running it would download a package. A contrast failure is a design bug, not a warning. Didn't run? Say so, and check contrast by hand.

### Step 4 — Mock up each key screen, and confirm each
- One static HTML file per key screen under `docs/design/mockups/`, using `DESIGN.md`'s tokens for every color, face, size, and radius, realistic copy in the product's own vocabulary, and every state `screens.md` lists. A state that can't occur on this screen — loading on a synchronous server-rendered page — is listed as not applicable, with why.
- Mockups are reference, not production code — no build step, free to ignore the production stack, never free to ignore the look. They **link** their tokens by relative path — the project's own stylesheet if it defines them, else `docs/design/tokens.css` — and never copy a value in, so they open from disk and can't drift from the product.
- Show each one and confirm it before the next. If a browser tool exists, save screenshots at a phone width and a desktop width into `docs/design/reference/` — those are what verification compares against later.

### Step 5 — Link it and hand off
- Add one line to the root context file's `## Related docs` pointing at `DESIGN.md` and `docs/design/screens.md`. That line, and a pending-decision entry when the user parks the look, are the only edits this skill makes outside `DESIGN.md` and `docs/design/` — the context file is `scaffold`'s, and the roadmap and plan files are never touched here.
- Migrating from `docs/design-system.md`: show what moved where, and ask before deleting the old file. Content with no home in the new files is raised as a question, never dropped.
- Report what was written, what's still deferred, and which modules now have a reference. Name any design choice that needs data or behavior the plan doesn't have yet — a flag that depends on today's date, a state the code can't produce — as a re-plan item, never a silent plan edit. Then offer `plan-module` — or, where a plan is already in flight, a re-plan so its open UI tasks gain visual scenarios.

## Reference files
- `references/visual-direction.md` — escaping the generic default, writing a visual thesis, proposing distinct directions, importing a prototype or handoff, and previewing per environment. Read this in Step 1.
- `references/design-files.md` — the `DESIGN.md` format, the `screens.md` and mockup conventions, and what `plan-module`, `execute-plan`, and `test-and-verify` read from them. Read this in Step 3. **Expected to age** — the `DESIGN.md` spec is alpha.
