# Changelog

## [2.0.1] — 2026-08-12

Major release. The skill's central rule is reversed: content no longer always lives in `AGENTS.md`.
It now lives in whichever file the target coding agent reads natively. Read **Breaking** before upgrading.

### Breaking
- **The generated file layout now depends on the target agent.** The same plan produces different files than it did in 1.x:

  | Target | Content lives in | No longer generated |
  |---|---|---|
  | Claude Code alone | `CLAUDE.md` | `AGENTS.md` |
  | Codex alone | `AGENTS.md` | `CLAUDE.md` |
  | Antigravity alone | `AGENTS.md`, or an existing `GEMINI.md` | `CLAUDE.md` |
  | Two or more agents, or generic | `AGENTS.md` + `CLAUDE.md` loader | — |

  A Claude-Code-only project no longer gets an `AGENTS.md` at all. If you standardised on `AGENTS.md` across repos on the strength of 1.x's "content always lives in AGENTS.md" rule, that rule is gone.
- **Re-running can now move or delete files.** When a re-run changes the target agent, the skill migrates the existing layout — folding `AGENTS.md` into `CLAUDE.md` or the reverse, and deleting what the new layout doesn't use. Every move is proposed and confirmed before anything is written, and content with no home in the new layout is raised as a question rather than dropped. It is never silent, but it is destructive if you approve it.
- **Re-runs now interrupt.** 1.x regenerated quietly. This version stops, announces the existing scaffold, and re-asks anything it cannot prove you decided. Expect an interview where you previously got files.

### Fixed
- **The frontmatter `description` exceeded Claude Code's 1024-character limit** (1225 chars), so the skill silently failed to register and nothing in it could run. Trimmed to 1001 by cutting descriptive text only, with every trigger phrase preserved verbatim. The limit is now a critical rule in `AGENTS.md` and is guarded by scenarios S33/S34 — S34 specifically forbids trimming a trigger phrase to fit, which would break matching invisibly.
- **Re-running against an existing scaffold no longer treats it as settled.** Facts read from generated docs on disk are now tagged as a distinct source and re-confirmed like any unconfirmed proposal — a doc proves a file was written, not that anyone decided anything, and it may predate the confirmation rules entirely. Previously a project scaffolded by an older version regenerated silently, skipping every question the newer rules were meant to force, including the target-agent question when a `CLAUDE.md` already existed. New Step 0 detects an existing scaffold and says so before asking anything.
- **Four claims about coding agents were wrong and are corrected.** All were plausible and all came from secondary sources rather than the agents' own documentation:
  - Claude Code does **not** need an opt-in setting to read `AGENTS.md` — no such setting exists, and it does not read the file at all. (Shipped in 1.1.0.)
  - Codex is **not** documented as running the test commands named in `AGENTS.md`; its docs frame them as working agreements, not execution directives.
  - Antigravity states **no** precedence between `GEMINI.md` and `AGENTS.md`. The previous claim that `GEMINI.md` wins was unsupported.
  - Antigravity's `AGENTS.md` support is confirmed, but the version it landed in is not — that came from a blog, not Google's docs, and is no longer asserted.
- **Codex's 32 KiB cap is cumulative, not per-file.** Codex stops adding files once the *combined* size across root and nested files reaches the cap, so an oversized root silently starves the deepest, most specific nested guidance. Size reporting now covers combined size for Codex targets.

### Added
- **Deferring a decision.** Every recommendation now offers three exits — accept, override, or defer. A deferred choice writes a dated `## Pending decisions — do not resolve these yourself` rule at the top of the context file, plus a `Status: Pending` entry in `decisions.md`, and skips the affected doc entirely rather than shipping a hollow one.
- **A hard rule against writing secrets into generated files.** Credentials, tokens, connection strings, private hostnames and IPs, and real customer data are never written into a generated file even when they appear in the plan — these files get committed. Named references are substituted instead, and the rule holds even if you ask for the value to be included.
- **Structure that survives the next session.** A generated rules directory (`.claude/rules/`, `.agents/rules/`) now ships with the routing that governs how rules are added to it later, and every generated doc carries a one-line rule stating how to extend it. Without these, a scaffold decays as soon as anyone adds to it.
- **Output integrity checks.** Internal links are verified to resolve before reporting — `design-system.md` is deliberately absent whenever the theme was deferred, so dead links were a common path rather than an edge case. File size is reported against each selected agent's own limit.
- `references/agent-profiles.md` — per-agent container facts, each with a source URL and verified-on date, behind an explicit verify-before-trusting header. Expected to age.
- `docs/conventions.md` as a generated candidate for naming and structural rules beyond linter defaults, with matching defaults in `recommendation-heuristics.md`.
- `examples/test-scenarios.md` — thirty-four scenarios a change must be checked against, including "must NOT produce" cases that catch a rule firing when it shouldn't.
- A `## Maintaining these docs` routing rule in generated output, so mid-project updates land in the content file rather than fragmenting across it and the loader, and so useful notes captured in Claude Code's machine-local auto memory get promoted where the team can see them.

### Changed
- The container is now separate from the content. The target agent decides which files exist and how they load; system design, naming conventions, UI direction, and business rules are identical in every layout.
- Agent size limits are no longer compared. Lines, bytes, and characters are not commensurable, so each selected agent's limit is reported in its own unit rather than collapsed into a single "strictest" number.
- `references/best-practices.md` — the canonical-filename and nested-files sections rewrote AGENTS.md-first from a universal rule to a portable default; added Claude Code's compaction, auto-memory, and enforcement limits.
- `CONTRIBUTING.md` — the no-placeholder rule now carves out dated pending-decision entries, which would otherwise have suppressed the feature.

### Upgrading from 1.x
Re-run the skill against an existing project. It will detect the scaffold, tell you what it found, and re-confirm anything it cannot prove you decided — including the target agent, which it will no longer infer from which files exist. If your answer changes the layout, it proposes the migration and waits for approval before moving or deleting anything.

## [1.1.0] — 2026-08-12
### Fixed
- **Confirmation is now explicit, never assumed from silence.** Step 1 requires tagging each fact extracted from conversation history by source — explicitly stated/confirmed by the user, vs. proposed by the assistant or produced by a prototype/demo and never separately confirmed. Only the former counts as "already known" and can skip a question in Step 2. Step 2 now routes everything in the latter category through the recommend-and-confirm pattern before it's written into any doc as settled, with a worked example. Previously the skill could silently carry a throwaway prototype's stack and theme into production docs just because they appeared in the conversation unobjected-to.
- **Companion `CLAUDE.md` files are now generated whenever Claude Code is a confirmed target agent**, at the root and beside every nested subsystem `AGENTS.md` — not conditionally, only when there were Claude-specific extras to add. Claude Code's context loading is CLAUDE.md-centric and does not automatically read an existing AGENTS.md without an opt-in setting, so the thin `@AGENTS.md` import is a functional requirement for the docs to load, not an optional extra. AGENTS.md remains the single source of truth and holds all content; nested `CLAUDE.md` is now generated *alongside* nested `AGENTS.md` rather than as an either/or alternative to it.

### Changed
- Step 5's generated file-tree summary now explicitly lists every companion `CLAUDE.md`, with a one-line note on why it was added.
- `references/templates.md` — the CLAUDE.md template now shows a bare `@AGENTS.md` one-liner as a complete, valid file; the `## Claude Code specific` section is documented as optional, not required scaffolding.
- `references/best-practices.md` — added "Prototype constraints are not production decisions"; reworked the canonical-filename and nested-files sections to explain why AGENTS.md and CLAUDE.md are generated together for Claude Code targets.
- `README.md` and `examples/sample-output` updated to reflect both fixes.

## [1.0.0] — 2026-08-11
### Added
- Initial release of `code-idea`.
- Dynamic interview workflow: gathers a plan, asks only what isn't already known, proposes grounded recommendations (tech stack, database/caching, UI theme/typography) rather than open questions.
- Per-project structure decisions — no fixed template; generates `AGENTS.md`, and only the linked docs (`architecture.md`, `decisions.md`, `roadmap.md`, `product.md`, `design-system.md`) and nested per-subsystem files a given project actually warrants.
- Defaults to nested `AGENTS.md` for monorepo/subdirectory context (cross-tool, closest-file-wins, supported by 20+ agents) rather than nested `CLAUDE.md`, which only nested-Claude-Code teams should use instead.
- `references/best-practices.md` — research backing for file-size limits, rule ordering, and the decisions-vs-product split.
- `references/recommendation-heuristics.md` — grounded defaults for stack, database, caching, and UI design choices.
- `references/templates.md` — skeleton structure for each generated doc type.
