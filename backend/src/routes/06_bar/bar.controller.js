import * as barService from './bar.service.js';

// Bar
export const createBar = async (req, res) => {
  try {
    const bar = await barService.createBar(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: bar });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getBar = async (req, res) => {
  try {
    const bar = await barService.getBar(req.user.organizationId);
    return res.json({ success: true, data: bar });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

// Counters
export const getAllCounters = async (req, res) => {
  try {
    const { bar_id } = req.query;
    const counters = await barService.getAllCounters(req.user.organizationId, bar_id);
    return res.json({ success: true, data: counters });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getCountersByStatus = async (req, res) => {
  try {
    const { status } = req.params;
    const counters = await barService.getCountersByStatus(req.user.organizationId, status);
    return res.json({ success: true, data: counters });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const createCounter = async (req, res) => {
  try {
    const counter = await barService.createCounter(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: counter });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const updateCounterStatus = async (req, res) => {
  try {
    const { counterId } = req.params;
    const { status } = req.body;
    await barService.updateCounterStatus(counterId, status);
    return res.json({ success: true, message: 'Counter status updated' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Drinks
export const getAllDrinks = async (req, res) => {
  try {
    const { bar_id } = req.query;
    const drinks = await barService.getAllDrinks(req.user.organizationId, bar_id);
    return res.json({ success: true, data: drinks });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getDrinksByCategory = async (req, res) => {
  try {
    const { bar_id, category } = req.query;
    const drinks = await barService.getDrinksByCategory(req.user.organizationId, bar_id, category);
    return res.json({ success: true, data: drinks });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const createDrink = async (req, res) => {
  try {
    const drink = await barService.createDrink(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: drink });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const updateDrink = async (req, res) => {
  try {
    const { drinkId } = req.params;
    const drink = await barService.updateDrink(drinkId, req.body);
    return res.json({ success: true, data: drink });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Bar Orders
export const createBarOrder = async (req, res) => {
  try {
    const order = await barService.createBarOrder(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: order });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getOpenOrders = async (req, res) => {
  try {
    const orders = await barService.getOpenOrders(req.user.organizationId);
    return res.json({ success: true, data: orders, count: orders.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getBarOrderById = async (req, res) => {
  try {
    const { orderId } = req.params;
    const order = await barService.getBarOrderById(orderId);
    if (!order) return res.status(404).json({ success: false, error: 'Order not found' });
    return res.json({ success: true, data: order });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const updateBarOrderStatus = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status } = req.body;
    await barService.updateBarOrderStatus(orderId, status);
    return res.json({ success: true, message: 'Order status updated' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const addDrinkToOrder = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { drink_id, quantity, special_instructions } = req.body;
    const item = await barService.addDrinkToOrder(orderId, drink_id, quantity, special_instructions);
    return res.status(201).json({ success: true, data: item });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const removeDrinkFromOrder = async (req, res) => {
  try {
    const { orderItemId } = req.params;
    await barService.removeDrinkFromOrder(orderItemId);
    return res.json({ success: true, message: 'Drink removed from order' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Inventory
export const getInventory = async (req, res) => {
  try {
    const { bar_id } = req.query;
    const inventory = await barService.getInventory(req.user.organizationId, bar_id);
    return res.json({ success: true, data: inventory });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getLowStockItems = async (req, res) => {
  try {
    const { bar_id } = req.query;
    const items = await barService.getLowStockItems(req.user.organizationId, bar_id);
    return res.json({ success: true, data: items });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const updateInventory = async (req, res) => {
  try {
    const { inventoryId } = req.params;
    const { quantity } = req.body;
    const inventory = await barService.updateInventory(inventoryId, quantity);
    return res.json({ success: true, data: inventory });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Stats
export const getBarStats = async (req, res) => {
  try {
    const stats = await barService.getBarStats(req.user.organizationId);
    return res.json({ success: true, data: stats });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export default {
  createBar, getBar,
  getAllCounters, getCountersByStatus, createCounter, updateCounterStatus,
  getAllDrinks, getDrinksByCategory, createDrink, updateDrink,
  createBarOrder, getOpenOrders, getBarOrderById, updateBarOrderStatus, addDrinkToOrder, removeDrinkFromOrder,
  getInventory, getLowStockItems, updateInventory,
  getBarStats,
};
