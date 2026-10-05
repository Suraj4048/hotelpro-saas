import express from 'express';
import * as pmsController from './pms.controller.js';
import { checkModuleAccess } from '../../middleware/authMiddleware.js';

const router = express.Router();
router.use(checkModuleAccess('pms'));

// Room Types
router.get('/room-types', pmsController.getAllRoomTypes);
router.post('/room-types', pmsController.createRoomType);

// Rooms
router.get('/rooms', pmsController.getAllRooms);
router.get('/rooms/status/:status', pmsController.getRoomsByStatus);
router.post('/rooms', pmsController.createRoom);
router.put('/rooms/:roomId/status', pmsController.updateRoomStatus);

// Reservations
router.post('/reservations', pmsController.createReservation);
router.get('/reservations', pmsController.getReservations);
router.get('/arrivals/today', pmsController.getTodayArrivals);
router.get('/departures/today', pmsController.getTodayDepartures);

// Check-In/Out
router.post('/check-in', pmsController.checkInGuest);
router.post('/check-out', pmsController.checkOutGuest);

// Stats
router.get('/occupancy', pmsController.getOccupancyStats);

export default router;
