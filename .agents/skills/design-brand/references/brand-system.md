# Brand system

The identity system — palette, type, logo, icons, imagery, motion, and sound — and the audit an
imported one goes through. Read this in Step 2 (import) and Step 4 (build).

**Partly expected to age.** The contrast thresholds and the licence questions are stable. Named
icon sets, font sources, and tools shift — verify one against its current source before
recommending it, and treat a stale entry as a welcome PR.

## Palette

- **Every colour gets a role, and a reason traced to the story.** "The accent is the full stop that
  closes the mark: done, sent, synced" is a role. "Brand green" is a value with no rule, and a
  colour with no rule gets used everywhere. A colour without a reason doesn't make the palette.
- **Built from the distinctive assets.** If a colour is one of the two, it gets the strictest rule —
  where it appears, how much of a layout it may take, what it never does.
- **Contrast failures travel with their palette.** In a built palette, the measured failures and the
  rules that replace them are part of the option shown — confirmed with it, not asked separately.
- **Proportions, not just swatches.** Say how much of a layout each colour takes (dominant neutral,
  supporting neutral, a small share of accent). One accent element gets the eye per screen; if two
  things shout in it, one is wrong.
- **Semantic colours are reserved.** An error colour is for errors only — never in marketing, never
  decoration.
- **Campaign colours stay out of the product.** Colours that exist for photography, duotones, or
  campaigns are listed as such, and the README says they never become product tokens.
- **Dark surfaces** — if the brand is shown on dark (in its book, its site, its product), the
  palette names the dark base and how each role carries over. `design-ui` decides whether the
  product gets a dark mode; the brand only supplies the values.

### Contrast — measured, never assumed

- Measure **every text pairing the brand allows** — each colour the book gives a text role, on
  each ground it names for that role — using WCAG 2 relative-luminance contrast: 4.5:1 for body
  text, 3:1 for large text (24px, or 18.66px bold) and for icons and UI edges. Use a script or the
  formula by hand, and say which. Pairings no role implies go in the ratio table only; they don't
  become rules.
- Record each ratio in the README, with the date measured. Each failing pairing is its own
  finding, confirmed on its own.
- **Every failure becomes a rule**, phrased as what to do instead: "never [colour] as text on
  [surface] (2.9:1) — on light, secondary text is [ink] at an opacity". A brand book that forbids
  only one failing pairing has usually missed others; measuring is how they're found.
- A mark is not text. A logo's coloured element on a light ground follows the logo's rules, not
  the text-contrast rules — say so, so nobody "fixes" the logo.

## Type

- **Check the licence before a face is offered**, not after it's adopted. The questions: may it be
  embedded on the web (self-hosted, or only through the foundry's service)? Bundled into a mobile
  or desktop app? Is it installed on every platform the product runs on, or only some? A face that
  ships with one operating system will fall back to something else everywhere else.
- **Prefer faces whose licence allows embedding and redistribution** — SIL Open Font License or
  Apache 2.0 — unless the user already holds a licence that covers every use above. A commercial face
  the user loves is a real option; it's a purchase decision, recorded as one.
- **An unlicensed face in an imported book** is a finding: name the problem, recommend a licensed
  substitute with the closest shapes and widths, and let the user choose — buy, substitute, or
  defer.
- Record for each face: its role (display, heading, body, data), weights and settings used, the
  licence, and the source URL. Keep the licence text in `docs/brand/type/` — always. The font files
  are optional there; bundling them into the app is a build task either way.
- One face for numbers with tabular figures, if the product shows prices, times, or counts.

## Logo

### Imported — a logo pack exists

- **Files, never retyped.** The README says which file to use where — on light, on dark, on the
  accent colour, one-colour — and that the mark is never set in a font, outlined, stretched,
  rotated, shadowed, or recoloured.
- **Audit every file against the book's rules.** Packs are exported by hand and are sometimes wrong:
  a colourway with the wrong fill, a light-ground file that breaks the book's own colour rule, a
  print file older than the screen one. Open each SVG and read its fills; compare each raster with
  its source.
- **Correct only what is a value, never the drawing.** A wrong fill colour in an SVG may be fixed in
  place, then rasters re-rendered from the corrected SVG if a tool for that exists. Letterforms,
  geometry, and spacing are never touched. Each correction is confirmed with the user first, then
  recorded in `CORRECTIONS.md` (format in `brand-files.md`).
- **What isn't corrected is listed as don't-use** — print files, video renders, a raster with no way
  to re-render it here, a file whose drawing doesn't match the mark at all — with "ask the designer
  for corrected exports" in a brief. A file the book lists that the pack doesn't contain is a finding
  too.
- Clear space and minimum sizes are copied from the book. Where the book and the pack disagree,
  that's a finding to confirm, not a value to pick.

### Built — no logo exists

- An agent can make **wordmark explorations**, not a logo. Write two or three as SVG under
  `docs/brand/logo/explorations/`, each built from the confirmed type and a distinctive asset (a
  mark, a punctuation device, a colour), each on light and on dark.
- Label each one an exploration in its file name and the README. Text set in a font is not
  outlined artwork: name the face it depends on, and preview it with that face loaded — an SVG
  previewed without the font shows a fallback, and hides overflow and spacing problems.
- Give the working mark provisional clear space and a minimum size, marked provisional until the
  professional pack sets them.
- A chosen exploration becomes a **working mark**, used until a professional pack exists. Record a
  pending decision — "professional logo pack: undecided as of [date]; meanwhile use the working
  mark from `docs/brand/logo/explorations/[file]`" — and write `docs/brand/briefs/logo.md` for the
  designer.

## Iconography

- **One base set**, named, at **one fixed stroke weight**, on one grid, with consistent caps and
  joins. Never mix sets or weights.
- **Custom icons** for what only this product does, drawn on the same grid at the same weight.
  An agent may draw simple ones as SVG; complex ones go in a brief.
- Colour through `currentColor`, so icons follow the text colour. A distinctive asset on icons —
  a dot, a corner — is used for states, never decoration.
- Third-party products (integrations, payment methods) appear as their official logos, never
  redrawn in the house style.
- Sizes and the minimum tap target are a product concern: suggest them, and leave the final values
  to `design-ui`.

## Imagery

- **Direction first:** what the photos show, how they're graded, what's never shown (the stock
  handshake, the glowing brain, the literal pun on the name). Real people, real places, real use.
- **Each file shows what the book says it shows** — a placeholder or a mislabelled file is a
  finding.
- **A licence recorded per file**, in `docs/brand/imagery/README.md`: source, licence, who confirmed
  it, and when. A blanket "they're licensed" is a starting point, not a record — ask for the
  per-file detail, and list any file without it as don't-use for public pages.
- **Third-party marks** — another company's banner, a printed T-shirt, a branded cup — are cropped
  out or blurred before public use, and the README says which files were treated how.
- **Brand-only colours stay in the files.** Duotones and campaign tints are baked into image files,
  never added as product tokens.
- Type over a photo sits on a scrim, never straight on a busy image. Lines and type over images are
  drawn by the page, not baked in, so they stay editable.
- **An agent never generates photographs as brand photography.** Without licensed photos, the brand
  uses its type, colour, and product UI, and a photo-shoot brief records what's needed.

## Motion and sound

- A few named principles with values: how fast things respond, how they settle, the one moment that
  celebrates. No bounce or confetti unless the voice calls for it.
- A logo sting or sound mark, if one exists, is a file — and a distinctive asset if the brand uses
  it everywhere. Respect reduce-motion: a still logo in its place.

## What an agent can't make

Each of these becomes a **brief** in `docs/brand/briefs/` and a **pending decision** — never a
placeholder asset presented as the real thing.

| Can't make | What gets written instead |
|---|---|
| A professional logo pack (outlined vectors, print PDF and EPS, CMYK and spot values, proofs) | The working mark, `briefs/logo.md`, and a pending decision |
| A photo shoot or licensed photography | The imagery direction, `briefs/photography.md` (shots, places, people, the four or five image types), and a pending decision |
| A trademark or domain clearance | A pending decision naming the classes and regions to check, and "don't invest in the identity until cleared" |
| Legal-reviewed wording (consent, terms, regulated claims) | A pending decision, and the voice rule that the moment is plain |
| Market validation (a category name, recall, positioning tests) | A pending decision with its test attached |
