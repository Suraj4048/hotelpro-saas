import * as restaurantService from './restaurant.service.js';

// Restaurant
export const createRestaurant = async (req, res) => {
  try {
    const restaurant = await restaurantService.createRestaurant(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: restaurant });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getRestaurant = async (req, res) => {
  try {
    const restaurant = await restaurantService.getRestaurant(req.user.organizationId);
    return res.json({ success: true, data: restaurant });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

// Tables
export const getAllTables = async (req, res) => {
  try {
    const { restaurant_id } = req.query;
    const tables = await restaurantService.getAllTables(req.user.organizationId, restaurant_id);
    return res.json({ success: true, data: tables });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getTablesByStatus = async (req, res) => {
  try {
    const { status } = req.params;
    const tables = await restaurantService.getTablesByStatus(req.user.organizationId, status);
    return res.json({ success: true, data: tables });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const createTable = async (req, res) => {
  try {
    const table = await restaurantService.createTable(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: table });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const updateTableStatus = async (req, res) => {
  try {
    const { tableId } = req.params;
    const { status } = req.body;
    await restaurantService.updateTableStatus(tableId, status);
    return res.json({ success: true, message: 'Table status updated' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Menu Items
export const getAllMenuItems = async (req, res) => {
  try {
    const { restaurant_id } = req.query;
    const items = await restaurantService.getAllMenuItems(req.user.organizationId, restaurant_id);
    return res.json({ success: true, data: items });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getMenuByCategory = async (req, res) => {
  try {
    const { restaurant_id, category } = req.query;
    const items = await restaurantService.getMenuByCategory(req.user.organizationId, restaurant_id, category);
    return res.json({ success: true, data: items });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const createMenuItem = async (req, res) => {
  try {
    const item = await restaurantService.createMenuItem(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: item });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const updateMenuItem = async (req, res) => {
  try {
    const { itemId } = req.params;
    const item = await restaurantService.updateMenuItem(itemId, req.body);
    return res.json({ success: true, data: item });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Orders
export const createOrder = async (req, res) => {
  try {
    const order = await restaurantService.createOrder(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: order });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getActiveOrders = async (req, res) => {
  try {
    const orders = await restaurantService.getActiveOrders(req.user.organizationId);
    return res.json({ success: true, data: orders, count: orders.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getOrderById = async (req, res) => {
  try {
    const { orderId } = req.params;
    const order = await restaurantService.getOrderById(orderId);
    if (!order) return res.status(404).json({ success: false, error: 'Order not found' });
    return res.json({ success: true, data: order });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const updateOrderStatus = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status } = req.body;
    await restaurantService.updateOrderStatus(orderId, status);
    return res.json({ success: true, message: 'Order status updated' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const addItemToOrder = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { menu_item_id, quantity, special_instructions } = req.body;
    const item = await restaurantService.addItemToOrder(orderId, menu_item_id, quantity, special_instructions);
    return res.status(201).json({ success: true, data: item });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const removeItemFromOrder = async (req, res) => {
  try {
    const { orderItemId } = req.params;
    await restaurantService.removeItemFromOrder(orderItemId);
    return res.json({ success: true, message: 'Item removed from order' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// KOT
export const generateKOT = async (req, res) => {
  try {
    const { orderId } = req.params;
    const kot = await restaurantService.generateKOT(req.user.organizationId, orderId);
    return res.status(201).json({ success: true, data: kot });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getPendingKOTs = async (req, res) => {
  try {
    const kots = await restaurantService.getPendingKOTs(req.user.organizationId);
    return res.json({ success: true, data: kots });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const updateKOTStatus = async (req, res) => {
  try {
    const { kotId } = req.params;
    const { status } = req.body;
    await restaurantService.updateKOTStatus(kotId, status);
    return res.json({ success: true, message: 'KOT status updated' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Stats
export const getRestaurantStats = async (req, res) => {
  try {
    const stats = await restaurantService.getRestaurantStats(req.user.organizationId);
    return res.json({ success: true, data: stats });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export default {
  createRestaurant, getRestaurant,
  getAllTables, getTablesByStatus, createTable, updateTableStatus,
  getAllMenuItems, getMenuByCategory, createMenuItem, updateMenuItem,
  createOrder, getActiveOrders, getOrderById, updateOrderStatus, addItemToOrder, removeItemFromOrder,
  generateKOT, getPendingKOTs, updateKOTStatus,
  getRestaurantStats,
};
