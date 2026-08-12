# code-idea v1.2.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the skill re-confirm decisions on a re-run, let a user defer an undecided choice, and generate each target agent's native context layout instead of one universal one.

**Architecture:** Two layers. Layer 1 is the agent-native container (which files exist, how they load) taken from each agent's official docs. Layer 2 is the universal engineering content (system design, naming conventions, UI, business rules) that is identical regardless of target. All per-agent facts live in one new reference file behind a verify-before-trusting header, so the fastest-aging content sits in exactly one place.

**Tech Stack:** Markdown only. No build, no test runner. Verification is content assertions via `grep`, plus running the skill against fixture scenarios.

## Global Constraints

- `SKILL.md` hard ceiling is **150 lines**. It is 88 now. Check after every task that touches it.
- No placeholder or TODO content ships, with exactly one carve-out: a dated pending-decision entry (C5).
- Bullet-point imperatives over prose paragraphs, matching how the skill asks generated files to be written.
- Every per-agent claim carries a **source URL and a verified-on date**. Anything not citable is left out, not guessed.
- Layer 2 output must be byte-identical across two runs targeting different agents.
- Agent facts are verified as of **2026-08-12**.
- Spec: `docs/superpowers/specs/2026-08-12-reconfirmation-deferred-decisions-agent-adapters-design.md`. Change IDs below (C1-C18) refer to it.
- Version for this release is **1.2.0**.

---

### Task 1: Test scenarios file

Write the tests first. This repo has no runner, so a "test" is a fixture plan plus the outcome the skill must produce. This file is what every later task verifies against, and what `CONTRIBUTING.md` currently only describes in prose.

**Files:**
- Create: `examples/test-scenarios.md`

**Interfaces:**
- Consumes: nothing.
- Produces: scenario IDs `S1`-`S32`, referenced by every later task's verification step.

- [ ] **Step 1: Create the scenarios file**

Create `examples/test-scenarios.md`:

```markdown
# Test scenarios

There's no automated suite — this is a markdown skill. Each scenario below is a fixture plan plus the
outcome the skill must produce. Run the skill against the fixture and check the expectations by hand.

Per `CONTRIBUTING.md`, a change needs at least one scenario where it clearly fires and one where it
clearly shouldn't. The "must NOT" rows exist for that reason — they're not filler.

## Fixture A — single app, some decisions made

> A web app for a small bakery to take custom cake orders. Customers submit an order with a date,
> size, and flavor; staff see a queue and mark orders done. Payments are card-on-pickup, no online
> payment. I want it on Postgres. I haven't thought about how it should look yet.

## Fixture B — monorepo, nothing decided

> A fleet-tracking product with three parts: a device agent in Go that reports GPS, an ingest API,
> and a web dashboard. Different teams own each. No stack decided beyond the Go agent.

## Fixture C — already scaffolded

Fixture A, run a second time against a repo that already contains `AGENTS.md`, `CLAUDE.md`, and
`docs/design-system.md` asserting a slate/shadcn theme that the user never confirmed.

## Fixture D — a plan containing secrets

Fixture A, with this appended. The values are fake, but the skill must treat them as real:

> Staging DB is `postgres://svc_bakery:Hunter2Bakery@db-staging.internal.acme.corp:5432/orders`.
> Admin panel is at `https://10.4.19.22:8443`. Stripe test key `sk_test_51QhExampleNotARealKey`.
> Our first customer is Maria Delgado, maria.delgado@example.com, 555-0142.

---

## Scenarios

| ID | Setup | Must produce | Must NOT produce |
|---|---|---|---|
| S1 | Fixture C | Step 0 announces the existing scaffold before any question | Silent regeneration |
| S2 | Fixture C | The theme in `design-system.md` is re-asked, offered as the current value | Treating it as settled |
| S3 | Fixture C | Target-agent question re-asked despite `CLAUDE.md` existing | Inferring the agent from the file layout |
| S4 | Fixture A | No re-run language anywhere | A Step 0 announcement on a fresh scaffold |
| S5 | Fixture A, user defers the theme | Pending block at top of the content file; `Status: Pending` entry in `decisions.md`; listed in Step 5 summary | Any `design-system.md` |
| S6 | Fixture A, user answers everything | No pending section at all | An empty "Pending decisions" heading |
| S7 | Fixture C with a pending decision on file | It is surfaced first, with an option to keep it parked | Re-asking it as if new |
| S8 | Fixture A, target = Claude Code alone | Content in root `CLAUDE.md`; auto-memory promotion line | Any `AGENTS.md` |
| S9 | Fixture A, target = Codex alone | Content in `AGENTS.md`, root file well under the 32 KiB cap | Any `CLAUDE.md` |
| S10 | Fixture A, target = generic | `AGENTS.md` + `CLAUDE.md` containing `@AGENTS.md` | Native-mode layout |
| S11 | Fixture A, target = Claude Code + Codex | Portable core; ceiling is the stricter of the two | Native mode for either |
| S12 | Fixture A run twice, Claude-native then Codex-native | `docs/*.md` byte-identical across both runs | Layer 2 content varying by target |
| S13 | Fixture B, Claude-native | Nested `CLAUDE.md` per subsystem; critical rules still in root | Critical rules pushed into `.claude/rules/` |
| S16 | Fixture A, target = Antigravity alone | Content in `AGENTS.md` | A `GEMINI.md`, or any `CLAUDE.md` |
| S17 | Fixture A, target = Antigravity, repo already has `GEMINI.md` | Content written into the existing `GEMINI.md` | A second root rules file alongside it |

## Rules-directory scenarios

| ID | Setup | Must produce | Must NOT produce |
|---|---|---|---|
| S18 | Fixture B, Claude-native, path-scoped conventions per subsystem | `.claude/rules/<topic>.md` with a valid `paths:` frontmatter, one topic per file | A rules file with no `paths` field |
| S19 | S18's output | Three-way routing rule in the content file naming `.claude/rules/` for path-scoped rules | Routing that sends all future rules to the content file |
| S20 | Fixture A, Claude-native, no path-scoped content | No `.claude/rules/` directory; no three-way routing lines | An empty rules directory, or routing pointing at a folder that doesn't exist |
| S21 | Fixture B, Antigravity-native | `.agents/rules/<topic>.md` as plain markdown under 12,000 chars | Any `paths:` frontmatter — that syntax is unverified for Antigravity |

## Doc-structure scenarios

| ID | Setup | Must produce | Must NOT produce |
|---|---|---|---|
| S22 | Any run generating `docs/*.md` | Every generated doc carries its extension rule directly under the H1 | A doc with no extension rule; a rule in a footer |
| S23 | S22's output | The rule is a single italic line | A `## Maintaining` section inside a `docs/*.md` file |
| S24 | Fixture A, user defers the theme | `decisions.md` extension rule present even though the only entry is `Status: Pending` | A pending-only decisions log with no append-only rule |

## Convention scenarios

| ID | Setup | Must produce | Must NOT produce |
|---|---|---|---|
| S14 | Fixture B (API route shapes, table naming across teams) | `docs/conventions.md` | A thin `## Code style` stub instead |
| S15 | Fixture A (nothing beyond linter defaults) | Thin `## Code style` section in the content file | A `docs/conventions.md` |

## Secrets scenarios

| ID | Setup | Must produce | Must NOT produce |
|---|---|---|---|
| S25 | Fixture D | Named references — `DATABASE_URL`, `STRIPE_SECRET_KEY`, `<internal-host>` | The password, the key, the internal hostname, or the IP, in any generated file |
| S26 | Fixture D | No customer name, email, or phone anywhere in output | Real personal data used as an example |
| S27 | Fixture D, user says "just include the connection string, it's only staging" | The named-reference form, and a short note on why | The literal credential, even when the user asked for it |

## Trigger scenarios

Run these after **any** edit to the frontmatter `description`. They guard the mechanism every other
scenario depends on.

| ID | Setup | Must produce | Must NOT produce |
|---|---|---|---|
| S28 | "get this ready for Claude Code" / "scaffold the project docs" / "turn this plan into context files" / "hand this off to a coding agent" | The skill fires on each | Silence on any of them |
| S29 | "how does AGENTS.md work?" — abstract question, no project in play | An explanation | A scaffold, or an interview |

## Output-integrity scenarios

| ID | Setup | Must produce | Must NOT produce |
|---|---|---|---|
| S30 | Fixture A, theme deferred | Every `## Related docs` link resolves to a generated file | A link to `docs/design-system.md`, which was deliberately not generated |
| S31 | Fixture B, target = Codex | Step 5 reports root file size against the 32 KiB cap | Silence about size on a target whose cap truncates silently |
| S32 | Fixture B, target = Claude Code + Codex | Size reported against the stricter of the two limits | Reporting against only one agent's limit |
```

- [ ] **Step 2: Verify the scenarios currently fail**

Run the skill against Fixture C in a scratch directory containing a stub `AGENTS.md`, `CLAUDE.md`, and `docs/design-system.md`.

Expected: S1, S2, S3 all fail — the current skill regenerates without announcing the existing scaffold and without re-asking the theme or the target agent. This failure is the bug being fixed; record what it actually did.

- [ ] **Step 3: Commit**

```bash
git add examples/test-scenarios.md
git commit -m "test: add scenario fixtures for v1.2.0 changes

Thirty-two scenarios covering re-run confirmation, deferred decisions,
per-agent layouts, and layer separation. S1-S3 currently fail against
v1.1.0, which is the defect this release fixes."
```

---

### Task 2: `references/agent-profiles.md`

The new home for all per-agent facts (C10, C12 Layer 1). Everything else references this file rather than restating it.

**Files:**
- Create: `references/agent-profiles.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the per-agent container facts that `SKILL.md` Step 3 and `references/templates.md` both point at. Agent keys used downstream: `claude-code`, `codex`, `antigravity`, `generic`.

- [ ] **Step 1: Confirm the verification record (already performed 2026-08-12)**

All three agents were verified against primary sources on 2026-08-12. Sources:

- Claude Code — https://code.claude.com/docs/en/memory
- Codex — https://learn.chatgpt.com/docs/agent-configuration/agents-md (redirected from `developers.openai.com/codex/guides/agents-md`)
- Antigravity — https://antigravity.google/docs/rules-workflows and https://antigravity.google/docs/cli/best-practices

**Three claims were removed for lack of primary support.** Do not reintroduce them from the spec's earlier drafts or from blog sources:

| Removed claim | Why |
|---|---|
| "Codex is trained to run test commands named in `AGENTS.md`" | Docs frame commands as working agreements, not execution directives |
| "`GEMINI.md` wins conflicts with `AGENTS.md`" | Antigravity docs say "`GEMINI.md` *or* `AGENTS.md`" and state no precedence |
| "Antigravity added `AGENTS.md` support in v1.20.3" | Third-party blog, not Google's docs. Support is confirmed; the version is not |

Step 2's content already reflects these corrections. This step exists so an executing agent knows the removals were deliberate rather than oversights.

If any source URL 404s or its content has changed, treat the affected row as unverified: correct it, or drop it and note the drop in the commit message. Primary docs outrank this plan.

- [ ] **Step 2: Write the file**

Create `references/agent-profiles.md`. Replace any claim Step 1 corrected:

```markdown
# Agent profiles

What each coding agent reads, and how it loads it. This is **Layer 1** — the container. It decides
where content lives and how it loads, never what the content says. Layer 2 (system design, naming
conventions, UI, business rules) is identical across every agent; see `templates.md`.

> **This file is expected to age.** Every row carries a source and a verified-on date. Agent context
> loading changes fast — a claim here went stale within one release of this skill. Verify against the
> source before trusting a row, and treat an outdated entry as a normal PR rather than a bug.
>
> **Never assert an agent behavior you can't cite.** If it isn't in that agent's own docs, leave it
> out rather than inferring it.

## Claude Code

- **Reads `AGENTS.md`?** No. It reads `CLAUDE.md` only. There is no setting that changes this.
- **Loader needed?** Yes, when `AGENTS.md` holds the content: a `CLAUDE.md` containing `@AGENTS.md`.
- **Content file:** `./CLAUDE.md` or `./.claude/CLAUDE.md`. Target under 200 lines.
- **Nested:** `CLAUDE.md` in a subdirectory loads on demand when Claude reads files there.
- **Path-scoped rules:** `.claude/rules/*.md` with `paths:` frontmatter — loads only when a matching
  file is touched.
- **Imports:** `@path` syntax. Relative paths resolve against the file containing the import, not the
  working directory. Max depth four hops.
- **Enforcement:** `CLAUDE.md` is context, not configuration. A rule that must hold regardless of
  what the agent decides belongs in a `PreToolUse` hook.
- **Verify loading:** run `/context` and check the list under **Memory files**.

**Gotchas that shape what this skill generates:**
- Root `CLAUDE.md` is re-injected after `/compact`. Nested `CLAUDE.md` and path-scoped rules are
  **not** — they reload only when Claude next reads a matching file. Keep critical rules in the root
  file.
- Block-level HTML comments are stripped before entering context. A rule written as an HTML comment
  is invisible to the agent.
- "Remember this" / auto memory writes to `~/.claude/projects/<project>/memory/`, which is
  machine-local and never committed. Useful rules captured there must be promoted into the content
  file to reach the team.
- `/init` does **not** overwrite an existing `CLAUDE.md`; it suggests improvements.
- `/import` (v2.1.213+) appends a one-time **copy** of `AGENTS.md` into `CLAUDE.md`, duplicating
  content. Don't run it against a scaffold this skill produced.

Source: https://code.claude.com/docs/en/memory — verified 2026-08-12

## Codex

- **Reads `AGENTS.md`?** Yes, natively. No loader needed.
- **Discovery:** from the project root down to the current working directory. Per directory it takes
  `AGENTS.override.md`, else `AGENTS.md`, else a name from `project_doc_fallback_filenames` — at most
  one file per directory. Empty files are skipped. It stops at the current directory.
- **Merge:** files are concatenated root→leaf, joined by blank lines. Closer files override earlier
  guidance by appearing later in the combined prompt.
- **Size cap:** 32 KiB (`project_doc_max_bytes`, 32,768 bytes default). Codex **stops adding files**
  once the combined size reaches the cap.
- **Config:** `.codex/config.toml` per project, `~/.codex/config.toml` globally. Not a context file —
  don't put project rules there.

**Gotcha that shapes what this skill generates:** because Codex stops adding files at the cap, an
oversized root `AGENTS.md` silently starves the nested ones — the deepest, most specific guidance is
what gets dropped. Keeping the root lean is a correctness requirement here, not just style. Raising
`project_doc_max_bytes` or splitting across nested directories are the escape hatches.

Not asserted: that Codex automatically executes the commands named in `AGENTS.md`. The docs describe
them as working agreements, not execution directives.

Source: https://learn.chatgpt.com/docs/agent-configuration/agents-md — verified 2026-08-12

## Antigravity

- **Reads `AGENTS.md`?** Yes, natively, alongside `GEMINI.md`. No loader needed. Both are parsed on
  startup and consulted before the agent suggests changes.
- **Workspace rules:** `.agents/rules/` in the workspace or git root. `.agent/rules` retains
  backward support.
- **Size cap:** 12,000 characters per rule file.
- **Global:** `~/.gemini/GEMINI.md` applies across all workspaces.

**Which root file to generate:** `AGENTS.md`. `GEMINI.md`'s only documented role is the *global*
file at `~/.gemini/GEMINI.md`, which this skill doesn't write. At the workspace root the two are
documented as parallel equivalents with no stated preference, so `AGENTS.md` wins on portability
alone — it's read by Codex and ~20 other agents at no extra cost.

**Exception:** if the repo already has a `GEMINI.md`, put the content there instead. Two root-level
rules files with no documented precedence between them is worse than either alone.

Not asserted: any precedence between `GEMINI.md` and `AGENTS.md`. The docs say "`GEMINI.md` *or*
`AGENTS.md`" and never resolve a conflict. If a project has both, surface it rather than guessing.

**The native capability worth adopting here is `.agents/rules/`,** not a different root filename —
it's the documented default for workspace rules and the exact parallel of Claude Code's
`.claude/rules/`. Offer it when there's genuinely path-scoped content, same rule.

Source: https://antigravity.google/docs/rules-workflows,
https://antigravity.google/docs/cli/best-practices, and
https://antigravity.google/docs/cli/gcli-migration — verified 2026-08-12

## Generic / multiple agents

No single native format applies, so use the portable layout: `AGENTS.md` holds the content, plus a
`CLAUDE.md` containing `@AGENTS.md`.

Ship the loader even when Claude Code wasn't named. It is one inert line that every other agent
ignores, and without it the docs are invisible the moment someone opens the repo in Claude Code —
the most common way a generic scaffold silently fails.

When several agents are selected, apply the **strictest** limit across them so one file stays valid
everywhere.
```

- [ ] **Step 3: Verify no uncited claim survives**

```bash
grep -n "^Source:" references/agent-profiles.md
```

Expected: three entries, each a real `https://` URL with `verified 2026-08-12`. No brackets, no TBD.

```bash
grep -in "trained to run\|wins on conflict\|v1\.20\.3" references/agent-profiles.md
```

Expected: no output. These are the three claims that failed verification; if any reappeared, it was copied from an outdated draft.

- [ ] **Step 4: Commit**

```bash
git add references/agent-profiles.md
git commit -m "feat: add agent-profiles.md with per-agent container facts

Layer 1 facts for Claude Code, Codex, and Antigravity, each with a
source URL and verified-on date. Carries an expected-to-age header:
per-agent knowledge is the fastest-aging content in the repo."
```

---

### Task 3: `references/templates.md`

Skeletons for the new outputs (C4 pending decisions, C8 routing rules, C12 conventions doc and native-mode content file) and the C5 carve-out.

**Files:**
- Modify: `references/templates.md`

**Interfaces:**
- Consumes: agent keys from Task 2.
- Produces: the `## Pending decisions` block shape and `Status: Pending` entry shape that `SKILL.md` Step 4 and Step 5 both reference.

- [ ] **Step 1: Amend the preamble with the C5 carve-out**

Replace the existing preamble (lines 1–4) with:

```markdown
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
```

- [ ] **Step 2: Add the pending-decisions block to the root content skeleton**

In the `## AGENTS.md (root)` skeleton, insert immediately after the `## Critical rules (read first)` section and before `## Commands`:

```markdown
## Pending decisions — do not resolve these yourself
- **[What's undecided]**: undecided as of [YYYY-MM-DD]. [What to do meanwhile — the concrete
  fallback behavior, e.g. "use unstyled/default components; do NOT pick a palette or font."]
  Ask before [the action this blocks]. → `docs/decisions.md#pending-[slug]`
```

Add below the skeleton:

> Omit this section entirely when nothing is deferred. Never ship it empty. It sits directly after
> Critical rules because a deferred decision is a rule — an agent that scrolls past it will invent an
> answer, which is the exact failure it exists to prevent.

- [ ] **Step 3: Add the routing rule, scaled to mode**

Add a new section after the root skeleton:

````markdown
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
````

- [ ] **Step 4: Amend the CLAUDE.md skeleton for both modes**

Replace the `## CLAUDE.md (root and each nested subsystem...)` section with:

````markdown
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
````

- [ ] **Step 5: Add the `Status: Pending` decisions entry**

In the `docs/decisions.md` section, add after the existing entry skeleton:

```markdown
A deferred decision is recorded the same way, with no rationale yet and the options still open:

## [YYYY-MM-DD] — [Decision title]
**Decision:** Deferred. Not yet decided.
**Options on the table:** [The candidates, including the one that would have been recommended]
**Why deferred:** [One line — e.g. "doesn't block the first slice of work"]
**Meanwhile:** [What an agent should do until this is settled]
**Status:** Pending

When it's decided later, append a **new** dated entry with `Status: Accepted` that supersedes this
one, and remove the matching item from the content file's Pending decisions section. Never edit the
pending entry in place — the log stays append-only.
```

- [ ] **Step 5b: Add the rules-directory skeletons (C13)**

Add a new section after the CLAUDE.md section:

````markdown
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
````

- [ ] **Step 6: Add the `docs/conventions.md` skeleton**

Add a new section before the nested-subsystem section:

````markdown
## docs/conventions.md (only when conventions exceed tooling defaults)

```markdown
# Conventions

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
````

- [ ] **Step 6b: Give every doc skeleton its extension rule (C14)**

Add one italic line directly under the `# H1` of each `docs/*.md` skeleton. One line, never a section — a maintenance block per doc would bloat the set the skill exists to keep lean.

| Skeleton | Line to add under the H1 |
|---|---|
| `decisions.md` | `*Append-only. Add a new dated entry; never edit or delete a past one. To reverse a decision, add an entry that supersedes it.*` |
| `architecture.md` | `*Update in the same change as any real design shift. Delete a section you can't keep current — a stale one misleads more than none.*` |
| `product.md` | `*Current state, not history. Edit rules in place; the reasoning behind a change goes in `decisions.md`.*` |
| `roadmap.md` | `*Move items between sections rather than deleting them — a deleted "deferred" item loses the record that it was deliberately not built.*` |
| `design-system.md` | `*Every token needs its semantic meaning — what it's reserved for, not just its value. Don't add one without saying when to use it.*` |
| `conventions.md` | `*Add a rule only if a linter or formatter doesn't already enforce it, and give each rule a concrete example.*` |

Three of these replace prose that already exists elsewhere in the skeleton — fold, don't duplicate:
- `decisions.md`'s current "Append-only. Each entry is dated and never rewritten…" preamble.
- `architecture.md`'s current keep-in-sync **footer** — this moves to the top. A rule about how to edit a doc has to be read before the edit, and a footer is exactly what a targeted edit skips.
- `product.md`'s current "Current-state business and feature rules…" preamble.

- [ ] **Step 7: Verify**

Every doc skeleton has an extension rule, and none grew a maintenance section:

```bash
grep -c "^\*.*\*$" references/templates.md
```

Expected: `6` — one italic extension line per doc skeleton.

```bash
grep -n "^---$" references/templates.md | tail -1
grep -n "Keep this file in sync" references/templates.md
```

Expected: the keep-in-sync line no longer appears at the end of the `architecture.md` skeleton — it moved under the H1.

```bash
grep -c "Pending" references/templates.md
```

Expected: at least `4` (carve-out, root skeleton section, decisions entry, status line).

```bash
grep -n "ship exactly this" references/templates.md
```

Expected: no output — the old one-liner claim contradicted the new routing echo and must be gone.

- [ ] **Step 8: Commit**

```bash
git add references/templates.md
git commit -m "feat: add pending-decision, routing, and conventions skeletons

Adds the C5 carve-out distinguishing a dated pending-decision entry
from placeholder text, the mode-dependent routing rule, the
Status: Pending decisions entry, and a docs/conventions.md skeleton.
Replaces the 'ship exactly this' CLAUDE.md one-liner, which
contradicted the new routing echo."
```

---

### Task 4: `references/best-practices.md`

The reasoning behind the new rules, plus corrections to sections this release makes wrong (C9, C12).

**Files:**
- Modify: `references/best-practices.md`

**Interfaces:**
- Consumes: Task 2's facts.
- Produces: the "why" that `SKILL.md` points at when a judgment call comes up.

- [ ] **Step 1: Fix the two now-wrong sections**

`## AGENTS.md is the canonical filename` (line 5) and `## Nested files for monorepos — content in AGENTS.md, companion CLAUDE.md for Claude Code` (line 34) both assert AGENTS.md-first as universal. Rewrite them to the native/portable rule:

```markdown
## The canonical filename depends on the target

There is no universal answer. `AGENTS.md` is read natively by Codex and Antigravity and is the right
portable default when the target is plural or unknown. Claude Code does not read it at all, so a
Claude-Code-only project is better served by its native `CLAUDE.md` layout.

One named agent gets its native layout. Two or more, or generic, gets `AGENTS.md` plus a `CLAUDE.md`
loader — going native for one of several would leave the others reading nothing.

This is a change from earlier versions of this skill, which treated `AGENTS.md` as the universal
home. Portability is worth having when more than one agent is in play, and worth nothing when only
one is — where it costs that agent's real capabilities.
```

- [ ] **Step 2: Add the layer-separation section**

```markdown
## Two layers: container and content

Picking a target agent decides how context is stored, loaded, and scoped. It never decides what the
engineering guidance says.

**Layer 1, the container** — which files exist, how they load, what their size limits are. This is
agent-specific and comes from that agent's own docs. It ages fast, so it lives in exactly one file,
`agent-profiles.md`, behind a verify-before-trusting header.

**Layer 2, the content** — system design, naming conventions, UI direction, business rules,
decisions, scope. Identical in every mode, because good naming and sound architecture don't vary by
which agent reads them.

The practical test: scaffold the same plan twice for two different agents. Every `docs/*.md` file
should come out byte-identical. If Layer 2 drifted by target, the boundary leaked.

This separation is also what makes re-runs safe. Changing the target agent rewrites Layer 1 only;
Layer 2 moves across untouched, so switching agents is a migration rather than a regeneration.
```

- [ ] **Step 3: Add the Claude Code limits section**

```markdown
## Claude Code specifics, and what they can't do

The `CLAUDE.md` loader is required, not a hedge — Claude Code does not read `AGENTS.md`, and no
setting changes that. Earlier versions of this skill claimed an opt-in setting existed. It does not.
That claim went stale within one release, which is why per-agent facts now carry sources and dates.

Four limits worth designing around:

- **Critical rules belong in the root file.** Root `CLAUDE.md` is re-injected after `/compact`.
  Nested files and path-scoped `.claude/rules/` are not — they reload only when Claude next reads a
  matching file. A critical rule pushed into a path-scoped file silently vanishes mid-session.
- **A routing rule can't intercept the harness.** It reliably catches an agent reasoning about where
  to put a change, which is the common case. It cannot catch writes that never consult file content.
  What it buys is recoverability: the next agent that reads it knows to migrate the content back.
- **Auto memory never reaches the team.** "Remember this" writes to a machine-local directory outside
  the repo. Genuinely useful rules captured there have to be promoted into the content file, which is
  why the routing rule says so explicitly.
- **`CLAUDE.md` is context, not enforcement.** A rule that must hold regardless of what the agent
  decides belongs in a `PreToolUse` hook. Don't write a doc rule and call it a guarantee.

`.claude/rules/` path-scoping is a real capability the portable layout gives up. Offer it in
Claude-native mode when there's genuinely path-scoped content — a monorepo, or a subsystem with
distinct conventions — and not otherwise.
```

- [ ] **Step 4: Add the deferred-decisions reasoning**

```markdown
## A deferred decision is a rule, not a gap

Forcing a decision the user hasn't made produces a doc that reads as settled and is wrong. Recording
"undecided" is strictly better information than a guess presented as a choice.

That's why a pending decision sits directly after Critical rules rather than in a linked doc: it *is*
a rule — "do not resolve this yourself" — and an agent that scrolls past it will invent an answer,
which is the exact failure being prevented.

It also has to survive the no-placeholder rule, which would otherwise suppress it. The distinction is
whether the text asserts anything. `[Project name]` asserts nothing. "Undecided as of 2026-08-12, use
default components, ask before adding tokens" asserts a current fact and prescribes behavior.

The doc that would have held the decision is not generated at all. A `design-system.md` whose main
content is a hole is worse than its absence — absence prompts a question, a hollow doc looks answered.
```

- [ ] **Step 5: Add the re-run reasoning**

```markdown
## A doc on disk is not a confirmation

Existing docs prove a file was written. They don't prove a user decided anything. The content may
come from an older version of this skill under weaker confirmation rules, from a different tool, or
from a hand edit nobody remembers.

So on-disk content is treated exactly like an assistant proposal: unconfirmed, and re-asked. This
matters most on the projects scaffolded before the confirmation rules existed — precisely the ones
where a silent regeneration would relaunch every unconfirmed guess as settled fact.

What makes it tolerable rather than an interrogation is offering the current value as the
recommendation. "Currently slate/shadcn — keep it, change it, or park it?" is one keystroke to
confirm, and it still gives the user the moment to say no.
```

- [ ] **Step 6: Verify the stale claim is gone**

```bash
grep -in "opt-in setting" references/best-practices.md references/*.md SKILL.md
```

Expected: no output outside `SKILL.md` at this point (SKILL.md is fixed in Task 6). After Task 6, expected: no output at all.

- [ ] **Step 7: Commit**

```bash
git add references/best-practices.md
git commit -m "docs: rewrite AGENTS.md-first reasoning, add layer and limits sections

Corrects the canonical-filename and nested-files sections, which
asserted AGENTS.md-first as universal. Adds the container/content
layer split, Claude Code's four design-relevant limits, and the
reasoning behind deferred decisions and re-run confirmation."
```

---

### Task 5: `references/recommendation-heuristics.md`

Layer 2's source of grounded defaults gains naming-convention guidance to match the new `docs/conventions.md` candidate (C12).

**Files:**
- Modify: `references/recommendation-heuristics.md`

- [ ] **Step 1: Add the naming conventions section**

Append after `## UI design — patterns and layout`:

```markdown
## Naming conventions

Recommend, don't ask — same pattern as the rest of this file. A user without strong opinions should
get a defensible default, not a blank prompt.

- **Database tables/columns:** plural snake_case tables, singular snake_case columns
  (`cake_orders.customer_id`). Exception: follow the ORM's convention when it's opinionated enough
  that fighting it costs more than it's worth.
- **API routes:** plural nouns, no verbs (`/orders`, `/orders/{id}/items`). Verbs go in the method.
  Exception: genuinely non-CRUD actions read better as `/orders/{id}/cancel` than as a PATCH with a
  magic field.
- **Files:** match the ecosystem rather than imposing one — kebab-case in JS/TS, snake_case in
  Python and Go, PascalCase for component files in React codebases that already do that.
- **Booleans:** `is_`/`has_`/`can_` prefix. Ambiguous names like `status` on a two-state field cause
  real bugs when an agent guesses the polarity.

Only write these into `docs/conventions.md` when they go beyond what a linter or formatter already
enforces — a rule the tooling checks doesn't need restating to an agent.
```

- [ ] **Step 2: Verify**

```bash
grep -n "^## " references/recommendation-heuristics.md
```

Expected: the existing sections plus `## Naming conventions`.

- [ ] **Step 3: Commit**

```bash
git add references/recommendation-heuristics.md
git commit -m "feat: add naming-convention defaults to recommendation heuristics

Layer 2 gains grounded defaults for table, route, file, and boolean
naming so docs/conventions.md has something to recommend rather than
asking the user to invent conventions."
```

---

### Task 6: `SKILL.md` — frontmatter and philosophy

The thesis change (C7, C12) and the stale-claim fix (C9). Highest-risk edit in the release: the `description` is what makes the skill fire at all.

**Files:**
- Modify: `SKILL.md:1-24`

**Interfaces:**
- Consumes: `references/agent-profiles.md` from Task 2.
- Produces: the philosophy bullets that Steps 0–5 assume.

- [ ] **Step 1: Rewrite the frontmatter description**

The current description promises "a lean root AGENTS.md plus linked docs," now false in native mode. Replace the description value, **keeping every existing trigger phrase** — those are what make the skill fire:

```yaml
description: Transforms a project plan, idea, or planning conversation into a complete AI-coding-agent-ready documentation set — a lean root context file in whichever format the target agent reads natively (CLAUDE.md for Claude Code, AGENTS.md for Codex/Antigravity, or both for mixed and generic targets), plus linked docs (architecture, decisions, conventions, roadmap, product, design-system) and, for monorepos, nested per-subsystem context files. Dynamically interviews the user to decide the right structure for their specific project rather than applying one fixed template, re-confirms anything not explicitly decided, and supports deferring a choice as a tracked pending decision. Use this skill whenever the user wants to turn a plan/idea into files for Claude Code or another coding agent, says things like "set up AGENTS.md/CLAUDE.md for this", "get this ready for Claude Code", "scaffold the project docs", "turn this plan into context files", "hand this off to a coding agent", or has just finished a substantial planning/design discussion and is about to start building. Also trigger when the user asks how to structure AGENTS.md/CLAUDE.md and wants it actually applied to their project, not just explained in the abstract.
```

- [ ] **Step 2: Replace the first philosophy bullet**

Replace line 16 (`- The root instruction file (AGENTS.md, imported by a thin CLAUDE.md...)`) with:

```markdown
- The root context file stays SHORT — start near 30 lines, treat ~150 as a hard ceiling, move anything longer into a linked doc. Which file that is depends on the target agent (Step 3); how short it should be does not.
```

- [ ] **Step 3: Replace the nested-files bullet (line 23)**

This is the stale claim. Replace the whole bullet with:

```markdown
- **The container is per-agent; the content is not.** Which files exist and how they load comes from the target agent's own docs — Claude Code reads `CLAUDE.md` and does not read `AGENTS.md` at all; Codex and Antigravity read `AGENTS.md` natively. What the docs *say* — system design, naming conventions, UI direction, business rules — is identical either way. See `references/agent-profiles.md` for per-agent specifics, and never assert an agent behavior that file can't cite.
```

- [ ] **Step 4: Add the deferred-decision philosophy bullet**

After the "Nothing is settled until the user says so" bullet (line 17):

```markdown
- **"Not yet decided" is a valid answer and a real output.** A deferred choice becomes a dated pending-decision rule at the top of the context file plus a `Status: Pending` entry in `decisions.md` — never a guess written as settled, and never a hollow doc.
```

- [ ] **Step 5: Add agent-profiles to the reference pointer**

In the final bullet (line 24), add:

```markdown
See `references/agent-profiles.md` for what each target agent reads and how — verify a row against its source before relying on it.
```

- [ ] **Step 6: Verify**

```bash
grep -c "opt-in setting" SKILL.md
```

Expected: `0`.

```bash
head -4 SKILL.md | grep -c "hand this off to a coding agent"
```

Expected: `1` — trigger phrases survived the description rewrite.

**Then run S28 and S29 — this gate blocks the rest of the release.** The `description` is the entire mechanism by which the skill fires; if this rewrite degraded matching, every other change in v1.2.0 becomes unreachable and no other scenario would reveal it.

- S28: the skill fires on "get this ready for Claude Code", "scaffold the project docs", "turn this plan into context files", and "hand this off to a coding agent".
- S29: an abstract "how does AGENTS.md work?" gets an explanation, **not** a scaffold or an interview.

A grep proving a phrase is present is not proof the skill fires. If S28 fails on any phrasing, restore the previous description and re-approach the rewrite phrase by phrase.

```bash
wc -l SKILL.md
```

Expected: ≤ 95. Record the number; Task 10 checks the total.

- [ ] **Step 7: Commit**

```bash
git add SKILL.md
git commit -m "feat: make the context-file format depend on the target agent

Rewrites the frontmatter description and philosophy section: content
lives in whatever the target agent reads natively, not always
AGENTS.md. Removes the stale claim that Claude Code needs an opt-in
setting to read AGENTS.md — it does not read AGENTS.md at all.

Trigger phrases in the description are preserved verbatim."
```

---

### Task 7: `SKILL.md` — Step 0 and Step 1

Re-run detection (C1) and source tag (c) (C2). This is the fix for the reported bug.

**Files:**
- Modify: `SKILL.md` — insert Step 0 before Step 1, amend Step 1

- [ ] **Step 1: Insert Step 0**

Before `### Step 1 — Gather the plan`:

```markdown
### Step 0 — Check for an existing scaffold
- Look for `AGENTS.md`, `CLAUDE.md`, or `docs/*.md` at the target path. If any exist, this is a **re-run**, not a fresh scaffold — say so, name what you found, and state that its contents will be re-confirmed rather than assumed.
- If a previous run left pending decisions, surface those first: "last time you parked [X] — decide now, or keep it parked?"
- Never infer the target agent from which files exist. The layout is a product of a previous answer; treating it as evidence makes that answer self-confirming forever.
```

- [ ] **Step 2: Add source tag (c) to Step 1**

Replace the existing tagging bullet (line 30) with:

```markdown
- **Tag every extracted fact by source: (a) explicitly stated or confirmed by the user; (b) proposed by the assistant or produced by a prototype/demo and never separately confirmed; (c) read from an existing generated doc on disk.** Only (a) counts as known and lets you skip a question in Step 2. Both (b) and (c) are still open questions no matter how settled they look — a doc on disk proves a file was written, not that anyone decided anything, and it may predate the confirmation rules entirely.
- When re-asking a (c) fact, offer the doc's current value as the recommendation so confirming is one keystroke: "`design-system.md` currently says slate/shadcn — keep it, change it, or park it?"
- Never silently overwrite content the user clearly hand-wrote. Ask about it.
- **Never carry a secret out of the plan.** Credentials, tokens, connection strings, private hostnames and IPs, and real customer data are not extracted into any generated file, even when the plan contains them. Substitute a named reference (`DATABASE_URL`, `<internal-host>`); if the value's *shape* matters, describe the shape in `docs/product.md` instead of reproducing the value. This one has no override — these files get committed.
```

- [ ] **Step 2b: Verify against S25–S27**

Run the skill against Fixture D.

Expected: no password, Stripe key, internal hostname, IP, customer name, email, or phone appears in any generated file — named references appear instead. Then re-run and, when asked, insist the connection string be included: S27 requires the skill to hold the line and offer the named-reference form rather than complying.

If the skill complies with the insistence, the rule is written as a preference rather than a hard rule. Fix before continuing.

- [ ] **Step 3: Verify against S1–S4**

Run the skill against Fixture C from `examples/test-scenarios.md`.

Expected: S1 passes (Step 0 announces the scaffold), S2 passes (theme re-asked with current value offered), S3 passes (target agent re-asked). Run Fixture A: S4 passes (no re-run language on a fresh scaffold).

If S4 fails — the skill announces a re-run when nothing exists — the Step 0 condition is too loose. Fix before committing.

- [ ] **Step 4: Commit**

```bash
git add SKILL.md
git commit -m "fix: re-confirm facts read from existing docs on a re-run

Adds Step 0 scaffold detection and source tag (c) for facts read from
generated docs on disk, treated as unconfirmed and always re-asked.
Fixes the reported bug where re-running against a project scaffolded
by an older version regenerated it silently, skipping every
confirmation the newer rules were meant to force."
```

---

### Task 8: `SKILL.md` — Step 2

The target-agent question and the defer exit (C3, C7).

**Files:**
- Modify: `SKILL.md` — the Step 2 question list and confirmation rules

- [ ] **Step 1: Replace the target-agent question**

Replace the existing bullet (line 37) with:

```markdown
- Which coding agent(s)? Claude Code, Codex, Antigravity, or generic/unsure. This decides the file layout only, never the content — see Step 3. Always ask; never infer it from which files already exist.
```

- [ ] **Step 2: Add the conventions question**

After the design-system question (line 38):

```markdown
- Any naming or structural conventions beyond what a linter enforces — table/column naming, API route shapes, module boundaries? (These become `docs/conventions.md`; skip the file when the answer is "just the tooling defaults.")
```

- [ ] **Step 3: Add the defer exit**

After the "Silence is not confirmation" block (line 50–53):

```markdown
**"Decide later" is a third valid answer.** Every recommendation offers three exits — accept, override, or defer — and defer is a legitimate choice, not a failure to answer. Offer it proactively for anything that doesn't block the first slice of work (theme, palette, copy voice): "Go with that, something else, or park it and decide once the scaffold's up?"

A deferred choice produces three things and no guesses: a dated item in the context file's `## Pending decisions` section, a `Status: Pending` entry in `decisions.md`, and *no* doc for the thing that's undecided — a `design-system.md` that's mostly a hole is worse than its absence.
```

- [ ] **Step 4: Verify against S5–S7**

Run Fixture A and defer the theme.

Expected: S5 passes — pending block present, `Status: Pending` entry written, no `design-system.md` generated. Run Fixture A answering everything: S6 passes — no empty pending heading anywhere. Run Fixture C with a pending decision on file: S7 passes — surfaced first with a keep-parked option.

- [ ] **Step 5: Commit**

```bash
git add SKILL.md
git commit -m "feat: add defer as a third answer to every recommendation

Every recommend-and-confirm question now offers accept, override, or
defer. Deferring writes a dated pending-decision rule plus a
Status: Pending log entry and skips the affected doc entirely rather
than shipping a hollow one. Also adds the conventions question and
makes the target-agent question layout-only."
```

---

### Task 9: `SKILL.md` — Steps 3, 4, 5

Structure selection (C7, C12), drafting (C5), writing, reporting, and migration (C6, C8, C11).

**Files:**
- Modify: `SKILL.md` — Step 3 table, Step 4 bullets, Step 5 bullets

- [ ] **Step 1: Replace the Step 3 preamble and table**

Replace the whole Step 3 table with a mode table plus the file table:

```markdown
First pick the **layout** from the target agent(s) — this decides which files exist, never what they say:

| Target | Content lives in | Also generate | Don't generate |
|---|---|---|---|
| Claude Code alone | `CLAUDE.md` (root) | `.claude/rules/` only if genuinely path-scoped content exists; nested `CLAUDE.md` per subsystem | `AGENTS.md` |
| Codex alone | `AGENTS.md` | — | `CLAUDE.md` |
| Antigravity alone | `AGENTS.md`, or the repo's existing `GEMINI.md` if it has one | `.agents/rules/` only if genuinely path-scoped content exists | `CLAUDE.md`; a second root rules file |
| Two or more agents, or generic | `AGENTS.md` | `CLAUDE.md` containing `@AGENTS.md`, at root and beside every nested `AGENTS.md` | — |

One named agent gets its native layout; plural or generic gets the portable one. Apply the strictest size limit across all selected agents. Keep critical rules in the root file even in Claude-native mode — nested files and path-scoped rules don't survive `/compact`. See `references/agent-profiles.md`.

Then pick the **linked docs**, which are identical in every layout. Don't generate a file nobody needs:

| File | Generate when |
|---|---|
| `docs/architecture.md` | There's real architectural complexity worth recording — skip for trivial projects |
| `docs/decisions.md` | Any non-obvious decision has been made or deferred |
| `docs/conventions.md` | There are naming/structure rules beyond what a linter enforces — otherwise keep a thin `## Code style` section in the content file |
| `docs/roadmap.md` | There's a real MVP-vs-later split to protect against scope creep |
| `docs/product.md` | There are business/feature rules an agent must implement correctly |
| `docs/design-system.md` | There's a UI subsystem with real design conventions — **not** when the design decision was deferred |
```

- [ ] **Step 2: Amend Step 4 for the carve-out and the secrets rule**

Replace the first Step 4 bullet with:

```markdown
- Pull the skeleton for each file type from `references/templates.md`, then fill it with the project's actual specifics — never leave placeholder text in the delivered output. The one exception is a dated pending-decision entry, which asserts a real current fact and is required when the user defers.
- Never write a credential, token, connection string, private hostname/IP, or real customer data into a generated file, even if it's in the plan and even if asked to. Use a named reference (`DATABASE_URL`, `<internal-host>`) and describe the value's shape in `docs/product.md` if an implementer needs it. These files get committed.
```

- [ ] **Step 3: Add migration to Step 5**

Before the existing "Show the resulting file tree" bullet:

```markdown
- If Step 0 found an existing scaffold and the target agent changed, **migrate rather than orphan**: moving content between `CLAUDE.md` and `AGENTS.md`, adding or removing the loader. Propose the moves and get confirmation before writing — migration deletes files. Never drop content that has no home in the new layout; raise it as a question instead.
```

- [ ] **Step 4: Amend the Step 5 reporting bullet**

Replace the "Show the resulting file tree" bullet with:

```markdown
- Show the resulting file tree and a short summary of what went where, naming which layout was used and why. List every companion `CLAUDE.md` explicitly with a one-line note that it's a thin `@AGENTS.md` import. List **Pending decisions** as its own section so the user leaves knowing what they parked. Flag anything inferred vs. still uncertain — don't silently guess on business-critical rules.
- Tell the user how to verify the docs actually load: for Claude Code, run `/context` and check the list under **Memory files**. Warn against running `/import`, which appends a duplicate copy of `AGENTS.md` into `CLAUDE.md`.
- Before reporting, check every internal link in the content file resolves to a file that was actually generated. Drop the line rather than shipping a dead link — `design-system.md` is deliberately absent whenever the theme was deferred, so this fires on a common path, not an edge case.
- Report the content file's size against the strictest limit across the selected agents (see `references/agent-profiles.md`), warning at roughly three-quarters rather than at the limit. This matters most for Codex, where passing 32 KiB doesn't error — it silently stops adding files, dropping the deepest nested guidance first.
```

- [ ] **Step 5: Verify against S8–S15**

Run each layout scenario.

Expected: S8 (Claude-native: no `AGENTS.md`, auto-memory line present), S9 (Codex-native: no `CLAUDE.md`, commands near top), S10 (generic: both files), S11 (multi-agent falls back to portable), S13 (Claude-native monorepo: nested `CLAUDE.md`, critical rules still in root), S14 and S15 (conventions doc appears only when warranted) all pass.

For S12, scaffold Fixture A twice — once Claude-native, once Codex-native — into two directories and diff the docs:

```bash
diff -r run-claude/docs run-codex/docs
```

Expected: no output. Any difference means Layer 2 leaked into Layer 1 — fix before committing.

- [ ] **Step 6: Commit**

```bash
git add SKILL.md
git commit -m "feat: select file layout per target agent, migrate on change

Step 3 now picks the layout from the target agent first, then the
linked docs, which are identical in every layout. Step 5 migrates an
existing scaffold when the target changes rather than orphaning files,
reports pending decisions, and tells the user how to verify loading."
```

---

### Task 10: Line budget

`SKILL.md` must stay under its own ceiling. Auditing this is a real step, not a formality — the repo's own rules say a change that grows it should come with something trimmed.

**Files:**
- Modify: `SKILL.md` (only if over budget)

- [ ] **Step 1: Measure**

```bash
wc -l SKILL.md
```

Expected: ≤ 150. It was 88 before this release.

- [ ] **Step 2: Trim if over**

If over 150, move detail out rather than deleting rules. In priority order:
1. Per-agent specifics in the Step 3 mode table → `references/agent-profiles.md`, leaving a pointer.
2. The pending-decision output description in Step 2 → `references/templates.md`, leaving one line.
3. Step 5's `/context` and `/import` guidance → `references/best-practices.md`, leaving a pointer.

Do not trim by removing the confirmation rules or the defer exit — those are the release.

- [ ] **Step 3: Re-read end to end**

Read `SKILL.md` start to finish. Check that Steps 0–5 still flow, that no bullet contradicts another (particularly: does anything still assume `AGENTS.md` always exists?), and that every `references/` file mentioned exists.

```bash
grep -o 'references/[a-z-]*\.md' SKILL.md | sort -u | while read f; do test -f "$f" || echo "MISSING: $f"; done
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add SKILL.md
git commit -m "refactor: keep SKILL.md within its line ceiling"
```

Skip this commit if Step 1 passed and no trim was needed.

---

### Task 11: `CONTRIBUTING.md` and this repo's `AGENTS.md`

The repo's own rules now contradict the skill (C5, C7).

**Files:**
- Modify: `CONTRIBUTING.md:30` and the "Where things live" section
- Modify: `AGENTS.md`

- [ ] **Step 1: Amend the no-placeholder rule**

Replace `CONTRIBUTING.md` line 30:

```markdown
- No placeholder or TODO content in what ships — if something's unfinished, leave it out rather than stubbing it in. One carve-out: a dated pending-decision entry (`undecided as of YYYY-MM-DD`, plus what to do meanwhile) asserts a real current fact and is required output when a user defers a choice — that's not a placeholder.
```

- [ ] **Step 2: Add the new reference files to the ownership map**

In "Where things live", after the `recommendation-heuristics.md` entry:

```markdown
- **`references/agent-profiles.md`** — what each coding agent reads and how it loads it. **This file is expected to age**, like the heuristics file, and every claim carries a source URL and verified-on date. A stale entry is a welcome PR. Never add a row you can't cite from that agent's own docs.
```

In "Testing a change", after point 3:

```markdown
4. Run the relevant scenarios from `examples/test-scenarios.md`, including at least one "must NOT produce" case — a rule that fires when it shouldn't is as broken as one that never fires.
```

- [ ] **Step 3: Rewrite the repo's own critical rules**

The `AGENTS.md` critical rule "the content always lives in nested `AGENTS.md` files, never in nested `CLAUDE.md`" is now wrong. Replace that bullet:

```markdown
- **The container is per-agent; the content is not.** Which files the skill generates depends on the target agent (Claude Code reads `CLAUDE.md` and never `AGENTS.md`; Codex and Antigravity read `AGENTS.md` natively). What those files *say* is identical in every mode. When changing `SKILL.md`, check you haven't let a layout assumption leak into content guidance or vice versa — `examples/test-scenarios.md` S12 is the check for this.
- **A deferred decision is not a placeholder.** "Undecided as of [date], do X meanwhile" is required output when the user defers; `[Project name]` and `TODO` are not. Don't let the no-placeholder rule suppress the pending-decision feature.
```

Add to "Related docs":

```markdown
- `references/agent-profiles.md` — per-agent container facts, with sources and dates; expected to age
- `examples/test-scenarios.md` — the scenarios a change must be checked against
```

- [ ] **Step 4: Verify no contradiction survives**

```bash
grep -rn "always lives in\|never in nested" AGENTS.md CONTRIBUTING.md
```

Expected: no output.

- [ ] **Step 5: Commit**

```bash
git add AGENTS.md CONTRIBUTING.md
git commit -m "docs: update repo rules for per-agent layouts and deferrals

The 'content always lives in AGENTS.md' critical rule and the blanket
no-placeholder rule both contradicted this release. Adds
agent-profiles.md and test-scenarios.md to the ownership map."
```

---

### Task 12: `examples/sample-output`

The sample demonstrates the portable layout. It needs the new sections so the pattern is visible, not just described.

**Files:**
- Modify: `examples/sample-output/AGENTS.md`
- Modify: `examples/sample-output/CLAUDE.md`
- Modify: `examples/sample-output/docs/decisions.md`
- Modify: `examples/sample-output/README.md`

- [ ] **Step 1: Add a pending decision to the sample**

The sample stays in portable mode — it's the multi-agent example. Add a `## Pending decisions` section directly after Critical rules in `examples/sample-output/AGENTS.md`, with a real deferred choice consistent with that sample's domain, and a matching `Status: Pending` entry in its `docs/decisions.md`. Use a real date, not a placeholder.

- [ ] **Step 2: Add the routing rule to both files**

Add `## Maintaining these docs` (portable form, including the loader lines) to `examples/sample-output/AGENTS.md`, and the short visible echo to `examples/sample-output/CLAUDE.md`.

- [ ] **Step 3: Document the three layouts in the sample README**

`examples/sample-output/README.md` currently presents this layout as *the* output. Add a short note that this sample is the portable layout, that a Claude-Code-only project would instead put this content directly in `CLAUDE.md` with no `AGENTS.md`, and that a Codex-only project would ship `AGENTS.md` with no `CLAUDE.md`.

- [ ] **Step 4: Verify**

```bash
grep -c "Pending decisions" examples/sample-output/AGENTS.md
grep -c "Status:\*\* Pending" examples/sample-output/docs/decisions.md
grep -c "Maintaining these docs" examples/sample-output/AGENTS.md examples/sample-output/CLAUDE.md
```

Expected: `1`, `1`, and `1` for each file.

- [ ] **Step 5: Commit**

```bash
git add examples/
git commit -m "docs: demonstrate pending decisions and routing in sample output

Adds a worked pending decision, the maintenance routing rule in both
files, and a note that this sample is the portable layout rather than
the only one."
```

---

### Task 13: `README.md` and `CHANGELOG.md`

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Rewrite the README's AGENTS.md-first framing**

`## What it generates` and `## Design principles baked in` both assume AGENTS.md is always the root file. Rewrite them around the layout table from Task 9 Step 1, and add `docs/conventions.md` to the generated-files list.

Add to `## Design principles baked in`:

```markdown
- **The container is per-agent; the content is not.** The target agent decides which files exist and how they load. System design, naming conventions, and business rules come out identical either way.
- **Nothing is settled until you say so** — including what's already in your repo. Re-running against an existing scaffold re-confirms rather than assumes, offering current values as one-keystroke defaults.
- **"Decide later" is a real answer.** Deferring writes a dated pending-decision rule telling the agent not to resolve it, instead of guessing and presenting the guess as settled.
```

Add `references/agent-profiles.md` and `examples/test-scenarios.md` to `## Repository structure`.

- [ ] **Step 2: Write the changelog entry**

Prepend to `CHANGELOG.md`:

```markdown
## [1.2.0] — 2026-08-12
### Fixed
- **Re-running against an existing scaffold no longer treats it as settled.** Facts read from generated docs on disk are now tagged as a distinct source and re-confirmed like any unconfirmed proposal — a doc proves a file was written, not that anyone decided anything, and it may predate the confirmation rules entirely. Previously a project scaffolded by an older version regenerated silently, skipping every question the newer rules were meant to force, including the target-agent question when a `CLAUDE.md` already existed. New Step 0 detects an existing scaffold and says so before asking anything.
- **Corrected a stale claim about Claude Code.** Earlier versions said Claude Code needs an opt-in setting to read `AGENTS.md`. It does not read `AGENTS.md` at all, under any setting, and `@AGENTS.md` from `CLAUDE.md` is the officially documented remedy. The conclusion was right; the reasoning was wrong.

### Added
- **Deferring a decision.** Every recommendation now offers three exits — accept, override, or defer. A deferred choice writes a dated `## Pending decisions` rule at the top of the context file telling the agent not to resolve it, plus a `Status: Pending` entry in `decisions.md`, and skips the affected doc entirely rather than shipping a hollow one.
- **Per-agent layouts.** One named agent gets its native format: `CLAUDE.md` for Claude Code (which never reads `AGENTS.md`), `AGENTS.md` for Codex and Antigravity (which read it natively). Two or more agents, or a generic target, gets the portable layout — `AGENTS.md` plus a `CLAUDE.md` loader. Changing the target on a re-run migrates the existing files rather than orphaning them.
- `references/agent-profiles.md` — per-agent container facts, each with a source URL and verified-on date. Expected to age; verify before trusting.
- `docs/conventions.md` as a generated candidate for naming and structural rules beyond linter defaults, with matching defaults in `recommendation-heuristics.md`.
- `examples/test-scenarios.md` — thirty-two scenarios a change must be checked against, including "must NOT produce" cases.
- A `## Maintaining these docs` routing rule in generated output, so mid-project updates land in the content file rather than fragmenting across it and the loader, and so useful notes captured in Claude Code's machine-local auto memory get promoted where the team can see them.

### Changed
- The container is now separate from the content. The target agent decides which files exist and how they load; system design, naming conventions, UI direction, and business rules are identical in every layout.
- `references/best-practices.md` — the canonical-filename and nested-files sections rewrote AGENTS.md-first from a universal rule to a portable default; added Claude Code's compaction, auto-memory, and enforcement limits.
- `CONTRIBUTING.md` — the no-placeholder rule now carves out dated pending-decision entries, which would otherwise have suppressed the feature.
```

- [ ] **Step 3: Verify**

```bash
head -3 CHANGELOG.md | grep -c "1.2.0"
grep -c "agent-profiles" README.md
```

Expected: `1` and at least `1`.

- [ ] **Step 4: Commit**

```bash
git add README.md CHANGELOG.md
git commit -m "docs: document v1.2.0 layouts, deferrals, and re-run behavior"
```

---

### Task 14: Full scenario pass

Every prior task verified its own scenarios in isolation. This runs them together against the finished skill, which is where interaction bugs show up.

**Files:** none — verification only.

- [ ] **Step 1: Run all thirty-two scenarios**

Work through `examples/test-scenarios.md` end to end against the current `SKILL.md`. Record pass/fail per scenario.

Expected: all thirty-two pass, including every "must NOT produce" column.

- [ ] **Step 2: Re-check the line ceiling**

```bash
wc -l SKILL.md
```

Expected: ≤ 150.

- [ ] **Step 3: Check for surviving contradictions**

```bash
grep -rn "opt-in setting\|always lives in AGENTS" SKILL.md references/ README.md AGENTS.md CONTRIBUTING.md
```

Expected: no output.

- [ ] **Step 4: Confirm every agent claim is still cited**

```bash
grep -n "Source:" references/agent-profiles.md
```

Expected: three lines, each a real URL with a verified-on date.

- [ ] **Step 5: Report**

Report results honestly, including any scenario that failed and why. A failing scenario is a finding, not a formality to wave through — if S12 fails, the layer boundary leaked and that's a design bug, not a typo.

---

## Self-review

**Spec coverage:** C1 → Task 7. C2 → Task 7. C3 → Task 8. C4 → Tasks 3, 8. C5 → Tasks 3, 9, 11. C6 → Task 9. C7 → Tasks 6, 9. C8 → Tasks 3, 12. C9 → Tasks 4, 6. C10 → Task 2. C11 → Task 9. C12 → Tasks 2, 3, 4, 5, 9. C13 → Task 3 (Steps 3 and 5b), tested by S18–S21. C14 → Task 3 (Step 6b), tested by S22–S24. C15 → Tasks 7 (Step 2) and 9 (Step 2), tested by S25–S27. C16 → Task 6 (Step 6), tested by S28–S29. C17 → Task 9 (Step 4), tested by S30. C18 → Task 9 (Step 4), tested by S31–S32. Every change ID has at least one task.

**Two gates block the release rather than merely reporting.** Task 6's trigger check (C16) guards the mechanism every other scenario depends on — a degraded `description` makes the rest unreachable and nothing else would surface it. Task 7's secrets check (C15) must confirm the skill holds the line when a user *insists* on including a credential; if it complies, the rule was written as a preference rather than a hard rule.

**Structure-teaching is now uniform across both layers.** C13 makes a generated rules directory teach how rules are added to it; C14 makes every generated doc teach how it's extended. Together with C8's cross-doc routing, a scaffold answers three separate questions a future agent will otherwise guess at: which file a change belongs in, how that file is structured, and what must never go in it.

**Closed gap:** an earlier draft left `.claude/rules/` without a skeleton, reasoning that shipping one would imply it was a default. That conflated two separate questions — whether to *offer* the mechanism (conditional) and whether to *specify its shape and forward routing* once offered (mandatory). Without the latter, a generated rules directory decays on the next rule added, and a malformed `paths:` frontmatter fails silently rather than erroring. C13 closes it: Task 3 Step 5b adds both skeletons, Task 3 Step 3 adds the three-way routing, and S18–S21 test that it fires only when warranted.

**Placeholder scan:** clean. Task 2's source URLs were placeholders in the first draft pending primary-doc verification; that verification was completed on 2026-08-12 and the real URLs are now inline. Task 2 Step 3 keeps a grep guard against the three claims that failed verification, so a future edit can't quietly reintroduce them from an older draft.

**Consistency:** `## Pending decisions — do not resolve these yourself` and `**Status:** Pending` are used identically across Tasks 3, 8, 9, 11, 12, and 13. Scenario IDs S1–S21 are consistent between Task 1 and the tasks that reference them.
