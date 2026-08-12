# TaskFlow

A small team task tracker: create tasks, assign them, track status. Single Node.js/Express API + React frontend, single Postgres database.

## Critical rules (read first)
- Task status transitions are `todo -> in_progress -> done` only — never allow a direct `todo -> done` write; see docs/product.md.
- Never log or persist raw user passwords or session tokens, even at debug level.

## Commands
- Install: `npm install`
- Dev/run: `npm run dev`
- Test: `npm test`
- Lint/format: `npm run lint`

## Code style
- Functional React components only, no class components.
- API responses use camelCase keys; database columns stay snake_case — mapping happens at the query layer, not ad hoc per route.

## Architecture
Express API talks to Postgres directly via a query layer in `/server/db`. React frontend calls the API over REST, no GraphQL. No separate service layer — this project is intentionally small.

## Testing requirements
- New API routes need at least one integration test hitting a real (test) database connection, not a mock.

## Security / boundaries
- `/server/db/migrations` should never be edited after being merged — write a new migration instead.

## Related docs
- `docs/decisions.md` — why non-obvious choices were made
- `docs/roadmap.md` — what's in scope now vs. deferred
- `docs/product.md` — current business/feature rules
