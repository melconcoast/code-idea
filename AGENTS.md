# code-idea

"Code this idea" — a Claude Skill (see `SKILL.md`) that turns a plan into an AI-coding-agent-ready docs set. This repo *is* the skill — there's no application code, only `SKILL.md` and `references/`.

## Critical rules (read first)
- **Confirmation must be explicit, never assumed from silence.** A fact that appears in a planning conversation because the assistant proposed it, or because it showed up in a prototype/demo (especially one shaped by the demo environment's own constraints), is NOT the same as something the user explicitly stated or confirmed. Step 2 of `SKILL.md` must apply the recommend-and-confirm pattern to both cases the same way — don't let "it's already in the conversation" substitute for a real confirmation.
- **`SKILL.md` stays lean.** Treat ~150 lines as a hard ceiling, ~30 as a starting point. If an edit grows it significantly, something else should shrink.
- **The frontmatter `description` has a hard 1024-character limit.** Exceeding it is a load-time error — the skill silently fails to register, so nothing else in it can work. Measure after any edit to that field, and never trim a quoted trigger phrase to fit; cut descriptive text instead. `examples/test-scenarios.md` S33 is the check.
- **Never leave placeholder or TODO content** in `SKILL.md` or `references/` — see `CONTRIBUTING.md`.
- **`references/recommendation-heuristics.md` is expected to age.** Verify a specific tool/version recommendation against a current search before trusting it, and treat outdated entries there as a normal, welcome PR rather than a bug.
- **The container is per-agent; the content is not.** Which files the skill generates depends on the target agent (Claude Code reads `CLAUDE.md` and never `AGENTS.md`; Codex and Antigravity read `AGENTS.md` natively). What those files *say* is identical in every mode. When changing `SKILL.md`, check you haven't let a layout assumption leak into content guidance or vice versa — `examples/test-scenarios.md` S12 is the check for this.
- **A deferred decision is not a placeholder.** "Undecided as of [date], do X meanwhile" is required output when the user defers; `[Project name]` and `TODO` are not. Don't let the no-placeholder rule suppress the pending-decision feature.

## Commands
- No build step — this is a pure markdown skill.
- Package for release: `.github/workflows/release.yml` handles this automatically on a `v*.*.*` tag push. To test packaging locally, see the packaging step in that workflow file directly.

## Testing a change
- See `CONTRIBUTING.md`'s "Testing a change" section — run the skill against a sample plan before and after any `SKILL.md` edit, including at least one case where the new/changed rule should clearly fire and one where it clearly shouldn't.

## Related docs
- `README.md` — human-facing overview, install/usage
- `CONTRIBUTING.md` — contribution guidelines and file-ownership map
- `CHANGELOG.md` — release history
- `references/best-practices.md` — the reasoning behind `SKILL.md`'s rules
- `references/recommendation-heuristics.md` — stack/database/UI defaults it proposes during its interview
- `references/agent-profiles.md` — per-agent container facts, with sources and dates; expected to age
- `examples/test-scenarios.md` — the scenarios a change must be checked against
