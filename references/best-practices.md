# Best practices behind Context Scaffolder's rules

Condensed reasoning for why the skill enforces what it does. Read this when the user asks "why," or when a structural judgment call isn't covered directly in SKILL.md.

## AGENTS.md is the canonical filename
By 2026, AGENTS.md is read natively by 30+ coding agents (Claude Code, Codex CLI, Cursor, Aider, Devin, GitHub Copilot, Gemini CLI, Windsurf, Amazon Q, and others) and is the closest thing to a universal instruction format. Claude Code is the notable asterisk: its default `/init` and context-loading behavior is CLAUDE.md-centric, and it does not automatically read an existing AGENTS.md unless an opt-in setting is enabled first. So the right setup is AGENTS.md as the canonical file holding all content, plus a thin CLAUDE.md that `@`-imports it whenever Claude Code is a target agent — that companion file is a functional requirement for the docs to load at all, not an optional extra for Claude-specific rules. A bare `@AGENTS.md` line is a complete file; the Claude-specific section on top is optional.

## Keep the root file short
A monolithic instruction file loads every rule into the agent's context on *every* invocation, whether relevant to the current task or not. Guidance converges on: start around 30 lines, split into subdirectories once the root file crosses roughly 150–200 lines, and add a section only when an agent has actually gotten something wrong — not preemptively. One data point worth internalizing: hand-curated files only outperformed generated ones by a small margin in one study, while costing the same tokens either way — length isn't buying much on its own. Write for precision, not comprehensiveness.

## Ordering matters, not just presence
Long-context coding agents can silently drop instructions buried in the middle of a long session or file (a documented "lost in the middle" pattern). Two implications: put the rules most likely to be violated at the very top of the root file, and favor starting a fresh agent session per distinct task over one long continuous session.

## Stale docs are worse than no docs
Architecture overviews that fall out of sync with the actual code don't just fail to help — one study found they *increased* inference cost and led an agent to traverse more files without improving task success, because the agent trusted a description that no longer matched reality. The fix is discipline, not more documentation: update `architecture.md` in the same change as any real architectural shift, or delete the section if it can't realistically be kept current.

## What NOT to put in the root file
Avoid: temporary/one-off task requirements, copied documentation that already exists elsewhere, large code samples, vague advice ("write clean code"), rules a linter or formatter already enforces mechanically, and step-by-step procedures that belong in a reusable Skill instead.

## README vs. AGENTS.md
They serve different readers. README.md is for human contributors — what the project is, how to get started. AGENTS.md is operational context specifically for an agent — build commands, architecture rules, boundaries, testing requirements. Don't merge them; an agent doesn't need the marketing framing a README often carries, and a human contributor doesn't need agent-specific operational minutiae.

## Recommended root-file sections
Overview, build/test commands (verified, exact flags), code style deltas from language defaults, testing requirements, security-sensitive boundaries (files/dirs that should never be edited directly), and commit/PR conventions. Everything else belongs in a linked doc, referenced by name with a one-line pointer on when to read it — not inlined.

## Decisions vs. product docs
`decisions.md` is a historical log — append-only, each entry dated, past entries never rewritten even after the decision is later superseded (note the supersession, don't erase the original). `product.md` is the current-state spec — it gets edited in place as the actual rules change. Conflating the two means either the history gets lost (if you keep "fixing" a decisions log to match current reality) or the current spec gets buried under obsolete detail (if you never prune product.md).

## Prototype constraints are not production decisions
A choice made to get a demo working inside a constrained environment — an artifact sandbox that only permits a fixed set of libraries, a chat surface with no filesystem, a hosted preview with no backend — was made by the environment, not by the user. It carries no signal about what the production system should use, and it should never be silently promoted into a decisions log, design system, or stack section as though it were settled. The failure mode is subtle because the choice genuinely appears in the conversation history and genuinely went unobjected-to; that reads as consensus when it was really just nobody's decision to make at the time. Surface where the choice came from, say plainly that the sandbox forced it, and re-recommend on the merits.

The general principle: absence of objection is not confirmation. Assistant proposals and prototype artifacts stay open questions until the user answers one.

## Nested files for monorepos — content in AGENTS.md, companion CLAUDE.md for Claude Code
Nested, closest-file-wins instruction files are supported across the board: OpenAI's own Codex repository ships 88 separate AGENTS.md files across its directory tree, and the rule is consistent everywhere it's implemented — the nearest AGENTS.md to the file being edited wins, with root-level rules applying everywhere and subdirectory rules overriding for that subtree. This nested model is honored natively by 20+ agents (Codex CLI, Cursor, GitHub Copilot, Gemini CLI, Claude Code, Devin, Aider, Zed, Windsurf, JetBrains Junie, and others), which is exactly why nested AGENTS.md is where the content belongs: CLAUDE.md's subdirectory support is real and well-built (Claude Code pulls in the nearest CLAUDE.md when it reads a file in that subtree) but it's Claude-Code-specific — content written into a nested CLAUDE.md is silently invisible to every other agent. Nested AGENTS.md gives the same "different conventions per subsystem" benefit (e.g. a Windows service vs. a web frontend) without betting on one tool.

Don't split into nested files at all for a single-codebase project — it's pure overhead there.

The Claude Code caveat from the canonical-filename section applies at every level, not just the root. Because Claude Code won't reliably load a bare AGENTS.md on its own, a nested AGENTS.md in a Claude Code project needs a sibling CLAUDE.md containing just `@AGENTS.md` — otherwise that subsystem's conventions are invisible to the very agent the project targets. This is why the two files are generated together rather than as an either/or: nested AGENTS.md is what makes the docs portable across tools, and the nested CLAUDE.md import is what makes them load in Claude Code. Content lives in exactly one place (AGENTS.md), so there's no duplication to keep in sync.
