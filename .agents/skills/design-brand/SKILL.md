---
name: design-brand
description: Use this skill when the user says things like "create a brand", "build our brand", "brand book", "import my brand guidelines", "bring our brand book in", "logo", "design a logo", "brand colours", "brand voice", "write our positioning", "refresh our brand", or when scaffold or design-ui hands off because a project needs a brand made or imported before its UI is designed. Not for designing screens, mockups, or DESIGN.md — use design-ui. Not for writing a project's agent docs — use scaffold. Imports a finished brand book and logo pack, auditing contrast, font licences, claims, and logo files — or builds one from the product story, one choice at a time. Writes docs/brand/, a builder-facing README with positioning, promise, voice, distinctive assets, a palette with roles and measured contrast, licensed type, logo rules, icons, imagery, and motion. What an agent can't make — a professional logo pack, a photo shoot, a trademark check — becomes a brief and a pending decision, never a fake asset.
license: MIT
metadata:
  version: "5.1.0"
---

# design-brand

Settles who the product is — its story, its voice, and the marks and colours that carry them — in files every later agent reads, before `design-ui` maps it onto screens.

## When this runs
- After `scaffold`, before `design-ui`, on a project with a public face — a product people choose, a landing page, a store listing — built or accepted in `docs/decisions.md`
- A brand book, logo pack, or guidelines arrive from founders or an agency, and need importing as the source
- A refresh or a rebrand of a project that already has `docs/brand/` — see Step 0
- **Not** when `docs/brand/` exists and the user confirms it is current (go to `design-ui`), for an internal tool, for a project with no UI and no public surface, or with no `docs/development-roadmap.md` (go to `scaffold`). Parked, it leaves a dated pending decision and `design-ui` works from its own visual thesis

## Core philosophy
- **Who comes before how it looks.** A palette with no story behind it is decoration, and nobody can map decoration onto a UI with reasons. Strategy, voice, and distinctive assets are settled before a single colour.
- **The brand outlives the UI.** It covers the site, the store listing, email, decks, and the booth. `docs/brand/` is its source of truth; `DESIGN.md` is one mapping of it, and belongs to `design-ui`.
- **Nothing is settled until the user says so.** One decision at a time, each with three exits: accept, override, or defer. An imported book is confirmed once, explicitly, as the source; then every audit finding is confirmed on its own.
- **Every claim must be true today.** A promise, proof line, certification, number, or customer name is checked against `docs/product.md`, `docs/decisions.md`, and the code. A false one becomes a never-say rule — a brand book is not evidence.
- **Assets are files, never retyped.** A logo is used from its file, never set in a font or redrawn. A wrong file in a pack is corrected and recorded, or listed as don't-use — never silently fixed.
- **Make only what you can honestly make.** Strategy, voice, palette, type, and simple wordmark explorations, yes. A professional logo pack, a photo shoot, a trademark search, legal wording, and market tests become briefs and pending decisions — never stand-ins presented as finished.
- **Precedence is explicit.** A dated `docs/decisions.md` entry beats the source book, and the book beats the README's summary. The README names every override and the decision behind it.

## Workflow

### Step 0 — Read the project, and check what exists
- Read the root context file, `docs/product.md`, `docs/decisions.md`, `docs/conventions.md`, and `docs/development-roadmap.md`. Who the product serves, and what it truly does today, come from there.
- Look for `docs/brand/`, brand files anywhere else in the repo or handed over in the conversation, and `DESIGN.md`. Say whether this is a new brand, an import, or a re-run.
- Surface any `Status: Pending` brand decision first — decide it now, or keep it parked.
- On a re-run, classify the change with `references/brand-strategy.md`: a **refresh** (colour, type, a cleaner mark, same story) or a **rebrand** (a new name, promise, or audience). Default to refresh. A rebrand is confirmed explicitly, after listing every file it reaches downstream.

### Step 1 — Find the source
- **A brand exists outside the repo** — a book, guidelines, a logo pack, a design file through a connector the environment offers. Save every file unchanged under `docs/brand/` (layout in `references/brand-files.md`) — a correction confirmed later is made in place, with the old value recorded — and extract from the files, never from memory. Ask once which file and version is the source, even when there is only one. Then Step 2.
- **Part of one exists** — a logo with no story, a palette with no voice. Import what exists through Step 2, then build the rest through Steps 3–4. A complete-looking book usually still lacks some of Step 3 (voice dials, a trust-moment rule, competitors' claims): after the audit, name the gaps in one question — build them now, or leave them out — then confirm each one built on its own.
- **Nothing** — Steps 3 and 4.

### Step 2 — Import: audit, then confirm each finding
Read `references/brand-system.md`. Extract the book into the README's sections, then audit it. Present each finding on its own:
- **Contrast** — measure every text pairing the book allows. Each failure becomes a rule ("never X as text on Y").
- **Font licences** — every face, for embedding on web and in apps. An unlicensed face gets a licensed substitute recommended.
- **Claims** — every promise, proof line, and number against what is true. False ones become never-say rules.
- **Logo files** — every file in the pack against the book's own rules. Colour corrections go in `CORRECTIONS.md`; anything not corrected is listed as don't-use. Letterforms are never redrawn.
- **Imagery** — a licence recorded per file, and third-party marks found.
- **The book's open questions** — ask whether each is still open; each that is becomes a pending decision.

### Step 3 — Build: strategy, voice, distinctive assets
Read `references/brand-strategy.md`. Pre-fill each answer from the plan and `docs/product.md`, say where it came from, and confirm one at a time:
- **Always:** positioning ("the only ___ that ___"), the value proposition in one breath, a promise the product keeps today, and what competitors already say.
- **Only when it applies:** brand architecture (two or more products or audiences), a new category (only if the user claims one, and parked with its test until validated), and an archetype as a shorthand for the voice.
- **Voice:** three dials, three "we are / we are not" lines, and a say/don't-say table in the product's own moments. Trust moments — security, pricing, consent, errors — are always plain.
- **Distinctive assets:** name the two the brand will own for years. The palette and the mark are built from them.
- **Surfaces:** list where the brand has to work. No surface, no rule for it.

### Step 4 — Build: the identity system
Read `references/brand-system.md`. For each part, propose two or three genuinely distinct options drawn from Step 3, recommend one, and confirm it before the next:
- **Palette** — every colour with a role and a reason traced to the story, measured contrast, failures as rules.
- **Type** — licence verified before a face is offered, with its source recorded.
- **Logo** — two or three SVG wordmark explorations under `docs/brand/logo/explorations/`, each labelled an exploration. A chosen one becomes a working mark, with a pending decision for the professional pack.
- **Icons, imagery, motion, and sound** — direction and rules, never generated photographs presented as brand photography.

Preview however the environment allows, and always give the file path — the file is written either way.

### Step 5 — Write and hand off
- Write `docs/brand/README.md` in the format of `references/brand-files.md`: only what was confirmed, every override named, and every brief and open item listed.
- Append dated entries to `docs/decisions.md` in the shape `scaffold` writes — accepted or pending, never editing a past one. A deferred choice also gets an item in the context file's pending-decisions section, with the heading and placement `scaffold`'s `references/templates.md` specifies, created if absent. Add one `## Related docs` line pointing at `docs/brand/README.md`.
- Those are the only writes outside `docs/brand/`. `DESIGN.md`, `docs/design/`, the roadmap, plan files, and app code are never touched — bundling fonts or logos into the app is a build task. A finding that should become a root rule, like a claim never to make, is reported for `scaffold`, not written.
- Report what was written, what is deferred, each brief, and every conflict with the project's own docs — a binding palette in `docs/conventions.md` the brand replaces, a claim a root rule should carry — naming which skill owns the fix. Then hand off to `design-ui` to map the brand onto the UI — or, after a refresh, to re-map it.

## Reference files
- `references/brand-strategy.md` — positioning, value proposition, promise, differentiation, architecture, category, archetype, voice, distinctive assets, refresh versus rebrand, and what only the market can measure. Read this in Steps 0 and 3.
- `references/brand-system.md` — palette and contrast, type and licences, the logo and its pack, iconography, imagery, motion and sound, and what an agent can't make. Read this in Steps 2 and 4.
- `references/brand-files.md` — the `docs/brand/` layout, the README, `CORRECTIONS.md`, and brief formats, and what `design-ui` reads from them. Read this in Steps 1 and 5.
