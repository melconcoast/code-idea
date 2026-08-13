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
- **Nested loader consequence:** a `<subsystem>/CLAUDE.md` containing `@AGENTS.md` loads that
  subsystem's `AGENTS.md` — the nested `CLAUDE.md` loads on demand (see Nested, above) and its
  `@` import resolves against its own directory (see Imports, above).
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

Source: https://antigravity.google/docs/rules-workflows, https://antigravity.google/docs/cli/best-practices, and https://antigravity.google/docs/cli/gcli-migration — verified 2026-08-12

## Generic / multiple agents

No single native format applies, so use the portable layout: `AGENTS.md` holds the content, plus a
`CLAUDE.md` containing `@AGENTS.md`.

Ship the loader even when Claude Code wasn't named. It is one inert line that every other agent
ignores, and without it the docs are invisible the moment someone opens the repo in Claude Code —
the most common way a generic scaffold silently fails.

When several agents are selected, their limits aren't comparable (lines vs. bytes vs. characters) — report
and respect each selected agent's limit in its own unit.
