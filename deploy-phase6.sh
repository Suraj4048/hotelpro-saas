#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}🍻 Phase 6: Bar Module Deployment${NC}"
echo -e "${YELLOW}========================================${NC}\n"

REPO="/workspaces/hotelpro-saas"
BACKEND="$REPO/backend/src"

cd "$REPO" || exit 1

# Create directories
echo -e "${YELLOW}1️⃣ Creating directories...${NC}"
mkdir -p "$BACKEND/routes/06_bar"
mkdir -p "$BACKEND/models"
echo -e "${GREEN}✅ Directories created${NC}\n"

# Create Bar model
echo -e "${YELLOW}2️⃣ Creating Bar.js...${NC}"
cat > "$BACKEND/models/Bar.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Bar = sequelize.define('Bar', {
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
  location: {
    type: DataTypes.STRING,
  },
  opening_time: {
    type: DataTypes.TIME,
  },
  closing_time: {
    type: DataTypes.TIME,
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
  tableName: 'bars',
});

export default Bar;
ENDOFFILE
echo -e "${GREEN}✅ Bar.js created${NC}"

# Create BarCounter model
echo -e "${YELLOW}3️⃣ Creating BarCounter.js...${NC}"
cat > "$BACKEND/models/BarCounter.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BarCounter = sequelize.define('BarCounter', {
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
  bar_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'bars', key: 'id' },
  },
  counter_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  counter_number: {
    type: DataTypes.STRING,
  },
  section: {
    type: DataTypes.STRING,
  },
  status: {
    type: DataTypes.ENUM('available', 'occupied', 'maintenance'),
    defaultValue: 'available',
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'bar_counters',
});

export default BarCounter;
ENDOFFILE
echo -e "${GREEN}✅ BarCounter.js created${NC}"

# Create Drink model
echo -e "${YELLOW}4️⃣ Creating Drink.js...${NC}"
cat > "$BACKEND/models/Drink.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Drink = sequelize.define('Drink', {
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
  bar_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'bars', key: 'id' },
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  category: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'Beer, Wine, Whiskey, Vodka, Cocktail, Non-Alcoholic',
  },
  description: {
    type: DataTypes.TEXT,
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  alcohol_percentage: {
    type: DataTypes.DECIMAL(5, 2),
  },
  volume: {
    type: DataTypes.STRING,
    comment: 'ml or oz (e.g., 30ml, 1oz)',
  },
  is_available: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  popularity_rank: {
    type: DataTypes.INTEGER,
  },
}, {
  timestamps: true,
  tableName: 'drinks',
});

export default Drink;
ENDOFFILE
echo -e "${GREEN}✅ Drink.js created${NC}"

# Create BarOrder model
echo -e "${YELLOW}5️⃣ Creating BarOrder.js...${NC}"
cat > "$BACKEND/models/BarOrder.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BarOrder = sequelize.define('BarOrder', {
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
  bar_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'bars', key: 'id' },
  },
  counter_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'bar_counters', key: 'id' },
  },
  order_number: {
    type: DataTypes.STRING,
    unique: true,
  },
  status: {
    type: DataTypes.ENUM('open', 'pending', 'completed', 'cancelled'),
    defaultValue: 'open',
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
  tableName: 'bar_orders',
});

export default BarOrder;
ENDOFFILE
echo -e "${GREEN}✅ BarOrder.js created${NC}"

# Create BarOrderItem model
echo -e "${YELLOW}6️⃣ Creating BarOrderItem.js...${NC}"
cat > "$BACKEND/models/BarOrderItem.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BarOrderItem = sequelize.define('BarOrderItem', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  bar_order_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'bar_orders', key: 'id' },
  },
  drink_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'drinks', key: 'id' },
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
    comment: 'e.g., Extra ice, No ice, Salt rim',
  },
  status: {
    type: DataTypes.ENUM('pending', 'preparing', 'ready', 'served', 'cancelled'),
    defaultValue: 'pending',
  },
}, {
  timestamps: true,
  tableName: 'bar_order_items',
});

export default BarOrderItem;
ENDOFFILE
echo -e "${GREEN}✅ BarOrderItem.js created${NC}"

# Create BarInventory model
echo -e "${YELLOW}7️⃣ Creating BarInventory.js...${NC}"
cat > "$BACKEND/models/BarInventory.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BarInventory = sequelize.define('BarInventory', {
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
  bar_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'bars', key: 'id' },
  },
  drink_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'drinks', key: 'id' },
  },
  quantity_in_stock: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  minimum_level: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  unit: {
    type: DataTypes.STRING,
    comment: 'Bottle, Liter, ml, oz',
  },
  cost_per_unit: {
    type: DataTypes.DECIMAL(10, 2),
  },
  last_restock_date: {
    type: DataTypes.DATE,
  },
  expiry_date: {
    type: DataTypes.DATE,
  },
}, {
  timestamps: true,
  tableName: 'bar_inventory',
});

export default BarInventory;
ENDOFFILE
echo -e "${GREEN}✅ BarInventory.js created${NC}"

# Create bar.service.js
echo -e "${YELLOW}8️⃣ Creating bar.service.js...${NC}"
cat > "$BACKEND/routes/06_bar/bar.service.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ bar.service.js created${NC}"

# Create bar.controller.js
echo -e "${YELLOW}9️⃣ Creating bar.controller.js...${NC}"
cat > "$BACKEND/routes/06_bar/bar.controller.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ bar.controller.js created${NC}"

# Create bar.routes.js
echo -e "${YELLOW}🔟 Creating bar.routes.js...${NC}"
cat > "$BACKEND/routes/06_bar/bar.routes.js" << 'ENDOFFILE'
import express from 'express';
import * as barController from './bar.controller.js';
import { checkModuleAccess } from '../../middleware/authMiddleware.js';

const router = express.Router();
router.use(checkModuleAccess('bar'));

// Bar
router.post('/', barController.createBar);
router.get('/', barController.getBar);

// Counters
router.get('/counters', barController.getAllCounters);
router.get('/counters/status/:status', barController.getCountersByStatus);
router.post('/counters', barController.createCounter);
router.put('/counters/:counterId/status', barController.updateCounterStatus);

// Drinks
router.get('/drinks', barController.getAllDrinks);
router.get('/drinks/category', barController.getDrinksByCategory);
router.post('/drinks', barController.createDrink);
router.put('/drinks/:drinkId', barController.updateDrink);

// Bar Orders
router.post('/orders', barController.createBarOrder);
router.get('/orders/open', barController.getOpenOrders);
router.get('/orders/:orderId', barController.getBarOrderById);
router.put('/orders/:orderId/status', barController.updateBarOrderStatus);
router.post('/orders/:orderId/drinks', barController.addDrinkToOrder);
router.delete('/orders/items/:orderItemId', barController.removeDrinkFromOrder);

// Inventory
router.get('/inventory', barController.getInventory);
router.get('/inventory/low-stock', barController.getLowStockItems);
router.put('/inventory/:inventoryId', barController.updateInventory);

// Stats
router.get('/stats', barController.getBarStats);

export default router;
ENDOFFILE
echo -e "${GREEN}✅ bar.routes.js created${NC}"

# Create bar.validators.js
echo -e "${YELLOW}1️⃣1️⃣ Creating bar.validators.js...${NC}"
cat > "$BACKEND/routes/06_bar/bar.validators.js" << 'ENDOFFILE'
import Joi from 'joi';

export const validateCreateBarOrder = (data) => {
  const schema = Joi.object({
    bar_id: Joi.string().uuid().required(),
    counter_id: Joi.string().uuid().required(),
    number_of_guests: Joi.number(),
    notes: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateAddDrinkToOrder = (data) => {
  const schema = Joi.object({
    drink_id: Joi.string().uuid().required(),
    quantity: Joi.number().required().min(1),
    special_instructions: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCreateDrink = (data) => {
  const schema = Joi.object({
    name: Joi.string().required(),
    category: Joi.string().required(),
    price: Joi.number().required().positive(),
    alcohol_percentage: Joi.number(),
    volume: Joi.string(),
    description: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateBarOrder,
  validateAddDrinkToOrder,
  validateCreateDrink,
};
ENDOFFILE
echo -e "${GREEN}✅ bar.validators.js created${NC}"

# Update server.js
echo -e "${YELLOW}1️⃣2️⃣ Updating server.js...${NC}"
if ! grep -q "import barRoutes" "$BACKEND/server.js"; then
  sed -i "/import restaurantRoutes/a import barRoutes from './routes/06_bar/bar.routes.js';" "$BACKEND/server.js"
  sed -i "/app.use('\/api\/restaurant'/a app.use('/api/bar', barRoutes);" "$BACKEND/server.js"
  echo -e "${GREEN}✅ server.js updated${NC}"
else
  echo -e "${YELLOW}⚠️ Bar routes already in server.js${NC}"
fi

# Git commit and push
echo -e "${YELLOW}1️⃣3️⃣ Git operations...${NC}"
git add -A
git commit -m "Phase 6: Bar Module

- Added Bar model
- Added BarCounter model
- Added Drink model
- Added BarOrder model
- Added BarOrderItem model
- Added BarInventory model
- Added bar.service.js (business logic)
- Added bar.controller.js (API handlers)
- Added bar.routes.js (route definitions)
- Added bar.validators.js (input validation)
- Integrated Bar routes into server.js"

git push origin main 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Pushed to GitHub${NC}"
else
  echo -e "${YELLOW}⚠️ Push failed (check connection)${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ PHASE 6 DEPLOYMENT COMPLETE!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${GREEN}📌 Bar Module Routes Ready:${NC}"
echo -e "  POST   /api/bar"
echo -e "  GET    /api/bar"
echo -e "  GET    /api/bar/counters"
echo -e "  POST   /api/bar/counters"
echo -e "  PUT    /api/bar/counters/:counterId/status"
echo -e "  GET    /api/bar/drinks"
echo -e "  GET    /api/bar/drinks/category"
echo -e "  POST   /api/bar/drinks"
echo -e "  PUT    /api/bar/drinks/:drinkId"
echo -e "  POST   /api/bar/orders"
echo -e "  GET    /api/bar/orders/open"
echo -e "  GET    /api/bar/orders/:orderId"
echo -e "  PUT    /api/bar/orders/:orderId/status"
echo -e "  POST   /api/bar/orders/:orderId/drinks"
echo -e "  DELETE /api/bar/orders/items/:orderItemId"
echo -e "  GET    /api/bar/inventory"
echo -e "  GET    /api/bar/inventory/low-stock"
echo -e "  PUT    /api/bar/inventory/:inventoryId"
echo -e "  GET    /api/bar/stats\n"

echo -e "${YELLOW}🚀 Ready for Phase 7: Banquet Module${NC}\n"
ENDOFFILE
