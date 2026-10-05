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
