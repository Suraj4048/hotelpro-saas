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
