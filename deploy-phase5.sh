#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}🍽️  Phase 5: Restaurant POS Deployment${NC}"
echo -e "${YELLOW}========================================${NC}\n"

REPO="/workspaces/hotelpro-saas"
BACKEND="$REPO/backend/src"

cd "$REPO" || exit 1

# Create directories
echo -e "${YELLOW}1️⃣ Creating directories...${NC}"
mkdir -p "$BACKEND/routes/05_restaurant"
mkdir -p "$BACKEND/models"
echo -e "${GREEN}✅ Directories created${NC}\n"

# Create Restaurant model
echo -e "${YELLOW}2️⃣ Creating Restaurant.js...${NC}"
cat > "$BACKEND/models/Restaurant.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Restaurant = sequelize.define('Restaurant', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  currency: {
    type: DataTypes.STRING,
    defaultValue: 'INR',
  },
  tax_rate: {
    type: DataTypes.DECIMAL(5, 2),
    defaultValue: 18.00,
  },
  service_charge_rate: {
    type: DataTypes.DECIMAL(5, 2),
    defaultValue: 0.00,
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'restaurants',
});

export default Restaurant;
ENDOFFILE
echo -e "${GREEN}✅ Restaurant.js created${NC}"

# Create Table model
echo -e "${YELLOW}3️⃣ Creating Table.js...${NC}"
cat > "$BACKEND/models/Table.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Table = sequelize.define('Table', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  restaurant_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'restaurants', key: 'id' },
  },
  table_number: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  section: {
    type: DataTypes.STRING,
  },
  capacity: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('available', 'occupied', 'reserved', 'maintenance'),
    defaultValue: 'available',
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'tables',
});

export default Table;
ENDOFFILE
echo -e "${GREEN}✅ Table.js created${NC}"

# Create MenuItem model
echo -e "${YELLOW}4️⃣ Creating MenuItem.js...${NC}"
cat > "$BACKEND/models/MenuItem.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const MenuItem = sequelize.define('MenuItem', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  restaurant_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'restaurants', key: 'id' },
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
  },
  category: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  veg: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  preparation_time: {
    type: DataTypes.INTEGER,
    comment: 'in minutes',
  },
  is_available: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'menu_items',
});

export default MenuItem;
ENDOFFILE
echo -e "${GREEN}✅ MenuItem.js created${NC}"

# Create Order model
echo -e "${YELLOW}5️⃣ Creating Order.js...${NC}"
cat > "$BACKEND/models/Order.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Order = sequelize.define('Order', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  restaurant_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'restaurants', key: 'id' },
  },
  table_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'tables', key: 'id' },
  },
  order_number: {
    type: DataTypes.STRING,
    unique: true,
  },
  status: {
    type: DataTypes.ENUM('pending', 'confirmed', 'preparing', 'ready', 'served', 'completed', 'cancelled'),
    defaultValue: 'pending',
  },
  subtotal: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  tax_amount: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  service_charge: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  total_amount: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'paid', 'partial', 'refunded'),
    defaultValue: 'pending',
  },
  ordered_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  number_of_guests: {
    type: DataTypes.INTEGER,
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'orders',
});

export default Order;
ENDOFFILE
echo -e "${GREEN}✅ Order.js created${NC}"

# Create OrderItem model
echo -e "${YELLOW}6️⃣ Creating OrderItem.js...${NC}"
cat > "$BACKEND/models/OrderItem.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const OrderItem = sequelize.define('OrderItem', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  order_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'orders', key: 'id' },
  },
  menu_item_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'menu_items', key: 'id' },
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  unit_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  special_instructions: {
    type: DataTypes.TEXT,
  },
  status: {
    type: DataTypes.ENUM('pending', 'preparing', 'ready', 'served', 'cancelled'),
    defaultValue: 'pending',
  },
}, {
  timestamps: true,
  tableName: 'order_items',
});

export default OrderItem;
ENDOFFILE
echo -e "${GREEN}✅ OrderItem.js created${NC}"

# Create KOT model
echo -e "${YELLOW}7️⃣ Creating KOT.js...${NC}"
cat > "$BACKEND/models/KOT.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const KOT = sequelize.define('KOT', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  order_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'orders', key: 'id' },
  },
  kot_number: {
    type: DataTypes.STRING,
    unique: true,
  },
  status: {
    type: DataTypes.ENUM('sent', 'acknowledged', 'preparing', 'ready', 'cancelled'),
    defaultValue: 'sent',
  },
  items_count: {
    type: DataTypes.INTEGER,
  },
  sent_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  acknowledged_at: {
    type: DataTypes.DATE,
  },
  ready_at: {
    type: DataTypes.DATE,
  },
}, {
  timestamps: true,
  tableName: 'kots',
});

export default KOT;
ENDOFFILE
echo -e "${GREEN}✅ KOT.js created${NC}"

# Create restaurant.service.js
echo -e "${YELLOW}8️⃣ Creating restaurant.service.js...${NC}"
cat > "$BACKEND/routes/05_restaurant/restaurant.service.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ restaurant.service.js created${NC}"

# Create restaurant.controller.js
echo -e "${YELLOW}9️⃣ Creating restaurant.controller.js...${NC}"
cat > "$BACKEND/routes/05_restaurant/restaurant.controller.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ restaurant.controller.js created${NC}"

# Create restaurant.routes.js
echo -e "${YELLOW}🔟 Creating restaurant.routes.js...${NC}"
cat > "$BACKEND/routes/05_restaurant/restaurant.routes.js" << 'ENDOFFILE'
import express from 'express';
import * as restaurantController from './restaurant.controller.js';
import { checkModuleAccess } from '../../middleware/authMiddleware.js';

const router = express.Router();
router.use(checkModuleAccess('restaurant'));

// Restaurant
router.post('/', restaurantController.createRestaurant);
router.get('/', restaurantController.getRestaurant);

// Tables
router.get('/tables', restaurantController.getAllTables);
router.get('/tables/status/:status', restaurantController.getTablesByStatus);
router.post('/tables', restaurantController.createTable);
router.put('/tables/:tableId/status', restaurantController.updateTableStatus);

// Menu Items
router.get('/menu-items', restaurantController.getAllMenuItems);
router.get('/menu/category', restaurantController.getMenuByCategory);
router.post('/menu-items', restaurantController.createMenuItem);
router.put('/menu-items/:itemId', restaurantController.updateMenuItem);

// Orders
router.post('/orders', restaurantController.createOrder);
router.get('/orders/active', restaurantController.getActiveOrders);
router.get('/orders/:orderId', restaurantController.getOrderById);
router.put('/orders/:orderId/status', restaurantController.updateOrderStatus);
router.post('/orders/:orderId/items', restaurantController.addItemToOrder);
router.delete('/orders/items/:orderItemId', restaurantController.removeItemFromOrder);

// KOT (Kitchen Order Ticket)
router.post('/orders/:orderId/kot', restaurantController.generateKOT);
router.get('/kots/pending', restaurantController.getPendingKOTs);
router.put('/kots/:kotId/status', restaurantController.updateKOTStatus);

// Stats
router.get('/stats', restaurantController.getRestaurantStats);

export default router;
ENDOFFILE
echo -e "${GREEN}✅ restaurant.routes.js created${NC}"

# Create restaurant.validators.js
echo -e "${YELLOW}1️⃣1️⃣ Creating restaurant.validators.js...${NC}"
cat > "$BACKEND/routes/05_restaurant/restaurant.validators.js" << 'ENDOFFILE'
import Joi from 'joi';

export const validateCreateOrder = (data) => {
  const schema = Joi.object({
    restaurant_id: Joi.string().uuid().required(),
    table_id: Joi.string().uuid().required(),
    number_of_guests: Joi.number().required(),
    notes: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateAddOrderItem = (data) => {
  const schema = Joi.object({
    menu_item_id: Joi.string().uuid().required(),
    quantity: Joi.number().required().min(1),
    special_instructions: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCreateMenuItem = (data) => {
  const schema = Joi.object({
    name: Joi.string().required(),
    category: Joi.string().required(),
    price: Joi.number().required().positive(),
    veg: Joi.boolean(),
    preparation_time: Joi.number(),
    description: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateOrder,
  validateAddOrderItem,
  validateCreateMenuItem,
};
ENDOFFILE
echo -e "${GREEN}✅ restaurant.validators.js created${NC}"

# Update server.js
echo -e "${YELLOW}1️⃣2️⃣ Updating server.js...${NC}"
if ! grep -q "import restaurantRoutes" "$BACKEND/server.js"; then
  sed -i "/import pmsRoutes/a import restaurantRoutes from './routes/05_restaurant/restaurant.routes.js';" "$BACKEND/server.js"
  sed -i "/app.use('\/api\/pms'/a app.use('/api/restaurant', restaurantRoutes);" "$BACKEND/server.js"
  echo -e "${GREEN}✅ server.js updated${NC}"
else
  echo -e "${YELLOW}⚠️ Restaurant routes already in server.js${NC}"
fi

# Git commit and push
echo -e "${YELLOW}1️⃣3️⃣ Git operations...${NC}"
git add -A
git commit -m "Phase 5: Restaurant POS Module

- Added Restaurant model
- Added Table model
- Added MenuItem model
- Added Order model
- Added OrderItem model
- Added KOT model (Kitchen Order Ticket)
- Added restaurant.service.js (business logic)
- Added restaurant.controller.js (API handlers)
- Added restaurant.routes.js (route definitions)
- Added restaurant.validators.js (input validation)
- Integrated Restaurant POS routes into server.js"

git push origin main 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Pushed to GitHub${NC}"
else
  echo -e "${YELLOW}⚠️ Push failed (check connection)${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ PHASE 5 DEPLOYMENT COMPLETE!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${GREEN}📌 Restaurant POS Routes Ready:${NC}"
echo -e "  POST   /api/restaurant"
echo -e "  GET    /api/restaurant"
echo -e "  GET    /api/restaurant/tables"
echo -e "  POST   /api/restaurant/tables"
echo -e "  PUT    /api/restaurant/tables/:tableId/status"
echo -e "  GET    /api/restaurant/menu-items"
echo -e "  GET    /api/restaurant/menu/category"
echo -e "  POST   /api/restaurant/menu-items"
echo -e "  PUT    /api/restaurant/menu-items/:itemId"
echo -e "  POST   /api/restaurant/orders"
echo -e "  GET    /api/restaurant/orders/active"
echo -e "  GET    /api/restaurant/orders/:orderId"
echo -e "  PUT    /api/restaurant/orders/:orderId/status"
echo -e "  POST   /api/restaurant/orders/:orderId/items"
echo -e "  DELETE /api/restaurant/orders/items/:orderItemId"
echo -e "  POST   /api/restaurant/orders/:orderId/kot"
echo -e "  GET    /api/restaurant/kots/pending"
echo -e "  PUT    /api/restaurant/kots/:kotId/status"
echo -e "  GET    /api/restaurant/stats\n"

echo -e "${YELLOW}🚀 Ready for Phase 6: Bar Module${NC}\n"
ENDOFFILE
