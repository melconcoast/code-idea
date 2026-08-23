# Templates

Skeletons for each file type. Fill every bracketed placeholder with the project's real specifics
before writing the final file — never ship a template with placeholder text still in it. Omit any
section that has nothing real to say rather than leaving it as a stub.

**One carve-out.** A dated pending-decision entry is not placeholder content. A placeholder is
unfilled template text (`[Project name]`, `TODO`) that asserts nothing. A pending-decision entry
asserts a real, current fact — this is undecided, as of this date, here's what to do instead — and is
required whenever the user defers a choice. Ship it.

**Layer 1 vs Layer 2.** Which file holds the content depends on the target agent — see
`agent-profiles.md`. What that content *says* does not. The `docs/*.md` skeletons below are identical
in every mode.

---

## AGENTS.md (root)

```markdown
# [Project name]

[One or two sentences: what this project is and does.]

## Critical rules (read first)
- [Highest-priority, most-likely-to-be-violated rule — e.g. a business/pricing rule, a security boundary]
- [Next most important rule]

## Pending decisions — do not resolve these yourself
- **[What's undecided]**: undecided as of [YYYY-MM-DD]. [What to do meanwhile — the concrete
  fallback behavior, e.g. "use unstyled/default components; do NOT pick a palette or font."]
  Ask before [the action this blocks]. → `docs/decisions.md`

  (Link the file, not a heading anchor — anchors derived from a dated title break silently if the title or date ever changes.)
```

> Omit this section entirely when nothing is deferred. Never ship it empty. It sits directly after
> Critical rules because a deferred decision is a rule — an agent that scrolls past it will invent an
> answer, which is the exact failure it exists to prevent.

```markdown
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
- `docs/development-roadmap.md` — the module/sub-module breakdown, dependency order, and what's deliberately deferred
- `docs/product.md` — current business/feature rules
- [`docs/design-system.md` — if applicable]
```

---

## `## Maintaining these docs` (every mode)

Goes in whichever file holds the content. Base version:

```markdown
## Maintaining these docs
- New rules, commands, and conventions → this file.
- New decisions → `docs/decisions.md` (append-only). Current business rules → `docs/product.md`.
- Recurring step-by-step procedures → a skill, not this file.
```

Claude Code native mode adds one line, because auto memory is machine-local and never committed:

```markdown
- If something useful landed in auto memory (`/memory`), promote it here so the team gets it.
```

When a rules directory was generated, the routing becomes a three-way decision so every *future*
rule follows the structure instead of defaulting back into the content file:

```markdown
- **Critical rules → this file**, never `.claude/rules/`. Path-scoped rules don't survive `/compact`.
- **Rules that apply only to certain paths → `.claude/rules/<topic>.md`**, one topic per file, with
  `paths:` frontmatter.
- **Everything else → this file.**
```

Omit these three lines entirely when no rules directory exists — they'd point at a folder that isn't
there.

Portable mode (two or more agents, or generic) adds the loader routing:

```markdown
- All rules live in THIS file. `CLAUDE.md` is a loader only — never add content to it.
- Nested subsystems: edit `<subsystem>/AGENTS.md`, never `<subsystem>/CLAUDE.md`.
```

---

## CLAUDE.md

Its role depends on the mode — see `agent-profiles.md`.

**Portable mode** (two or more agents, or generic) — `CLAUDE.md` is a loader. The import plus a short
visible echo of the routing rule:

```markdown
@AGENTS.md

## Maintaining these docs
- Do NOT add content to this file. It exists only so Claude Code loads `AGENTS.md`.
- New rules and conventions → `AGENTS.md`. New decisions → `docs/decisions.md`.
```

The echo must be visible markdown. Block-level HTML comments are stripped before entering Claude's
context, so a comment here would be invisible to the agent.

Append `## Claude Code specific` only when there is genuinely something extra — subagent conventions,
permitted tools. Never add it empty.

**Claude Code native mode** (Claude Code is the only target) — `CLAUDE.md` *is* the content file. Use
the root content skeleton above verbatim, with `## Maintaining these docs` in its native-mode form.
No `AGENTS.md` is generated.

The nested `<subsystem>/CLAUDE.md` is a loader one-liner in portable mode, and holds the subsystem's
content in native mode.

---

## Rules directories (only when a rules directory is warranted)

Generated only when there's genuinely path-scoped content — a monorepo, or a subsystem with distinct
conventions. When one is generated, the content file's `## Maintaining these docs` section **must**
carry the three-way routing rule, or the next rule added goes into the content file and the
directory goes vestigial.

### `.claude/rules/<topic>.md` (Claude Code)

One topic per file, named for the topic — `api.md`, `testing.md`, `migrations.md`:

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# [Topic] rules

- [Rule that applies only to files matching the paths above]
```

Three failure modes to avoid, all of them silent:

- **Omitting `paths` doesn't error.** It makes the rule load every session at the same priority as
  the content file. If that's what's wanted, put the rule in the content file instead — a rules file
  with no `paths` is just a confusing way to write a global rule.
- **An invalid `[`** that can't be parsed as a bracket expression matches nothing, so the rule never
  fires. Escape a literal bracket as `\[`.
- **Brace expansion multiplies.** A rule's whole `paths` list shares a budget of 1,000 expanded
  patterns; `{a,b}/{c,d}/*.{ts,tsx}` is already 8. A pattern over budget is used unexpanded and its
  literal braces match no files.

Never put a critical rule here. Path-scoped rules are not re-injected after `/compact` — they reload
only when Claude next reads a matching file, so a critical rule placed here silently vanishes
mid-session.

### `.agents/rules/<topic>.md` (Antigravity)

Plain markdown, one topic per file, 12,000 characters maximum per file.

**Do not add `paths:` frontmatter here.** The location and the size limit are verified; per-file
path-scoping syntax is not. Claude Code's `paths:` field is not known to transfer. If path scoping is
wanted, verify the syntax against Antigravity's own docs first and add it to `agent-profiles.md` with
a source — don't infer it from the Claude Code section of this file.

---

## docs/decisions.md

```markdown
# Decisions log

*Append-only. Add a new dated entry; never edit or delete a past one. To reverse a decision, add an entry that supersedes it.*

## [YYYY-MM-DD] — [Decision title]
**Decision:** [What was decided, one or two lines]
**Rationale:** [Why, one or two lines]
**Alternatives considered:** [Optional — only if genuinely useful context]
**Status:** Accepted
```

A deferred decision is recorded the same way, with no rationale yet and the options still open:

```markdown
## [YYYY-MM-DD] — [Decision title]
**Decision:** Deferred. Not yet decided.
**Options on the table:** [The candidates, including the one that would have been recommended]
**Why deferred:** [One line — e.g. "doesn't block the first slice of work"]
**Meanwhile:** [What an agent should do until this is settled]
**Status:** Pending
```

When it's decided later, append a **new** dated entry with `Status: Accepted` that supersedes this
one, and remove the matching item from the content file's Pending decisions section. Never edit the
pending entry in place — the log stays append-only.

---

## docs/development-roadmap.md

Always generated, including for trivial projects — see `best-practices.md`, "Why the development
roadmap is always generated." One `## Module <n>` block per module, each holding one or more
`### Sub-Module <n>.<m>` blocks, in dependency order.

**This file records modules and sub-modules only. It does not contain task tables.** Task-level
detail is `plan-module`'s output, written to its own plan file, and inventing it here — before any
code exists — produces confident guesses, which is the placeholder failure this whole file forbids.

```markdown
# Development Roadmap

*One block per module, sub-modules nested under it, in dependency order. A module or sub-module that's dropped keeps its block and becomes `Status: dropped` with a one-line reason — never deleted and never demoted into Deferred, or every `Depends on:` pointing at it dangles.*

## Module 1 — [Module name]
**Status:** planned
**Depends on:** none

### Sub-Module 1.1 — [Sub-module name]
**Status:** planned
**In scope:** [the specific capabilities this sub-module delivers]
**Out of scope:** [what a reader would reasonably assume is here but isn't — and where it went instead]
**Tasks:** not yet planned

## Deferred (explicitly out of scope for now)
- [Capability intentionally NOT being built yet, and why — prevents an agent from scope-creeping into it]

## Open questions
- [Anything still genuinely undecided — point at `docs/decisions.md` if it has a Pending entry]
```

**`Status` is a closed vocabulary — these five values only**, at both module and sub-module level. A
free-text status makes the file unusable by the step that reads it.

| Status | Means |
|---|---|
| `planned` | Agreed and sequenced, not started |
| `in progress` | Being built now |
| `done` | Built and merged |
| `blocked` | Cannot start; the blocker is named in `Depends on:` |
| `dropped` | Was planned, deliberately abandoned. Keep the block; state why in `Out of scope:` |

**Identifiers.** Modules are `Module <n>`; sub-modules are `<n>.<m>`. `plan-module` operates on one
**module** at a time and its sub-modules become the phase boundaries of that module's plan file.

**`Depends on:`** takes `none`, one or more module or sub-module ids with blocks in this same file, or
a named external blocker (a pending decision, a third-party dependency) — but never an id with no
block here.

**`Tasks:` is a pointer, never a task list.** It reads `not yet planned` until `plan-module` runs,
and then becomes `see docs/guides/feature_<module>_plan.md — Phase <n>`. Task detail lives in the
plan file only. Code in a roadmap goes stale the moment the code changes, and a stale doc misleads
more than no doc at all.

`## Deferred` and a `dropped` module are not the same thing. Deferred items were never modules —
they're capability-level scope decisions. A dropped module was scoped and sequenced first, and the
roadmap keeps that distinction because "we never planned this" and "we planned this and killed it"
are different facts.

---

## docs/product.md

```markdown
# Product spec

*Current state, not history. Edit rules in place; the reasoning behind a change goes in `decisions.md`.*

## [Feature/domain area]
- [Rule, formula, or behavior an agent must implement correctly]

## [Another feature/domain area]
- [...]
```

---

## docs/architecture.md

```markdown
# Architecture

*Update in the same change as any real design shift. Delete a section you can't keep current — a stale one misleads more than none.*

[System overview — one paragraph plus a component list or diagram description]

## Components
- **[Component name]**: [what it does, what it talks to]

## Data flow
[How a request/job/unit of work moves through the system, only as detailed as needed to be useful]

## Key constraints
- [Anything architectural that must not be violated, e.g. "the cloud must never hold a decryptable copy of X"]
```

---

## docs/design-system.md (only if a UI subsystem exists)

```markdown
# Design system — [subsystem name]

*Every token needs its semantic meaning — what it's reserved for, not just its value. Don't add one without saying when to use it.*

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

## docs/conventions.md (only when conventions exceed tooling defaults)

```markdown
# Conventions

*Add a rule only if a linter or formatter doesn't already enforce it, and give each rule a concrete example.*

## Naming
- [Entity type]: [the rule, with a concrete example — e.g. "DB tables: plural snake_case, `cake_orders`"]

## File and directory structure
- [Where a given kind of file goes, and what the name should look like]

## API shape
- [Route naming, verb usage, response envelope — only if there's a real convention to state]

## Module boundaries
- [What may import what, and what must not]
```

Generate this only when there are real conventions beyond what a linter or formatter already
enforces. A project with nothing but tooling defaults keeps a thin `## Code style` section in the
content file and gets no separate doc — same rule as every other optional file.

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
