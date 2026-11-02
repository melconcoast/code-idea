# Brand strategy

Who the product is, before how it looks. Read this in Step 0 (refresh versus rebrand) and Step 3.

Every element below ends in something checkable — a sentence with its blanks filled, a test it
passes, a list it is compared against. An element that can't be checked isn't finished; one that
can only be checked in the market is recorded as a pending decision with its test, never asserted.

## Pre-fill, tag, confirm

Most of the strategy is already in the plan: who uses the product, what it replaces, what it
guarantees. Draft each element from `docs/product.md`, the roadmap, and the planning conversation,
and say where the draft came from — the same source tagging `scaffold` uses. A draft the assistant
wrote is a recommendation, not a fact, however well it reads. Confirm each element on its own.

**One decision is one element.** A set — the three "we are / we are not" lines, the say/don't-say
table, a palette option with its contrast rules — is one decision, shown in full so the user
confirms what they actually read. Two elements in one message are two decisions.

Scale to the project. A one-product, one-audience app needs positioning, value proposition,
promise, differentiation, voice, and distinctive assets — nothing more. Ask the rest only when the
condition in its heading holds.

## Always

### Positioning
The one place in a buyer's head that belongs to this product.
- The check: a filled-in **"We're the only [kind of thing] that [what only it does]."** If a named
  competitor could truthfully say the same sentence, it isn't positioning yet.
- Place it on a two-axis map whose axes matter to *this* buyer (fast–thorough, playful–serious,
  budget–premium), with the alternatives plotted. Pick a corner, not the middle.
- Competitor names on the map are internal. Unless the user confirms they're validated and cleared
  for public use, the README says they stay out of the product and public pages.

### Value proposition
Why someone picks this, answered in one breath.
- Their pain → the product → the gain, each concrete: "no stock count at close → the tally screen →
  tomorrow's order placed by 6pm", not "inefficiency → our platform → productivity".
- The check: **if it needs a comma, it's too long.**

### Promise
What the product guarantees, every single time.
- **Promise less, deliver every time.** Four kept promises buy little; one broken one costs the
  trust of all of them.
- The check: the promise is kept **today**. Where the software keeps it, check `docs/product.md` and
  the code; where people keep it (the staff, the makers), ask the user — and never let copy imply
  the software does what people do. A promise
  the roadmap will make true later is a pending decision ("promise X once Module 4 ships"), not copy.
- The same check applies to every proof line — certifications, compliance, customer counts, speed
  claims, "trusted by" lists. A claim that isn't true becomes a never-say rule with the true
  alternative beside it ("never claim [certification]; say what is true: [the controls that exist]").

### Differentiation
- List what the alternatives already say — from the user, or from a web search when one is
  available. Then make sure the positioning and the promise say something else.
- Ten products saying "simple, powerful, secure" is one product's worth of message.

## Only when it applies

### Brand architecture — two or more products, or audiences that need different names
- **Master brand** — one name on everything (Acme Maps, Acme Pay, Acme Docs). The default, and the right answer
  on a small budget: build one name, not five.
- **Sub-brand** — its own name, backed by the parent. Only when the audience is genuinely different
  (a hardware add-on sold to a different buyer, say).
- **Extension** — the trusted name on something new. Extend to neighbours, not strangers: a booking
  app adding reminders is a neighbour; the same app selling insurance is a stranger.
- Record the tree. It decides lockups (does the product name sit beside the parent mark?) and how
  features are named in the UI.

### Category — only if the user claims a new one
- A new category is a bet, not a fact. Name the problem before the product.
- Record the category name as a **pending decision with its test** attached: "keep it if five target
  buyers repeat it back unprompted." Until then it may appear in internal docs, not as a headline.

### Archetype — optional, as a voice shorthand
- One character the brand acts like everywhere (the rebel, the sage, the caregiver…). One, never a
  cast.
- Useful only if it makes the voice easier to hold. If the user shrugs, skip it — the dials below do
  the same job.

## Voice

How the brand sounds every time it speaks — the product's own strings included.

- **Three dials**, each set once: funny ↔ serious, casual ↔ formal, bold ↔ quiet. Write where each
  sits and why, in terms of the user ("serious, because the reader is about to send money").
- **Three "we are / we are not" lines** — "we are direct, not curt", "we are specific, not technical".
- **A say/don't-say table** built from the product's real moments: a success, an empty state, an
  error, an offline state, a confirmation. Each "say" names the specifics (who, how many, what
  next); each "don't say" is the generic version an agent would write unsteered. Names, items, and
  numbers in the examples are illustrative — label them so, so nobody copies one as a claim.
- **Trust moments are always plain.** Security, pricing, consent, and errors get no wit, whatever
  the dials say. That isn't the dials moving — it's a fixed exception, written as a rule.
- **A wit budget.** If the brand is witty, cap it ("one wink per page at most"), or wit spreads to
  every string.

## Distinctive assets

The colours, shapes, sounds, and marks that say "this brand" without the name.

- Name **two** before choosing a palette or drawing a mark: a colour, a shape, a typographic
  device, a sound, a motion. Everything in the identity system is built around them.
- Choose ones the brand can **use for years, not months**. Each distinctive asset becomes the most
  strictly protected rule in the README: it appears the same way everywhere, and a file that gets
  it wrong is corrected or banned.
- The check is the logo-hidden test: cover the name — is it still recognisably this brand?

## Where the brand shows up

List the surfaces it has to work on — the app, a landing page, store listings, email, social
images, decks, events, packaging. Each buying or using moment ("at the counter", "on the train
home") is a place to show up. The list scopes the identity system: no surface, no rule for it.

## Refresh or rebrand — re-runs

| | Refresh | Rebrand |
|---|---|---|
| Changes | Colours, type, a cleaner mark, imagery | Name, promise, audience |
| Story | Same | New |
| Reaches | `docs/brand/`, then `design-ui`'s re-map | Everything a refresh reaches, plus every string in the product's voice, every surface, and the decisions that depended on the old story |
| Default | Yes — fix the look first | Only if the story is broken, confirmed explicitly |

Before a rebrand is written, list every file it reaches and confirm. The old brand's decision
entries are superseded by new dated ones, never edited.

## Only the market can measure

Equity (what buyers pay for the name), recall ("name a product in this space"), and salience (how
often the brand comes to mind at the moment of choice) are measured out in the world. The skill
never claims them. If the user wants them tracked, write a short brief in `docs/brand/briefs/` with
the test ("ask ten target buyers to name a product in the space, unprompted; count mentions").
