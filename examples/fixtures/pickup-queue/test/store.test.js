import test from 'node:test';
import assert from 'node:assert/strict';
import { createStore } from '../src/store.js';
import { createOrder } from '../src/orders.js';

test('an added order can be read back by id', () => {
  const store = createStore();
  const order = createOrder({ id: 'b1', customer: 'Ines', pickupDate: '2026-03-04' });
  store.add(order);
  assert.deepEqual(store.get('b1'), order);
});

test('adding a duplicate id is refused', () => {
  const store = createStore();
  store.add(createOrder({ id: 'b2', customer: 'Ola', pickupDate: '2026-03-04' }));
  assert.throws(
    () => store.add(createOrder({ id: 'b2', customer: 'Bo', pickupDate: '2026-03-05' })),
    /already exists/,
  );
});
