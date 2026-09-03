# Product rules

- An order has an `id`, a `customer`, a `pickupDate` (YYYY-MM-DD), and a `status` of
  `waiting` or `done`.
- An order may be marked done **on or after** its pickup date. An order whose pickup date is
  today is collectable — "not before the pickup date" includes the date itself.
- An order already `done` cannot be marked done again.
- The pickup queue shows waiting orders only, oldest pickup date first.
