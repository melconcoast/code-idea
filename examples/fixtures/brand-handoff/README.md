# Fixture L — a brand handed over, with flaws

An overlay on `../pickup-queue/` (Fixture I) for `design-brand`'s import path. Copy the pickup
queue, then this directory's `docs/` over it and `handoff/` beside it:

```
cp -R examples/fixtures/pickup-queue /tmp/fixture-l
cp examples/fixtures/brand-handoff/docs/decisions.md /tmp/fixture-l/docs/
cp -R examples/fixtures/brand-handoff/handoff /tmp/fixture-l/
```

The founders' studio delivered `handoff/` — guidelines, a logo pack, a hero photo — and the
founders say: "this is our brand, bring it in." `docs/decisions.md` adds a public order page, so the
product now has a public face. Every flaw below is deliberate; a run passes when it finds each one
and confirms each separately. Nothing in `handoff/` is a real brand.

| Seeded flaw | Where | What `design-brand` must do | Scenario |
|---|---|---|---|
| Three text pairings fail contrast that the book doesn't forbid: Sage on Flour (2.18:1, which the book assigns to labels on light) and Rye on Crust and Oven (2.13:1 and 1.87:1, secondary type on dark). The book forbids only Ember on Flour (2.54:1) | §7 | Measure every allowed pairing; each failure becomes a rule | S126 |
| The light-ground SVG's sprig is Sage; the book says it is always Ember. The `@2x.png` raster carries the same error, is 1× size, and isn't a render of the wordmark at all | `handoff/logo/` | Find it by reading the fill; correct the SVG fill only, after confirming; record it in `CORRECTIONS.md`; list the PNG as don't-use unless it can be re-rendered from the corrected SVG | S127 |
| The book (§6) lists three logo files — on-light, on-dark, one-colour — but the pack has no one-colour file | `handoff/logo/` | Report the missing file as a finding; ask the designer for it in a brief rather than making one | S127 |
| Brandon Grotesque is held on a desktop licence only, bought for print | §8 | Flag before adoption for web or app; recommend a licensed substitute; buy, substitute, or defer | S128 |
| "Every loaf from certified-organic flour" contradicts the 2026-09-02 decision | §3 | Never-say rule with a true alternative; a root rule offered to `scaffold`, not written | S129 |
| The hero photo is "from a friend's shoot", with no licence | §9 | Don't-use for public pages until a per-file licence is recorded | S130 |
| The hero photo the book describes (§9) as the counter in early-morning light is a 320×240 flat brown gradient, not a photograph of anything | `handoff/imagery/` | Find it by opening the file, not trusting its name; report it as a placeholder that doesn't show what the book says, and put the real shot in the photography brief | S130 |
| Three open items | §10 | Each a pending decision | S131 |
| `docs/conventions.md` binds `--accent: #a8552b`, which no brand colour matches | `pickup-queue` | Conflict named for `design-ui` and `scaffold`; conventions untouched | S132 |

The 2,000-regulars proof line is unverifiable, not false: the expected outcome is a question, not a
ban. The other proof line ("baked before 6am") is a process claim the docs are silent on — the same.
