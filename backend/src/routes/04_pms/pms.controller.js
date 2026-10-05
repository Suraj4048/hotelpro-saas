import * as pmsService from './pms.service.js';

// Room Types
export const getAllRoomTypes = async (req, res) => {
  try {
    const types = await pmsService.getAllRoomTypes(req.user.organizationId);
    return res.json({ success: true, data: types });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const createRoomType = async (req, res) => {
  try {
    const type = await pmsService.createRoomType(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: type });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Rooms
export const getAllRooms = async (req, res) => {
  try {
    const rooms = await pmsService.getAllRooms(req.user.organizationId);
    return res.json({ success: true, data: rooms, count: rooms.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getRoomsByStatus = async (req, res) => {
  try {
    const { status } = req.params;
    const rooms = await pmsService.getRoomsByStatus(req.user.organizationId, status);
    return res.json({ success: true, data: rooms });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const createRoom = async (req, res) => {
  try {
    const room = await pmsService.createRoom(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: room });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const updateRoomStatus = async (req, res) => {
  try {
    const { roomId } = req.params;
    const { status } = req.body;
    const room = await pmsService.updateRoomStatus(roomId, status);
    return res.json({ success: true, data: room });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Reservations
export const createReservation = async (req, res) => {
  try {
    const reservation = await pmsService.createReservation(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: reservation });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getReservations = async (req, res) => {
  try {
    const { status, check_in_date } = req.query;
    const reservations = await pmsService.getReservations(req.user.organizationId, 
      { status, check_in_date });
    return res.json({ success: true, data: reservations });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getTodayArrivals = async (req, res) => {
  try {
    const arrivals = await pmsService.getTodayArrivals(req.user.organizationId);
    return res.json({ success: true, data: arrivals });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getTodayDepartures = async (req, res) => {
  try {
    const departures = await pmsService.getTodayDepartures(req.user.organizationId);
    return res.json({ success: true, data: departures });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

// Check-In/Out
export const checkInGuest = async (req, res) => {
  try {
    const checkIn = await pmsService.checkInGuest(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: checkIn });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const checkOutGuest = async (req, res) => {
  try {
    const checkOut = await pmsService.checkOutGuest(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: checkOut });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Stats
export const getOccupancyStats = async (req, res) => {
  try {
    const stats = await pmsService.getOccupancyStats(req.user.organizationId);
    return res.json({ success: true, data: stats });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export default {
  getAllRoomTypes, createRoomType,
  getAllRooms, getRoomsByStatus, createRoom, updateRoomStatus,
  createReservation, getReservations, getTodayArrivals, getTodayDepartures,
  checkInGuest, checkOutGuest,
  getOccupancyStats,
};
