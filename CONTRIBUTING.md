# Contributing

Thanks for considering a contribution. This plugin is small on purpose — most useful contributions will be sharpening what's already here, not adding new files.

## Where things live

The repo is a Claude Code plugin. Each skill owns a directory under `skills/`, holding its own
`SKILL.md` and its own `references/`. Three skills ship — `scaffold`, `plan-module`, and
`execute-plan` — and they run in that order. No skill name is reserved-but-unbuilt any more; if you
propose a fourth, it gets no directory until it is written, because git can't track an empty directory
and a stub `SKILL.md` registers a broken skill for everyone.

- **`.claude-plugin/plugin.json`** and **`marketplace.json`** — the plugin manifest, and the entry that makes this repo its own marketplace (named `melconcoast`, after the owner, so installs read `code-idea@melconcoast`). The version lives in `plugin.json` only and must match the release tag; CI enforces it.
- **`skills/scaffold/SKILL.md`** — the workflow itself: when the skill triggers, how the interview works, how structure is decided, how content gets drafted and written. Changes here affect behavior directly, so keep edits scoped and explain the reasoning in the PR description.
- **`skills/scaffold/references/best-practices.md`** — the research and reasoning behind the size limits, ordering rules, and doc-vs-skill split. If you're proposing a change to the skill's rules, the backing reasoning (or a correction to outdated reasoning) belongs here.
- **`skills/scaffold/references/recommendation-heuristics.md`** — stack/database/caching/UI defaults the skill proposes during its interview. **This file is expected to age** — tooling and best practices shift. If something here is outdated, that's a welcome PR, not a bug report.
- **`skills/scaffold/references/agent-profiles.md`** — what each coding agent reads and how it loads it. **This file is expected to age**, like the heuristics file, and every claim carries a source URL and verified-on date. A stale entry is a welcome PR. Never add a row you can't cite from that agent's own docs.
- **`skills/scaffold/references/templates.md`** — the skeleton structure for each generated doc type. The `docs/development-roadmap.md` section here is the contract `plan-module` reads; a change to that block is a change to both skills.
- **`skills/plan-module/SKILL.md`** — how a roadmap module is located, cut into phases, and written out as a plan file. It reads the roadmap contract rather than restating it, so a scope or vocabulary change belongs in `scaffold`'s `templates.md` first.
- **`skills/plan-module/references/plan-template.md`** — the plan file's exact format, its four-state checkbox vocabulary, and how progress is counted. `execute-plan` parses this, so treat the headings and glyphs as a contract, not styling.
- **`skills/plan-module/references/scenario-writing.md`** — what makes a plain-English test scenario checkable, with weak/strong pairs. New guidance on scenario quality belongs here, not in the SKILL.md.
- **`skills/execute-plan/SKILL.md`** — the micro-loop: how one task is selected, implemented, verified, and written back. It reads the plan file `plan-module` produced rather than restating that file's format, so a vocabulary or counting change belongs in `plan-module`'s `plan-template.md` first.
- **`skills/execute-plan/references/verification.md`** — finding or bootstrapping a test runner, what counts as green, and what to do with a scenario that's wrong or can't be checked. Guidance on proving a task is done belongs here, not in the SKILL.md.
- **`skills/execute-plan/references/progress-updates.md`** — every write execution makes to a plan file or the roadmap. **This file is deliberately subordinate**: the checkbox vocabulary and counting rules are specified in `plan-module`'s `plan-template.md`, and the roadmap `Status` vocabulary in `scaffold`'s `templates.md`. It may say how to apply them and nothing more — if it ever disagrees with either, it's the file that's wrong.
- **`examples/`** — shared across every skill in the plugin, which is why it stays at the repo root rather than moving under `skills/scaffold/`.

## Reporting an outdated recommendation

The skill explicitly leans on a web-search tool (when available) to verify a recommendation is current before offering it — but the heuristics file itself is a fallback and won't always be caught. If you notice a stale default (a deprecated tool, a superseded pattern), open an issue or PR citing what's changed and why the new guidance is better — a source link is ideal.

## Proposing a new default or rule

Ground it, don't just assert it. "Recommend X because it's popular" is weaker than "recommend X for [specific project shape] because [concrete reasoning], with Y as the exception when [condition]." The existing heuristics file follows this pattern — match it.

## Testing a change

There's no automated test suite — this is a markdown-based plugin, not code. CI checks frontmatter and description length on a tag, but behavior is validated by hand. To validate a change:
1. Run the skill against a small sample plan (a paragraph describing a hypothetical project is enough) and check that the interview questions and generated structure make sense.
2. Try at least one case where your change should clearly kick in, and one where it clearly shouldn't, to make sure the trigger condition is specific enough.
3. If you're changing a `SKILL.md` itself, re-read it end to end afterward — it's meant to stay short, so a change that grows it significantly should come with something else trimmed.
4. Run the relevant scenarios from `examples/test-scenarios.md`, including at least one "must NOT produce" case — a rule that fires when it shouldn't is as broken as one that never fires.

## Style

- Bullet-point imperatives over prose paragraphs, consistent with how the skill asks generated instruction files (`AGENTS.md`, `CLAUDE.md`) to be written.
- No placeholder or TODO content in what ships — if something's unfinished, leave it out rather than stubbing it in. One carve-out: a dated pending-decision entry (`undecided as of YYYY-MM-DD`, plus what to do meanwhile) asserts a real current fact and is required output when a user defers a choice — that's not a placeholder.
- Keep each `SKILL.md` lean; anything that needs more than a few lines of explanation probably belongs in that skill's `references/` instead, linked from the relevant step.

## Code of conduct

Be respectful, assume good faith, keep disagreements about the work rather than the person.
