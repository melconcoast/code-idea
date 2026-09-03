# Pickup Queue Plan
Status: In Progress | Last Updated: 2026-08-28 | Overall Progress: [1/2 Phases Closed]

## Progress Log
- 2026-08-26: Plan initialized via plan-module skill.
- 2026-08-28: Phase 1 closed. The order store holds orders in memory and reads them back by id; duplicate ids are refused.

## Files Modified
- `src/store.js`
- `test/store.test.js`

---

## Phase 1: Order store
- Status: [x] Done
- Dependencies: None
- Progress: [2/2 Tasks Closed]

### Tasks & Test Scenarios
- [x] **Task 1.1: In-memory order store**
  - *Details:* Add `src/store.js` exporting `createStore()`, with `add(order)`, `get(id)` and `all()`. `add` refuses an id already present. `get` returns `null` for an unknown id.
  - [x] *Scenario 1.1a:* An order that has been added can be read back by its id.
  - [x] *Scenario 1.1b:* Adding a second order with an id already in the store is refused.

### Phase Completion Gate
- [x] **Task 1.V: Run test-and-verify suite for Phase 1**
  - *Details:* Execute the tests covering Phase 1, confirm zero failures, then mark Phase 1 complete.

---

## Phase 2: Queue page
- Status: [ ] Open
- Dependencies: Phase 1
- Progress: [0/4 Tasks Closed]

### Tasks & Test Scenarios
- [ ] **Task 2.1: Waiting-orders query**
  - *Details:* Add `waitingOrders(store)` to `src/store.js`. It returns only the orders whose `status` is `waiting`, sorted by `pickupDate` ascending, oldest first, with ties broken by `id` ascending. No new file.
  - [ ] *Scenario 2.1a:* A store holding a mix of waiting and done orders returns only the waiting ones.
  - [ ] *Scenario 2.1b:* Two waiting orders with different pickup dates come back oldest first.
  - [ ] *Scenario 2.1c:* An empty store returns an empty list rather than raising.

- [ ] **Task 2.2: Queue page view**
  - *Details:* Add `src/views/queue.js` exporting `renderQueuePage(orders)`, which returns a complete HTML document as a string for the screen behind the counter. It shows a heading, how many orders are waiting, and one entry per order carrying that order's customer, pickup date and id. It links `public/styles.css`.
  - [ ] *Scenario 2.2a:* A page rendered from three waiting orders shows all three customers and all three pickup dates.
  - [ ] *Scenario 2.2b:* A page rendered from an empty list still renders, and says nothing is waiting rather than showing an empty list.
  - [ ] *Scenario 2.2c:* A customer name containing `<` or `&` appears on the page as text, not as markup.

- [ ] **Task 2.3: Queue route**
  - *Details:* Add `src/server.js` exporting `createServer(store)` built on `node:http`. `GET /queue` responds 200 with the rendered page and `Content-Type: text/html; charset=utf-8`. `GET /styles.css` responds 200 with the contents of `public/styles.css` and `Content-Type: text/css`. Any other path responds 404 with a plain-text body.
  - [ ] *Scenario 2.3a:* A GET to `/queue` returns 200 and a body containing the waiting orders' customer names.
  - [ ] *Scenario 2.3b:* A GET to an unknown path returns 404.

### Phase Completion Gate
- [ ] **Task 2.V: Run test-and-verify suite for Phase 2**
  - *Details:* Execute the tests covering Phase 2, confirm zero failures, then mark Phase 2 complete.
