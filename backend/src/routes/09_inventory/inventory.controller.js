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
