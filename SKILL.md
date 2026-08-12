---
name: code-idea
description: Transforms a project plan, idea, or planning conversation into a complete AI-coding-agent-ready documentation set — a lean root AGENTS.md plus linked docs (architecture, decisions, roadmap, product, design-system) and, for monorepos, nested per-subsystem context files. Dynamically interviews the user to decide the right structure for their specific project rather than applying one fixed template. Use this skill whenever the user wants to turn a plan/idea into files for Claude Code or another coding agent, says things like "set up AGENTS.md/CLAUDE.md for this", "get this ready for Claude Code", "scaffold the project docs", "turn this plan into context files", "hand this off to a coding agent", or has just finished a substantial planning/design discussion and is about to start building. Also trigger when the user asks how to structure AGENTS.md/CLAUDE.md and wants it actually applied to their project, not just explained in the abstract.
---

# Context Scaffolder

Turns a plan into the actual files a coding agent needs to work correctly — not a lecture on best practices, the files themselves.

## When this runs
- Right after a planning/design conversation, before the user moves to Claude Code (or another agent) to start building
- When the user pastes or describes a new idea and wants it scaffolded from scratch
- When updating or extending an existing project's agent docs as the plan evolves

## Core philosophy — bake this into every output
- The root instruction file (`AGENTS.md`, imported by a thin `CLAUDE.md` only if the user specifically needs Claude Code extras) stays SHORT. Structure and length are decided per project in Step 3 below, but as a rule of thumb: start near 30 lines, and treat ~150 lines as a hard ceiling for the root file — move anything longer into a linked doc.
- Only write rules that fix an actual observed or clearly anticipated mistake. No vague advice, no restating what a linter/formatter already enforces, no pasted-in documentation, no large code samples.
- Put the rules most likely to be violated at the TOP of the file — agents can lose instructions buried later in a long file.
- Separate the *living spec* from the *historical log*: `product.md` is current-state and gets edited as things change; `decisions.md` is append-only — past entries are never rewritten, each one dated with its rationale.
- A doc that goes stale actively misleads more than no doc at all. `architecture.md` must be updated in the same change as any real architecture shift, or removed if it can't be kept current.
- Recurring step-by-step procedures (how to test X, how to rotate Y) belong in a Skill, not a static markdown doc — skills load conditionally instead of sitting in every session's context.
- For subdirectory/monorepo context, **default to nested `AGENTS.md` files, not nested `CLAUDE.md`**. AGENTS.md's nested, closest-file-wins model is honored natively across 20+ agents (Codex, Cursor, Copilot, Gemini CLI, Claude Code, and others), so it's the portable choice regardless of which coding agent ends up being used. Only use nested `CLAUDE.md` when the user has explicitly confirmed the team is standardized on Claude Code specifically and wants Claude-only per-directory behavior beyond what AGENTS.md provides. If the target agent is unknown or mixed, nested AGENTS.md is the safe default.
- See `references/best-practices.md` for the fuller reasoning behind these rules if the user asks why, or if a judgment call comes up mid-scaffold. See `references/recommendation-heuristics.md` for grounded defaults on tech stack, database/caching choices, and UI design conventions to offer during Step 2.

## Workflow

### Step 1 — Gather the plan
- If this conversation already contains a planning/design discussion, extract it directly (architecture, product rules, decisions already made, open questions, tech stack). Don't make the user repeat what they already said.
- If starting fresh, ask the user to paste or describe the plan/idea. A rough idea is enough to start the interview in Step 2 — don't insist on a fully fleshed-out plan first.

### Step 2 — Interview (this is what makes it dynamic, not templated)
Ask only what isn't already known from the plan or conversation. Typical questions — adapt freely, don't ask ones you already have answers to:
- Single app, or multiple subsystems / a monorepo? (This alone determines whether nested per-subsystem files are needed at all — most small projects don't need them.)
- What does each subsystem do, and what stack does it use?
- Target coding agent(s) — Claude Code specifically, or keep it tool-agnostic via AGENTS.md only?
- Is there a frontend/UI subsystem with its own design conventions worth a dedicated design-system doc?
- Any business rules, pricing logic, or security/compliance constraints an agent must never quietly change? (These become the highest-priority root-file rules AND get a decisions.md entry.)
- Writing into an existing repo, or drafting for one that doesn't exist yet?
- Any procedures likely to recur (testing steps, deployment, local setup) that should become a Skill instead of a doc?

**Don't leave these as open questions the user has to answer from scratch.** For anything with a genuine best-practice default — tech stack, database/caching choice, monorepo vs. single-repo, UI theme/typography/design pattern — propose a specific, context-grounded recommendation *as part of the question*, and let the user accept it or override it. This matters most for a user without strong opinions on the topic; don't make them invent an answer to a question they came here to avoid having to research themselves.

- Bad: "What database do you want to use?"
- Good: "For [the order/credit/job data described], I'd recommend Postgres (relational, transactional, handles the credits ledger cleanly) with Redis for the live print-queue/session state. Go with that, or do you have something else in mind?"
- Bad: "What's your color palette and typography?"
- Good: "Based on [the domain], I'd suggest [a specific grounded direction, not a generic default] for the palette and pairing. Want me to run with that, or do you already have brand colors/fonts in mind?"

Ground every recommendation in the actual project context (data shape, expected scale, real-time needs, domain) rather than reaching for a generic default — see `references/recommendation-heuristics.md` for starting points on stack/database/caching/UI choices, and lean on a web-search tool if one is available to confirm a recommendation is still current before offering it, since specific tools and best practices shift over time. If the user has already stated a preference or constraint earlier in the conversation, don't re-litigate it — just confirm and move on.

Prefer short, specific questions. Use an elicitation/multiple-choice tool where the surface supports it and the question fits that shape (a recommendation plus 2–3 alternatives works well there); don't force an open-ended essay prompt when a recommend-and-confirm question would do.

### Step 3 — Decide the structure (per-project, not fixed)
Based on the interview, choose which files are actually warranted. Don't generate a file nobody needs — a trivial single-file project needs an AGENTS.md and maybe nothing else. Typical candidates:

| File | Generate when |
|---|---|
| `AGENTS.md` (root) | Always |
| `CLAUDE.md` (root) | Only if the user specifically targets Claude Code and needs extras beyond AGENTS.md — content is just an `@`-import plus the Claude-specific bits |
| `docs/architecture.md` | There's real architectural complexity worth recording — skip for trivial projects |
| `docs/decisions.md` | Any non-obvious decision has already been made (pricing model, auth approach, protocol choices, etc.) |
| `docs/roadmap.md` | There's a real MVP-vs-later split to protect against scope creep |
| `docs/product.md` | There are business/feature rules an agent needs to implement correctly (pricing formulas, refund logic, access rules) |
| `docs/design-system.md` | There's a UI subsystem with real design conventions (palette, components, copy voice) |
| Nested `<subsystem>/AGENTS.md` | Genuine monorepo where subsystems have materially different conventions — not needed for a single codebase. This is the default nested format regardless of target agent. |
| Nested `<subsystem>/CLAUDE.md` (instead of AGENTS.md) | Only if the user has confirmed the team is standardized on Claude Code specifically and wants Claude-only per-directory behavior |

### Step 4 — Draft the content
- Pull the skeleton for each file type from `references/templates.md`, then fill it with the project's actual specifics — never leave placeholder text in the delivered output.
- Keep `decisions.md` entries terse: date, the decision, a one-line rationale, alternatives considered if relevant. Don't editorialize beyond that.
- Keep `AGENTS.md` content to bullet-point imperatives, not prose paragraphs.
- Use the project's own terminology (product names, domain vocabulary, language/locale) rather than generic placeholders.

### Step 5 — Write and confirm
- If there's filesystem access to the actual project (e.g. running inside Claude Code with a real repo), write the files directly into the correct paths.
- If running in a chat-only surface without a project filesystem, produce the files as downloadable/presentable content and tell the user exactly which path each one belongs at once they're in their project.
- Show the resulting file tree and a short summary of what went where. Explicitly flag anything inferred vs. anything still uncertain — don't silently guess on business-critical rules; ask instead.
- Offer to keep going — e.g. drafting a Skill for a recurring procedure surfaced in Step 2, or scaffolding the next subsystem.

## Reference files
- `references/best-practices.md` — the research and reasoning behind the size limits, ordering rules, and doc-vs-skill split. Read this if the user asks "why," or a structural judgment call comes up that isn't covered above.
- `references/templates.md` — skeleton structure for each file type (AGENTS.md, decisions.md, roadmap.md, product.md, architecture.md, design-system.md). Read this in Step 4 before drafting.
