# Conventions

These are binding. Where this file is silent, match the surrounding code.

## Code
- ES modules, `.js`, no TypeScript, no transpiler, no build step.
- No runtime dependencies. Node's standard library only.
- Tests use `node:test` and `node:assert/strict`, one file per source module.

## UI
- **Server-rendered HTML strings** from plain template functions in `src/views/`. No client-side
  framework, no JSX, no hydration.
- **No CSS frameworks.** Not Tailwind, not Bootstrap, not a component library. Plain CSS lives in
  `public/styles.css`.
- **Use only the custom properties already defined in `public/styles.css`** — `--ink`, `--paper`,
  `--accent`. Do not introduce new colors, and do not hardcode hex values in markup.
- **Semantic elements.** `<ol>`, `<li>`, `<time>`, `<button>`. Markup built out of `<div>` alone is
  rejected in review.
