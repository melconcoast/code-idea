# Development Roadmap

*One block per module, sub-modules nested under it, in dependency order. A module or sub-module that's dropped keeps its block and becomes `Status: dropped` with a one-line reason — never deleted and never demoted into Deferred, or every `Depends on:` pointing at it dangles.*

## Module 1 — Task core
**Status:** done
**Depends on:** none

### Sub-Module 1.1 — Task CRUD
**Status:** done
**In scope:** create, edit, and delete tasks; title, description, and due date
**Out of scope:** recurring tasks — see Deferred
**Tasks:** not yet planned

### Sub-Module 1.2 — Status machine
**Status:** done
**In scope:** the `todo -> in_progress -> done` transition rules, enforced server-side
**Out of scope:** custom per-workspace status names
**Tasks:** not yet planned

## Module 2 — Workspace and membership
**Status:** done
**Depends on:** Module 1

### Sub-Module 2.1 — Single-team workspace
**Status:** done
**In scope:** one workspace, its member list, and the admin role that can override task status
**Out of scope:** multi-workspace support and tenant isolation — see Deferred
**Tasks:** not yet planned

## Module 3 — Assignment
**Status:** in progress
**Depends on:** Module 2

### Sub-Module 3.1 — Assign a task
**Status:** done
**In scope:** exactly one assignee per task; only the assignee or a workspace admin may change status
**Out of scope:** multi-assignee tasks; reassignment history
**Tasks:** see `docs/guides/feature_assignment_plan.md` — Phase 1

### Sub-Module 3.2 — Assignment notifications
**Status:** blocked
**Depends on:** 3.1, plus the pending email-provider decision in `docs/decisions.md`
**In scope:** notify the new assignee by email when a task is assigned to them
**Out of scope:** digests, in-app notifications, per-user notification preferences
**Tasks:** see `docs/guides/feature_assignment_plan.md` — Phase 2

## Deferred (explicitly out of scope for now)
- Multi-workspace/team support — the data model isn't designed for tenant isolation yet, don't build features assuming it
- Recurring tasks — no demand from the pilot team yet
- Mobile app — web-only for now

## Open questions
- Whether task comments are needed for v1 or can wait
