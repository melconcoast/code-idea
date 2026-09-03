export function createStore() {
  const orders = new Map();
  return {
    add(order) {
      if (orders.has(order.id)) {
        throw new Error(`order ${order.id} already exists`);
      }
      orders.set(order.id, order);
      return order;
    },
    get(id) {
      return orders.get(id) ?? null;
    },
    all() {
      return [...orders.values()];
    },
  };
}
