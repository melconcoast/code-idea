# Brand files

What this skill writes under `docs/brand/`, the formats, and what `design-ui` reads from them. Read
this in Step 1 (where an import goes) and Step 5 (writing the README).

## Layout

Only what the brand actually has — never an empty folder, never a stub file.

| Path | Holds | Written when |
|---|---|---|
| `docs/brand/README.md` | The brand for builders: the working summary every agent reads | Always |
| `docs/brand/book/` | An imported brand book, unchanged — and its pages as images, if the environment can render them, so an agent without PDF tools can read it | A book was imported |
| `docs/brand/logo/` | The logo pack, its folders kept as delivered, plus `CORRECTIONS.md` if anything was corrected — corrections are made in place, and `CORRECTIONS.md` records each old value, so the delivered file can be rebuilt | A pack exists |
| `docs/brand/logo/explorations/` | Wordmark explorations, chosen or not | Step 4 built them |
| `docs/brand/type/` | Each face's licence text, and the font files if the licence allows redistribution | Faces were adopted |
| `docs/brand/icons/` | Custom icons drawn for the product | Any were drawn |
| `docs/brand/imagery/` | `source/` unchanged, `web/` treated copies, and a `README.md` with a licence per file | Photos exist |
| `docs/brand/motion/` | Logo stings, sound marks | Files exist |
| `docs/brand/briefs/` | One file per thing a person must make or decide: logo, photography, validation tests | Step 4 deferred something an agent can't make |

Where the files were delivered (a `handoff/` folder, a download) is left as it is; the report names
it and says `docs/brand/` is now the only copy to use, so the user can remove the old one.

Bundling a font or a logo into the app — copying it into the build, wiring it into a theme — is a
build task. This skill never writes outside `docs/brand/`, except its `docs/decisions.md` entries,
its pending-decision items, and one `## Related docs` line.

## docs/brand/README.md

The brand distilled for builders. Short sections, tables where values are compared, bullets where
rules are stated. Omit a section with nothing real to say; never ship one as a stub.

```markdown
# [Brand] brand

[One paragraph: where the brand came from (imported [book, version] on [date], or built here on
[date]), and the precedence rule below.]

**Precedence:** a dated entry in `docs/decisions.md` beats [the book]; [the book] beats this
summary. Where this file differs from the book, the difference is listed under
"Overrides" with its decision.

## What's here
[Table: path → what it holds. Only paths that exist.]

## The idea
- **Positioning:** We're the only ___ that ___.
- **Value proposition:** [one breath]
- **Promise:** [what the product guarantees today]
- **Architecture:** [master brand / the tree] — only if it applies
- **Audiences:** [each buyer or user, and the line that speaks to them]
- **Distinctive assets:** [the two, and the rule protecting each]
- **Surfaces:** [where the brand has to work]

## Voice
[The three dials, the "we are / we are not" lines, the wit budget, the trust-moment rule.]
| Say this | Not this |
|---|---|

## Logo
[Which file where, clear space, minimum sizes, the never-list. Link CORRECTIONS.md if it exists.
For a working mark: say so, and link the pending decision.]

## Colour
| Name | Hex | Role |
|---|---|---|
[Proportions. **Contrast** (WCAG, measured [date]): every pairing and its ratio. **Fails as
text:** each failure, and the rule that replaces it. Campaign-only colours, marked as never
product tokens.]

## Typography
| Face | Role | Setting | Licence | Source |
|---|---|---|---|---|

## Iconography
## Imagery
## Motion and sound

## Overrides
[Each place the project departs from the book: the rule, the decision entry, the reason.]

## Never say
[Each false claim, and the true alternative. An unverified claim is not here — it is a pending
decision under "Open", kept out of copy until checked.]

## Open
[Each pending decision and brief, linked.]
```

- **Use the brand's own names** for colours and faces (the README is a brand document). `design-ui`
  maps those names onto product tokens; this file never invents product token names.
- **Write only what was confirmed.** Confirming the source covers what the audit didn't flag; each
  flagged finding covers itself. A deferred choice is absent from its section, and present under
  "Open".
- **No secrets, no private customer data** — the same rule as `scaffold`. Customer names in a
  book's "trusted by" list are claims to check, not facts to copy.

## CORRECTIONS.md

One file in `docs/brand/logo/` whenever a pack file was changed. The rule first, then what changed,
then what didn't.

```markdown
# Corrections to the logo pack

**[The rule]** — e.g. "the mark's dot is always [colour], on every ground except [colour]."
[Who decided, when; the decision entry.]

The pack [version] shipped [what was wrong]. Corrected here on [date] — [what changed only];
letterforms, geometry, and sizes unchanged, nothing redrawn.

| Files | Was | Now |
|---|---|---|

**Not corrected — don't use until replaced:** [files, and why they couldn't be fixed here].
Ask the designer for corrected exports.

**Already correct, unchanged:** [the rest].
```

## Briefs

One file per thing a person must make. Each is real content, never a stub: what's needed, why,
the constraints from the README (palette, type, distinctive assets, never-list), the formats and
sizes required, and how the result will be checked.

## Decision entries

Appended to `docs/decisions.md` in the shape `scaffold`'s `templates.md` specifies — date,
decision, rationale, alternatives, status — never editing a past entry. Typical brand entries: the
brand adopted (or imported, naming the book and version), each override of the book, each logo
correction, photography licensing, each font substitution, and each pending item. A deferred item
also gets a line in the context file's pending-decisions section, using the exact heading and placement `templates.md` gives, so a `scaffold` re-run recognises it —
or, if the context file has no Critical rules section to follow, directly after its opening
paragraph.

## What design-ui reads

`design-ui` reads `docs/brand/README.md` in its Step 0 and maps it onto `DESIGN.md`: brand colours
into product tokens with product roles, faces into its type scale, the logo files into components,
voice into its copy rules and mockups. It never edits `docs/brand/`. If mapping exposes a brand-level
problem — a pairing the product needs that fails contrast, a face unusable on one platform — it raises
it as a question for this skill, and the answer lands here first.
