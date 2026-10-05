import Banquet from '../../models/Banquet.js';
import BanquetGuest from '../../models/BanquetGuest.js';
import BanquetMenu from '../../models/BanquetMenu.js';
import BanquetTable from '../../models/BanquetTable.js';
import BanquetTimeline from '../../models/BanquetTimeline.js';
import BanquetStaff from '../../models/BanquetStaff.js';
import BanquetPayment from '../../models/BanquetPayment.js';
import { Op } from 'sequelize';

// Banquet Management
export const createBanquet = async (orgId, data) => {
  const banquet = await Banquet.create({
    organization_id: orgId,
    ...data,
  });

  // Create payment record
  await BanquetPayment.create({
    banquet_id: banquet.id,
    base_cost: 0,
    per_head_rate: 0,
    total_amount: 0,
  });

  return banquet;
};

export const getBanquetById = async (banquetId) => {
  return await Banquet.findByPk(banquetId, {
    include: [
      { model: BanquetGuest },
      { model: BanquetMenu },
      { model: BanquetTable },
      { model: BanquetPayment },
    ],
  });
};

export const getAllBanquets = async (orgId, filters = {}) => {
  const where = { organization_id: orgId };
  if (filters.status) where.status = filters.status;
  if (filters.event_type) where.event_type = filters.event_type;
  if (filters.start_date) {
    where.event_date = { [Op.gte]: filters.start_date };
  }

  return await Banquet.findAll({
    where,
    include: [BanquetPayment],
    order: [['event_date', 'DESC']],
  });
};

export const updateBanquetStatus = async (banquetId, status) => {
  return await Banquet.update({ status }, { where: { id: banquetId } });
};

// Guest Management
export const addGuest = async (banquetId, guestData) => {
  return await BanquetGuest.create({
    banquet_id: banquetId,
    ...guestData,
  });
};

export const getAllGuests = async (banquetId) => {
  return await BanquetGuest.findAll({
    where: { banquet_id: banquetId },
  });
};

export const updateGuestRSVP = async (guestId, rsvp_status) => {
  const guest = await BanquetGuest.findByPk(guestId);
  if (guest) {
    await guest.update({ rsvp_status });
    // Update confirmed guests count
    const confirmedCount = await BanquetGuest.count({
      where: { banquet_id: guest.banquet_id, rsvp_status: 'confirmed' },
    });
    await Banquet.update({ confirmed_guests: confirmedCount }, { where: { id: guest.banquet_id } });
  }
  return guest;
};

export const checkInGuest = async (guestId) => {
  return await BanquetGuest.update(
    { check_in_status: 'checked_in', check_in_time: new Date() },
    { where: { id: guestId } }
  );
};

export const getGuestsByDietaryRequirements = async (banquetId, requirement) => {
  return await BanquetGuest.findAll({
    where: {
      banquet_id: banquetId,
      dietary_requirements: { [Op.iLike]: `%${requirement}%` },
    },
  });
};

// Menu Management
export const addMenuItemToBanquet = async (banquetId, menuItem) => {
  return await BanquetMenu.create({
    banquet_id: banquetId,
    ...menuItem,
  });
};

export const getBanquetMenu = async (banquetId) => {
  return await BanquetMenu.findAll({
    where: { banquet_id: banquetId },
    order: [['sequence', 'ASC']],
  });
};

export const updateMenuCost = async (menuItemId, unitPrice) => {
  return await BanquetMenu.update({ unit_price: unitPrice }, { where: { id: menuItemId } });
};

export const calculateMenuCost = async (banquetId) => {
  const banquet = await Banquet.findByPk(banquetId);
  const menuItems = await BanquetMenu.findAll({ where: { banquet_id: banquetId } });

  const totalMenuCost = menuItems.reduce((sum, item) => sum + (item.unit_price || 0), 0);
  const baseCost = totalMenuCost * banquet.expected_guests;

  const payment = await BanquetPayment.findOne({ where: { banquet_id: banquetId } });
  const tax = (baseCost * payment.tax_rate) / 100;
  const serviceCharge = (baseCost * payment.service_charge_rate) / 100;
  const total = baseCost + tax + serviceCharge - (payment.discount_amount || 0);

  await BanquetPayment.update(
    {
      base_cost: baseCost,
      per_head_rate: totalMenuCost,
      tax_amount: tax,
      service_charge: serviceCharge,
      total_amount: total,
      balance_due: total - payment.advance_paid,
    },
    { where: { banquet_id: banquetId } }
  );

  return {
    baseCost,
    tax,
    serviceCharge,
    total,
  };
};

// Table Management
export const createTable = async (banquetId, tableData) => {
  return await BanquetTable.create({
    banquet_id: banquetId,
    ...tableData,
  });
};

export const getAllTables = async (banquetId) => {
  return await BanquetTable.findAll({
    where: { banquet_id: banquetId },
    order: [['table_number', 'ASC']],
  });
};

export const assignGuestToTable = async (guestId, tableId) => {
  const table = await BanquetTable.findByPk(tableId);
  const guest = await BanquetGuest.findByPk(guestId);

  if (table && table.current_occupancy >= table.seating_capacity) {
    throw new Error('Table is full');
  }

  await guest.update({ table_assignment: tableId });
  await table.increment('current_occupancy');

  return guest;
};

export const updateTableStatus = async (tableId, status) => {
  return await BanquetTable.update({ status }, { where: { id: tableId } });
};

// Timeline Management
export const createTimelineEvent = async (banquetId, eventData) => {
  return await BanquetTimeline.create({
    banquet_id: banquetId,
    ...eventData,
  });
};

export const getBanquetTimeline = async (banquetId) => {
  return await BanquetTimeline.findAll({
    where: { banquet_id: banquetId },
    order: [['sequence', 'ASC']],
  });
};

export const updateTimelineEventStatus = async (eventId, status) => {
  return await BanquetTimeline.update({ status }, { where: { id: eventId } });
};

// Staff Management
export const assignStaffToBanquet = async (banquetId, staffData) => {
  return await BanquetStaff.create({
    banquet_id: banquetId,
    ...staffData,
  });
};

export const getBanquetStaff = async (banquetId) => {
  return await BanquetStaff.findAll({
    where: { banquet_id: banquetId },
  });
};

export const checkInStaff = async (staffAssignmentId) => {
  return await BanquetStaff.update(
    { status: 'confirmed', check_in_time: new Date() },
    { where: { id: staffAssignmentId } }
  );
};

// Payment Management
export const getPaymentDetails = async (banquetId) => {
  return await BanquetPayment.findOne({ where: { banquet_id: banquetId } });
};

export const recordAdvancePayment = async (banquetId, amount) => {
  const payment = await BanquetPayment.findOne({ where: { banquet_id: banquetId } });
  const newAdvancePaid = (payment.advance_paid || 0) + amount;
  const status = newAdvancePaid >= payment.total_amount ? 'completed' : 'partial';

  return await BanquetPayment.update(
    {
      advance_paid: newAdvancePaid,
      balance_due: payment.total_amount - newAdvancePaid,
      payment_status: status,
    },
    { where: { banquet_id: banquetId } }
  );
};

export const updateFinalGuestCount = async (banquetId, finalCount) => {
  const payment = await BanquetPayment.findOne({ where: { banquet_id: banquetId } });
  const perHeadRate = payment.per_head_rate;

  const newBaseCost = perHeadRate * finalCount;
  const tax = (newBaseCost * payment.tax_rate) / 100;
  const serviceCharge = (newBaseCost * payment.service_charge_rate) / 100;
  const finalAmount = newBaseCost + tax + serviceCharge - (payment.discount_amount || 0);
  const balanceDue = finalAmount - payment.advance_paid;

  return await BanquetPayment.update(
    {
      final_guest_count: finalCount,
      final_amount: finalAmount,
      balance_due: Math.max(0, balanceDue),
      payment_status: balanceDue <= 0 ? 'completed' : payment.payment_status,
    },
    { where: { banquet_id: banquetId } }
  );
};

// Analytics
export const getBanquetStats = async (orgId) => {
  const totalBanquets = await Banquet.count({ where: { organization_id: orgId } });
  const upcomingBanquets = await Banquet.count({
    where: {
      organization_id: orgId,
      event_date: { [Op.gte]: new Date() },
    },
  });

  const completedBanquets = await Banquet.findAll({
    where: {
      organization_id: orgId,
      status: 'completed',
    },
    include: [BanquetPayment],
  });

  const totalRevenue = completedBanquets.reduce((sum, b) => sum + (b.banquet_payment?.final_amount || 0), 0);

  return {
    totalBanquets,
    upcomingBanquets,
    completedBanquets: completedBanquets.length,
    totalRevenue,
  };
};

export default {
  createBanquet, getBanquetById, getAllBanquets, updateBanquetStatus,
  addGuest, getAllGuests, updateGuestRSVP, checkInGuest, getGuestsByDietaryRequirements,
  addMenuItemToBanquet, getBanquetMenu, updateMenuCost, calculateMenuCost,
  createTable, getAllTables, assignGuestToTable, updateTableStatus,
  createTimelineEvent, getBanquetTimeline, updateTimelineEventStatus,
  assignStaffToBanquet, getBanquetStaff, checkInStaff,
  getPaymentDetails, recordAdvancePayment, updateFinalGuestCount,
  getBanquetStats,
};
