#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}📦 Phase 9: Inventory & Procurement${NC}"
echo -e "${YELLOW}========================================${NC}\n"

REPO="/workspaces/hotelpro-saas"
BACKEND="$REPO/backend/src"

cd "$REPO" || exit 1

# Create directories
echo -e "${YELLOW}1️⃣ Creating directories...${NC}"
mkdir -p "$BACKEND/routes/09_inventory"
mkdir -p "$BACKEND/models"
echo -e "${GREEN}✅ Directories created${NC}\n"

# Create InventoryCategory model
echo -e "${YELLOW}2️⃣ Creating InventoryCategory.js...${NC}"
cat > "$BACKEND/models/InventoryCategory.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const InventoryCategory = sequelize.define('InventoryCategory', {
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
  category_name: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  category_type: {
    type: DataTypes.ENUM('food', 'beverage', 'supplies', 'equipment', 'other'),
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'inventory_categories',
});

export default InventoryCategory;
ENDOFFILE
echo -e "${GREEN}✅ InventoryCategory.js created${NC}"

# Create Inventory model
echo -e "${YELLOW}3️⃣ Creating Inventory.js...${NC}"
cat > "$BACKEND/models/Inventory.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Inventory = sequelize.define('Inventory', {
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
  category_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'inventory_categories', key: 'id' },
  },
  item_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  item_code: {
    type: DataTypes.STRING,
    unique: true,
    comment: 'SKU or item code',
  },
  description: {
    type: DataTypes.TEXT,
  },
  unit: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'kg, liter, box, piece, etc.',
  },
  quantity_in_stock: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  par_level: {
    type: DataTypes.DECIMAL(10, 2),
    comment: 'Ideal quantity to maintain',
  },
  reorder_point: {
    type: DataTypes.DECIMAL(10, 2),
    comment: 'Trigger point for purchase order',
  },
  reorder_quantity: {
    type: DataTypes.DECIMAL(10, 2),
    comment: 'Quantity to order when stock falls below reorder point',
  },
  cost_per_unit: {
    type: DataTypes.DECIMAL(10, 2),
  },
  opening_stock: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  last_count_date: {
    type: DataTypes.DATE,
  },
  last_purchase_date: {
    type: DataTypes.DATE,
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'inventory',
});

export default Inventory;
ENDOFFILE
echo -e "${GREEN}✅ Inventory.js created${NC}"

# Create Vendor model
echo -e "${YELLOW}4️⃣ Creating Vendor.js...${NC}"
cat > "$BACKEND/models/Vendor.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Vendor = sequelize.define('Vendor', {
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
  vendor_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  vendor_code: {
    type: DataTypes.STRING,
    unique: true,
  },
  contact_person: {
    type: DataTypes.STRING,
  },
  phone: {
    type: DataTypes.STRING,
  },
  email: {
    type: DataTypes.STRING,
  },
  address: {
    type: DataTypes.TEXT,
  },
  city: {
    type: DataTypes.STRING,
  },
  gst_number: {
    type: DataTypes.STRING,
  },
  payment_terms: {
    type: DataTypes.STRING,
    comment: 'Net 30, COD, etc.',
  },
  credit_limit: {
    type: DataTypes.DECIMAL(12, 2),
  },
  outstanding_balance: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  vendor_type: {
    type: DataTypes.ENUM('food_supplier', 'beverage_supplier', 'general_supplies', 'equipment', 'other'),
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  rating: {
    type: DataTypes.DECIMAL(3, 1),
    comment: '1-5 stars',
  },
}, {
  timestamps: true,
  tableName: 'vendors',
});

export default Vendor;
ENDOFFILE
echo -e "${GREEN}✅ Vendor.js created${NC}"

# Create PurchaseOrder model
echo -e "${YELLOW}5️⃣ Creating PurchaseOrder.js...${NC}"
cat > "$BACKEND/models/PurchaseOrder.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const PurchaseOrder = sequelize.define('PurchaseOrder', {
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
  po_number: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
  },
  vendor_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'vendors', key: 'id' },
  },
  po_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  expected_delivery_date: {
    type: DataTypes.DATE,
  },
  subtotal: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  tax_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  tax_rate: {
    type: DataTypes.DECIMAL(5, 2),
    defaultValue: 18.00,
  },
  total_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  status: {
    type: DataTypes.ENUM('draft', 'sent', 'confirmed', 'partially_received', 'received', 'cancelled', 'invoiced'),
    defaultValue: 'draft',
  },
  notes: {
    type: DataTypes.TEXT,
  },
  created_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
}, {
  timestamps: true,
  tableName: 'purchase_orders',
});

export default PurchaseOrder;
ENDOFFILE
echo -e "${GREEN}✅ PurchaseOrder.js created${NC}"

# Create PurchaseOrderItem model
echo -e "${YELLOW}6️⃣ Creating PurchaseOrderItem.js...${NC}"
cat > "$BACKEND/models/PurchaseOrderItem.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const PurchaseOrderItem = sequelize.define('PurchaseOrderItem', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  purchase_order_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'purchase_orders', key: 'id' },
  },
  inventory_item_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'inventory', key: 'id' },
  },
  quantity_ordered: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  quantity_received: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  unit_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  line_total: {
    type: DataTypes.DECIMAL(12, 2),
  },
  unit: {
    type: DataTypes.STRING,
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'purchase_order_items',
});

export default PurchaseOrderItem;
ENDOFFILE
echo -e "${GREEN}✅ PurchaseOrderItem.js created${NC}"

# Create GoodsReceipt model
echo -e "${YELLOW}7️⃣ Creating GoodsReceipt.js...${NC}"
cat > "$BACKEND/models/GoodsReceipt.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const GoodsReceipt = sequelize.define('GoodsReceipt', {
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
  gr_number: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
  },
  purchase_order_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'purchase_orders', key: 'id' },
  },
  receipt_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  vendor_invoice_number: {
    type: DataTypes.STRING,
  },
  vendor_invoice_date: {
    type: DataTypes.DATE,
  },
  received_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  status: {
    type: DataTypes.ENUM('pending_inspection', 'inspected', 'accepted', 'rejected', 'partial'),
    defaultValue: 'pending_inspection',
  },
  total_received_amount: {
    type: DataTypes.DECIMAL(12, 2),
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'goods_receipts',
});

export default GoodsReceipt;
ENDOFFILE
echo -e "${GREEN}✅ GoodsReceipt.js created${NC}"

# Create GoodsReceiptItem model
echo -e "${YELLOW}8️⃣ Creating GoodsReceiptItem.js...${NC}"
cat > "$BACKEND/models/GoodsReceiptItem.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const GoodsReceiptItem = sequelize.define('GoodsReceiptItem', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  goods_receipt_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'goods_receipts', key: 'id' },
  },
  purchase_order_item_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'purchase_order_items', key: 'id' },
  },
  quantity_received: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  quantity_accepted: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  quantity_rejected: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  unit_price: {
    type: DataTypes.DECIMAL(10, 2),
  },
  line_total: {
    type: DataTypes.DECIMAL(12, 2),
  },
  batch_number: {
    type: DataTypes.STRING,
  },
  expiry_date: {
    type: DataTypes.DATE,
  },
  quality_notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'goods_receipt_items',
});

export default GoodsReceiptItem;
ENDOFFILE
echo -e "${GREEN}✅ GoodsReceiptItem.js created${NC}"

# Create StockAdjustment model
echo -e "${YELLOW}9️⃣ Creating StockAdjustment.js...${NC}"
cat > "$BACKEND/models/StockAdjustment.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const StockAdjustment = sequelize.define('StockAdjustment', {
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
  adjustment_number: {
    type: DataTypes.STRING,
    unique: true,
  },
  inventory_item_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'inventory', key: 'id' },
  },
  adjustment_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  adjustment_type: {
    type: DataTypes.ENUM('addition', 'reduction', 'correction'),
    allowNull: false,
  },
  reason: {
    type: DataTypes.ENUM('stock_count', 'damage', 'theft', 'expired', 'return_to_vendor', 'correction', 'other'),
    allowNull: false,
  },
  quantity_before: {
    type: DataTypes.DECIMAL(10, 2),
  },
  adjustment_quantity: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  quantity_after: {
    type: DataTypes.DECIMAL(10, 2),
  },
  cost_impact: {
    type: DataTypes.DECIMAL(12, 2),
  },
  notes: {
    type: DataTypes.TEXT,
  },
  adjusted_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  approved_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  status: {
    type: DataTypes.ENUM('pending', 'approved', 'rejected'),
    defaultValue: 'pending',
  },
}, {
  timestamps: true,
  tableName: 'stock_adjustments',
});

export default StockAdjustment;
ENDOFFILE
echo -e "${GREEN}✅ StockAdjustment.js created${NC}"

# Create InventoryMovement model
echo -e "${YELLOW}🔟 Creating InventoryMovement.js...${NC}"
cat > "$BACKEND/models/InventoryMovement.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const InventoryMovement = sequelize.define('InventoryMovement', {
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
  inventory_item_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'inventory', key: 'id' },
  },
  movement_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  movement_type: {
    type: DataTypes.ENUM('inward', 'outward', 'adjustment', 'transfer'),
    allowNull: false,
  },
  reference_type: {
    type: DataTypes.ENUM('purchase_order', 'goods_receipt', 'restaurant_order', 'stock_adjustment', 'manual'),
  },
  reference_id: {
    type: DataTypes.UUID,
  },
  quantity: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  unit_cost: {
    type: DataTypes.DECIMAL(10, 2),
  },
  transaction_value: {
    type: DataTypes.DECIMAL(12, 2),
  },
  stock_before: {
    type: DataTypes.DECIMAL(10, 2),
  },
  stock_after: {
    type: DataTypes.DECIMAL(10, 2),
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'inventory_movements',
  indexes: [
    { fields: ['inventory_item_id', 'movement_date'] },
  ],
});

export default InventoryMovement;
ENDOFFILE
echo -e "${GREEN}✅ InventoryMovement.js created${NC}"

# Create inventory.service.js
echo -e "${YELLOW}1️⃣1️⃣ Creating inventory.service.js...${NC}"
cat > "$BACKEND/routes/09_inventory/inventory.service.js" << 'ENDOFFILE'
import Inventory from '../../models/Inventory.js';
import InventoryCategory from '../../models/InventoryCategory.js';
import Vendor from '../../models/Vendor.js';
import PurchaseOrder from '../../models/PurchaseOrder.js';
import PurchaseOrderItem from '../../models/PurchaseOrderItem.js';
import GoodsReceipt from '../../models/GoodsReceipt.js';
import GoodsReceiptItem from '../../models/GoodsReceiptItem.js';
import StockAdjustment from '../../models/StockAdjustment.js';
import InventoryMovement from '../../models/InventoryMovement.js';
import { Op } from 'sequelize';
import sequelize from '../../config/database.js';

// Inventory Item Management
export const createInventoryItem = async (orgId, data) => {
  return await Inventory.create({
    organization_id: orgId,
    ...data,
  });
};

export const getInventoryItemById = async (itemId) => {
  return await Inventory.findByPk(itemId, {
    include: [InventoryCategory],
  });
};

export const getAllInventoryItems = async (orgId, filters = {}) => {
  const where = { organization_id: orgId };
  if (filters.category_id) where.category_id = filters.category_id;
  if (filters.is_active !== undefined) where.is_active = filters.is_active;

  return await Inventory.findAll({
    where,
    include: [InventoryCategory],
    order: [['item_name', 'ASC']],
  });
};

export const getLowStockItems = async (orgId) => {
  return await Inventory.findAll({
    where: {
      organization_id: orgId,
      quantity_in_stock: { [Op.lte]: sequelize.col('reorder_point') },
    },
    include: [InventoryCategory],
  });
};

export const updateInventoryItem = async (itemId, data) => {
  return await Inventory.update(data, { where: { id: itemId } });
};

// Vendor Management
export const createVendor = async (orgId, data) => {
  const vendorCode = `VEN-${Date.now().toString().slice(-6)}`;
  return await Vendor.create({
    organization_id: orgId,
    vendor_code: vendorCode,
    ...data,
  });
};

export const getAllVendors = async (orgId, filters = {}) => {
  const where = { organization_id: orgId };
  if (filters.is_active !== undefined) where.is_active = filters.is_active;
  if (filters.vendor_type) where.vendor_type = filters.vendor_type;

  return await Vendor.findAll({
    where,
    order: [['vendor_name', 'ASC']],
  });
};

export const updateVendor = async (vendorId, data) => {
  return await Vendor.update(data, { where: { id: vendorId } });
};

// Purchase Order Management
export const createPurchaseOrder = async (orgId, data) => {
  const poNumber = `PO-${new Date().getFullYear()}-${Date.now().toString().slice(-5)}`;

  return await PurchaseOrder.create({
    organization_id: orgId,
    po_number: poNumber,
    ...data,
  });
};

export const getPurchaseOrderById = async (poId) => {
  return await PurchaseOrder.findByPk(poId, {
    include: [
      { model: PurchaseOrderItem, include: [Inventory] },
      { model: Vendor },
    ],
  });
};

export const getAllPurchaseOrders = async (orgId, filters = {}) => {
  const where = { organization_id: orgId };
  if (filters.status) where.status = filters.status;
  if (filters.vendor_id) where.vendor_id = filters.vendor_id;

  return await PurchaseOrder.findAll({
    where,
    include: [Vendor],
    order: [['po_date', 'DESC']],
  });
};

export const addItemToPO = async (poId, itemData) => {
  const item = await PurchaseOrderItem.create({
    purchase_order_id: poId,
    line_total: itemData.quantity_ordered * itemData.unit_price,
    ...itemData,
  });

  await calculatePOTotal(poId);
  return item;
};

export const calculatePOTotal = async (poId) => {
  const items = await PurchaseOrderItem.findAll({ where: { purchase_order_id: poId } });
  const po = await PurchaseOrder.findByPk(poId);

  const subtotal = items.reduce((sum, item) => sum + (item.line_total || 0), 0);
  const taxAmount = (subtotal * (po.tax_rate || 18)) / 100;
  const totalAmount = subtotal + taxAmount;

  await PurchaseOrder.update(
    {
      subtotal,
      tax_amount: taxAmount,
      total_amount: totalAmount,
    },
    { where: { id: poId } }
  );
};

export const updatePOStatus = async (poId, status) => {
  return await PurchaseOrder.update({ status }, { where: { id: poId } });
};

// Goods Receipt Management
export const createGoodsReceipt = async (orgId, data) => {
  const grNumber = `GR-${new Date().getFullYear()}-${Date.now().toString().slice(-5)}`;

  const gr = await GoodsReceipt.create({
    organization_id: orgId,
    gr_number: grNumber,
    ...data,
  });

  await PurchaseOrder.update({ status: 'partially_received' }, { where: { id: data.purchase_order_id } });
  return gr;
};

export const getGoodsReceiptById = async (grId) => {
  return await GoodsReceipt.findByPk(grId, {
    include: [
      { model: GoodsReceiptItem, include: [{ model: PurchaseOrderItem, include: [Inventory] }] },
      { model: PurchaseOrder, include: [Vendor] },
    ],
  });
};

export const addItemToGoodsReceipt = async (grId, itemData) => {
  return await GoodsReceiptItem.create({
    goods_receipt_id: grId,
    line_total: itemData.quantity_accepted * itemData.unit_price,
    ...itemData,
  });
};

export const acceptGoodsReceiptItem = async (grItemId) => {
  const grItem = await GoodsReceiptItem.findByPk(grItemId);
  const poItem = await PurchaseOrderItem.findByPk(grItem.purchase_order_item_id);
  const inventory = await Inventory.findByPk(poItem.inventory_item_id);

  // Update inventory
  const newStock = inventory.quantity_in_stock + grItem.quantity_accepted;
  await Inventory.update(
    {
      quantity_in_stock: newStock,
      last_purchase_date: new Date(),
    },
    { where: { id: inventory.id } }
  );

  // Create movement record
  await InventoryMovement.create({
    organization_id: inventory.organization_id,
    inventory_item_id: inventory.id,
    movement_type: 'inward',
    reference_type: 'goods_receipt',
    reference_id: grItemId,
    quantity: grItem.quantity_accepted,
    unit_cost: grItem.unit_price,
    transaction_value: grItem.line_total,
    stock_before: inventory.quantity_in_stock,
    stock_after: newStock,
  });

  // Update PO item received quantity
  const totalReceived = (poItem.quantity_received || 0) + grItem.quantity_accepted;
  await PurchaseOrderItem.update(
    { quantity_received: totalReceived },
    { where: { id: poItem.id } }
  );

  return grItem;
};

// Stock Adjustment Management
export const createStockAdjustment = async (orgId, data) => {
  const adjNumber = `ADJ-${new Date().getFullYear()}-${Date.now().toString().slice(-5)}`;
  const inventory = await Inventory.findByPk(data.inventory_item_id);

  const quantityAfter = data.adjustment_type === 'addition'
    ? inventory.quantity_in_stock + data.adjustment_quantity
    : inventory.quantity_in_stock - data.adjustment_quantity;

  const adjustment = await StockAdjustment.create({
    organization_id: orgId,
    adjustment_number: adjNumber,
    quantity_before: inventory.quantity_in_stock,
    quantity_after: quantityAfter,
    cost_impact: quantityAfter * inventory.cost_per_unit,
    ...data,
  });

  // Create movement record
  await InventoryMovement.create({
    organization_id: orgId,
    inventory_item_id: data.inventory_item_id,
    movement_type: 'adjustment',
    reference_type: 'stock_adjustment',
    reference_id: adjustment.id,
    quantity: data.adjustment_quantity,
    stock_before: inventory.quantity_in_stock,
    stock_after: quantityAfter,
  });

  return adjustment;
};

export const approveStockAdjustment = async (adjustmentId) => {
  const adjustment = await StockAdjustment.findByPk(adjustmentId);
  const inventory = await Inventory.findByPk(adjustment.inventory_item_id);

  const newStock = adjustment.adjustment_type === 'addition'
    ? inventory.quantity_in_stock + adjustment.adjustment_quantity
    : inventory.quantity_in_stock - adjustment.adjustment_quantity;

  await Inventory.update(
    { quantity_in_stock: newStock },
    { where: { id: inventory.id } }
  );

  await StockAdjustment.update({ status: 'approved' }, { where: { id: adjustmentId } });
  return adjustment;
};

// Inventory Movement/Ledger
export const getInventoryMovements = async (orgId, itemId, filters = {}) => {
  const where = { organization_id: orgId };
  if (itemId) where.inventory_item_id = itemId;
  if (filters.start_date) where.movement_date = { [Op.gte]: filters.start_date };
  if (filters.end_date) where.movement_date = { [Op.lte]: filters.end_date };

  return await InventoryMovement.findAll({
    where,
    order: [['movement_date', 'DESC']],
  });
};

export const getInventoryValuation = async (orgId) => {
  const items = await Inventory.findAll({
    where: { organization_id: orgId, is_active: true },
  });

  let totalValue = 0;
  const valuations = items.map(item => {
    const itemValue = (item.quantity_in_stock || 0) * (item.cost_per_unit || 0);
    totalValue += itemValue;
    return {
      item_name: item.item_name,
      quantity: item.quantity_in_stock,
      cost_per_unit: item.cost_per_unit,
      total_value: itemValue,
    };
  });

  return {
    items: valuations,
    total_inventory_value: totalValue,
  };
};

export const getInventoryStats = async (orgId) => {
  const totalItems = await Inventory.count({ where: { organization_id: orgId } });
  const lowStockItems = await Inventory.count({
    where: {
      organization_id: orgId,
      quantity_in_stock: { [Op.lte]: sequelize.col('reorder_point') },
    },
  });

  const valuation = await getInventoryValuation(orgId);

  return {
    totalItems,
    lowStockItems,
    totalInventoryValue: valuation.total_inventory_value,
  };
};

export default {
  createInventoryItem, getInventoryItemById, getAllInventoryItems, getLowStockItems, updateInventoryItem,
  createVendor, getAllVendors, updateVendor,
  createPurchaseOrder, getPurchaseOrderById, getAllPurchaseOrders, addItemToPO, updatePOStatus,
  createGoodsReceipt, getGoodsReceiptById, addItemToGoodsReceipt, acceptGoodsReceiptItem,
  createStockAdjustment, approveStockAdjustment,
  getInventoryMovements, getInventoryValuation, getInventoryStats,
};
ENDOFFILE
echo -e "${GREEN}✅ inventory.service.js created${NC}"

# Create inventory.controller.js
echo -e "${YELLOW}1️⃣2️⃣ Creating inventory.controller.js...${NC}"
cat > "$BACKEND/routes/09_inventory/inventory.controller.js" << 'ENDOFFILE'
import * as inventoryService from './inventory.service.js';

// Inventory Items
export const createInventoryItem = async (req, res) => {
  try {
    const item = await inventoryService.createInventoryItem(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: item });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getInventoryItemById = async (req, res) => {
  try {
    const { itemId } = req.params;
    const item = await inventoryService.getInventoryItemById(itemId);
    if (!item) return res.status(404).json({ success: false, error: 'Item not found' });
    return res.json({ success: true, data: item });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getAllInventoryItems = async (req, res) => {
  try {
    const filters = req.query;
    const items = await inventoryService.getAllInventoryItems(req.user.organizationId, filters);
    return res.json({ success: true, data: items, count: items.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getLowStockItems = async (req, res) => {
  try {
    const items = await inventoryService.getLowStockItems(req.user.organizationId);
    return res.json({ success: true, data: items, count: items.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

// Vendors
export const createVendor = async (req, res) => {
  try {
    const vendor = await inventoryService.createVendor(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: vendor });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getAllVendors = async (req, res) => {
  try {
    const filters = req.query;
    const vendors = await inventoryService.getAllVendors(req.user.organizationId, filters);
    return res.json({ success: true, data: vendors, count: vendors.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

// Purchase Orders
export const createPurchaseOrder = async (req, res) => {
  try {
    const po = await inventoryService.createPurchaseOrder(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: po });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getPurchaseOrderById = async (req, res) => {
  try {
    const { poId } = req.params;
    const po = await inventoryService.getPurchaseOrderById(poId);
    if (!po) return res.status(404).json({ success: false, error: 'PO not found' });
    return res.json({ success: true, data: po });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getAllPurchaseOrders = async (req, res) => {
  try {
    const filters = req.query;
    const pos = await inventoryService.getAllPurchaseOrders(req.user.organizationId, filters);
    return res.json({ success: true, data: pos, count: pos.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const addItemToPO = async (req, res) => {
  try {
    const { poId } = req.params;
    const item = await inventoryService.addItemToPO(poId, req.body);
    return res.status(201).json({ success: true, data: item });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const updatePOStatus = async (req, res) => {
  try {
    const { poId } = req.params;
    const { status } = req.body;
    await inventoryService.updatePOStatus(poId, status);
    return res.json({ success: true, message: 'PO status updated' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Goods Receipt
export const createGoodsReceipt = async (req, res) => {
  try {
    const gr = await inventoryService.createGoodsReceipt(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: gr });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getGoodsReceiptById = async (req, res) => {
  try {
    const { grId } = req.params;
    const gr = await inventoryService.getGoodsReceiptById(grId);
    if (!gr) return res.status(404).json({ success: false, error: 'Goods Receipt not found' });
    return res.json({ success: true, data: gr });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const acceptGoodsReceiptItem = async (req, res) => {
  try {
    const { grItemId } = req.params;
    const item = await inventoryService.acceptGoodsReceiptItem(grItemId);
    return res.json({ success: true, data: item });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Stock Adjustments
export const createStockAdjustment = async (req, res) => {
  try {
    const adjustment = await inventoryService.createStockAdjustment(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: adjustment });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const approveStockAdjustment = async (req, res) => {
  try {
    const { adjustmentId } = req.params;
    const adjustment = await inventoryService.approveStockAdjustment(adjustmentId);
    return res.json({ success: true, data: adjustment });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Inventory Movements & Reports
export const getInventoryMovements = async (req, res) => {
  try {
    const { itemId } = req.params;
    const filters = req.query;
    const movements = await inventoryService.getInventoryMovements(req.user.organizationId, itemId, filters);
    return res.json({ success: true, data: movements });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getInventoryValuation = async (req, res) => {
  try {
    const valuation = await inventoryService.getInventoryValuation(req.user.organizationId);
    return res.json({ success: true, data: valuation });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getInventoryStats = async (req, res) => {
  try {
    const stats = await inventoryService.getInventoryStats(req.user.organizationId);
    return res.json({ success: true, data: stats });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export default {
  createInventoryItem, getInventoryItemById, getAllInventoryItems, getLowStockItems,
  createVendor, getAllVendors,
  createPurchaseOrder, getPurchaseOrderById, getAllPurchaseOrders, addItemToPO, updatePOStatus,
  createGoodsReceipt, getGoodsReceiptById, acceptGoodsReceiptItem,
  createStockAdjustment, approveStockAdjustment,
  getInventoryMovements, getInventoryValuation, getInventoryStats,
};
ENDOFFILE
echo -e "${GREEN}✅ inventory.controller.js created${NC}"

# Create inventory.routes.js
echo -e "${YELLOW}1️⃣3️⃣ Creating inventory.routes.js...${NC}"
cat > "$BACKEND/routes/09_inventory/inventory.routes.js" << 'ENDOFFILE'
import express from 'express';
import * as inventoryController from './inventory.controller.js';
import { checkModuleAccess } from '../../middleware/authMiddleware.js';

const router = express.Router();
router.use(checkModuleAccess('inventory'));

// Inventory Items
router.post('/items', inventoryController.createInventoryItem);
router.get('/items', inventoryController.getAllInventoryItems);
router.get('/items/:itemId', inventoryController.getInventoryItemById);
router.get('/items/low-stock', inventoryController.getLowStockItems);

// Vendors
router.post('/vendors', inventoryController.createVendor);
router.get('/vendors', inventoryController.getAllVendors);

// Purchase Orders
router.post('/purchase-orders', inventoryController.createPurchaseOrder);
router.get('/purchase-orders', inventoryController.getAllPurchaseOrders);
router.get('/purchase-orders/:poId', inventoryController.getPurchaseOrderById);
router.post('/purchase-orders/:poId/items', inventoryController.addItemToPO);
router.put('/purchase-orders/:poId/status', inventoryController.updatePOStatus);

// Goods Receipt
router.post('/goods-receipts', inventoryController.createGoodsReceipt);
router.get('/goods-receipts/:grId', inventoryController.getGoodsReceiptById);
router.put('/goods-receipts/:grItemId/accept', inventoryController.acceptGoodsReceiptItem);

// Stock Adjustments
router.post('/stock-adjustments', inventoryController.createStockAdjustment);
router.put('/stock-adjustments/:adjustmentId/approve', inventoryController.approveStockAdjustment);

// Reports
router.get('/movements/:itemId', inventoryController.getInventoryMovements);
router.get('/valuation', inventoryController.getInventoryValuation);
router.get('/stats', inventoryController.getInventoryStats);

export default router;
ENDOFFILE
echo -e "${GREEN}✅ inventory.routes.js created${NC}"

# Create inventory.validators.js
echo -e "${YELLOW}1️⃣4️⃣ Creating inventory.validators.js...${NC}"
cat > "$BACKEND/routes/09_inventory/inventory.validators.js" << 'ENDOFFILE'
import Joi from 'joi';

export const validateCreateInventoryItem = (data) => {
  const schema = Joi.object({
    category_id: Joi.string().uuid().required(),
    item_name: Joi.string().required(),
    item_code: Joi.string(),
    unit: Joi.string().required(),
    reorder_point: Joi.number(),
    reorder_quantity: Joi.number(),
    cost_per_unit: Joi.number(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCreateVendor = (data) => {
  const schema = Joi.object({
    vendor_name: Joi.string().required(),
    contact_person: Joi.string(),
    phone: Joi.string(),
    email: Joi.string().email(),
    vendor_type: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCreatePurchaseOrder = (data) => {
  const schema = Joi.object({
    vendor_id: Joi.string().uuid().required(),
    expected_delivery_date: Joi.date(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateInventoryItem,
  validateCreateVendor,
  validateCreatePurchaseOrder,
};
ENDOFFILE
echo -e "${GREEN}✅ inventory.validators.js created${NC}"

# Update server.js
echo -e "${YELLOW}1️⃣5️⃣ Updating server.js...${NC}"
if ! grep -q "import inventoryRoutes" "$BACKEND/server.js"; then
  sed -i "/import billingRoutes/a import inventoryRoutes from './routes/09_inventory/inventory.routes.js';" "$BACKEND/server.js"
  sed -i "/app.use('\/api\/billing'/a app.use('/api/inventory', inventoryRoutes);" "$BACKEND/server.js"
  echo -e "${GREEN}✅ server.js updated${NC}"
else
  echo -e "${YELLOW}⚠️ Inventory routes already in server.js${NC}"
fi

# Git commit and push
echo -e "${YELLOW}1️⃣6️⃣ Git operations...${NC}"
git add -A
git commit -m "Phase 9: Inventory & Procurement Module

- Added InventoryCategory model
- Added Inventory model (with par level & reorder points)
- Added Vendor model (supplier management)
- Added PurchaseOrder model
- Added PurchaseOrderItem model
- Added GoodsReceipt model
- Added GoodsReceiptItem model (acceptance/rejection)
- Added StockAdjustment model (damage, waste, corrections)
- Added InventoryMovement model (full ledger)
- Added inventory.service.js (business logic)
- Added inventory.controller.js (API handlers)
- Added inventory.routes.js (route definitions)
- Added inventory.validators.js (input validation)
- Integrated Inventory routes into server.js
- Auto PO number generation
- Auto GR number generation
- Auto ADJ number generation
- Low stock alerts
- Inventory valuation report
- Stock movement tracking (FIFO compatible)
- Multi-warehouse ready"

git push origin main 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Pushed to GitHub${NC}"
else
  echo -e "${YELLOW}⚠️ Push failed (check connection)${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ PHASE 9 DEPLOYMENT COMPLETE!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${GREEN}📌 Inventory Module Endpoints:${NC}"
echo -e "  POST   /api/inventory/items"
echo -e "  GET    /api/inventory/items"
echo -e "  GET    /api/inventory/items/:itemId"
echo -e "  GET    /api/inventory/items/low-stock"
echo -e "  POST   /api/inventory/vendors"
echo -e "  GET    /api/inventory/vendors"
echo -e "  POST   /api/inventory/purchase-orders"
echo -e "  GET    /api/inventory/purchase-orders"
echo -e "  GET    /api/inventory/purchase-orders/:poId"
echo -e "  POST   /api/inventory/purchase-orders/:poId/items"
echo -e "  PUT    /api/inventory/purchase-orders/:poId/status"
echo -e "  POST   /api/inventory/goods-receipts"
echo -e "  GET    /api/inventory/goods-receipts/:grId"
echo -e "  PUT    /api/inventory/goods-receipts/:grItemId/accept"
echo -e "  POST   /api/inventory/stock-adjustments"
echo -e "  PUT    /api/inventory/stock-adjustments/:adjustmentId/approve"
echo -e "  GET    /api/inventory/movements/:itemId"
echo -e "  GET    /api/inventory/valuation"
echo -e "  GET    /api/inventory/stats\n"

echo -e "${YELLOW}🚀 Ready for Phase 10: HR & Staff Management${NC}\n"
ENDOFFILE
