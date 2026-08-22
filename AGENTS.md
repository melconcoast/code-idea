# code-idea

"Code this idea" — a Claude Code plugin that turns a plan into an AI-coding-agent-ready docs set, then plans and builds the modules it defines. There's no application code, only markdown. One skill exists today: `scaffold` (see `skills/scaffold/SKILL.md`). Two more are planned and deliberately unbuilt — `plan-module` and `execute-plan` — and neither ships a directory until it is written.

## Critical rules (read first)
- **Confirmation must be explicit, never assumed from silence.** A fact that appears in a planning conversation because the assistant proposed it, or because it showed up in a prototype/demo (especially one shaped by the demo environment's own constraints), is NOT the same as something the user explicitly stated or confirmed. Step 2 of `skills/scaffold/SKILL.md` must apply the recommend-and-confirm pattern to both cases the same way — don't let "it's already in the conversation" substitute for a real confirmation.
- **Each `SKILL.md` stays lean.** Treat ~150 lines as a hard ceiling, ~30 as a starting point. If an edit grows it significantly, something else should shrink.
- **The frontmatter `description` has a hard 1024-character limit.** Exceeding it is a load-time error — the skill silently fails to register, so nothing else in it can work. Measure after any edit to that field, and never trim a quoted trigger phrase to fit; cut descriptive text instead. `examples/test-scenarios.md` S33 is the check.
- **Never leave placeholder or TODO content** in any `SKILL.md` or `references/` — see `CONTRIBUTING.md`.
- **`skills/scaffold/references/recommendation-heuristics.md` is expected to age.** Verify a specific tool/version recommendation against a current search before trusting it, and treat outdated entries there as a normal, welcome PR rather than a bug.
- **The container is per-agent; the content is not.** Which files the skill generates depends on the target agent (Claude Code reads `CLAUDE.md` and never `AGENTS.md`; Codex and Antigravity read `AGENTS.md` natively). What those files *say* is identical in every mode. When changing a `SKILL.md`, check you haven't let a layout assumption leak into content guidance or vice versa — `examples/test-scenarios.md` S12 is the check for this.
- **The version lives in two places — the git tag and `.claude-plugin/plugin.json`.** Bump both together; CI blocks a tag whose `plugin.json` version doesn't match. `.claude-plugin/marketplace.json` deliberately carries no version, so the plugin's own manifest stays the single answer to "what version is this?" — don't add one there.
- **A skill directory without a `SKILL.md` is not a placeholder for a future skill.** Git can't track an empty directory, and a `.gitkeep` stub registers a broken skill for every user. Reserve an unbuilt skill's name in `README.md` and `CHANGELOG.md`; create the directory when you write it.
- **`scaffold` stops at sub-modules.** `docs/development-roadmap.md` records modules and sub-modules only — never task tables. Task detail is `plan-module`'s output, and inventing it at scaffold time means guessing implementation detail nobody has decided. `examples/test-scenarios.md` S37 is the check.
- **A deferred decision is not a placeholder.** "Undecided as of [date], do X meanwhile" is required output when the user defers; `[Project name]` and `TODO` are not. Don't let the no-placeholder rule suppress the pending-decision feature.

## Commands
- No build step — this is a pure markdown plugin.
- Package for release: `.github/workflows/release.yml` handles this automatically on a `v*.*.*` tag push. To test packaging locally, see the packaging step in that workflow file directly.

## Testing a change
- See `CONTRIBUTING.md`'s "Testing a change" section — run the skill against a sample plan before and after any `SKILL.md` edit, including at least one case where the new/changed rule should clearly fire and one where it clearly shouldn't.

## Related docs
- `README.md` — human-facing overview, install/usage
- `CONTRIBUTING.md` — contribution guidelines and file-ownership map
- `CHANGELOG.md` — release history
- `skills/scaffold/references/best-practices.md` — the reasoning behind the skill's rules
- `skills/scaffold/references/recommendation-heuristics.md` — stack/database/UI defaults it proposes during its interview
- `skills/scaffold/references/agent-profiles.md` — per-agent container facts, with sources and dates; expected to age
- `examples/test-scenarios.md` — the scenarios a change must be checked against
