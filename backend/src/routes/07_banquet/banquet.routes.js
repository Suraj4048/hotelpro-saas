import express from 'express';
import * as banquetController from './banquet.controller.js';
import { checkModuleAccess } from '../../middleware/authMiddleware.js';

const router = express.Router();
router.use(checkModuleAccess('banquet'));

// Banquet Management
router.post('/', banquetController.createBanquet);
router.get('/', banquetController.getAllBanquets);
router.get('/:banquetId', banquetController.getBanquetById);
router.put('/:banquetId/status', banquetController.updateBanquetStatus);

// Guest Management
router.post('/:banquetId/guests', banquetController.addGuest);
router.get('/:banquetId/guests', banquetController.getAllGuests);
router.put('/guests/:guestId/rsvp', banquetController.updateGuestRSVP);
router.put('/guests/:guestId/check-in', banquetController.checkInGuest);

// Menu Management
router.post('/:banquetId/menu', banquetController.addMenuItemToBanquet);
router.get('/:banquetId/menu', banquetController.getBanquetMenu);

// Table Management
router.post('/:banquetId/tables', banquetController.createTable);
router.get('/:banquetId/tables', banquetController.getAllTables);
router.put('/guests/:guestId/assign-table', banquetController.assignGuestToTable);

// Timeline Management
router.post('/:banquetId/timeline', banquetController.createTimelineEvent);
router.get('/:banquetId/timeline', banquetController.getBanquetTimeline);

// Staff Management
router.post('/:banquetId/staff', banquetController.assignStaffToBanquet);
router.get('/:banquetId/staff', banquetController.getBanquetStaff);

// Payment Management
router.get('/:banquetId/payment', banquetController.getPaymentDetails);
router.post('/:banquetId/payment/advance', banquetController.recordAdvancePayment);
router.put('/:banquetId/payment/final-count', banquetController.updateFinalGuestCount);

// Analytics
router.get('/stats', banquetController.getBanquetStats);

export default router;
