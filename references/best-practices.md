# Best practices behind Context Scaffolder's rules

Condensed reasoning for why the skill enforces what it does. Read this when the user asks "why," or when a structural judgment call isn't covered directly in SKILL.md.

## The canonical filename depends on the target

There is no universal answer. `AGENTS.md` is read natively by Codex and Antigravity and is the right
portable default when the target is plural or unknown. Claude Code does not read it at all, so a
Claude-Code-only project is better served by its native `CLAUDE.md` layout.

One named agent gets its native layout. Two or more, or generic, gets `AGENTS.md` plus a `CLAUDE.md`
loader — going native for one of several would leave the others reading nothing.

This is a change from earlier versions of this skill, which treated `AGENTS.md` as the universal
home. Portability is worth having when more than one agent is in play, and worth nothing when only
one is — where it costs that agent's real capabilities.

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

## Keep the root file short
A monolithic instruction file loads every rule into the agent's context on *every* invocation, whether relevant to the current task or not. Guidance converges on: start around 30 lines, split into subdirectories once the root file crosses roughly 150–200 lines, and add a section only when an agent has actually gotten something wrong — not preemptively. One data point worth internalizing: hand-curated files only outperformed generated ones by a small margin in one study, while costing the same tokens either way — length isn't buying much on its own. Write for precision, not comprehensiveness.

## Ordering matters, not just presence
Long-context coding agents can silently drop instructions buried in the middle of a long session or file (a documented "lost in the middle" pattern). Two implications: put the rules most likely to be violated at the very top of the root file, and favor starting a fresh agent session per distinct task over one long continuous session.

## Stale docs are worse than no docs
Architecture overviews that fall out of sync with the actual code don't just fail to help — one study found they *increased* inference cost and led an agent to traverse more files without improving task success, because the agent trusted a description that no longer matched reality. The fix is discipline, not more documentation: update `architecture.md` in the same change as any real architectural shift, or delete the section if it can't realistically be kept current.

## What NOT to put in the root file
Avoid: temporary/one-off task requirements, copied documentation that already exists elsewhere, large code samples, vague advice ("write clean code"), rules a linter or formatter already enforces mechanically, and step-by-step procedures that belong in a reusable Skill instead.

## README vs. the operational context file
They serve different readers. README.md is for human contributors — what the project is, how to get started. The root content file (`AGENTS.md` or `CLAUDE.md`, whichever the target agent reads natively — see `agent-profiles.md`) is operational context specifically for an agent — build commands, architecture rules, boundaries, testing requirements. Don't merge them; an agent doesn't need the marketing framing a README often carries, and a human contributor doesn't need agent-specific operational minutiae.

## Recommended root-file sections
Overview, build/test commands (verified, exact flags), code style deltas from language defaults, testing requirements, security-sensitive boundaries (files/dirs that should never be edited directly), and commit/PR conventions. Everything else belongs in a linked doc, referenced by name with a one-line pointer on when to read it — not inlined.

## Decisions vs. product docs
`decisions.md` is a historical log — append-only, each entry dated, past entries never rewritten even after the decision is later superseded (note the supersession, don't erase the original). `product.md` is the current-state spec — it gets edited in place as the actual rules change. Conflating the two means either the history gets lost (if you keep "fixing" a decisions log to match current reality) or the current spec gets buried under obsolete detail (if you never prune product.md).

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

## Prototype constraints are not production decisions
A choice made to get a demo working inside a constrained environment — an artifact sandbox that only permits a fixed set of libraries, a chat surface with no filesystem, a hosted preview with no backend — was made by the environment, not by the user. It carries no signal about what the production system should use, and it should never be silently promoted into a decisions log, design system, or stack section as though it were settled. The failure mode is subtle because the choice genuinely appears in the conversation history and genuinely went unobjected-to; that reads as consensus when it was really just nobody's decision to make at the time. Surface where the choice came from, say plainly that the sandbox forced it, and re-recommend on the merits.

The general principle: absence of objection is not confirmation. Assistant proposals and prototype artifacts stay open questions until the user answers one.

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
