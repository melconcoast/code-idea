# Changelog

## [1.2.0] — 2026-08-12
### Fixed
- **Re-running against an existing scaffold no longer treats it as settled.** Facts read from generated docs on disk are now tagged as a distinct source and re-confirmed like any unconfirmed proposal — a doc proves a file was written, not that anyone decided anything, and it may predate the confirmation rules entirely. Previously a project scaffolded by an older version regenerated silently, skipping every question the newer rules were meant to force, including the target-agent question when a `CLAUDE.md` already existed. New Step 0 detects an existing scaffold and says so before asking anything.
- **Corrected a stale claim about Claude Code.** Earlier versions said Claude Code needs an opt-in setting to read `AGENTS.md`. It does not read `AGENTS.md` at all, under any setting, and `@AGENTS.md` from `CLAUDE.md` is the officially documented remedy. The conclusion was right; the reasoning was wrong.

### Added
- **Deferring a decision.** Every recommendation now offers three exits — accept, override, or defer. A deferred choice writes a dated `## Pending decisions` rule at the top of the context file telling the agent not to resolve it, plus a `Status: Pending` entry in `decisions.md`, and skips the affected doc entirely rather than shipping a hollow one.
- **Per-agent layouts.** One named agent gets its native format: `CLAUDE.md` for Claude Code (which never reads `AGENTS.md`), `AGENTS.md` for Codex and Antigravity (which read it natively). Two or more agents, or a generic target, gets the portable layout — `AGENTS.md` plus a `CLAUDE.md` loader. Changing the target on a re-run migrates the existing files rather than orphaning them.
- `references/agent-profiles.md` — per-agent container facts, each with a source URL and verified-on date. Expected to age; verify before trusting.
- `docs/conventions.md` as a generated candidate for naming and structural rules beyond linter defaults, with matching defaults in `recommendation-heuristics.md`.
- `examples/test-scenarios.md` — thirty-two scenarios a change must be checked against, including "must NOT produce" cases.
- A `## Maintaining these docs` routing rule in generated output, so mid-project updates land in the content file rather than fragmenting across it and the loader, and so useful notes captured in Claude Code's machine-local auto memory get promoted where the team can see them.

### Changed
- The container is now separate from the content. The target agent decides which files exist and how they load; system design, naming conventions, UI direction, and business rules are identical in every layout.
- `references/best-practices.md` — the canonical-filename and nested-files sections rewrote AGENTS.md-first from a universal rule to a portable default; added Claude Code's compaction, auto-memory, and enforcement limits.
- `CONTRIBUTING.md` — the no-placeholder rule now carves out dated pending-decision entries, which would otherwise have suppressed the feature.

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
