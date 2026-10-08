# Recommendation heuristics

Starting points for the "recommend, then let the user confirm or override" pattern used in Step 2. These are heuristics to reason from, not a lookup table to apply blindly — always ground the actual recommendation in the specific project's data shape, scale, and domain, and prefer a web-search tool (if available) to confirm a specific technology/version recommendation is still current before offering it as the default, since this space moves fast and this file will age.

If a more specialized skill for a sub-domain is available, prefer its guidance over the heuristics below — this file is the fallback for when nothing more specific exists.

## Tech stack
- Don't recommend a stack in the abstract — recommend it against what the project actually needs to do. A real-time job queue, a content site, and a data pipeline warrant different stacks even if they're all "a web app."
- If the user already has a stated preference or existing codebase language/framework, follow it — don't relitigate a settled choice.
- When genuinely greenfield and the user has no opinion, favor boring, well-supported, widely-documented choices over novel ones — an AI coding agent (and future maintainers) will have an easier time with something well-represented in training data and documentation than with a niche framework, all else equal.

## Database
- Relational, transactional data with clear entities and relationships (users, orders, payments, any kind of ledger/balance) → a relational database (e.g. Postgres) by default. This covers the large majority of product backends.
- Justify a NoSQL/document store specifically — schema genuinely unknown or wildly variable per record, or extreme write-throughput on unstructured data — rather than defaulting to it for "flexibility." Flexibility often just becomes unenforced data integrity later.
- Full-text search needs: try the relational database's built-in full-text search first; only reach for a dedicated search engine (e.g. Elasticsearch/Meilisearch) once the built-in option demonstrably can't keep up — it's a real operational cost to run and maintain a second system.

## Caching / real-time / ephemeral state
- Session state, rate limiting, short-lived job/queue state, pub-sub between services, or anything that's explicitly disposable and speed-sensitive → an in-memory store (e.g. Redis) is the standard default. Don't put this kind of data in the primary relational database just because it's already there — it pollutes the durable dataset with ephemeral rows and adds write pressure the primary DB doesn't need.
- If the project has a real-time push requirement (live status updates, notifications, multi-client sync), that's a signal for a pub-sub layer (Redis pub/sub, or a managed equivalent) sitting behind a WebSocket/SSE connection — not polling, if avoidable.
- Don't recommend a caching layer at all for a low-traffic, mostly-static project — it's operational overhead with no payoff until there's actual load to justify it.

## File/blob storage
- Anything larger than a database row (uploads, generated documents, images) → object storage (S3-compatible), not the database. If there's a privacy/ephemerality requirement (files that must not persist), pair this with an explicit lifecycle/TTL policy and application-level delete-on-completion, not just "we'll clean it up later."

## UI design
Not this file's job any more. How a product looks — typography, palette, layout, density — is settled
by `design-ui` after the scaffold, against mockups the user has seen; its
`references/visual-direction.md` holds the guidance that used to live here. This skill still
recommends the UI *framework* and component approach under Tech stack, because that's a stack choice.

## Naming conventions

Recommend, don't ask — same pattern as the rest of this file. A user without strong opinions should
get a defensible default, not a blank prompt.

- **Database tables/columns:** plural snake_case tables, singular snake_case columns
  (`cake_orders.customer_id`). Exception: follow the ORM's convention when it's opinionated enough
  that fighting it costs more than it's worth.
- **API routes:** plural nouns, no verbs (`/orders`, `/orders/{id}/items`). Verbs go in the method.
  Exception: genuinely non-CRUD actions read better as `/orders/{id}/cancel` than as a PATCH with a
  magic field.
- **Files:** match the ecosystem rather than imposing one — kebab-case in JS/TS, snake_case in
  Python and Go, PascalCase for component files in React codebases that already do that.
- **Booleans:** `is_`/`has_`/`can_` prefix. Ambiguous names like `status` on a two-state field cause
  real bugs when an agent guesses the polarity. Exception: match the existing convention when a codebase already has one — consistency beats the prefix.

Only write these into `docs/conventions.md` when they go beyond what a linter or formatter already
enforces — a rule the tooling checks doesn't need restating to an agent.
