# Assignment Plan
Status: In Progress | Last Updated: 2026-08-20 | Overall Progress: [1/2 Phases Closed]

## Progress Log
- 2026-08-14: Plan initialized via plan-module skill. Cut from `Module 3 — Assignment`; Phase 2 gated by the pending email-provider decision in `docs/decisions.md`.
- 2026-08-18: Task 1.2 reframed — admin override was specified as a separate endpoint, folded into the existing status route instead.
- 2026-08-20: Phase 1 closed. All scenarios passing, type-checks clean.

## Files Modified
- `server/db/migrations/0007_add_task_assignee.sql`
- `server/db/queries/tasks.js`
- `server/routes/tasks.js`
- `web/src/components/AssigneePicker.jsx`
- `server/routes/__tests__/tasks.assignment.test.js`

---

## Phase 1: Assign a task
- Status: [x] Done
- Dependencies: None
- Progress: [4/4 Tasks Closed]

### Tasks & Test Scenarios
- [x] **Task 1.1: Add an assignee to the task record**
  - *Details:* Add a nullable `assignee_id` column on `tasks`, referencing the workspace member. Map it to `assigneeId` in the query layer, not per route.
  - [x] *Scenario 1.1a:* A task created without an assignee reads back with a null assignee rather than erroring.
  - [x] *Scenario 1.1b:* After migrating, every pre-existing task still loads, with a null assignee.

- [x] **Task 1.2: Accept an assignment on the task update route**
  - *Details:* Extend the existing task update route to accept an assignee. Exactly one assignee per task.
  - [x] *Scenario 1.2a:* Assigning an unassigned task to a workspace member sets that member as the assignee and returns the updated task.
  - [x] *Scenario 1.2b:* Assigning a task to a user who is not a member of the workspace is rejected, the task keeps its previous assignee, and nothing is written.
  - [x] *Scenario 1.2c:* Sending two assignees in one request is rejected before any write.

- [~] **Task 1.3: Restrict status changes to the assignee or a workspace admin** (reframed: specified as a separate admin-override endpoint, folded into the existing status route instead — one authorization check rather than two)
  - *Details:* Enforce on the status route that the caller is either the task's assignee or a workspace admin.
  - [x] *Scenario 1.3a:* The assignee moves their own task from `todo` to `in_progress` and the change is accepted.
  - [x] *Scenario 1.3b:* A workspace member who is neither the assignee nor an admin is refused, and the task's status is unchanged.
  - [x] *Scenario 1.3c:* A workspace admin changes the status of a task assigned to someone else, and the change is accepted.

### Phase Completion Gate
- [x] **Task 1.V: Run test-and-verify suite for Phase 1**
  - *Details:* Execute the tests covering Phase 1, confirm zero failures, confirm type-checks pass, then mark Phase 1 complete.

---

## Phase 2: Assignment notifications
- Status: [ ] Open
- Dependencies: Phase 1
- Progress: [1/4 Tasks Closed]

*Blocked on the email-provider decision in `docs/decisions.md` (`Status: Pending`). Tasks 2.2 and 2.3 cannot close until it is made; 2.1 is provider-independent and can proceed.*

### Tasks & Test Scenarios
- [ ] **Task 2.1: Emit a notification event when an assignee changes**
  - *Details:* On a successful assignment, call the existing `logNotification()` stub in `server/notifications` with the recipient and the task. No provider wiring — that is the parked decision.
  - [ ] *Scenario 2.1a:* Assigning a task to a member produces exactly one notification event naming that member and that task.
  - [ ] *Scenario 2.1b:* Re-saving a task without changing its assignee produces no notification event.
  - [ ] *Scenario 2.1c:* A rejected assignment produces no notification event.

- [ ] **Task 2.2: Deliver the notification by email**
  - *Details:* Replace the `logNotification()` stub with real delivery. **Blocked** — the provider is undecided; do not select one here.
  - [ ] *Scenario 2.2a:* An assigned member receives one message naming the task and who assigned it.
  - [ ] *Scenario 2.2b:* A delivery failure is recorded and does not roll back the assignment itself.

- [-] **Task 2.3: Per-user notification preferences** (skipped: `Out of scope` on Sub-Module 3.2 in the roadmap — recorded here so the omission is deliberate, not forgotten)
  - *Details:* Not being built in this module.

### Phase Completion Gate
- [ ] **Task 2.V: Run test-and-verify suite for Phase 2**
  - *Details:* Execute the tests covering Phase 2, confirm zero failures, then mark Phase 2 complete.
