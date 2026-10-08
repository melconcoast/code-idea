# Design files

The formats this skill writes, and what the other skills read from them. Read this in Step 3.

**Expected to age.** `DESIGN.md` follows the open format from Google Labs, which its maintainers mark
alpha — the spec, schema, and CLI are under active development
([spec](https://github.com/google-labs-code/design.md), verified 2026-10-08). Check the current spec
before relying on a section name or a CLI command below, and treat a stale entry as a welcome PR.

## What gets written, and where

| File | Holds | Read later by |
|---|---|---|
| `DESIGN.md` (repo root) | Tokens and the reasoning behind them | `execute-plan` before every UI task |
| `docs/design/screens.md` | One entry per screen, with every state | `plan-module` to write visual scenarios |
| `docs/design/mockups/<screen>.html` | A static mockup of one key screen | `execute-plan` as the build target |
| `docs/design/reference/` | Imported sources, and screenshots of each mockup | `test-and-verify` to compare against |
| `docs/design/directions/` | The directions proposed in Step 1, chosen or not | Nobody — a record, never a target |
| `docs/design/tokens.css` | `DESIGN.md`'s tokens as CSS custom properties — only when the project has no token stylesheet yet | Every mockup, by relative link |

`DESIGN.md` sits at the root because that is where the format's tools and other agents look for it.
It is content, not a container: the same file serves every target agent, linked from whichever root
context file the project uses.

## DESIGN.md

Two layers. YAML front matter holds the normative tokens; the markdown body says why they exist and
how to apply them.

```markdown
---
version: alpha
name: [Product name]
description: [The visual thesis, in one sentence]
colors:
  ink: "#1d1a16"
  paper: "#f6f1e7"
  accent: "#c2410c"
typography:
  display: { fontFamily: "[Face]", fontSize: 48px, fontWeight: 800, lineHeight: 1.1 }
  body: { fontFamily: "[Face]", fontSize: 16px, fontWeight: 400, lineHeight: 1.5 }
rounded:
  sm: 4px
spacing:
  sm: 8px
  md: 16px
components:
  button-primary: { backgroundColor: "{colors.accent}", textColor: "{colors.paper}" }
---

## Overview
## Colors
## Typography
## Layout
## Elevation & Depth
## Shapes
## Components
## Do's and Don'ts
```

- **Sections are optional but ordered.** Omit one with nothing real to say; never reorder them, and
  never ship one as an empty stub.
- **Every token gets a meaning, not just a value** — what it's reserved for and when to use it. A
  color named `accent` with no rule for when it appears will be used everywhere.
- **`## Do's and Don'ts` carries the anti-defaults.** Name the specific fallbacks this product must
  not use — the stock font, the gradient, the card grid — alongside the project's own rules.
- **Write only what was confirmed.** A deferred choice is absent, with its pending-decision entry
  elsewhere — never a guessed value.
- **Lint it when you can.** `npx @google/design.md lint DESIGN.md` checks broken token references and
  WCAG contrast, and exits non-zero on an error. No `npx`, or no network? Say the lint didn't run;
  don't imply it passed.
- **Match the project.** Where the project already defines tokens — CSS custom properties in an
  existing stylesheet, a theme config — `DESIGN.md` names and explains those, rather than inventing a
  parallel set the code will never use.

Accessibility expectations — minimum target size, focus order, contrast — go in the body under the
section they affect, and only when actually decided.

## docs/design/screens.md

One entry per screen the roadmap implies. This is what turns "make it look like the prototype" into
something `plan-module` can write checkable scenarios against.

```markdown
# Screens

## [Screen name] — `docs/design/mockups/[screen].html`
- **Module:** [Roadmap module and sub-module it belongs to]
- **Purpose:** [The one job this screen does]
- **User and device:** [Who uses it, on what, in what situation]
- **Layout:** [Regions, their order, and what dominates]
- **Key components:** [By their `DESIGN.md` component names]
- **States:** default · empty · loading · error · many items — [what each shows]
- **Breakpoints:** [What changes between phone and desktop]
- **Interactions:** [What responds, and how — only what's decided]
```

Omit a line with nothing real to say. Every screen a module will build needs an entry before that
module is planned — that's the check `plan-module` makes.

## Mockups

- **One HTML file per key screen** — no build step, no external request except a web font if
  `DESIGN.md` names one. It must open from disk in any browser, by double-click, from inside the repo.
- **Tokens are linked, never copied.** Every color and face — and every size and radius the project
  has a token for — comes from one token stylesheet, linked by relative path:
  - the project's own stylesheet when it already defines the tokens (`../../../public/styles.css`) —
    one source of truth, and a convention against hex values in markup holds for the mockup too;
  - otherwise `docs/design/tokens.css`, written from `DESIGN.md`'s front matter as CSS custom
    properties. The build later adopts those same values, so mockup and product can't drift.

  The mockup's own `<style>` holds layout — grids, spacing, column widths, rule thickness — plus any
  size the project has no token for and its conventions forbid adding, with that size recorded in
  `DESIGN.md`. It references tokens with `var(...)`. A color value inside a mockup is a second source
  of truth.
- **Previews inline, the repo file doesn't.** A rendered preview (a chat artifact, a published page)
  can't follow a relative link, so inline the token stylesheet into the *preview copy* only. The file
  in `docs/design/mockups/` keeps its link.
- **Every state `screens.md` lists**, shown side by side or in labelled sections of the same file. A
  state that can't occur on this screen is listed there as not applicable, with the reason.
- **Real copy** in the product's own vocabulary — names, dates, amounts that look like the domain.
  Lorem ipsum hides exactly the overflow and hierarchy problems a mockup exists to surface.
- **Not production code.** The mockup may use a technique the production stack doesn't; the
  implementation reproduces the look, not the markup. Production code follows `docs/conventions.md`.

## Reference screenshots

When a browser tool is available, save a screenshot of each confirmed mockup at a phone width (375px)
and a desktop width (1280px) as `docs/design/reference/[screen]-375.png` and
`docs/design/reference/[screen]-1280.png`. `test-and-verify` renders the built screen at the same
widths and compares. Without a browser, the HTML mockup is the reference and comparison is by reading
it — say so in the report.
