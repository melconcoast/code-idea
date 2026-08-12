# context-scaffolder

A Claude Skill that turns a project plan, idea, or planning conversation into a complete, AI-coding-agent-ready documentation set — a lean root `AGENTS.md` plus linked docs (architecture, decisions, roadmap, product, design-system), and, for monorepos, nested per-subsystem context files.

It doesn't apply one fixed template. It interviews you (or reads the plan straight out of your conversation) to figure out what your specific project actually needs, proposes grounded recommendations for anything you don't have a strong opinion on — tech stack, database/caching choice, UI theme and typography — and lets you confirm or override each one.

## Why

Most "let's add a CLAUDE.md" moments end one of two ways: a single giant file with everything crammed in (which coding agents parse worse, not better), or a set of docs that looked right on day one and quietly went stale. This skill bakes in the current best practices for both problems — file size discipline, ordering, the decisions-log-vs-living-spec split, and cross-tool portability — so you don't have to re-derive them per project.

## What it generates

Only what a given project actually warrants — never a fixed set:

| File | When |
|---|---|
| `AGENTS.md` | Always — the canonical, cross-tool root instruction file |
| `CLAUDE.md` | Only if you're standardized on Claude Code specifically — a thin file that `@`-imports AGENTS.md |
| `docs/architecture.md` | Real architectural complexity worth recording |
| `docs/decisions.md` | Non-obvious decisions have been made (append-only, dated, rationale-first) |
| `docs/roadmap.md` | There's a real MVP-vs-later split worth protecting |
| `docs/product.md` | Business/feature rules an agent needs to implement correctly |
| `docs/design-system.md` | There's a UI subsystem with real design conventions |
| Nested `<subsystem>/AGENTS.md` | Genuine monorepo, subsystems with materially different conventions |

## How it works

1. **Gather the plan** — pulled from the current conversation if you've already been planning, or asked for directly if starting fresh.
2. **Interview, with recommendations** — asks only what it doesn't already know, and proposes a grounded default for anything you don't have an opinion on ("I'd recommend Postgres for this, plus Redis for the live queue state — go with that, or tell me what you'd prefer?") rather than leaving you to answer an open question cold.
3. **Decide the structure** — per project, based on the interview. A single small app might only need `AGENTS.md`. A monorepo with a frontend, backend, and a native service gets nested files per subsystem.
4. **Draft the content** — filled from templates, using your project's actual specifics, never left as placeholder text.
5. **Write and confirm** — written directly if there's filesystem access to your project, or handed back as content with exact target paths if not. Shows you what was generated and flags anything it inferred rather than confirmed.

## Design principles baked in

- **AGENTS.md is canonical**, not CLAUDE.md — read natively by 20+ coding agents (Codex, Cursor, Copilot, Gemini CLI, Claude Code, and others), with nested, closest-file-wins support for monorepos. CLAUDE.md is only added as a thin import when a team is specifically standardized on Claude Code.
- **Root file stays short** — starts near 30 lines, ~150 lines is treated as a hard ceiling. Everything longer moves into a linked doc.
- **Most-violated rules go first** — long-context agents can lose instructions buried later in a file.
- **Decisions vs. product are separate** — `decisions.md` is an append-only historical log; `product.md` is the current-state living spec.
- **Stale docs are worse than no docs** — architecture docs must be updated alongside real changes, or removed.
- **Recurring procedures become Skills**, not static docs.

See [`references/best-practices.md`](references/best-practices.md) for the full reasoning, and [`references/recommendation-heuristics.md`](references/recommendation-heuristics.md) for the stack/database/UI defaults it draws on.

## Installation

**Claude.ai / Claude Desktop / Claude Code:** clone this repo (or download a packaged `.skill` release) and add it as a skill — see [Anthropic's skills documentation](https://docs.claude.com) for the current install path, since this changes over time.

**From source:** the skill is just `SKILL.md` plus `references/` — no build step. Point your tool's skill directory at this repo, or copy the two into an existing skills folder.

## Usage

Once installed, just ask naturally — "let's get this ready for Claude Code," "scaffold AGENTS.md for this project," "turn this plan into context files." See [`examples/`](examples/) for a sample of what the output looks like for a small multi-subsystem project.

## Repository structure

```
.
├── SKILL.md                              # the skill itself
├── references/
│   ├── best-practices.md                 # research/reasoning behind the rules
│   ├── recommendation-heuristics.md      # stack/DB/UI defaults, with sources
│   └── templates.md                      # skeleton for each doc type
├── examples/
│   └── sample-output/                    # example generated file tree
└── CONTRIBUTING.md
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) — the reference docs are explicitly expected to age (tooling and best practices shift), so keeping them current is one of the most useful contributions.

## License

MIT — see [LICENSE](LICENSE).
