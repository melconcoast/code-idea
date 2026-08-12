# Sample output

What `code-idea` produced for a small, single-repo example project: a basic task-tracker web app with a Postgres backend and a React frontend — no monorepo, no nested files needed, since there's only one codebase with one set of conventions.

This is intentionally a *small* example. A multi-subsystem project (e.g. a native background service plus a web frontend plus an API) would additionally get nested `<subsystem>/AGENTS.md` files — see the main [README](../../README.md) for when those get generated.

```
sample-output/
├── AGENTS.md
├── CLAUDE.md      # thin @AGENTS.md import — generated because Claude Code was a target agent
└── docs/
    ├── decisions.md
    ├── roadmap.md
    └── product.md
```

`CLAUDE.md` here is a single line: `@AGENTS.md`. That's the whole file, and it's complete as-is — there was nothing Claude-Code-specific to add on top. It exists because Claude Code's context loading is CLAUDE.md-centric and won't reliably read a bare AGENTS.md without an opt-in setting, so the import is what makes the docs load. AGENTS.md stays the single source of truth. In a monorepo, each nested `<subsystem>/AGENTS.md` gets the same one-line companion beside it.

Note there's no `docs/architecture.md` or `docs/design-system.md` in this example — the skill didn't generate them because a small single-repo CRUD app didn't have enough architectural complexity or UI-specific design conventions to warrant a dedicated doc. That's the "only what's warranted" behavior working as intended, not an omission.
