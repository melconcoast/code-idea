# Decisions log

Append-only. Each entry is dated and never rewritten — if a decision is later superseded, add a new entry noting that, don't edit the old one.

## 2026-08-01 — Postgres over a document store
**Decision:** Use Postgres as the only database.
**Rationale:** Tasks, users, and assignments are relational with clear foreign keys — a document store would just mean reimplementing referential integrity in application code.
**Status:** Accepted

## 2026-08-01 — No GraphQL
**Decision:** Plain REST over GraphQL for the API.
**Rationale:** Small, fixed set of screens with predictable data needs — GraphQL's flexibility isn't paying for its added complexity here.
**Status:** Accepted
