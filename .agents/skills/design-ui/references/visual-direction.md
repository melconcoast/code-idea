# Visual direction

How to find the look before anything is built. Read this in Step 1. The guidance on what to avoid is
**expected to age** — what counts as a generic default shifts as models and design trends do. Treat
an outdated entry as a normal, welcome PR.

## Why the default is generic

A model asked for a screen with no direction samples from the middle of what it has seen: Anthropic
calls this *distributional convergence*, and names the result — Inter, purple gradients on white,
minimal motion ([source](https://claude.com/resources/articles/improving-frontend-design-through-skills),
2025-11-12). OpenAI describes its own models the same way: unsteered output is "plausible and
functional" but drifts toward "generic structure, weak visual hierarchy"
([source](https://developers.openai.com/blog/designing-delightful-frontends-with-gpt-5-4)). Verified
2026-10-08.

That is why a chat prototype and a coding-agent build of the same idea look so different. A chat
artifact surface typically loads design guidance on every request; a coding agent's defaults point
the other way — match the surrounding code, take the smallest diff. Neither is the model's ceiling.
The fix both vendors give is the same: a direction decided first, and a reference to check against.

## The visual thesis

One sentence: the mood, the material, and the energy of the product — derived from something concrete
about its domain and its users, never from a trend.

- Weak: "Clean, modern, and user-friendly." Every product claims this; it decides nothing.
- Strong: "A bakery's order ticket — warm paper, heavy ink, stamped dates — read at arm's length by
  staff with flour on their hands."

The strong one already implies a palette (paper and ink), a type treatment (heavy, legible at
distance), and a density (big targets, few things per row). That's the test: a thesis that doesn't
constrain a single token isn't finished.

## Proposing directions when there is no reference

- Propose **two or three**, each a small static mockup of the *same* key screen so they compare
  fairly. One direction is a choice already made; four is a menu nobody wants to read.
- Make them **genuinely distinct** — different type pairings, different palettes, different density.
  Three shades of the same layout is one direction shown three times.
- Ground each in the product's domain. Derive a palette from a material, process, or reference tied
  to what the product does — the way ink and CMYK suit a printing product specifically.
- Recommend one, say why, and let the user pick, mix, or override.

## Steering away from the default

Give every direction explicit constraints, and write the ones that survive into `DESIGN.md`'s
`## Do's and Don'ts`:

- **Typography.** One distinctive face with real contrast against its pair — weight jumps like
  200 against 800, not 400 against 600. Avoid the stock stacks (Inter, Roboto, Arial, system-ui as a
  choice rather than a fallback), and avoid swapping in the *next* overused face just as reflexively.
- **Color.** A dominant color with a sharp accent beats a timid, evenly spread palette. Reserve
  accents for meaning — one color always means "warning", another always means "upgrade" — never
  decoration. Avoid the generic assistant palettes: purple-on-white, and the muted cream/beige/
  terracotta that appears whenever a model isn't given a reason to choose otherwise.
- **Numbers get tabular figures.** Prices, IDs, timestamps, and codes read better in a monospace or
  tabular-figure face — small, and disproportionately noticeable when missing.
- **Composition before components.** Decide the layout's rhythm and hierarchy first. Cards only where
  the card *is* the interaction; a grid of three cards is the most common default there is.
- **Density matches the user.** A desk user benefits from density; a customer on a phone in a hurry
  needs large targets and one obvious action per screen.
- **Motion is a few deliberate moments**, not decoration on everything — and none of it where the
  project's conventions or the user's accessibility settings say otherwise.
- **One pattern per kind of decision.** The same small set of mutually exclusive choices looks the
  same on every screen. Name the icon set and component approach once, so screens don't mix them.

None of these override the project. If `docs/conventions.md` binds a palette or a face — even one this
list calls generic — the direction works inside it: that constraint is the design brief, not an
obstacle to it. The avoid-list is for choices still open, not for re-litigating decided ones; where
it's silent on a face, match what the project already uses.

## Mapping a brand onto a UI

When `docs/brand/README.md` exists, the brand is fixed and the mapping is the design. Its colours,
faces, logo files, voice, and contrast rules are inputs — don't re-ask them as choices. What gets
proposed and confirmed is how they land on the product.

- **Re-skin, don't re-layout.** On screens already built, a brand changes the look, not the
  structure. If the brand shows a structural change (its own pages picture the product a certain
  way), raise each one as its own question.
- **Brand colours become product roles, usually narrower ones.** A brand accent that means
  "progress" in marketing might mean only "live or done" in the app. The primary action often gets
  its own colour rather than the accent, so the accent stays free to signal state. Apps usually
  carry less accent than marketing pages; say how much.
- **Contrast rules carry over** into `## Do's and Don'ts` word for word, and campaign-only colours
  never become tokens. A non-text accent that carries meaning needs 3:1 against its ground; below
  that, it always sits beside words that say the same thing. A brand's per-screen limits on its
  accent count UI elements, not the logo's own artwork.
- **Dark mode is a decision, not a default.** If the brand shows itself on dark, offer dark mode,
  with the brand's dark values — and record the answer.
- **Faces get product sizes.** A display face built for billboards is often too wide or too heavy for
  app titles; map it to marketing surfaces and pick the heading cut for the app.
- **Logos by file.** Components reference the files in `docs/brand/logo/` — which variant on which
  ground — and never set the name in a font.
- **Voice reaches the mockups.** Copy follows the brand's say/don't-say table and trust-moment rule,
  and its never-say list goes into `## Do's and Don'ts`.
- **Binding conventions still bind.** If `docs/conventions.md` fixes a palette the brand replaces,
  that's a conflict to raise: adopting the brand changes the conventions, and that edit is `scaffold`'s.
  Never design past them quietly.
- **A brand-level problem goes back.** A pairing the product needs that fails contrast, or a face
  unusable on one platform, is a question for `design-brand`. `docs/brand/` is never edited here.

## Importing a prototype or handoff

- **Save the source, not a summary.** Copy the artifact code, the export bundle, or the screenshots
  into `docs/design/reference/` unchanged. Extracting tokens later from the file is reliable;
  extracting them from a memory of the conversation is not.
- **Extract, then confirm.** Read colors, type, spacing, and radius out of the source and present them
  as the recommendation. The user confirms the look — not the code.
- **Separate what the sandbox forced.** A chat artifact may only permit certain libraries; a design
  tool's export may assume its own component set. Name those as forced, and leave them to `scaffold`.
- **Notice what the prototype skipped.** Prototypes usually show the happy path with ideal data.
  List the states it never showed — empty, loading, error, overflow, a long name, a hundred rows — and
  design them in Step 4 rather than leaving them for build time.
- **A connector is optional.** If the environment offers access to a design file through a connector,
  read the frame's real values rather than estimating them from an image. If it doesn't, screenshots
  and the artifact's code are enough.

## Previewing, per environment

The file is always written; how the user sees it depends on what the environment offers. Detect the
capability — never assume one exists.

| The environment can… | Show the mockup by… |
|---|---|
| Render or publish an HTML page (a chat artifact surface, a page-publishing tool) | Rendering it there, and naming the repo path it was saved to |
| Drive a browser | Opening the file and taking screenshots at a phone and a desktop width. If the tool refuses `file://` URLs, serve the repo from a throwaway local static server — relative token links resolve the same way. If the window won't go narrow enough, render the page in a fixed-width frame and confirm the width from inside it |
| Neither | Giving the path, and asking the user to open it locally |

In a chat surface with no project filesystem, produce each file as content and say exactly which path
it belongs at, the same way `scaffold` hands back its docs.
