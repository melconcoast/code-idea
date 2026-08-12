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
| Codex | Yes, natively. Merges root→leaf; `AGENTS.override.md` wins in-folder | No | `~/.codex/config.toml`, `.codex/config.toml` | 32 KiB |
| Antigravity | Yes, since v1.20.3 (2026-03-05). Merged with `GEMINI.md`, which wins conflicts | No | `.agents/rules/`, skills | 12 K chars per rule file |
| Claude Code | **No** | **Yes** — `CLAUDE.md` containing `@AGENTS.md` | `.claude/rules/` (path-scoped), skills, hooks | ~200 lines |

Claude Code is the outlier: Codex and Antigravity read `AGENTS.md` natively, so for them the
portable core *is* the best-practice output and no adapter exists.

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

### C7 — Portable core + per-agent adapters

The doc set — `AGENTS.md` plus `docs/` — is identical regardless of target agent. That is the
portable core. Each selected agent adds a thin adapter with three parts:

1. **Loader file.** Claude Code only: `CLAUDE.md` containing `@AGENTS.md`. Codex and Antigravity
   need nothing. `CLAUDE.md` is generated **unconditionally**, including for a generic target — it
   is one inert line that every other agent ignores, and without it the docs are invisible the
   moment someone opens the repo in Claude Code.
2. **Content tuning** applied to the same `AGENTS.md`: ordering emphasis (Codex is trained to run
   the test commands named in `AGENTS.md`, so commands go near the top when Codex is a target), and
   a size ceiling equal to the **strictest limit across all selected agents**, so one file stays
   valid everywhere.
3. **Optional native extras**, offered only when an agent is the sole target and only as an opt-in:
   `.claude/rules/` path-scoped rules, `.agents/rules/`, agent-specific skills. Adopting these
   trades away portability, so the user chooses knowingly.

The target-agent question in Step 2 becomes multi-select over Claude Code / Codex / Antigravity /
generic, and stays in the always-re-ask set. It must never be inferred from a `CLAUDE.md` on disk —
we now write that file unconditionally, so its presence would otherwise become self-confirming on
every future run.

Its job also changes: it no longer decides *whether* `CLAUDE.md` exists, only which adapters apply
and whether a `## Claude Code specific` section is warranted. Step 3's table row and the philosophy
bullet at `SKILL.md:23` both simplify accordingly.

### C8 — Doc-routing rule in both files

Canonical version in `AGENTS.md`, because it covers every agent including generic targets:

```markdown
## Maintaining these docs
- All rules, commands, and conventions live in THIS file. `CLAUDE.md` is a loader only — never add
  content to it.
- New decisions → `docs/decisions.md` (append-only). Current business rules → `docs/product.md`.
- Nested subsystems: edit `<subsystem>/AGENTS.md`, never `<subsystem>/CLAUDE.md`.
- If something useful was captured in Claude Code's auto memory, promote it here so the team gets it.
```

Short visible echo in `CLAUDE.md`. This is a deliberate amendment to `templates.md`'s current
"ship exactly this" one-liner, and that line is updated so the two do not contradict. It must be
visible markdown, not an HTML comment — see the verified facts above.

**Stated limit, not oversold:** this rule reliably catches an agent *reasoning about where to put a
change*, which is the common case. It cannot intercept harness paths that write without consulting
file content. The `AGENTS.md` routing rule makes those recoverable — the next agent that reads it
knows to migrate the content — rather than preventing them.

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

## Files touched

| File | Change |
|---|---|
| `SKILL.md` | C1, C2, C3, C6, C7, C8, C9 — new Step 0, tag (c), defer exit, target-agent question, Step 3 table, Step 5 reporting + `/context` check, rewritten line 23 |
| `references/templates.md` | C4, C5, C8 — pending-decisions section, `Status: Pending` entry, routing rule in both `AGENTS.md` and `CLAUDE.md` skeletons, amended one-liner note, preamble carve-out |
| `references/best-practices.md` | C9 — Claude Code specifics and their limits; reasoning for C2 and C4 |
| `references/agent-profiles.md` | C10 — new file |
| `CONTRIBUTING.md` | C5 — carve-out at line 30; file-ownership map gains `agent-profiles.md` |
| `README.md` | Surface deferred decisions and per-agent adapters |
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
- Fully divergent per-agent template sets. Rejected: 4× the aging surface, and it breaks the common
  case where a teammate uses a different agent than whoever ran the skill.

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
| Target = generic | `CLAUDE.md` still generated |
| Target = Codex only | `CLAUDE.md` loader still generated (unconditional); commands near the top of `AGENTS.md`; no `## Claude Code specific` section |
| Target = Claude Code + Codex | Size ceiling is the stricter of the two; both adapters applied |
| Monorepo scaffold | Nested `AGENTS.md` carries content; nested `CLAUDE.md` is the loader plus routing echo |
