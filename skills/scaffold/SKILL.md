---
name: scaffold
description: Transforms a project plan, idea, or planning conversation into an AI-coding-agent-ready docs set — a lean root context file for the target agent (CLAUDE.md, AGENTS.md, or both), plus linked docs and nested per-subsystem files for monorepos. Interviews to pick the right structure, re-confirms undecided facts, and tracks deferred choices as pending decisions. Use this skill whenever the user wants to turn a plan/idea into files for Claude Code or another coding agent, says things like "set up AGENTS.md/CLAUDE.md for this", "get this ready for Claude Code", "scaffold the project docs", "turn this plan into context files", "hand this off to a coding agent", or has just finished a substantial planning/design discussion and is about to start building. Also trigger when the user asks how to structure AGENTS.md/CLAUDE.md and wants it actually applied to their project, not just explained in the abstract. Not for planning or building a module from an existing roadmap — use plan-module or execute-plan.
---

# code-idea

Turns a plan into the actual files a coding agent needs to work correctly — not a lecture on best practices, the files themselves.

## When this runs
- Right after a planning/design conversation, before the user moves to Claude Code (or another agent) to start building
- When the user pastes or describes a new idea and wants it scaffolded from scratch
- When updating or extending an existing project's agent docs as the plan evolves

## Core philosophy — bake this into every output
- The root context file stays SHORT — start near 30 lines, treat ~150 as a hard ceiling, move anything longer into a linked doc. Which file that is depends on the target agent (Step 3); how short it should be does not.
- **Nothing is settled until the user says so.** A fact that entered the conversation because *you* proposed it, or because it showed up in a prototype/demo, is not confirmed — see Step 1's source tagging and Step 2's confirmation rule.
- **"Not yet decided" is a valid answer and a real output.** A deferred choice becomes a dated pending-decision rule at the top of the context file plus a `Status: Pending` entry in `decisions.md` — never a guess written as settled, and never a hollow doc.
- Only write rules that fix an actual observed or clearly anticipated mistake. No vague advice, no restating what a linter/formatter already enforces, no pasted-in documentation, no large code samples.
- Put the rules most likely to be violated at the TOP of the file — agents can lose instructions buried later in a long file.
- Separate the *living spec* from the *historical log*: `product.md` is current-state and gets edited as things change; `decisions.md` is append-only — past entries are never rewritten, each one dated with its rationale.
- A doc that goes stale actively misleads more than no doc at all. `architecture.md` must be updated in the same change as any real architecture shift, or removed if it can't be kept current.
- Recurring step-by-step procedures (how to test X, how to rotate Y) belong in a Skill, not a static markdown doc — skills load conditionally instead of sitting in every session's context.
- **The container is per-agent; the content is not.** Which files exist and how they load comes from the target agent's own docs — Claude Code reads `CLAUDE.md` and does not read `AGENTS.md` at all; Codex and Antigravity read `AGENTS.md` natively. What the docs *say* — system design, naming conventions, UI direction, business rules — is identical either way. See `references/agent-profiles.md` for per-agent specifics, and never assert an agent behavior that file can't cite.
- See `references/best-practices.md` for the fuller reasoning behind these rules if the user asks why, or if a judgment call comes up mid-scaffold. See `references/recommendation-heuristics.md` for grounded defaults on tech stack, database/caching choices, and UI design conventions to offer during Step 2. See `references/agent-profiles.md` for what each target agent reads and how — verify a row against its source before relying on it.

## Workflow

### Step 0 — Check for an existing scaffold
- Look for a root `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md`, or a `docs/` file matching one of this skill's own generated names (`decisions.md`, `product.md`, `development-roadmap.md`, `roadmap.md` from before 3.0, `architecture.md`, `conventions.md`, `design-system.md`) at the target path. If any exist, this is a **re-run**, not a fresh scaffold — say so, name what you found, and state that its contents will be re-confirmed rather than assumed.
- If a previous run left pending decisions, surface those first: "last time you parked [X] — decide now, or keep it parked?"
- Never infer the target agent from which files exist. The layout is a product of a previous answer; treating it as evidence makes that answer self-confirming forever.

### Step 1 — Gather the plan
- If this conversation already contains a planning/design discussion, extract it directly (architecture, product rules, decisions already made, open questions, tech stack). Don't make the user repeat what they already said.
- **Tag every extracted fact by source: (a) explicitly stated or confirmed by the user; (b) proposed by the assistant or produced by a prototype/demo and never separately confirmed; (c) read from an existing generated doc on disk.** Only (a) counts as known and lets you skip a question in Step 2. Both (b) and (c) are still open questions no matter how settled they look — a doc on disk proves a file was written, not that anyone decided anything, and it may predate the confirmation rules entirely.
- When re-asking a (c) fact, offer the doc's current value as the recommendation so confirming is one keystroke: "`design-system.md` currently says slate/shadcn — keep it, change it, or park it?"
- Never silently overwrite content the user clearly hand-wrote. Ask about it.
- **Never carry a secret out of the plan.** Credentials, tokens, connection strings, private hostnames and IPs, and real customer data are not extracted into any generated file, even when the plan contains them. Substitute a named reference (`DATABASE_URL`, `<internal-host>`); if the value's *shape* matters, describe the shape in `docs/product.md` instead of reproducing the value. This one has no override — these files get committed. If the user asks for the value to be included anyway, decline and offer the named-reference form instead — the file being committed means this isn't the user's call.
- If starting fresh, ask the user to paste or describe the plan/idea. A rough idea is enough to start the interview in Step 2 — don't insist on a fully fleshed-out plan first.

### Step 2 — Interview (this is what makes it dynamic, not templated)
Ask only what isn't already known from the plan or conversation. Typical questions — adapt freely, don't ask ones you already have answers to:
- Single app, or multiple subsystems / a monorepo — and if multiple, what does each do and what stack does it use? (This alone determines whether nested per-subsystem files are needed — most small projects don't need them.)
- Which coding agent(s)? Claude Code, Codex, Antigravity, or generic/unsure. This decides the file layout only, never the content — see Step 3. Always ask; never infer it from which files already exist.
- Is there a frontend/UI subsystem with its own design conventions worth a dedicated design-system doc?
- Any naming or structural conventions beyond what a linter enforces — table/column naming, API route shapes, module boundaries? (These become `docs/conventions.md`; skip the file when the answer is "just the tooling defaults.")
- Any business rules, pricing logic, or security/compliance constraints an agent must never quietly change? (These become the highest-priority root-file rules AND get a decisions.md entry.)
- Writing into an existing repo, or drafting for one that doesn't exist yet?
- Any procedures likely to recur (testing steps, deployment, local setup) that should become a Skill instead of a doc?
- How does this break into modules and sub-modules, and in what order? Propose a specific decomposition with its dependency chain ("Module 1 Infrastructure — 1.1 auth, 1.2 audit logging — then Module 2 Orders, since orders needs a user"), not an open-ended ask. This becomes `docs/development-roadmap.md`.

**Don't leave these as open questions the user has to answer from scratch.** For anything with a genuine best-practice default — tech stack, database/caching choice, monorepo vs. single-repo, UI theme/typography/design pattern — propose a specific, context-grounded recommendation *as part of the question*, and let the user accept it or override it. This matters most for a user without strong opinions on the topic; don't make them invent an answer to a question they came here to avoid having to research themselves.

- Bad: "What database do you want to use?"
- Good: "For [the order/credit/job data described], I'd recommend Postgres (relational, transactional, handles the credits ledger cleanly) with Redis for the live print-queue/session state. Go with that, or do you have something else in mind?"

**Silence is not confirmation.** Anything tagged (b) in Step 1 — an assistant proposal, or a choice baked into a prototype/demo — goes through the same recommend-and-confirm pattern before it's written into any doc as settled, even if the user never objected to it at the time. Be explicit about where it came from, especially when the choice was forced by the demo environment rather than chosen on the merits.

**One decision at a time.** Never bundle several recommendations into one message and read a single "sounds good" as confirming all of them — a blanket yes against a bundle confirms nothing. Ask, confirm, then move to the next.

- Bad: silently carrying the prototype's UI stack and theme into `design-system.md` because it's "already decided."
- Good: "The working prototype used [library + theme], but that was partly forced by what the chat artifact sandbox allows — it wasn't a production call. For the real build I'd recommend [grounded recommendation]. Keep the prototype's choice, go with this, or something else?"

**"Decide later" is a third valid answer.** Every recommendation offers three exits — accept, override, or defer — and defer is a legitimate choice, not a failure to answer. Offer it proactively for anything that doesn't block the first slice of work (theme, palette, copy voice): "Go with that, something else, or park it and decide once the scaffold's up?"

A deferred choice produces three things and no guesses: a dated item in the context file's `## Pending decisions` section, a `Status: Pending` entry in `decisions.md`, and *no* doc for the thing that's undecided — a `design-system.md` that's mostly a hole is worse than its absence.

Ground every recommendation in the actual project context (data shape, expected scale, real-time needs, domain) rather than reaching for a generic default — see `references/recommendation-heuristics.md` for starting points on stack/database/caching/UI choices, and lean on a web-search tool if one is available to confirm a recommendation is still current before offering it, since specific tools and best practices shift over time. If the user has already stated a preference or constraint earlier in the conversation, don't re-litigate it — just confirm and move on.

Prefer short, specific questions. Use an elicitation/multiple-choice tool where the surface supports it and the question fits that shape (a recommendation plus 2–3 alternatives works well there); don't force an open-ended essay prompt when a recommend-and-confirm question would do.

### Step 3 — Decide the structure (per-project, not fixed)
Based on the interview, choose which files are actually warranted. Don't generate a file nobody needs — a trivial single-file project needs one root file, `docs/development-roadmap.md`, and often nothing else.

First pick the **layout** from the target agent(s) — this decides which files exist, never what they say:

| Target | Content lives in | Also generate | Don't generate |
|---|---|---|---|
| Claude Code alone | `CLAUDE.md` (root) | `.claude/rules/` only if genuinely path-scoped content exists; nested `CLAUDE.md` per subsystem | `AGENTS.md` |
| Codex alone | `AGENTS.md` | — | `CLAUDE.md` |
| Antigravity alone | `AGENTS.md`, or the repo's existing `GEMINI.md` if it has one | `.agents/rules/` only if genuinely path-scoped content exists | `CLAUDE.md`; a second root rules file |
| Two or more agents, or generic | `AGENTS.md` | `CLAUDE.md` containing `@AGENTS.md`, at root and beside every nested `AGENTS.md` | — |

One named agent gets its native layout; plural or generic gets the portable one. Size limits aren't comparable across agents (lines vs. bytes vs. characters) — report each in its own unit; the skill's own ~150-line root-file ceiling still applies to the root file independently of any agent's cap. Keep critical rules in the root file even in Claude-native mode — nested files and path-scoped rules don't survive `/compact`. See `references/agent-profiles.md`.

Then pick the **linked docs**, which are identical in every layout. Don't generate a file nobody needs — with one deliberate exception, `development-roadmap.md`, which is always generated because downstream module planning reads it as its input contract (see `references/best-practices.md`):

| File | Generate when |
|---|---|
| `docs/architecture.md` | There's real architectural complexity worth recording — skip for trivial projects |
| `docs/decisions.md` | Any non-obvious decision has been made or deferred |
| `docs/conventions.md` | There are naming/structure rules beyond what a linter enforces — otherwise keep a thin `## Code style` section in the content file |
| `docs/development-roadmap.md` | **Always** — record the Step 2 module/sub-module decomposition and its dependency order, even on a trivial project. Modules and sub-modules only; task-level detail is not invented here |
| `docs/product.md` | There are business/feature rules an agent must implement correctly |
| `docs/design-system.md` | There's a UI subsystem with real design conventions — **not** when the design decision was deferred |

### Step 4 — Draft the content
- Pull the skeleton for each file type from `references/templates.md`, then fill it with the project's actual specifics — never leave placeholder text in the delivered output. The one exception is a dated pending-decision entry, which asserts a real current fact and is required when the user defers.
- Never write a credential, token, connection string, private hostname/IP, or real customer data into a generated file, even if it's in the plan and even if asked to. Use a named reference (`DATABASE_URL`, `<internal-host>`) and describe the value's shape in `docs/product.md` if an implementer needs it. These files get committed.
- Keep `decisions.md` entries terse: date, the decision, a one-line rationale, alternatives considered if relevant. Don't editorialize beyond that.
- Keep the content file (`AGENTS.md` or `CLAUDE.md`, per Step 3's layout) to bullet-point imperatives, not prose paragraphs.
- Use the project's own terminology (product names, domain vocabulary, language/locale) rather than generic placeholders.

### Step 5 — Write and confirm
- If there's filesystem access to the actual project (e.g. running inside Claude Code with a real repo), write the files directly into the correct paths.
- If running in a chat-only surface without a project filesystem, produce the files as downloadable/presentable content and tell the user exactly which path each one belongs at once they're in their project.
- If Step 0 found an existing scaffold and the target agent changed, **migrate rather than orphan**: moving content between `CLAUDE.md` and `AGENTS.md`, adding or removing the loader. Propose the moves and get confirmation before writing — migration deletes files. A pre-3.0 `docs/roadmap.md` migrates the same way: propose the rename to `docs/development-roadmap.md` and the conversion of its flat lists into module/sub-module blocks, show what maps where, and confirm before writing. Never drop content that has no home in the new layout; raise it as a question instead. On any re-run, a sub-module whose `**Tasks:**` already points at a `docs/guides/feature_*_plan.md` file keeps that pointer — `plan-module` wrote it, and resetting it to `not yet planned` orphans a live plan.
- Show the resulting file tree and a short summary of what went where, naming which layout was used and why. List every companion `CLAUDE.md` explicitly with a one-line note that it's a thin `@AGENTS.md` import. List **Pending decisions** as its own section when any exist, so the user leaves knowing what they parked. Flag anything inferred vs. still uncertain — don't silently guess on business-critical rules.
- Tell the user how to verify the docs actually load: for Claude Code, run `/context` and check the list under **Memory files**. In portable mode (an `AGENTS.md` exists alongside `CLAUDE.md`), warn against running `/import`, which appends a duplicate copy of `AGENTS.md` into `CLAUDE.md`.
- Before reporting, check every internal link in the content file resolves to a file that was actually generated. Drop the line rather than shipping a dead link — `design-system.md` is deliberately absent whenever the theme was deferred, so this fires on a common path, not an edge case.
- Report size against each selected agent's own limit, in its own unit — line count for Claude Code, bytes for Codex, characters for Antigravity (see `references/agent-profiles.md`) — warning at roughly three-quarters of any limit. For Codex, report the combined root-plus-nested size against the 32 KiB cap, not just the root: it stops adding files once the *combined* total hits the cap, silently dropping the deepest nested guidance first.
- Offer to keep going — e.g. drafting a Skill for a recurring procedure surfaced in Step 2, or scaffolding the next subsystem.

## Reference files
- `references/best-practices.md` — the research and reasoning behind the size limits, ordering rules, and doc-vs-skill split. Read this if the user asks "why," or a structural judgment call comes up that isn't covered above.
- `references/templates.md` — skeleton structure for each file type (AGENTS.md, CLAUDE.md, rules directories, decisions.md, development-roadmap.md, product.md, architecture.md, design-system.md, conventions.md). Read this in Step 4 before drafting.
- `references/agent-profiles.md` — what each target agent reads and how, with sources and verified-on dates. Read this before Step 3, and before asserting any agent behavior anywhere.
- `references/recommendation-heuristics.md` — grounded defaults for stack, database/caching, and UI choices. Read this in Step 2 before recommending one.
