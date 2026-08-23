# code-idea

*"Code this idea"* — take a plan or idea from conversation to a state a coding agent can actually build from correctly.

A Claude Code **plugin**. Two skills today, run in sequence: **`scaffold`** turns a plan into the docs a coding agent needs, and **`plan-module`** turns one module of the roadmap it produces into a phase-based execution spec.

`scaffold` turns a project plan, idea, or planning conversation into a complete, AI-coding-agent-ready documentation set — a lean root context file in whichever format your target agent reads natively (`CLAUDE.md` for Claude Code, `AGENTS.md` for Codex or Antigravity, or both for mixed/generic targets), plus linked docs (architecture, decisions, conventions, development roadmap, product, design-system), and, for monorepos, nested per-subsystem context files.

It doesn't apply one fixed template. It interviews you (or reads the plan straight out of your conversation) to figure out what your specific project actually needs, proposes grounded recommendations for anything you don't have a strong opinion on — tech stack, database/caching choice, UI theme and typography — and lets you confirm or override each one.

## Why

Most "let's add a CLAUDE.md" moments end one of two ways: a single giant file with everything crammed in (which coding agents parse worse, not better), or a set of docs that looked right on day one and quietly went stale. This skill bakes in the current best practices for both problems — file size discipline, ordering, the decisions-log-vs-living-spec split, and cross-tool portability — so you don't have to re-derive them per project.

## scaffold — what it generates

The **container** — which root file(s) exist and how they load — depends on which agent(s) you target; see [`references/agent-profiles.md`](skills/scaffold/references/agent-profiles.md) for the sourced facts behind each row:

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
| `docs/development-roadmap.md` | **Always** — modules and sub-modules, in dependency order, with scope boundaries |
| `docs/product.md` | Business/feature rules an agent needs to implement correctly |
| `docs/design-system.md` | There's a UI subsystem with real design conventions |
| Nested `<subsystem>/AGENTS.md` or `<subsystem>/CLAUDE.md` | Genuine monorepo, subsystems with materially different conventions — matches the root layout |

## scaffold — how it works

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

See [`references/best-practices.md`](skills/scaffold/references/best-practices.md) for the full reasoning, [`references/recommendation-heuristics.md`](skills/scaffold/references/recommendation-heuristics.md) for the stack/database/UI defaults it draws on, and [`references/agent-profiles.md`](skills/scaffold/references/agent-profiles.md) for the sourced per-agent facts behind the container table above.

## plan-module — from roadmap to execution spec

`scaffold` always writes `docs/development-roadmap.md`: modules, their sub-modules, dependency order,
and scope boundaries, with every `Tasks:` field reading `not yet planned`. `plan-module` is what fills
that in, one module at a time, when you're actually ready to build it.

It reads the module's block out of the roadmap — plus the root context file, `docs/product.md`, and any
pending decisions in `docs/decisions.md` — and writes `docs/guides/feature_<module>_plan.md`:

- **2–4 phases** in dependency order, each declaring `Dependencies: None` or `Dependencies: Phase X`. The
  module's sub-modules are the natural phase boundaries, so the cut comes from the roadmap rather than
  from a fresh guess.
- **At most 3–4 development tasks per phase**, each with a one-line *Details* naming what changes.
- **1–3 plain-English test scenarios under every task** — at least one happy path, plus an edge or error
  case wherever the task can fail. Never test code.
- **A mandatory `Task X.V` verification gate** closing each phase.
- **A four-state checkbox vocabulary** — `[ ]` open, `[x]` done *and verified*, `[~]` reframed, `[-]`
  skipped — with progress counted in closed items, never percentages.

The plan file is a living document: it carries a `## Progress Log` and a `## Files Modified` section
that fill in as the work runs, and re-planning a module in flight preserves everything already closed
rather than resetting it. The roadmap's `Tasks:` field flips to point at the plan file, so the roadmap
stays an index and task detail lives in exactly one place.

Why it's a separate skill rather than part of `scaffold`: at scaffold time there's no codebase to plan
against, so writing tasks then means inventing implementation detail nobody has decided yet. The
roadmap is the contract between the two — `scaffold` writes it, `plan-module` reads it.

## Installation

**Claude Code** — install as a plugin:

```
/plugin marketplace add melconcoast/code-idea
/plugin install code-idea@melconcoast
```

Skills are then invoked as `/code-idea:scaffold` and `/code-idea:plan-module`, or triggered naturally by what you ask for.

**Claude.ai / Claude Desktop** — download the `scaffold.skill` and `plan-module.skill` assets from a [release](https://github.com/melconcoast/code-idea/releases) and add them as skills.

**From source** — no build step. Point a local marketplace at your clone: `/plugin marketplace add /path/to/code-idea`.

## Usage

Once installed, just ask naturally — "let's get this ready for Claude Code," "scaffold AGENTS.md for this project," "turn this plan into context files." Once the roadmap exists and you're ready to build, "plan the next module" or "plan module 3" hands off to `plan-module`. See [`examples/`](examples/) for a sample of what the output looks like for a small multi-subsystem project.

## Repository structure

```
.
├── .claude-plugin/
│   ├── plugin.json                       # plugin manifest
│   └── marketplace.json                  # so the repo is its own marketplace
├── skills/
│   ├── scaffold/
│   │   ├── SKILL.md                      # plan -> agent docs set
│   │   └── references/
│   │       ├── best-practices.md         # research/reasoning behind the rules
│   │       ├── recommendation-heuristics.md  # stack/DB/UI defaults, with sources
│   │       ├── agent-profiles.md         # what each target agent reads and how, with sources
│   │       └── templates.md              # skeleton for each doc type
│   └── plan-module/
│       ├── SKILL.md                      # one roadmap module -> phase-based execution spec
│       └── references/
│           ├── plan-template.md          # plan file format, checkbox vocabulary, counting rules
│           └── scenario-writing.md       # what makes a test scenario checkable
├── examples/
│   ├── sample-output/                    # example generated file tree
│   └── test-scenarios.md                 # scenarios a change must be checked against
├── AGENTS.md                             # this repo's own content file
├── CLAUDE.md                             # @AGENTS.md import, so Claude Code loads it too
├── CONTRIBUTING.md
├── CHANGELOG.md
└── LICENSE
```

One further skill is planned for this plugin and is **not built yet**: `execute-plan`, which works
through a plan file phase by phase, marking tasks closed as their scenarios pass. It does not ship a
directory until it is written.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) — the reference docs are explicitly expected to age (tooling and best practices shift), so keeping them current is one of the most useful contributions.

## License

MIT — see [LICENSE](LICENSE).
