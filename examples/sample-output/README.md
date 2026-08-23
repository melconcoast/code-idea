# Sample output

What `code-idea` produced for a small, single-repo example project: a basic task-tracker web app with a Postgres backend and a React frontend — no monorepo, no nested files needed, since there's only one codebase with one set of conventions.

This is intentionally a *small* example. A multi-subsystem project (e.g. a native background service plus a web frontend plus an API) would additionally get nested `<subsystem>/AGENTS.md` files — see the main [README](../../README.md) for when those get generated.

```
sample-output/
├── AGENTS.md
├── CLAUDE.md      # @AGENTS.md import plus a routing echo — generated because Claude Code was a target agent
└── docs/
    ├── decisions.md
    ├── development-roadmap.md
    ├── product.md
    └── guides/
        └── feature_assignment_plan.md   # written by plan-module, not scaffold
```

`CLAUDE.md` here is the `@AGENTS.md` import plus a short visible routing echo — see the actual file for the exact text. It exists because Claude Code does not read AGENTS.md at all, so the `@AGENTS.md` import is what makes the docs load. AGENTS.md stays the single source of truth. In a monorepo, each nested `<subsystem>/AGENTS.md` gets the same loader companion beside it.

**This is the portable layout, not the only one.** It's generated whenever the target is a generic or multi-agent project — two or more agents, or the agent wasn't named. Two other layouts exist for narrower targets:
- **Claude-Code-only project:** this same content goes directly into `CLAUDE.md`. No `AGENTS.md` is generated — Claude Code doesn't read it, so a separate copy would just be a second file to keep in sync.
- **Codex-only project:** this same content goes into `AGENTS.md`, which Codex reads natively. No `CLAUDE.md` is generated — nothing in this scenario reads it.

`docs/guides/` is the one directory here that `scaffold` did not create. `plan-module` wrote it when Module 3 was about to be built, and flipped that module's `**Tasks:**` fields in the roadmap to point at it — which is why two sub-modules there read `see docs/guides/…` while Modules 1 and 2 still read `not yet planned`.

Note there's no `docs/architecture.md` or `docs/design-system.md` in this example — the skill didn't generate them because a small single-repo CRUD app didn't have enough architectural complexity or UI-specific design conventions to warrant a dedicated doc. That's the "only what's warranted" behavior working as intended, not an omission.
