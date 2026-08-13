# code-idea

*"Code this idea"* — take a plan or idea from conversation to a state a coding agent can actually build from correctly.

A Claude Skill that turns a project plan, idea, or planning conversation into a complete, AI-coding-agent-ready documentation set — a lean root context file in whichever format your target agent reads natively (`CLAUDE.md` for Claude Code, `AGENTS.md` for Codex or Antigravity, or both for mixed/generic targets), plus linked docs (architecture, decisions, conventions, roadmap, product, design-system), and, for monorepos, nested per-subsystem context files.

It doesn't apply one fixed template. It interviews you (or reads the plan straight out of your conversation) to figure out what your specific project actually needs, proposes grounded recommendations for anything you don't have a strong opinion on — tech stack, database/caching choice, UI theme and typography — and lets you confirm or override each one.

## Why

Most "let's add a CLAUDE.md" moments end one of two ways: a single giant file with everything crammed in (which coding agents parse worse, not better), or a set of docs that looked right on day one and quietly went stale. This skill bakes in the current best practices for both problems — file size discipline, ordering, the decisions-log-vs-living-spec split, and cross-tool portability — so you don't have to re-derive them per project.

## What it generates

The **container** — which root file(s) exist and how they load — depends on which agent(s) you target; see [`references/agent-profiles.md`](references/agent-profiles.md) for the sourced facts behind each row:

| Target agent(s) | Root file(s) |
|---|---|
| Claude Code alone | `CLAUDE.md` — Claude Code never reads `AGENTS.md` |
| Codex alone | `AGENTS.md` — Codex reads it natively |
| Antigravity alone | `AGENTS.md`, or the repo's existing `GEMINI.md` if it already has one |
| Two or more agents, or generic/unsure | `AGENTS.md` plus a `CLAUDE.md` containing `@AGENTS.md` |

The **content** is identical regardless of layout — only what a given project actually warrants, never a fixed set:

| File | When |
|---|---|
| `docs/architecture.md` | Real architectural complexity worth recording |
| `docs/decisions.md` | Non-obvious decisions have been made (append-only, dated, rationale-first) |
| `docs/conventions.md` | Naming/structural rules beyond what a linter enforces |
| `docs/roadmap.md` | There's a real MVP-vs-later split worth protecting |
| `docs/product.md` | Business/feature rules an agent needs to implement correctly |
| `docs/design-system.md` | There's a UI subsystem with real design conventions |
| Nested `<subsystem>/AGENTS.md` or `<subsystem>/CLAUDE.md` | Genuine monorepo, subsystems with materially different conventions — matches the root layout |

## How it works

1. **Gather the plan** — pulled from the current conversation if you've already been planning, or asked for directly if starting fresh.
2. **Interview, with recommendations** — asks only what it doesn't already know, and proposes a grounded default for anything you don't have an opinion on ("I'd recommend Postgres for this, plus Redis for the live queue state — go with that, or tell me what you'd prefer?") rather than leaving you to answer an open question cold.
3. **Decide the structure** — per project, based on the interview. A single small app might only need a single root context file. A monorepo with a frontend, backend, and a native service gets nested files per subsystem.
4. **Draft the content** — filled from templates, using your project's actual specifics, never left as placeholder text.
5. **Write and confirm** — written directly if there's filesystem access to your project, or handed back as content with exact target paths if not. Shows you what was generated and flags anything it inferred rather than confirmed.

## Design principles baked in

- **The container is per-agent; the content is not.** The target agent decides which files exist and how they load. System design, naming conventions, and business rules come out identical either way.
- **Nothing gets written as settled unless you confirmed it** — choices the assistant proposed, or that a throwaway prototype happened to use, get re-surfaced for a real decision instead of quietly hardening into your docs.
- **Nothing is settled until you say so** — including what's already in your repo. Re-running against an existing scaffold re-confirms rather than assumes, offering current values as one-keystroke defaults.
- **"Decide later" is a real answer.** Deferring writes a dated pending-decision rule telling the agent not to resolve it, instead of guessing and presenting the guess as settled.
- **Root file stays short** — starts near 30 lines, ~150 lines is treated as a hard ceiling. Everything longer moves into a linked doc.
- **Most-violated rules go first** — long-context agents can lose instructions buried later in a file.
- **Decisions vs. product are separate** — `decisions.md` is an append-only historical log; `product.md` is the current-state living spec.
- **Stale docs are worse than no docs** — architecture docs must be updated alongside real changes, or removed.
- **Recurring procedures become Skills**, not static docs.

See [`references/best-practices.md`](references/best-practices.md) for the full reasoning, [`references/recommendation-heuristics.md`](references/recommendation-heuristics.md) for the stack/database/UI defaults it draws on, and [`references/agent-profiles.md`](references/agent-profiles.md) for the sourced per-agent facts behind the container table above.

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
│   ├── agent-profiles.md                 # what each target agent reads and how, with sources
│   └── templates.md                      # skeleton for each doc type
├── examples/
│   ├── sample-output/                    # example generated file tree
│   └── test-scenarios.md                 # scenarios a change must be checked against
└── CONTRIBUTING.md
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) — the reference docs are explicitly expected to age (tooling and best practices shift), so keeping them current is one of the most useful contributions.

## License

MIT — see [LICENSE](LICENSE).
