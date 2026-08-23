# Finding and scoping the test command

Read this in Step 1 when the caller didn't supply a command.

**This file is expected to age.** Runners, flags, and defaults shift. A command you read out of the
project beats one you read out of this table, every time — the table is a fallback for when the
project doesn't say, not an override for when it does.

## Discovery order

Stop at the first real answer:

1. **The root context file's `## Commands` section** — `CLAUDE.md` or `AGENTS.md`. In this plugin's
   chain, `execute-plan` records the command there once it sets a runner up. It is the intended answer.
2. **The project manifest** — `package.json` scripts, `pyproject.toml`, `Makefile`, `Cargo.toml`,
   `go.mod`, `build.gradle`. A `test` script here is the project's own answer.
3. **A CI workflow** — `.github/workflows/*`, or whatever the project uses. What CI runs is what the
   project actually considers a pass, whatever the docs claim.
4. **An existing test directory.** If tests exist, something runs them. Infer from the file naming and
   imports before inventing anything.

If none of these answer, say so and hand back. Standing a test runner up is a project decision — it
picks tooling, edits a manifest, and belongs to `execute-plan`, not to a verification pass.

## Running a subset versus the whole suite

**Default to the tests covering the work at hand.** Most runners take a path or a name filter:

| Ecosystem | Whole suite | Targeted |
|---|---|---|
| npm / pnpm / yarn | `npm test` | `npm test -- <path>`, or the runner directly |
| Node built-in | `node --test` | `node --test <path>` |
| Vitest / Jest | `npx vitest run` / `npx jest` | add a path, or `-t "<name>"` |
| pytest | `pytest` | `pytest <path>`, `pytest -k "<expr>"` |
| Go | `go test ./...` | `go test ./pkg/...`, `-run <regex>` |
| Cargo | `cargo test` | `cargo test <name>` |

Two cautions that cost real time:

- **`npm test -- <path>` only forwards correctly if the script passes arguments through.** When a
  `test` script is a chain (`lint && jest`), the path lands on the wrong command. Invoke the runner
  directly instead.
- **A filter that matches nothing usually exits 0.** "No tests found" is not a pass. Always check the
  reported count against what you expected to run.

## What a phase gate adds

A `Task X.V` gate runs the **whole** module's suite — a targeted run cannot see what this phase broke
elsewhere, which is the only reason the gate exists. On top of that, run whichever of these the
project actually has:

| Check | Typical command |
|---|---|
| Type-check | `tsc --noEmit`, `mypy`, `go vet`, `cargo check` |
| Lint | `eslint .`, `ruff check`, `golangci-lint run`, `cargo clippy` |

Look for these the same way you looked for the test command — the manifest's scripts and the CI
workflow, not assumption. **If the project has no type-checker or no linter, say so in the report.**
Silence reads as "it passed", and a gate that reports a check it never ran is worse than one that
admits the gap.
