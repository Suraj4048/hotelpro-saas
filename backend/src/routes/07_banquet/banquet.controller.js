import * as banquetService from './banquet.service.js';

// Banquet Management
export const createBanquet = async (req, res) => {
  try {
    const banquet = await banquetService.createBanquet(req.user.organizationId, req.body);
    return res.status(201).json({ success: true, data: banquet });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getBanquetById = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const banquet = await banquetService.getBanquetById(banquetId);
    if (!banquet) return res.status(404).json({ success: false, error: 'Banquet not found' });
    return res.json({ success: true, data: banquet });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getAllBanquets = async (req, res) => {
  try {
    const filters = req.query;
    const banquets = await banquetService.getAllBanquets(req.user.organizationId, filters);
    return res.json({ success: true, data: banquets, count: banquets.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const updateBanquetStatus = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const { status } = req.body;
    await banquetService.updateBanquetStatus(banquetId, status);
    return res.json({ success: true, message: 'Banquet status updated' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Guest Management
export const addGuest = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const guest = await banquetService.addGuest(banquetId, req.body);
    return res.status(201).json({ success: true, data: guest });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getAllGuests = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const guests = await banquetService.getAllGuests(banquetId);
    return res.json({ success: true, data: guests, count: guests.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const updateGuestRSVP = async (req, res) => {
  try {
    const { guestId } = req.params;
    const { rsvp_status } = req.body;
    const guest = await banquetService.updateGuestRSVP(guestId, rsvp_status);
    return res.json({ success: true, data: guest });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const checkInGuest = async (req, res) => {
  try {
    const { guestId } = req.params;
    await banquetService.checkInGuest(guestId);
    return res.json({ success: true, message: 'Guest checked in' });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Menu Management
export const addMenuItemToBanquet = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const menuItem = await banquetService.addMenuItemToBanquet(banquetId, req.body);
    await banquetService.calculateMenuCost(banquetId);
    return res.status(201).json({ success: true, data: menuItem });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getBanquetMenu = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const menu = await banquetService.getBanquetMenu(banquetId);
    return res.json({ success: true, data: menu });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

// Table Management
export const createTable = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const table = await banquetService.createTable(banquetId, req.body);
    return res.status(201).json({ success: true, data: table });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getAllTables = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const tables = await banquetService.getAllTables(banquetId);
    return res.json({ success: true, data: tables });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const assignGuestToTable = async (req, res) => {
  try {
    const { guestId } = req.params;
    const { tableId } = req.body;
    const guest = await banquetService.assignGuestToTable(guestId, tableId);
    return res.json({ success: true, data: guest });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Timeline Management
export const createTimelineEvent = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const event = await banquetService.createTimelineEvent(banquetId, req.body);
    return res.status(201).json({ success: true, data: event });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getBanquetTimeline = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const timeline = await banquetService.getBanquetTimeline(banquetId);
    return res.json({ success: true, data: timeline });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

// Staff Management
export const assignStaffToBanquet = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const staffAssignment = await banquetService.assignStaffToBanquet(banquetId, req.body);
    return res.status(201).json({ success: true, data: staffAssignment });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getBanquetStaff = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const staff = await banquetService.getBanquetStaff(banquetId);
    return res.json({ success: true, data: staff });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

// Payment Management
export const getPaymentDetails = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const payment = await banquetService.getPaymentDetails(banquetId);
    return res.json({ success: true, data: payment });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const recordAdvancePayment = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const { amount } = req.body;
    await banquetService.recordAdvancePayment(banquetId, amount);
    const payment = await banquetService.getPaymentDetails(banquetId);
    return res.json({ success: true, data: payment });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const updateFinalGuestCount = async (req, res) => {
  try {
    const { banquetId } = req.params;
    const { finalCount } = req.body;
    await banquetService.updateFinalGuestCount(banquetId, finalCount);
    const payment = await banquetService.getPaymentDetails(banquetId);
    return res.json({ success: true, data: payment });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

// Analytics
export const getBanquetStats = async (req, res) => {
  try {
    const stats = await banquetService.getBanquetStats(req.user.organizationId);
    return res.json({ success: true, data: stats });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export default {
  createBanquet, getBanquetById, getAllBanquets, updateBanquetStatus,
  addGuest, getAllGuests, updateGuestRSVP, checkInGuest,
  addMenuItemToBanquet, getBanquetMenu,
  createTable, getAllTables, assignGuestToTable,
  createTimelineEvent, getBanquetTimeline,
  assignStaffToBanquet, getBanquetStaff,
  getPaymentDetails, recordAdvancePayment, updateFinalGuestCount,
  getBanquetStats,
};
