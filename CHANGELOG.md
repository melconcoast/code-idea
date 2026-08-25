# Changelog

## [4.1.0] — 2026-08-24

### Added
- **`execute-plan` may consult a domain skill while implementing a task.** Step 2 now says to use a
  skill covering the task's domain — frontend, data modeling, infrastructure — when the environment
  offers one. The hook is deliberately capability-agnostic: no skill is named, none is assumed
  installed, and a task builds normally where none exists or where the host agent doesn't support
  skill-to-skill invocation. The domain skill advises; `execute-plan` still decides, and its output
  stays bounded by the task's *Details* and the project's stated conventions, which win on conflict.
  Anything it proposes past the task's scope is reported, not built. Covered by `examples/test-scenarios.md`
  S102–S104. `plan-module` deliberately gains no such hook — domain expertise reaches a plan through
  `docs/conventions.md` and `docs/architecture.md`, never through implementation detail injected at
  plan time.

## [4.0.0] — 2026-08-23

Major release. The four skills move from `skills/` to `.agents/skills/`, which makes them installable
on Codex, Cursor, Gemini CLI, GitHub Copilot, Kimi Code and Deep Code rather than Claude Code alone.
Read **Breaking** before upgrading — plugin users are unaffected, but a vendored copy or symlink is
not.

Nothing changes about what the skills do or what they generate. Every `SKILL.md` body and all ten
reference files are byte-identical to 3.3.0; only frontmatter and file location changed.

### Breaking
- **The skills move from `skills/<name>/` to `.agents/skills/<name>/`.** `.agents/skills/` is the
  interoperable path defined by the [Agent Skills](https://agentskills.io) standard and read natively
  by every supported agent except Claude Code. Any skills directory pointed at the old path — a
  symlink into `~/.claude/skills/`, a vendored copy, a submodule, a script that reads
  `skills/scaffold/SKILL.md` — no longer finds a skill and loads nothing, *silently*. This is the same
  break, one directory level on, that 3.0.0 made when the repo became a plugin. See **Upgrading**.
- **Installing via the plugin or the `.skill` release assets is unaffected.** Skill names, the
  `/code-idea:*` commands, the four asset filenames, and every generated file are unchanged. If that
  is how you install, there is nothing to do.

### Added
- **Cross-agent installation.** `npx skills add melconcoast/code-idea` installs into any of 76+
  agents the skills CLI supports, with no registration needed — `.agents/skills/` is one of the
  directories it scans.
- **`scripts/install.sh`** — detects which agents are configured, resolves each to its own skills
  directory, and copies. Agents sharing `.agents/skills/` are written once rather than repeatedly.
  Supports `--global`, `--agent NAME`, `--all`, `--dry-run`, and `--list`. Its agent table cites each
  agent's own documentation with a verified-on date, and **is expected to age** like
  `agent-profiles.md`.
- **`license` and `metadata.version` in every skill's frontmatter.** Both are Agent Skills spec
  fields. `metadata.version` exists because `plugin.json` does not travel with a skill copied into
  `.agents/skills/`, so a standalone install would otherwise have no way to know its version.
- **Scenarios S97–S101** cover the distribution layer — the layer below every other scenario, where a
  skill that never registers cannot fail a behavioral test, it just goes quiet.

### Fixed
- **Two skills were invisible to every non-Claude agent.** `execute-plan` and `test-and-verify` each
  had a `: ` inside an unquoted `description`, which a strict YAML parser reads as a nested mapping
  and rejects — skipping the whole skill. Claude Code's lenient parser hid this, so it shipped
  undetected from the versions that introduced those descriptions until the skills CLI refused them:
  it found two of four skills. Both now read naturally with an em dash or a period, and the release
  workflow parses all four with a strict parser so it cannot recur.
- **Trigger phrases moved to the front of all four descriptions.** Codex budgets its startup skills
  list to ~2% of context and shortens descriptions first, cutting from the end — which is exactly
  where the routing phrases sat. The wording is unchanged and the token multisets are identical, so
  this is provably a reorder: all 21 quoted phrases survive verbatim, each is still owned by exactly
  one skill, and all four remain within the 1024-character limit.

### Changed
- `.claude-plugin/plugin.json` declares `"skills": ["./.agents/skills/"]`. This is load-bearing:
  because the marketplace entry's `source` is the repository root, the paths it lists are the complete
  set, and one that does not resolve makes Claude Code fall back to scanning `./skills/` — now gone —
  and load **zero skills with no error**.
- **The release workflow gained six guards**, each for a failure that produces silence rather than an
  error: an unresolvable `skills` path, a skill outside every declared path, a skill count other than
  four, a non-spec frontmatter key, a spec-invalid `name`, and a `: ` or ` #` inside an unquoted
  description. It also parses all four frontmatter blocks with PyYAML.
- **The version now lives in three places, not two** — the git tag, `plugin.json`, and each skill's
  `metadata.version`. CI blocks a tag that disagrees with the manifest, and a skill that disagrees
  with it. The critical rule in `AGENTS.md` is rewritten to say so.

### Upgrading from 3.x
1. **If you install via the plugin or the `.skill` assets, do nothing.** Run
   `/plugin marketplace update melconcoast` and restart; the skills load from the new location
   automatically.
2. **If you symlinked, vendored, or submoduled `skills/`, repoint it to `.agents/skills/`.** The old
   path no longer holds a skill, and nothing will tell you so — check that `/skills` still lists all
   four after the change.
3. **To add another agent**, run `npx skills add melconcoast/code-idea` or clone the repo and run
   `./scripts/install.sh`. Neither replaces an existing Claude Code plugin install.

## [3.3.0] — 2026-08-22

Adds a fourth skill, `test-and-verify`. The first three are a pipeline; this one is a service the
others call. `execute-plan` no longer runs tests itself — it hands each task and each `Task X.V` gate
to this skill and acts on the verdict.

Additive for anyone on 3.2.0. No generated file changes shape, and `execute-plan` behaves the same
way from the outside — it just stops duplicating a job that now has an owner.

### Added
- **`test-and-verify`** (`skills/test-and-verify/SKILL.md`) — finds the project's test command, runs
  the tests relevant to the work, **reads the real output rather than the exit code**, and fixes what
  fails in a bounded diagnose-fix-rerun loop. Every failure gets classified as an *application* bug or
  a *test* bug before anything is edited, because picking wrong papers over a real defect or bends
  correct code to satisfy a broken assertion. Invoked as `/code-idea:test-and-verify`, or triggered by
  "run the tests", "verify this", "check the tests pass", "fix the failing tests", "why is this test
  failing".
- **A three-attempt circuit breaker.** Past three remediation attempts the diagnosis is usually what
  was wrong rather than the fix, so further attempts widen the diff on a false premise. It stops and
  hands back what failed, what it tried, and what it ruled out. `execute-plan` may not re-invoke it to
  get around a red verdict — that is the same attempt with the safety removed.
- **Two boundaries that make it safe to call automatically.** It never writes to a plan file — it
  returns a verdict and `execute-plan` marks the boxes, because two writers on one plan file is how a
  plan stops being trustworthy. And it never weakens a test to reach green: no deleted assertions,
  loosened matchers, added skips, widened timeouts, or expected values rewritten to match whatever the
  code currently produces. If the honest outcome is "still failing", that is what it reports.
- **Gate runs widen automatically.** At a `Task X.V` gate it runs the whole module's suite plus the
  project's type-checker and linter. If the project has neither, it says so — an omitted line reads as
  a check that passed.
- `skills/test-and-verify/references/test-commands.md` — the discovery order, targeted-versus-whole-suite
  invocation per ecosystem, and the type-check and lint commands a gate adds. Includes two traps that
  cost real time: `npm test -- <path>` misroutes when the `test` script is a chain, and a filter
  matching nothing usually exits 0. **This file is expected to age**, like `recommendation-heuristics.md`.
- `skills/test-and-verify/references/remediation.md` — application-bug versus test-bug diagnosis, what
  a targeted fix may touch, the circuit breaker, and the exact pass and fail report formats.
- `examples/test-scenarios.md` — Fixture H (a suite with one genuine bug) and S85–S96, covering
  diagnosis, the no-op on an already-green suite, the chained-script and empty-filter traps, the
  breaker, test-weakening, the missing-checks report, the plan-file boundary, and the now four-way
  trigger boundary.

### Changed
- **Fixture G is now explicitly the false-closure fixture, and Fixture I is the default for execution
  scenarios.** Fixture G's plan called Phase 1 closed while only one of its tasks had ever been built,
  so every `execute-plan` run against it correctly stopped at Step 0 and never reached the behavior
  the scenario was actually testing. That inconsistency is exactly what S84 needs, so it stays — but
  the sixteen other scenarios keyed to it now name Fixture I, whose closed work is real.
- **`execute-plan` delegates verification instead of doing it.** Step 3 hands the run to
  `test-and-verify` and takes its verdict as given; Step 5 hands it the gate. It only runs tests inline
  if that skill isn't available, and then by its rules.
- **Test-command discovery has one owner now.** It lived in `execute-plan`'s `verification.md` and
  would have been duplicated by the new skill. `verification.md` keeps what is genuinely
  `execute-plan`'s — *bootstrapping* a runner when the project has none, which is a project decision
  tied to the stack the docs already chose, not a remediation step — and defers the search itself.
  Its "what counts as green" section narrowed to the question this skill actually owns: not whether
  the run passed, but whether that pass closes a checkbox.

### Upgrading
Nothing to do. `test-and-verify` appears once the plugin updates, and `execute-plan` starts using it
automatically. If you invoke `execute-plan` in an environment where the new skill is unavailable, it
falls back to running the tests inline.

## [3.2.0] — 2026-08-22

Adds the plugin's third and final skill, `execute-plan`, and with it the chain closes: `scaffold`
writes the docs set, `plan-module` cuts a module into a plan file, and `execute-plan` builds that plan
file into working, tested code. No skill name is reserved-but-unbuilt any more.

Additive for anyone already on 3.1.0 — nothing `scaffold` or `plan-module` generates changes shape,
and an existing plan file is exactly what the new skill expects to find.

### Added
- **`execute-plan`** (`skills/execute-plan/SKILL.md`) — works a plan file in a strict **micro-loop**:
  select the first open task, implement only what its *Details* names, write the test code its
  plain-English scenarios describe, run it until green, then update the plan file — before looking at
  the next task. Never a whole phase in one pass. At each `Task X.V` gate it runs the *whole* module's
  suite rather than just that phase's tests, closes the phase, and **stops to ask** before continuing.
  Invoked as `/code-idea:execute-plan`, or triggered by "execute the plan", "build task 2.1",
  "start phase 2", "continue building this module", "implement the next task".
- **Test-runner bootstrap.** In this chain a project starts with no code, so the first module usually
  has nothing to run and `scaffold` has left `## Commands` reading "not yet established". `execute-plan`
  sets up the runner that fits the stack the project's docs already chose — never introducing a
  language or framework those docs didn't pick — and writes the real commands back into the root
  context file. That closes a loop `scaffold` could not close on its own.
- **Roadmap status write-back.** Sub-modules move to `in progress` as their phase starts and `done` as
  it closes; the module becomes `done` once every phase is. Phases match sub-modules through the
  `**Tasks:**` pointer `plan-module` wrote. Nothing else updated these statuses, so before this a
  finished module still read `planned` and the next `plan-module` run would be pointed at work that
  was already built.
- `skills/execute-plan/references/verification.md` — where to look for a test runner, how to bootstrap
  one without adding tooling nobody asked for, what counts as green, and what to do with a scenario
  that is wrong or that can't be checked in the environment at hand.
- `skills/execute-plan/references/progress-updates.md` — every write execution makes to a plan file or
  the roadmap. **Deliberately subordinate**: it applies the vocabularies specified in `plan-module`'s
  `plan-template.md` and `scaffold`'s `templates.md` and never restates them, so the plugin keeps one
  source of truth per contract rather than three.
- **A stop-and-report rule for a plan that disagrees with the repository** — a task marked closed whose
  code isn't there, a `## Files Modified` path that doesn't exist. `execute-plan` neither builds on the
  false closure nor quietly repairs it: reopening a phase the file calls done is the user's decision,
  and rewriting the record to match reality would erase the evidence that it was wrong.
- `examples/test-scenarios.md` — Fixture G (a plan file in a repo that has code and a working runner)
  and S65–S84, covering the micro-loop, phase-dependency enforcement, runner bootstrap, reframe-not-
  delete, scope containment, the gate-and-stop, resume-don't-restart, roadmap write-back, the
  verified-not-written rule, bare status values, and the three-way trigger boundary.

### Changed
- **`[x]` is now enforced as *verified*, not *written*.** The distinction was always in
  `plan-template.md`; `execute-plan` is what acts on it. A task whose code exists but whose tests never
  ran stays `[ ]`, and behavior that genuinely can't be checked here becomes `[~]` with what would
  verify it — never `[x]` on faith.
- **Status values are bare, and both vocabularies now say so.** `scaffold`'s `templates.md` already
  called the roadmap `Status` a closed vocabulary, but not that the value is the word *alone* — so
  `done (server-side only — see Sub-Module 2.2)` looked permissible while breaking the same parse a
  new status word would. Both `templates.md` and `plan-template.md` now state it, and a caveat worth
  recording goes in the Progress Log instead. Caught by running S67 against the real skill.
- `skills/plan-module/references/plan-template.md` now specifies a **phase's** `Status:` line, not just
  the header's. It reads `[ ] Open` while anything in the phase is open and `[x] Done` once every item
  including the `X.V` gate is closed. Only the open form was written down before, so the closed form
  was being improvised.
- `examples/test-scenarios.md` — S43 and S64 changed meaning. Both previously accepted silence or a
  hand-off *naming* `execute-plan`, because it didn't exist; now the sibling skill is expected to fire.
- `examples/sample-output/docs/development-roadmap.md` — Sub-Module 3.1 corrected to `done`. The sample
  plan file closes Phase 1, so under the new write-back rule its sub-module can't still read
  `in progress`. The sample was internally inconsistent before there was a rule to catch it.
- `README.md`, `AGENTS.md`, and `CONTRIBUTING.md` updated for a three-skill plugin.

### Upgrading
Nothing to do. `execute-plan` appears once the plugin updates. Existing plan files work unchanged —
it reads the format `plan-module` has always written. If you have a roadmap whose statuses drifted
while there was no skill maintaining them, the first `execute-plan` pass over a module will bring that
module's own entries back in line; it won't touch any other module's.

## [3.1.0] — 2026-08-22

Adds the plugin's second skill, `plan-module`. `scaffold` has always written a
`docs/development-roadmap.md` whose every `**Tasks:**` field read `not yet planned`; `plan-module` is
what fills that in. `plan-module` itself is purely additive — it changes nothing 3.0.0 established, and
no generated file changes shape.

**This release also carries everything listed under 3.0.0 below**, which was prepared but never tagged.
If you are upgrading from 2.x, read 3.0.0's **Breaking** and **Upgrading from 2.x** sections — they
apply to this release.

### Added
- **`plan-module`** (`skills/plan-module/SKILL.md`) — reads one `## Module <n>` block out of
  `docs/development-roadmap.md` and writes `docs/guides/feature_<module>_plan.md`: 2–4 phases in
  dependency order, at most 3–4 development tasks per phase, 1–3 plain-English test scenarios under
  every task, and a mandatory `Task X.V` verification gate closing each phase. It reads the module's
  scope and dependency order out of the roadmap rather than re-deriving them, reads the project's own
  context file, `product.md`, and pending decisions before drafting, and confirms the phase cut before
  writing any tasks. Invoked as `/code-idea:plan-module`, or triggered by "plan the next module",
  "plan module 3", "break this module into phases", "create the execution plan for [module]".
- **A four-state checkbox vocabulary** for plan files — `[ ]` open, `[x]` done *and verified*,
  `[~]` reframed (annotation required), `[-]` skipped (annotation required) — with progress counted in
  closed items and never as a percentage. Specified in
  `skills/plan-module/references/plan-template.md`, which `execute-plan` will parse.
- `skills/plan-module/references/scenario-writing.md` — what makes a plain-English test scenario
  checkable, with weak/strong pairs, per-task coverage rules, and the never-write-test-code rule.
- The plan file is a **living document**: it carries a `## Progress Log` and a `## Files Modified`
  section that fill in during execution, and re-planning a module in flight preserves every closed
  item rather than resetting it.
- `examples/sample-output/docs/guides/feature_assignment_plan.md` — a worked example showing a closed
  phase, a `[~]` reframe, a `[-]` skip, and a phase gated by a pending decision.
- `examples/test-scenarios.md` — Fixtures E and F, plus S45–S64 covering module selection, the phase
  cut, output integrity, the re-plan-preserves-progress rule, and the trigger boundary between the two
  skills.

### Changed
- **The roadmap's `**Tasks:**` field is now a pointer, not a placeholder.** It reads `not yet planned`
  until `plan-module` runs, then becomes `see docs/guides/feature_<module>_plan.md — Phase <n>`. Task
  detail lives only in the plan file; the roadmap stays an index of modules and sub-modules.
- **The planning unit is a module, not a sub-module.** `skills/scaffold/references/templates.md`
  previously called sub-modules "the addressable unit," which contradicted how `plan-module` actually
  works — a module's sub-modules are the phase boundaries of its plan file. Corrected in
  `templates.md` and `best-practices.md`.
- `skills/scaffold/SKILL.md` Step 5 — a re-run must not reset a `**Tasks:**` pointer back to
  `not yet planned`, which would orphan a live plan file.
- `README.md`, `AGENTS.md`, and `CONTRIBUTING.md` updated for a two-skill plugin. `execute-plan`
  remains the only reserved-but-unbuilt name, and still ships no directory until it is written.
- `examples/sample-output/README.md` — fixed a stale `docs/roadmap.md` in its file tree, missed by
  3.0.0's rename.

### Upgrading
Nothing to do. `plan-module` appears automatically once the plugin updates; existing roadmaps work
unchanged, since `**Tasks:** not yet planned` is exactly what it expects to find.

## [3.0.0] — 2026-08-21

*Never tagged on its own — these changes ship as part of 3.1.0. Kept as a separate entry because it is
where the breaking changes are described.*

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
