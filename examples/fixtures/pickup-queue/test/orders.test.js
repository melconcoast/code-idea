import test from 'node:test';
import assert from 'node:assert/strict';
import { createOrder, markOrderDone } from '../src/orders.js';

test('an order on its pickup date can be marked done', () => {
  const order = createOrder({ id: 'a1', customer: 'Ines', pickupDate: '2026-03-04' });
  assert.equal(markOrderDone(order, '2026-03-04').status, 'done');
});

test('an order before its pickup date is refused', () => {
  const order = createOrder({ id: 'a2', customer: 'Ola', pickupDate: '2026-03-04' });
  assert.throws(() => markOrderDone(order, '2026-03-03'), /before 2026-03-04/);
});

test('an order already done cannot be marked done again', () => {
  const order = { id: 'a3', customer: 'Bo', pickupDate: '2026-03-01', status: 'done' };
  assert.throws(() => markOrderDone(order, '2026-03-04'), /already done/);
});
