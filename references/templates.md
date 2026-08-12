# Templates

Skeletons for each file type. Fill every bracketed placeholder with the project's real specifics before writing the final file — never ship a template with placeholder text still in it. Omit any section that has nothing real to say rather than leaving it as a stub.

---

## AGENTS.md (root)

```markdown
# [Project name]

[One or two sentences: what this project is and does.]

## Critical rules (read first)
- [Highest-priority, most-likely-to-be-violated rule — e.g. a business/pricing rule, a security boundary]
- [Next most important rule]

## Commands
- Install: `[command]`
- Dev/run: `[command]`
- Test: `[command]`
- Lint/format: `[command]`

## Code style
- [Only deltas from language/framework defaults — not restated tooling defaults]

## Architecture
[2-4 lines max — link to docs/architecture.md for anything longer]
See `docs/architecture.md` for the full system design.

## Testing requirements
- [What must be true before code is considered done]

## Security / boundaries
- [Files or directories that should never be edited directly, and why]
- [Data-handling rules, e.g. what must never be logged or persisted]

## Related docs
- `docs/decisions.md` — why non-obvious choices were made
- `docs/roadmap.md` — what's in scope now vs. deferred
- `docs/product.md` — current business/feature rules
- [`docs/design-system.md` — if applicable]
```

---

## CLAUDE.md (root and each nested subsystem, whenever Claude Code is a target agent)

A single import line is a complete, valid file — ship exactly this when there's nothing Claude-specific to add:

```markdown
@AGENTS.md
```

The section below is optional scaffolding, appended only if there's genuinely something extra. Never add it empty or with a placeholder:

```markdown
@AGENTS.md

## Claude Code specific
- [Anything genuinely specific to Claude Code — subagent conventions, permitted tools, etc. Keep this section short; if it's not Claude-specific, it belongs in AGENTS.md instead.]
```

The nested `<subsystem>/CLAUDE.md` is the same bare one-liner, importing that subsystem's sibling `AGENTS.md`. All real content stays in AGENTS.md.

---

## docs/decisions.md

```markdown
# Decisions log

Append-only. Each entry is dated and never rewritten — if a decision is later superseded, add a new entry noting that, don't edit the old one.

## [YYYY-MM-DD] — [Decision title]
**Decision:** [What was decided, one or two lines]
**Rationale:** [Why, one or two lines]
**Alternatives considered:** [Optional — only if genuinely useful context]
**Status:** Accepted
```

---

## docs/roadmap.md

```markdown
# Roadmap

## MVP scope
- [Feature/capability that's in for launch]

## Deferred (explicitly out of scope for now)
- [Feature/capability intentionally NOT being built yet, and why — prevents an agent from scope-creeping into it]

## Open questions
- [Anything still genuinely undecided]
```

---

## docs/product.md

```markdown
# Product spec

Current-state business and feature rules. Edit this in place as rules change — this is not a history log (see decisions.md for that).

## [Feature/domain area]
- [Rule, formula, or behavior an agent must implement correctly]

## [Another feature/domain area]
- [...]
```

---

## docs/architecture.md

```markdown
# Architecture

[System overview — one paragraph plus a component list or diagram description]

## Components
- **[Component name]**: [what it does, what it talks to]

## Data flow
[How a request/job/unit of work moves through the system, only as detailed as needed to be useful]

## Key constraints
- [Anything architectural that must not be violated, e.g. "the cloud must never hold a decryptable copy of X"]

---
Keep this file in sync with the actual code. A stale architecture doc is worse than none — update it in the same change as any real design shift, or remove sections that can't be kept current.
```

---

## docs/design-system.md (only if a UI subsystem exists)

```markdown
# Design system — [subsystem name]

## Color
- [Token/class]: [semantic meaning — what it's reserved for, not just what it looks like]

## Typography
- [Scale/weight]: [when to use it]

## Components
- [Component pattern name]: [where it's used, any variant rules]

## Layout
- [Any layout rules that differ meaningfully across screens/breakpoints]

## Voice / copy conventions
- [Language, tone, terminology specific to this product's domain]

## Accessibility baseline
- [Minimum touch target, contrast, etc. — only if actually decided]
```

---

## Nested `<subsystem>/AGENTS.md` (monorepos only)

```markdown
# [Subsystem name]

[One line: what this subsystem does, distinct from the rest of the repo]

## Stack
- [Language/framework/key libraries specific to this subsystem]

## Conventions specific to this subsystem
- [Only what differs from the root AGENTS.md — don't repeat root-level rules here]

## Commands (if different from root)
- [...]
```
