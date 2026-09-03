# Development Roadmap

*One block per module, sub-modules nested under it, in dependency order. A module or sub-module that's dropped keeps its block and becomes `Status: dropped` with a one-line reason — never deleted and never demoted into Deferred, or every `Depends on:` pointing at it dangles.*

## Module 1 — Order core
**Status:** done
**Depends on:** none

### Sub-Module 1.1 — Order record and transitions
**Status:** done
**In scope:** the order record, and the rules for moving one to `done`.
**Out of scope:** persistence, HTTP, anything a customer sees — all in Module 2.
**Tasks:** not yet planned

## Module 2 — Pickup queue
**Status:** in progress
**Depends on:** Module 1

### Sub-Module 2.1 — Order store
**Status:** done
**In scope:** holding orders in memory and reading them back by id.
**Out of scope:** durable storage across restarts — deferred.
**Tasks:** see docs/guides/feature_pickup_queue_plan.md — Phase 1

### Sub-Module 2.2 — Queue page
**Status:** planned
**In scope:** listing the waiting orders and rendering that list as a page staff can read at the counter.
**Out of scope:** editing an order from the page; notifying the customer, which is Module 3.
**Tasks:** see docs/guides/feature_pickup_queue_plan.md — Phase 2

## Module 3 — Notifications
**Status:** planned
**Depends on:** Module 2

### Sub-Module 3.1 — Ready-for-pickup message
**Status:** planned
**In scope:** telling a customer their order is ready.
**Out of scope:** everything in Module 2.
**Tasks:** not yet planned

## Deferred (explicitly out of scope for now)
- Durable storage. The counter screen is rebuilt each morning, so an in-memory store is enough until there is more than one till.

## Open questions
- None currently.
