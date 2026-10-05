import Restaurant from '../../models/Restaurant.js';
import Table from '../../models/Table.js';
import MenuItem from '../../models/MenuItem.js';
import Order from '../../models/Order.js';
import OrderItem from '../../models/OrderItem.js';
import KOT from '../../models/KOT.js';
import { Op } from 'sequelize';

// Restaurant
export const createRestaurant = async (orgId, data) => {
  return await Restaurant.create({ organization_id: orgId, ...data });
};

export const getRestaurant = async (orgId) => {
  return await Restaurant.findOne({ where: { organization_id: orgId } });
};

// Tables
export const getAllTables = async (orgId, restaurantId) => {
  return await Table.findAll({
    where: { organization_id: orgId, restaurant_id: restaurantId },
  });
};

export const getTablesByStatus = async (orgId, status) => {
  return await Table.findAll({
    where: { organization_id: orgId, status },
  });
};

export const createTable = async (orgId, data) => {
  return await Table.create({ organization_id: orgId, ...data });
};

export const updateTableStatus = async (tableId, status) => {
  return await Table.update({ status }, { where: { id: tableId } });
};

// Menu Items
export const getAllMenuItems = async (orgId, restaurantId) => {
  return await MenuItem.findAll({
    where: { organization_id: orgId, restaurant_id: restaurantId },
  });
};

export const getMenuByCategory = async (orgId, restaurantId, category) => {
  return await MenuItem.findAll({
    where: { organization_id: orgId, restaurant_id: restaurantId, category },
  });
};

export const createMenuItem = async (orgId, data) => {
  return await MenuItem.create({ organization_id: orgId, ...data });
};

export const updateMenuItem = async (itemId, data) => {
  return await MenuItem.update(data, { where: { id: itemId } });
};

// Orders
export const createOrder = async (orgId, data) => {
  const orderId = require('uuid').v4();
  const orderNumber = `ORD-${Date.now()}`;
  
  return await Order.create({
    organization_id: orgId,
    order_number: orderNumber,
    ...data,
  });
};

export const getActiveOrders = async (orgId) => {
  return await Order.findAll({
    where: { 
      organization_id: orgId,
      status: { [Op.in]: ['pending', 'confirmed', 'preparing', 'ready'] }
    },
    include: [
      { model: Table },
      { model: OrderItem, include: [MenuItem] }
    ],
    order: [['created_at', 'DESC']],
  });
};

export const getOrderById = async (orderId) => {
  return await Order.findByPk(orderId, {
    include: [
      { model: Table },
      { model: OrderItem, include: [MenuItem] }
    ],
  });
};

export const updateOrderStatus = async (orderId, status) => {
  return await Order.update({ status }, { where: { id: orderId } });
};

export const addItemToOrder = async (orderId, menuItemId, quantity, instructions) => {
  const menuItem = await MenuItem.findByPk(menuItemId);
  const order = await Order.findByPk(orderId);
  
  const orderItem = await OrderItem.create({
    order_id: orderId,
    menu_item_id: menuItemId,
    quantity,
    unit_price: menuItem.price,
    special_instructions: instructions,
  });

  // Update order totals
  const items = await OrderItem.findAll({ where: { order_id: orderId } });
  const subtotal = items.reduce((sum, item) => sum + (item.unit_price * item.quantity), 0);
  const restaurant = await Restaurant.findByPk(order.restaurant_id);
  const tax = (subtotal * restaurant.tax_rate) / 100;
  const serviceCharge = (subtotal * restaurant.service_charge_rate) / 100;
  const total = subtotal + tax + serviceCharge;

  await Order.update({
    subtotal,
    tax_amount: tax,
    service_charge: serviceCharge,
    total_amount: total,
  }, { where: { id: orderId } });

  return orderItem;
};

export const removeItemFromOrder = async (orderItemId) => {
  const orderItem = await OrderItem.findByPk(orderItemId);
  const orderId = orderItem.order_id;
  
  await orderItem.destroy();

  // Recalculate totals
  const items = await OrderItem.findAll({ where: { order_id: orderId } });
  const order = await Order.findByPk(orderId);
  const restaurant = await Restaurant.findByPk(order.restaurant_id);
  
  const subtotal = items.reduce((sum, item) => sum + (item.unit_price * item.quantity), 0);
  const tax = (subtotal * restaurant.tax_rate) / 100;
  const serviceCharge = (subtotal * restaurant.service_charge_rate) / 100;
  const total = subtotal + tax + serviceCharge;

  await Order.update({
    subtotal,
    tax_amount: tax,
    service_charge: serviceCharge,
    total_amount: total,
  }, { where: { id: orderId } });

  return true;
};

// KOT - Kitchen Order Ticket
export const generateKOT = async (orgId, orderId) => {
  const kotNumber = `KOT-${Date.now()}`;
  const order = await Order.findByPk(orderId);
  const items = await OrderItem.findAll({ where: { order_id: orderId } });

  const kot = await KOT.create({
    organization_id: orgId,
    order_id: orderId,
    kot_number: kotNumber,
    items_count: items.length,
  });

  return kot;
};

export const getPendingKOTs = async (orgId) => {
  return await KOT.findAll({
    where: { 
      organization_id: orgId,
      status: { [Op.in]: ['sent', 'acknowledged', 'preparing'] }
    },
    include: [
      { model: Order, include: [{ model: OrderItem, include: [MenuItem] }] }
    ],
    order: [['sent_at', 'ASC']],
  });
};

export const updateKOTStatus = async (kotId, status) => {
  const updates = { status };
  if (status === 'acknowledged') updates.acknowledged_at = new Date();
  if (status === 'ready') updates.ready_at = new Date();
  
  return await KOT.update(updates, { where: { id: kotId } });
};

// Summary Stats
export const getRestaurantStats = async (orgId) => {
  const totalTables = await Table.count({ where: { organization_id: orgId } });
  const occupiedTables = await Table.count({ where: { organization_id: orgId, status: 'occupied' } });
  const totalOrders = await Order.count({ where: { organization_id: orgId } });
  
  const todayOrders = await Order.findAll({
    where: {
      organization_id: orgId,
      created_at: {
        [Op.gte]: new Date(new Date().setHours(0, 0, 0, 0)),
      },
    },
  });

  const todayRevenue = todayOrders.reduce((sum, order) => sum + (order.total_amount || 0), 0);

  return {
    totalTables,
    occupiedTables,
    availableTables: totalTables - occupiedTables,
    totalOrders,
    todayOrders: todayOrders.length,
    todayRevenue,
  };
};

export default {
  createRestaurant, getRestaurant,
  getAllTables, getTablesByStatus, createTable, updateTableStatus,
  getAllMenuItems, getMenuByCategory, createMenuItem, updateMenuItem,
  createOrder, getActiveOrders, getOrderById, updateOrderStatus, addItemToOrder, removeItemFromOrder,
  generateKOT, getPendingKOTs, updateKOTStatus,
  getRestaurantStats,
};
