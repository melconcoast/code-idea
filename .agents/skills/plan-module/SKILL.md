---
name: plan-module
description: Use this skill when the user says things like "plan the next module", "plan module 3", "break this module into phases", "create the execution plan for [module]", or is ready to start building a module the roadmap already defines. Not for creating the roadmap or a project's agent docs — use scaffold. Not for building a module that already has a plan file — use execute-plan. Turns one module of an existing development roadmap into a phase-based execution spec an automated coding agent can build from — `docs/guides/feature_[module]_plan.md`, with 2–4 dependency-ordered phases, at most 3–4 tasks each, plain-English test scenarios under every task, and a mandatory verification gate closing each phase. Reads scope, sub-modules, and dependency order out of `docs/development-roadmap.md` rather than inventing them, and confirms the phase cut before writing.
license: MIT
metadata:
  version: "4.2.0"
---

# plan-module

Turns one module of the development roadmap into the phase-based execution spec a coding agent builds from — the plan file itself, not advice about planning.

## When this runs
- The roadmap defines a module and the user is ready to start building it
- A module was planned earlier, work has since moved, and the plan needs re-cutting around what changed
- Never as a project's first step — `docs/development-roadmap.md` must already exist; if it doesn't, hand off to `scaffold`

## Core philosophy — bake this into every output
- **The roadmap is the input contract, not a suggestion.** Scope, sub-modules, dependency order, and every `Out of scope:` line come from the module's own block. Widening scope at plan time is how a roadmap stops meaning anything — if the block is wrong, fix the block first and say so.
- **Plan the decided, not the desirable.** A module gated by a `Status: Pending` entry in `docs/decisions.md` gets planned up to that boundary and no further. Never resolve a parked decision by quietly planning past it.
- **Every task carries its own proof.** A development task with no scenario beneath it is not a task, it's a wish. Scenarios are plain English — observable behavior a reader can check — never test code.
- **No implementation code in the plan.** Not a snippet, not a schema, not a function signature. The plan states what must become true; `execute-plan` decides how. Naming an endpoint, table, or data shape in *Details* is right; writing it out is not.
- **The plan file is living, and execution writes to it.** It accumulates a Progress Log and a Files Modified list as work proceeds. A re-plan edits that file in place and never discards closed work — see Step 4.
- **Never carry a secret into the plan.** Credentials, tokens, connection strings, private hostnames and IPs, real customer data — use a named reference (`DATABASE_URL`, `<internal-host>`) and describe the shape if an implementer needs it. This file gets committed, so it isn't the user's call to override.

## Workflow

### Step 0 — Find the roadmap and pick the module
- Read `docs/development-roadmap.md`. No roadmap means there is nothing to plan: say so and hand off to `scaffold` rather than inventing a decomposition here. A pre-3.0 `docs/roadmap.md` needs migrating by `scaffold` first.
- If the user named a module, use it. Otherwise propose the first `## Module <n>` that is not `done` or `dropped` and whose `Depends on:` modules are all `done` — name it, say why it's next, and confirm before planning.
- If the user named a **sub-module**, say plans are cut per module and offer both: plan the whole parent module, or plan that sub-module alone as its own file. Never silently widen or narrow the ask.
- A `Status: dropped` block is not plannable. Ask whether it's being revived — that's a roadmap edit, not a planning decision.

### Step 1 — Read the block, then read around it
- Extract from the module's block: every `### Sub-Module`, its `Status`, `In scope`, `Out of scope`, and every `Depends on:`.
- Read the root context file (`CLAUDE.md` / `AGENTS.md`) and whichever of `docs/product.md`, `docs/conventions.md`, `docs/architecture.md` it links. Business rules and conventions constrain the tasks; a plan that ignores them tells the coding agent to violate the project's own docs.
- Check `docs/decisions.md` for `Status: Pending` entries this module touches, and name each one before planning. A task depending on a parked decision is a phase boundary, not a task.
- If a `Depends on:` module is not `done`, say so and ask whether to plan this one anyway or plan the dependency first. Don't assume either.

### Step 2 — Cut the phases, then confirm the cut
- Propose 2–4 phases in dependency order, each carrying `Dependencies: None` or `Dependencies: Phase X`.
- **Sub-modules are the natural phase boundaries** — one per phase, unless two are genuinely inseparable. When a module has a single sub-module, split by layer instead (data → behavior → surface) and say explicitly that you did, since that split is yours and not the roadmap's.
- Cap each phase at 3–4 development tasks. A phase needing more is two phases. The verification gate doesn't count toward the cap.
- Show the phase titles, their order, and their dependencies, and get confirmation before writing any tasks. A wrong cut wastes the entire plan and costs one question to catch.
- Anything the roadmap marks `Out of scope:` stays out. If the user wants it in, the roadmap block changes first.

### Step 3 — Write tasks and scenarios
- Read `references/plan-template.md` for the exact output shape, the four-state checkbox vocabulary, and the counting rules before drafting. Read `references/scenario-writing.md` before writing the scenarios.
- Give each development task a one-line *Details* naming what gets created or changed — endpoints, tables, data shapes, by name — and 1–3 scenarios beneath it.
- Write at least one happy-path scenario, plus at least one edge or error scenario wherever the task can fail. A task carrying only a happy path is under-specified.
- Scenarios state observable behavior: given what, what happens, with what result. No test code, no assertions, no framework names.
- Close every phase with its gate task, `Task X.V: Run test-and-verify suite for Phase X`. It is mandatory and it is not a development task.
- Use the project's own domain vocabulary, pulled from its docs, rather than generic placeholders.

### Step 4 — Write the file and link it back
- Write `docs/guides/feature_<module_name>_plan.md`, snake_case, derived from the module title (`Module 3 — Assignment` → `docs/guides/feature_assignment_plan.md`). Create `docs/guides/` if it doesn't exist.
- **If that file already exists, this is a re-plan, not a fresh write.** Preserve every `[x]`, `[~]`, and `[-]` item with its annotation, and preserve the Progress Log and Files Modified list whole. Show the user the diff before writing. A task being re-cut becomes `[~]` with its reason — it never reverts to `[ ]`, because that would silently un-do finished work.
- Update the roadmap in the same pass: each planned sub-module's `**Tasks:** not yet planned` becomes `**Tasks:** see docs/guides/feature_<module>_plan.md — Phase <n>`. The roadmap stays an index of modules and sub-modules; task detail lives only in the plan file.
- Append a dated Progress Log line saying the plan was initialized or re-cut, and what changed.
- Report the phase count, the total task count, any decisions still parked and which phases they gate, and the exact path written. Then offer to hand off to `execute-plan`.

## Reference files
- `references/plan-template.md` — the exact output format, the four-state checkbox vocabulary, and how progress is counted. Read this in Step 3 before drafting.
- `references/scenario-writing.md` — what makes a scenario checkable, with weak/strong pairs. Read this in Step 3, and again if a scenario comes out vague or starts drifting toward test code.
