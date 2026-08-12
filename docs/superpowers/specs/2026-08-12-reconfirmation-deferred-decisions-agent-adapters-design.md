# Design — re-run confirmation, deferred decisions, and per-agent adapters

**Date:** 2026-08-12
**Target release:** v1.2.0
**Status:** Approved (design), pending implementation

## Problem

Three defects surfaced by running the v1.1.0 skill against a project scaffolded by v1.0.0.

**P1 — a re-run treats existing docs as settled.** Step 1 tags every extracted fact as
(a) user-confirmed or (b) assistant-proposed/prototype-derived, but that tagging only covers facts
from the *conversation*. Facts read from an existing generated doc on disk carry no tag at all, so
the skill reads `design-system.md`, sees a theme, and skips the question. The v1.1.0 confirmation
rules never fire on the exact projects that most need them — the ones scaffolded before those rules
existed. The same defect swallowed the target-agent question: a `CLAUDE.md` on disk was read as an
answer rather than as an artifact of a previous run.

**P2 — there is no way to say "decide later."** Every recommend-and-confirm question in Step 2
offers exactly two exits: accept the recommendation, or override it. A user who hasn't decided the
theme yet has no third option, so the skill picks something. The repo's own "never leave placeholder
or TODO content" rule (`AGENTS.md`, `CONTRIBUTING.md:30`, `templates.md` preamble) actively
suppresses the fix by making any deferred marker look forbidden.

**P3 — nothing routes mid-project updates back to `AGENTS.md`.** With a bare `@AGENTS.md`
`CLAUDE.md`, a new rule added during development lands wherever the agent or the harness puts it,
splitting content across files and defeating the "content always lives in AGENTS.md" philosophy.

## Verified agent facts

Verified 2026-08-12 against official documentation. **These age — re-verify before trusting.**
They live in the new `references/agent-profiles.md`, which carries this same warning.

| Agent | Reads `AGENTS.md`? | Loader needed | Native extras | Size limit |
|---|---|---|---|---|
| Codex | Yes, natively. Concatenated root→leaf, blank-line joined; closer files override by appearing later. `AGENTS.override.md` wins per directory; one file per directory | No | `.codex/config.toml` | 32 KiB (`project_doc_max_bytes`); **stops adding files at the cap** |
| Antigravity | Yes, natively, alongside `GEMINI.md` | No | `.agents/rules/` (`.agent/rules` still supported), skills | 12 K chars per rule file |
| Claude Code | **No** | **Yes** — `CLAUDE.md` containing `@AGENTS.md` | `.claude/rules/` (path-scoped), skills, hooks | ~200 lines |

Three earlier claims did not survive primary-source verification and have been removed:

- **"Codex is trained to run the test commands named in `AGENTS.md`."** Not supported — the docs
  frame commands as working agreements, not execution directives. This was the stated reason for
  leading with commands, so that rationale is replaced by the verified truncation behavior below.
- **"`GEMINI.md` wins conflicts with `AGENTS.md`."** Antigravity's docs say "`GEMINI.md` *or*
  `AGENTS.md`" and never state a precedence. Dropped rather than guessed.
- **"Antigravity added `AGENTS.md` support in v1.20.3."** A third-party blog claim, not in Google's
  docs. The support is confirmed; the version is not, so no version is asserted.

The Codex cap earns a design rule on its own: Codex stops adding files once the combined size
reaches 32 KiB, so an oversized root file silently starves the nested ones. Keeping the root lean is
a correctness requirement there, not just style.

Claude Code is the outlier: Codex and Antigravity read `AGENTS.md` natively, so for them the
portable layout *is* their native layout. Claude Code's native layout is `CLAUDE.md` plus its own
extras — see C7.

Two further verified facts constrain C7:

- Project-root `CLAUDE.md` is re-injected after `/compact`. Nested `CLAUDE.md` files and
  path-scoped `.claude/rules/` are **not** — they reload only when Claude next reads a matching
  file. Critical rules must therefore stay in the root file.
- Claude Code hooks are the only hard enforcement layer; `CLAUDE.md` is context, not configuration.
  Rules that must hold regardless of what the agent decides belong in a `PreToolUse` hook.

Corrections to prior assumptions, all now verified:

- `SKILL.md:23` claims Claude Code "won't reliably pick up a bare AGENTS.md without an opt-in
  setting enabled first." **No such setting exists.** Claude Code does not read `AGENTS.md` at all,
  and `@AGENTS.md` is the officially documented remedy. The conclusion was right; the reasoning was
  wrong. This strengthens the case for shipping `CLAUDE.md` unconditionally.
- `/init` does **not** overwrite an existing `CLAUDE.md` — it suggests improvements instead.
- The `#` / "remember this" path writes to **auto memory**
  (`~/.claude/projects/<project>/memory/`), which is machine-local and never committed — not to
  `CLAUDE.md`. The risk is knowledge that never reaches the team, not file fragmentation.
- Relative `@` imports resolve against the file containing the import, so nested
  `<subsystem>/CLAUDE.md` → `@AGENTS.md` is correct. Max import depth is four hops; our chain is two.
- Block-level HTML comments in `CLAUDE.md` are **stripped before entering context**, so a routing
  rule written as an HTML comment would be invisible to Claude. It must be visible markdown.
- Official Claude Code guidance is "target under 200 lines per CLAUDE.md," consistent with the
  skill's stricter ~150-line ceiling. No change needed.

## Design

### C1 — Step 0: detect an existing scaffold

New step before Step 1. Check the target path for `AGENTS.md`, `CLAUDE.md`, or `docs/*.md`. If any
exist, this is a re-run: say so explicitly, name what was found, and state that its contents will be
re-confirmed rather than assumed. If a previous run recorded pending decisions, surface those first
— "last time you parked the theme; decide now, or keep it parked?"

### C2 — Step 1 gains source tag (c)

Add a third source tag: **(c) read from an existing generated doc on disk**, treated exactly as (b)
— unconfirmed, always re-asked.

The rationale ships with the rule, because the rule looks redundant without it: a doc on disk may
have been written by an older version of this skill under weaker confirmation rules, by a different
tool, or hand-edited since. Its existence proves a file was written, not that a user decided
anything.

Two supporting rules:

- **The current value becomes the recommendation.** Re-asking is cheap only if confirming is one
  keystroke: "`design-system.md` currently says slate/shadcn — keep it, change it, or park it?"
  This is what makes "always re-ask" tolerable rather than an interrogation.
- **Never silently overwrite hand-written content.** Content that the user clearly authored is
  asked about, not replaced.

### C3 — Step 2 gains a third exit: defer

Every recommend-and-confirm question offers three ways out — accept, override, **defer** — with
defer presented as legitimate rather than as a failure to answer, and offered proactively for
choices that don't block the first slice of work (theme, palette, copy voice):

> "Go with that, something else, or park it and decide once the scaffold's up?"

### C4 — What a deferred decision produces

Three coordinated artifacts:

1. **Root `AGENTS.md`** gains `## Pending decisions — do not resolve these yourself`, placed
   immediately after Critical rules, at the top of the file where an agent won't lose it. Each item
   records what is undecided, the date, what the agent should do *meanwhile*, and a link into
   `decisions.md`.
2. **`docs/decisions.md`** gains a dated `**Status:** Pending` entry holding the options that were
   on the table and why it was deferred. When it is decided later, a *new* dated
   `Status: Accepted` entry supersedes it — preserving the append-only rule — and the `AGENTS.md`
   pending item is removed.
3. **The doc that would have held the decision is not generated at all.** Deferring the theme means
   no `design-system.md`, not a hollow one.

Example:

```markdown
## Pending decisions — do not resolve these yourself
- **UI theme/palette**: undecided as of 2026-08-12. Use unstyled/default components; do NOT pick a
  palette or font. Ask before adding design tokens. → `docs/decisions.md#pending-ui-theme`
```

### C5 — Carve-out to the no-placeholder rule

Without this, the existing ban keeps suppressing C4. Add to `CONTRIBUTING.md:30`, the
`templates.md` preamble, and Step 4:

> A placeholder is unfilled template text (`[Project name]`, `TODO`) that asserts nothing. A dated
> pending-decision entry asserts a real, current fact — this is undecided, as of this date, here is
> what to do instead — and is therefore allowed and required.

### C6 — Step 5 reports pending decisions

The closing file tree gains a **Pending decisions** section listing what is still owed, so the user
leaves knowing what they parked.

### C7 — Native layout per agent, portable core as the fallback

**This changes the skill's central thesis.** "Content always lives in `AGENTS.md`" becomes
"content lives in whatever the target agent reads natively." `AGENTS.md` is demoted from the
universal home to one of several native formats — the one Codex and Antigravity happen to read, and
the one used whenever the target is plural or unknown.

The selection rule:

| Target | Content lives in | Extras offered | No longer generated |
|---|---|---|---|
| Claude Code alone | `CLAUDE.md` (root) | `.claude/rules/` path-scoped rules, nested `CLAUDE.md`, skills, hooks | `AGENTS.md` |
| Codex alone | `AGENTS.md` | `.codex/config.toml` | `CLAUDE.md` |
| Antigravity alone | `AGENTS.md` | `.agents/rules/`, skills | `CLAUDE.md` |
| Two or more agents, **or** generic | `AGENTS.md` + `CLAUDE.md` containing `@AGENTS.md` | none by default | — |

**One named agent gets its native best practice; two or more, or generic, gets the portable core.**
Going native for one of several selected agents would leave the others reading nothing, so plurality
forces the portable layout. Generic keeps the loader for the reason established earlier: it is one
inert line that every other agent ignores, and without it the docs are invisible the moment someone
opens the repo in Claude Code.

`docs/*.md` is unchanged in every mode — those files are agent-agnostic and linked, not loaded.

**Claude Code native mode, specifically:**

- Root `CLAUDE.md` holds the content, against the official ~200-line target.
- **Critical rules stay in the root file.** `.claude/rules/` is *offered, not default*, and only
  when there is genuinely path-scoped content — a monorepo, or a subsystem with distinct
  conventions. This is forced by the compaction behavior above: a critical rule pushed into a
  path-scoped file silently disappears after `/compact` until Claude next touches a matching file.
- Nested subsystem context uses nested `CLAUDE.md` (loads on demand), not nested `AGENTS.md`.
- Recurring procedures continue to become skills, as the skill already recommends.
- Where a rule must hold regardless of what the agent decides, note that a `PreToolUse` hook is the
  only enforcement layer — `CLAUDE.md` is context, not configuration.

**Content tuning by agent**, applied to whichever file holds the content: the size ceiling is the
strictest limit across all selected agents, and when Codex is a target the root file is kept well
clear of the 32 KiB cap — Codex stops adding files once the combined size reaches it, so a bloated
root silently drops the deepest and most specific nested guidance.

**The trade, stated plainly:** a Claude-native scaffold is invisible to Codex and Antigravity, and
vice versa. Adding an agent later means re-running the skill — which C1 and C2 now handle correctly,
since the re-run detects the existing scaffold and re-asks the target-agent question rather than
inferring it.

The target-agent question in Step 2 becomes multi-select over Claude Code / Codex / Antigravity /
generic, and stays in the always-re-ask set. It must never be inferred from which files exist on
disk, since under this model the file layout is itself a product of a previous answer and would
otherwise be self-confirming on every future run.

### C8 — Doc-routing rule, scaled to the mode

Every mode gets a `## Maintaining these docs` section in whichever file holds the content. What it
says depends on the mode, because C7 removes most of the ambiguity from native mode.

**Native mode** (one named agent) — there is only one content file, so routing is about *which
doc*, not which instruction file:

```markdown
## Maintaining these docs
- New rules, commands, and conventions → this file.
- New decisions → `docs/decisions.md` (append-only). Current business rules → `docs/product.md`.
- Recurring step-by-step procedures → a skill, not this file.
```

**Claude Code native mode** adds one line, because auto memory is machine-local and never committed:

```markdown
- If something useful landed in auto memory (`/memory`), promote it here so the team gets it.
```

**Portable mode** (two or more agents, or generic) adds the CLAUDE-vs-AGENTS routing that P3
identified:

```markdown
- All rules live in THIS file. `CLAUDE.md` is a loader only — never add content to it.
- Nested subsystems: edit `<subsystem>/AGENTS.md`, never `<subsystem>/CLAUDE.md`.
```

plus a short visible echo in `CLAUDE.md` itself. That echo is a deliberate amendment to
`templates.md`'s current "ship exactly this" one-liner, and that line is updated so the two do not
contradict. It must be visible markdown, not an HTML comment — see the verified facts above.

**P3 largely dissolves in native mode.** With no `CLAUDE.md`/`AGENTS.md` split there is nothing to
fragment, which is a genuine argument in C7's favor that was not obvious before verifying.

**Stated limit, not oversold:** this rule reliably catches an agent *reasoning about where to put a
change*, which is the common case. It cannot intercept harness paths that write without consulting
file content. The routing rule makes those recoverable — the next agent that reads it knows to
migrate the content — rather than preventing them.

### C9 — Rewrite the Claude Code rationale, and document its limits

Rewrite `SKILL.md:23` to the verified reasoning: Claude Code does not read `AGENTS.md`, so the
`CLAUDE.md` loader is required, not a hedge against a setting.

Add a "Claude Code specifics and their limits" section to `references/best-practices.md`:
auto-memory promotion, nested memory files not re-injecting after `/compact`, don't run `/import`
(v2.1.213+ appends a one-time *copy* of `AGENTS.md` into `CLAUDE.md`, duplicating content), and
`.claude/rules/` as an opt-in extra.

Step 5's verification step becomes the officially documented check: run `/context` and confirm the
files appear under **Memory files**.

### C10 — New `references/agent-profiles.md`

One file holding the per-agent facts from the table above — what each agent reads, whether it needs
a loader, its size limits, its native extras, and how to verify loading. Carries the same
expected-to-age header as `recommendation-heuristics.md`: verify against current docs before
trusting, and treat outdated entries as a normal PR rather than a bug.

This exists to contain the maintenance surface. Per-agent knowledge is the fastest-aging content in
the repo — `SKILL.md:23` was stale within one release — so it belongs in exactly one file with an
explicit warning, not spread across `SKILL.md` and `templates.md`.

### C11 — Mode migration on re-run

C7 makes the file layout a *product* of the target-agent answer, and C2 makes that answer
re-askable. Together they create a case that did not exist before: a re-run where the answer
changes, and the existing layout is now wrong for it.

The skill must migrate rather than orphan. Three transitions matter:

| Transition | Action |
|---|---|
| Claude-native → portable (agent added) | Move `CLAUDE.md`'s content into a new `AGENTS.md`; reduce `CLAUDE.md` to the loader plus routing echo. Path-scoped `.claude/rules/` content is surfaced to the user, since it has no portable equivalent — it either folds into `AGENTS.md` or is knowingly kept as Claude-only |
| Portable → Claude-native (agents dropped) | Fold `AGENTS.md` into `CLAUDE.md`; delete `AGENTS.md`. Confirm before deleting |
| Codex-native → portable | Add the `CLAUDE.md` loader. `AGENTS.md` is already correct; nothing moves |

Migration is destructive, so it is proposed and confirmed, never silent — the user sees which files
move, merge, or are deleted before anything is written. Content is never dropped: anything without a
home in the new layout is raised as a question, not discarded.

### C12 — Two layers: agent-native container, universal engineering content

This reframes C7 and governs how it is written. C7 as drafted says *where files go* per agent, but
leaves implicit *what goes in them* — which invites the wrong reading, that picking Claude Code
changes the engineering guidance itself. It does not. Every scaffold is two layers:

**Layer 1 — the agent-native container.** How context is stored, loaded, and scoped, taken from
that agent's own official documentation:

| Agent | Container, per its official docs |
|---|---|
| Claude Code | `CLAUDE.md` (~200-line target), `.claude/rules/` with `paths:` frontmatter, nested `CLAUDE.md` for subtrees, skills for procedures, hooks for hard enforcement |
| Codex | `AGENTS.md` concatenated root→leaf, `AGENTS.override.md` precedence per directory, 32 KiB cap that stops adding files once reached, `.codex/config.toml` |
| Antigravity | `AGENTS.md` read alongside `GEMINI.md`, `.agents/rules/` at 12 K chars per file, skills |
| Generic / multiple | `AGENTS.md` + `CLAUDE.md` loader, strictest limits across selected agents |

**Layer 2 — universal engineering content.** Identical in every mode, because good naming and sound
system design do not vary by which agent reads them:

| Content | Home |
|---|---|
| System design, components, data flow, constraints | `docs/architecture.md` |
| Naming conventions, code style, file/project structure | `docs/conventions.md` **(new candidate file)**, or a section in the root file when thin |
| UI: palette, typography, component patterns, copy voice | `docs/design-system.md` |
| Business rules, pricing, access logic | `docs/product.md` |
| Non-obvious choices with rationale | `docs/decisions.md` |
| MVP vs. deferred scope | `docs/roadmap.md` |

Layer 2 is where `references/recommendation-heuristics.md` does its work — the grounded defaults
the skill proposes during Step 2 for stack, database, caching, UI direction, and now naming
conventions. Those recommendations are agent-independent and must not drift by target.

**`docs/conventions.md` is a new Step 3 candidate**, generated on the existing rule: only when there
are real conventions beyond what a linter or formatter already enforces — API route shapes, database
table and column naming, component and file naming, module boundaries. A project with nothing but
tooling defaults keeps the thin `## Code style` section in the root file and gets no separate doc.

**Layer 1 must cite its sources.** "Official best practices" means traceable to the agent's own
documentation, not inferred. `references/agent-profiles.md` (C10) gains a source URL and a
verified-on date per agent, so every container claim can be re-checked — the discipline that caught
`SKILL.md:23`. Any container behavior the skill cannot cite is left out rather than guessed.

**Layer separation is a rule, not just a description.** Layer 1 decides where content lives and how
it loads; it never changes what the content says. Layer 2 decides what is true about the project; it
never assumes a file layout. A re-run that changes the target agent therefore rewrites Layer 1 only
— which is exactly what makes C11's migration safe, since Layer 2 moves across unchanged.

## Files touched

| File | Change |
|---|---|
| `SKILL.md` (frontmatter) | C7 — the `description` currently promises "a lean root AGENTS.md plus linked docs," which is no longer true in native mode. Must describe the layout as agent-determined, without losing the trigger phrases that make the skill fire |
| `SKILL.md` (body) | C1, C2, C3, C6, C7, C8, C9 — new Step 0, tag (c), defer exit, target-agent question, rewritten philosophy section, Step 3 selection table, Step 5 reporting + `/context` check, rewritten line 23 |
| `references/templates.md` | C4, C5, C8 — pending-decisions section, `Status: Pending` entry, mode-dependent routing rule, a `CLAUDE.md`-as-content skeleton for native mode, amended one-liner note, preamble carve-out |
| `references/best-practices.md` | C9 — Claude Code specifics and their limits; reasoning for C2 and C4 |
| `references/agent-profiles.md` | C10, C12 — new file; per-agent container facts with a source URL and verified-on date for each |
| `references/recommendation-heuristics.md` | C12 — this is Layer 2's source of grounded defaults; extend with naming-convention guidance to match the new `docs/conventions.md` candidate |
| `CONTRIBUTING.md` | C5 — carve-out at line 30; file-ownership map gains `agent-profiles.md` |
| `README.md` | Surface deferred decisions and the per-agent native/portable split. The AGENTS.md-first framing is currently load-bearing in the overview and must be rewritten, not appended to |
| `AGENTS.md` (this repo) | The "content always lives in AGENTS.md" critical rule is now wrong as stated; rewrite to the native/portable rule |
| `CHANGELOG.md` | v1.2.0 |

**Line budget.** `SKILL.md` is 88 lines against a ~150 hard ceiling. Estimated net change is roughly
+25 lines, landing near 113. If it overshoots, the per-agent detail moves wholesale into
`agent-profiles.md` and `SKILL.md` keeps only a pointer.

## Out of scope

- Provenance metadata in generated docs. Considered and rejected: it would only help projects
  scaffolded *after* this release, while the motivating case is a project scaffolded before it.
  Always-re-ask covers both, at the cost of repetition that C2's recommend-the-current-value rule
  makes cheap.
- Per-agent companion files beyond Claude Code (`.github/copilot-instructions.md`, `.cursorrules`).
  Codex and Antigravity need none, and Cursor/Copilot profiles are unverified. They can be added to
  `agent-profiles.md` once verified.
- Auto-detecting the target agent from the environment. The question is always asked, never
  inferred — that inference is precisely what P1 was.

## Accepted risks

**Native mode is not portable, by design.** A Claude-native scaffold is invisible to Codex and
Antigravity. This was weighed against the alternative — one portable layout for everyone — and
native was chosen deliberately: for a single-agent project, portability buys nothing and costs the
agent's real capabilities (`.claude/rules/` path-scoping, hooks, `/doctor`'s trim check). The
plurality fallback in C7 covers mixed-agent teams, and C1/C2 make switching a clean re-run rather
than a manual migration.

**Per-agent knowledge is the fastest-aging content in the repo,** and this change increases how much
of it the skill depends on. `SKILL.md:23` went stale within one release. C10 is the mitigation:
all of it lives in `references/agent-profiles.md` behind an explicit verify-before-trusting header,
and `SKILL.md` points rather than duplicates.

## Testing

Per `CONTRIBUTING.md`, run the skill against a sample plan before and after, covering at least one
case where each new rule clearly fires and one where it clearly does not.

| Case | Expectation |
|---|---|
| Re-run against an existing v1.0.0 scaffold | Step 0 announces the re-run; every recommendation is re-asked with the current doc value pre-filled; target-agent is re-asked despite `CLAUDE.md` existing |
| Fresh scaffold, no existing files | Step 0 stays silent; no re-run language appears |
| User defers the theme | No `design-system.md`; pending block at top of `AGENTS.md`; `Status: Pending` entry in `decisions.md`; Step 5 lists it |
| User answers every question | No pending section anywhere — the block does not appear empty |
| Re-run with a pending decision on file | It is surfaced first, with the option to keep it parked |
| Target = Claude Code alone | Content in root `CLAUDE.md`; **no `AGENTS.md` generated**; `.claude/rules/` offered only if path-scoped content exists; auto-memory promotion line present |
| Target = Codex alone | Content in `AGENTS.md`; **no `CLAUDE.md` generated**; commands near the top |
| Target = generic | Portable core: `AGENTS.md` + `CLAUDE.md` containing `@AGENTS.md` |
| Target = Claude Code + Codex | Portable core, **not** native — plurality forces the fallback; size ceiling is the stricter of the two |
| Claude-native monorepo | Nested `CLAUDE.md` carries subsystem content; critical rules remain in root `CLAUDE.md`, not pushed into `.claude/rules/` |
| Portable-mode monorepo | Nested `AGENTS.md` carries content; nested `CLAUDE.md` is the loader plus routing echo |
| Re-run switching Claude-only → +Codex | Existing `CLAUDE.md`-as-content is migrated to `AGENTS.md` with a loader, not left orphaned |
| Same plan, scaffolded twice for different agents | Layer 2 output is **byte-identical** across both runs — `docs/architecture.md`, `conventions.md`, `design-system.md`, `product.md` do not vary by target. Only the container differs |
| Project with real naming conventions | `docs/conventions.md` generated and linked |
| Project with only linter-default style | No `conventions.md`; thin `## Code style` section in the root file instead |
| Any container claim in the output | Traceable to a source URL in `agent-profiles.md`; nothing asserted about an agent that cannot be cited |
