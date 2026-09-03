export function createOrder({ id, customer, pickupDate }) {
  return { id, customer, pickupDate, status: 'waiting' };
}

export function markOrderDone(order, today) {
  if (order.status === 'done') {
    throw new Error(`order ${order.id} is already done`);
  }
  if (today < order.pickupDate) {
    throw new Error(`order ${order.id} cannot be collected before ${order.pickupDate}`);
  }
  return { ...order, status: 'done' };
}
