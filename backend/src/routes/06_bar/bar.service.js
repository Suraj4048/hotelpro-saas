import Bar from '../../models/Bar.js';
import BarCounter from '../../models/BarCounter.js';
import Drink from '../../models/Drink.js';
import BarOrder from '../../models/BarOrder.js';
import BarOrderItem from '../../models/BarOrderItem.js';
import BarInventory from '../../models/BarInventory.js';
import { Op } from 'sequelize';

// Bar
export const createBar = async (orgId, data) => {
  return await Bar.create({ organization_id: orgId, ...data });
};

export const getBar = async (orgId) => {
  return await Bar.findOne({ where: { organization_id: orgId } });
};

// Bar Counters
export const getAllCounters = async (orgId, barId) => {
  return await BarCounter.findAll({
    where: { organization_id: orgId, bar_id: barId },
  });
};

export const getCountersByStatus = async (orgId, status) => {
  return await BarCounter.findAll({
    where: { organization_id: orgId, status },
  });
};

export const createCounter = async (orgId, data) => {
  return await BarCounter.create({ organization_id: orgId, ...data });
};

export const updateCounterStatus = async (counterId, status) => {
  return await BarCounter.update({ status }, { where: { id: counterId } });
};

// Drinks
export const getAllDrinks = async (orgId, barId) => {
  return await Drink.findAll({
    where: { organization_id: orgId, bar_id: barId, is_available: true },
    order: [['popularity_rank', 'ASC']],
  });
};

export const getDrinksByCategory = async (orgId, barId, category) => {
  return await Drink.findAll({
    where: { organization_id: orgId, bar_id: barId, category, is_available: true },
  });
};

export const createDrink = async (orgId, data) => {
  return await Drink.create({ organization_id: orgId, ...data });
};

export const updateDrink = async (drinkId, data) => {
  return await Drink.update(data, { where: { id: drinkId } });
};

// Bar Orders
export const createBarOrder = async (orgId, data) => {
  const orderNumber = `BAR-${Date.now()}`;
  
  return await BarOrder.create({
    organization_id: orgId,
    order_number: orderNumber,
    ...data,
  });
};

export const getOpenOrders = async (orgId) => {
  return await BarOrder.findAll({
    where: { 
      organization_id: orgId,
      status: { [Op.in]: ['open', 'pending'] }
    },
    include: [
      { model: BarCounter },
      { model: BarOrderItem, include: [Drink] }
    ],
    order: [['created_at', 'DESC']],
  });
};

export const getBarOrderById = async (orderId) => {
  return await BarOrder.findByPk(orderId, {
    include: [
      { model: BarCounter },
      { model: BarOrderItem, include: [Drink] }
    ],
  });
};

export const updateBarOrderStatus = async (orderId, status) => {
  return await BarOrder.update({ status }, { where: { id: orderId } });
};

export const addDrinkToOrder = async (orderId, drinkId, quantity, instructions) => {
  const drink = await Drink.findByPk(drinkId);
  const order = await BarOrder.findByPk(orderId);
  
  const orderItem = await BarOrderItem.create({
    bar_order_id: orderId,
    drink_id: drinkId,
    quantity,
    unit_price: drink.price,
    special_instructions: instructions,
  });

  // Update order totals
  const items = await BarOrderItem.findAll({ where: { bar_order_id: orderId } });
  const subtotal = items.reduce((sum, item) => sum + (item.unit_price * item.quantity), 0);
  const bar = await Bar.findByPk(order.bar_id);
  const tax = (subtotal * bar.tax_rate) / 100;
  const serviceCharge = (subtotal * bar.service_charge_rate) / 100;
  const total = subtotal + tax + serviceCharge;

  await BarOrder.update({
    subtotal,
    tax_amount: tax,
    service_charge: serviceCharge,
    total_amount: total,
  }, { where: { id: orderId } });

  return orderItem;
};

export const removeDrinkFromOrder = async (orderItemId) => {
  const orderItem = await BarOrderItem.findByPk(orderItemId);
  const orderId = orderItem.bar_order_id;
  
  await orderItem.destroy();

  // Recalculate totals
  const items = await BarOrderItem.findAll({ where: { bar_order_id: orderId } });
  const order = await BarOrder.findByPk(orderId);
  const bar = await Bar.findByPk(order.bar_id);
  
  const subtotal = items.reduce((sum, item) => sum + (item.unit_price * item.quantity), 0);
  const tax = (subtotal * bar.tax_rate) / 100;
  const serviceCharge = (subtotal * bar.service_charge_rate) / 100;
  const total = subtotal + tax + serviceCharge;

  await BarOrder.update({
    subtotal,
    tax_amount: tax,
    service_charge: serviceCharge,
    total_amount: total,
  }, { where: { id: orderId } });

  return true;
};

// Inventory
export const getInventory = async (orgId, barId) => {
  return await BarInventory.findAll({
    where: { organization_id: orgId, bar_id: barId },
    include: [Drink],
  });
};

export const getLowStockItems = async (orgId, barId) => {
  return await BarInventory.findAll({
    where: {
      organization_id: orgId,
      bar_id: barId,
      quantity_in_stock: { [Op.lte]: sequelize.col('minimum_level') },
    },
    include: [Drink],
  });
};

export const updateInventory = async (inventoryId, quantity) => {
  const inventory = await BarInventory.findByPk(inventoryId);
  return await inventory.update({ quantity_in_stock: quantity });
};

// Stats
export const getBarStats = async (orgId) => {
  const totalCounters = await BarCounter.count({ where: { organization_id: orgId } });
  const occupiedCounters = await BarCounter.count({ 
    where: { organization_id: orgId, status: 'occupied' } 
  });
  const totalOrders = await BarOrder.count({ where: { organization_id: orgId } });
  
  const todayOrders = await BarOrder.findAll({
    where: {
      organization_id: orgId,
      created_at: {
        [Op.gte]: new Date(new Date().setHours(0, 0, 0, 0)),
      },
    },
  });

  const todayRevenue = todayOrders.reduce((sum, order) => sum + (order.total_amount || 0), 0);

  return {
    totalCounters,
    occupiedCounters,
    availableCounters: totalCounters - occupiedCounters,
    totalOrders,
    todayOrders: todayOrders.length,
    todayRevenue,
  };
};

export default {
  createBar, getBar,
  getAllCounters, getCountersByStatus, createCounter, updateCounterStatus,
  getAllDrinks, getDrinksByCategory, createDrink, updateDrink,
  createBarOrder, getOpenOrders, getBarOrderById, updateBarOrderStatus, addDrinkToOrder, removeDrinkFromOrder,
  getInventory, getLowStockItems, updateInventory,
  getBarStats,
};
