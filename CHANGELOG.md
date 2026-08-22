# Changelog

## [3.0.0] — 2026-08-21

Major release. `code-idea` is now a Claude Code **plugin** rather than a standalone skill repo, the
skill inside it is renamed `scaffold`, and `docs/roadmap.md` becomes `docs/development-roadmap.md`
with a module/sub-module structure and unconditional generation. Read **Breaking** before upgrading.

### Breaking
- **The skill is renamed `code-idea` → `scaffold`.** It now lives at `skills/scaffold/` inside a
  plugin named `code-idea`, so explicit invocation is `/code-idea:scaffold`. Natural-language
  triggering is unchanged — every trigger phrase from 2.x still fires.
- **The repo is now a plugin.** `SKILL.md` and `references/` moved from the repo root to
  `skills/scaffold/`, alongside a new `.claude-plugin/plugin.json` and `marketplace.json`. Any skills
  directory pointed at this repo's root — a symlink into `~/.claude/skills/`, a vendored copy, a
  submodule — no longer finds a skill and loads nothing, *silently*. See **Upgrading**.
- **`docs/roadmap.md` is renamed `docs/development-roadmap.md` and restructured.** The three flat
  lists (`## MVP scope`, `## Deferred`, `## Open questions`) become `## Module <n>` blocks holding
  `### Sub-Module <n>.<m>` blocks, each carrying `Status`, `Depends on`, `In scope`, `Out of scope`,
  and `Tasks`, in dependency order. `## Deferred` and `## Open questions` survive unchanged. Anything
  reading the old `## MVP scope` list will find nothing. A re-run detects a pre-3.0 `roadmap.md`,
  proposes the rename and conversion, and waits for approval — like any other content migration.
- **The development roadmap is now always generated**, including for projects with no MVP-vs-later
  split. It is the input contract for downstream module planning, so its absence removes that step's
  input rather than degrading it. This is a deliberate, documented exception to "don't generate a
  file nobody needs" — see `references/best-practices.md`, "Why the development roadmap is always
  generated." A re-run against a project with no roadmap will add one.
- **`Status` is a closed vocabulary** — `planned`, `in progress`, `done`, `blocked`, `dropped` — at
  both module and sub-module level. A dropped module keeps its block with `Status: dropped` rather
  than moving into `## Deferred`, so `Depends on:` references to its id don't dangle. This replaces
  the old "move items between sections rather than deleting them" directive for modules; it still
  holds for `## Deferred` items themselves.

### Added
- **A module/sub-module decomposition question in Step 2**, covering both the units of work and their
  dependency order, delivered as a specific proposal to accept or reorder rather than an open
  question. It fills the roadmap, and it is mandatory rather than conditional now that the roadmap
  always ships.
- **A one-decision-at-a-time confirmation rule.** Recommendations are no longer bundled, and a single
  "sounds good" against a bundle confirms none of them.
- **Anti-triggers in the frontmatter `description`.** "plan the next module", "build task 3", and
  "execute the plan" no longer wake this skill into re-scaffolding a repo that already has docs.
  Every existing trigger phrase is preserved verbatim; the room was paid for out of descriptive text.
- **CI validates every skill on a tag** — description length against the 1024-character limit,
  frontmatter `name` matching its directory, and `plugin.json`'s version matching the tag. Scenario
  S33 was a manual check guarding a failure that has already shipped once (see 2.0.1's Fixed
  section); it now blocks the release. Length is measured in characters, not bytes — em dashes made
  byte-counting reject valid descriptions.
- `examples/test-scenarios.md` — S35–S44, covering the roadmap format, unconditional generation, the
  scaffold-stops-at-sub-modules boundary, the dropped-module rule, dependency integrity, pre-3.0
  migration, the decomposition question, the confirmation rule, and the sibling anti-triggers.
- `plan-module` and `execute-plan` are reserved skill names in this plugin. Neither is authored yet,
  and neither ships a directory — git cannot track an empty one, and a stub `SKILL.md` would register
  a broken skill for every user.

### Changed
- `.github/workflows/release.yml` discovers and packages every `skills/*/SKILL.md` instead of a
  hardcoded root `SKILL.md`, so a new skill needs no workflow change. Each still ships as its own
  `.skill` asset — the plugin itself is distributed by git ref, not as an archive, because Claude
  Code installs plugins from a marketplace source and has no install path for a zipped plugin.
- `README.md`, `AGENTS.md`, and `CONTRIBUTING.md` rewritten for a multi-skill repo.
  `CONTRIBUTING.md`'s "Where things live" is no longer written in the singular.
- Step 2 trimmed to pay for the additions: the single-app and per-subsystem questions merged into
  one, and the palette Bad/Good example pair dropped — the database pair already carries the pattern,
  and the prototype-theme pair still covers the UI case. `SKILL.md` is unchanged in length at 119 lines.
- `examples/sample-output/` regenerated in the new format, now demonstrating a `blocked` sub-module
  whose blocker is the pending decision already recorded in `decisions.md`.

### Upgrading from 2.x
1. Remove the old install. If you symlinked or copied this repo into a skills directory, delete it —
   it points at a location that no longer holds a skill.
2. Install the plugin: `/plugin marketplace add melconcoast/code-idea` then
   `/plugin install code-idea@melconcoast`. For Claude.ai or Claude Desktop, download the
   `scaffold.skill` asset from the release instead; that path is unchanged apart from the filename.
3. Re-run the skill against existing projects. It detects the scaffold, proposes the roadmap rename
   and migration to the module format, and adds a roadmap to any project that doesn't have one.
   Nothing is written without approval.

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
