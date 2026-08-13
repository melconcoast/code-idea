# Decisions log

*Append-only. Add a new dated entry; never edit or delete a past one. To reverse a decision, add an entry that supersedes it.*

## 2026-08-01 — Postgres over a document store
**Decision:** Use Postgres as the only database.
**Rationale:** Tasks, users, and assignments are relational with clear foreign keys — a document store would just mean reimplementing referential integrity in application code.
**Status:** Accepted

## 2026-08-01 — No GraphQL
**Decision:** Plain REST over GraphQL for the API.
**Rationale:** Small, fixed set of screens with predictable data needs — GraphQL's flexibility isn't paying for its added complexity here.
**Status:** Accepted

## 2026-08-12 — Email provider for assignment notifications
**Decision:** Deferred. Not yet decided.
**Options on the table:** SES, SendGrid, or Postmark for outbound mail; also whether to send
transactional email directly from the API process or hand it off to a queue/worker.
**Why deferred:** Doesn't block the first slice of work — assignment and status tracking already work
end-to-end against the console-logging stub.
**Meanwhile:** Keep using the `logNotification()` stub in `/server/notifications`; do not add a real
email dependency or provider credentials.
**Status:** Pending
