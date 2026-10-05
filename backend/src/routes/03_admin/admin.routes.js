import express from 'express';
import * as adminController from './admin.controller.js';
import { checkRoleAccess } from '../../middleware/authMiddleware.js';

const router = express.Router();
router.use(checkRoleAccess('SUPER_ADMIN'));

router.get('/plans', adminController.getAllPlans);
router.get('/clients', adminController.getAllClients);
router.get('/clients/:clientId', adminController.getClientById);
router.post('/clients/:clientId/subscription', adminController.createClientSubscription);
router.get('/dashboard', adminController.getAdminDashboard);

export default router;
