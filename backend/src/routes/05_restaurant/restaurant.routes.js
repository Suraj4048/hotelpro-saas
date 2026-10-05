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
