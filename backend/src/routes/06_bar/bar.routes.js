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
