# code-idea

*"Code this idea"* — take a plan or idea from conversation to a state a coding agent can actually build from correctly.

A Claude Code **plugin**. Three skills run in sequence — **`scaffold`** turns a plan into the docs a coding agent needs, **`plan-module`** turns one module of the roadmap it produces into a phase-based execution spec, and **`execute-plan`** builds that spec task by task — with a fourth, **`test-and-verify`**, doing the running and fixing of tests on their behalf.

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
roadmap is the contract between the two — `scaffold` writes it, `plan-module` reads it. The plan file
is the contract in turn between `plan-module` and `execute-plan`.

## execute-plan — from spec to working code

`plan-module` leaves you a plan file full of `[ ]` items. `execute-plan` is what closes them, working
in a strict **micro-loop**: one task at a time, never a whole phase at once.

For each open task, in order:

1. **Implement exactly that task** — the endpoints, tables, and data shapes its *Details* names, and
   nothing it doesn't.
2. **Write the test code its scenarios describe** — one test per scenario, in the scenario's own terms.
   The scenarios are plain English precisely so that choosing the framework is this step's job.
3. **Run them until green**, reading real output. `[x]` means *verified* — a task whose code exists but
   whose tests never ran stays open.
4. **Update the plan file in the same pass** — the glyphs, the closed counts, `## Files Modified` by
   real path, and `Last Updated`.

At each phase's `Task X.V` gate it runs the **whole** module's suite, not just that phase's tests,
then closes the phase, appends a `## Progress Log` line, flips the matching sub-module in
`docs/development-roadmap.md`, and **stops to ask** before starting the next phase. A phase boundary
is your decision point, not the agent's.

Two things it does that are easy to miss:

- **It bootstraps the test runner.** In this chain the project starts with no code, so the first module
  usually has nothing to run. `execute-plan` sets up the runner that fits the stack the docs already
  chose, then writes the real commands back into the root context file's `## Commands` section —
  closing the loop `scaffold` opens when it writes "not yet established."
- **It keeps the roadmap true.** Sub-modules move to in-progress and done as phases close. Nothing else
  updates those statuses, so without this the roadmap would still call a finished module `planned`.

When an approach doesn't survive contact with the code, the task becomes `[~]` with its reason and
replacement — reported, never silently dropped.

## test-and-verify — the run-and-fix loop

`execute-plan` doesn't run tests itself; it hands that to `test-and-verify`, which is also useful on
its own ("run the tests", "why is this test failing").

It finds the right command — the root context file's `## Commands` first, then the manifest, then CI —
runs it, and **reads the output rather than the exit code**. A suite that exits 0 having collected no
tests, or having skipped the new ones, is a failure wearing a green hat.

On a failure it decides whether the bug is in the **application code** or in the **test** — a drifted
fixture, a stale mock, an assertion on incidental output — says which, and applies one targeted fix at
a time. **Three attempts, then it stops.** Past three, the diagnosis is usually what was wrong, not
the fix, and further attempts just widen the diff on a false premise. It hands back what failed, what
it tried, and what it ruled out.

Two boundaries make it safe to call automatically:

- **It never edits a plan file.** It returns a verdict; `execute-plan` marks the boxes. Two writers on
  one plan file is how a plan stops being trustworthy.
- **It never weakens a test to reach green** — no deleted assertions, loosened matchers, added skips,
  or expected values rewritten to match whatever the code happens to produce. If the honest outcome is
  "still failing", that's the outcome it reports.

At a `Task X.V` phase gate it widens automatically: the whole module's suite plus the project's
type-checker and linter. If the project has neither, it says so rather than leaving a silence that
reads as a pass.

## Installation

**Claude Code** — install as a plugin:

```
/plugin marketplace add melconcoast/code-idea
/plugin install code-idea@melconcoast
```

Skills are then invoked as `/code-idea:scaffold`, `/code-idea:plan-module`, `/code-idea:execute-plan`, and `/code-idea:test-and-verify`, or triggered naturally by what you ask for.

**Claude.ai / Claude Desktop** — download the `scaffold.skill`, `plan-module.skill`, `execute-plan.skill`, and `test-and-verify.skill` assets from a [release](https://github.com/melconcoast/code-idea/releases) and add them as skills.

**From source** — no build step. Point a local marketplace at your clone: `/plugin marketplace add /path/to/code-idea`.

## Usage

Once installed, just ask naturally — "let's get this ready for Claude Code," "scaffold AGENTS.md for this project," "turn this plan into context files." Once the roadmap exists and you're ready to build, "plan the next module" or "plan module 3" hands off to `plan-module`; once a plan file exists, "execute the plan" or "build task 2.1" hands off to `execute-plan`, which calls `test-and-verify` to prove each task before closing it. See [`examples/`](examples/) for a sample of what the output looks like for a small multi-subsystem project.

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
│   ├── plan-module/
│   │   ├── SKILL.md                      # one roadmap module -> phase-based execution spec
│   │   └── references/
│   │       ├── plan-template.md          # plan file format, checkbox vocabulary, counting rules
│   │       └── scenario-writing.md       # what makes a test scenario checkable
│   ├── execute-plan/
│   │   ├── SKILL.md                      # plan file -> working, tested code
│   │   └── references/
│   │       ├── verification.md           # bootstrapping a runner, what counts as verified
│   │       └── progress-updates.md       # the plan-file and roadmap writes execution makes
│   └── test-and-verify/
│       ├── SKILL.md                      # run the suite, fix what fails, report a verdict
│       └── references/
│           ├── test-commands.md          # finding/scoping the command, with sources
│           └── remediation.md            # app-bug vs test-bug, circuit breaker, report formats
├── examples/
│   ├── sample-output/                    # example generated file tree
│   └── test-scenarios.md                 # scenarios a change must be checked against
├── AGENTS.md                             # this repo's own content file
├── CLAUDE.md                             # @AGENTS.md import, so Claude Code loads it too
├── CONTRIBUTING.md
├── CHANGELOG.md
└── LICENSE
```

All four skills ship. `scaffold` writes the docs set, `plan-module` cuts a module into a plan file,
`execute-plan` builds it, and `test-and-verify` proves each piece before a box gets checked.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) — the reference docs are explicitly expected to age (tooling and best practices shift), so keeping them current is one of the most useful contributions.

## License

MIT — see [LICENSE](LICENSE).
