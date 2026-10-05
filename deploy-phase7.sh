#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}🎉 Phase 7: Banquet Module Deployment${NC}"
echo -e "${YELLOW}========================================${NC}\n"

REPO="/workspaces/hotelpro-saas"
BACKEND="$REPO/backend/src"

cd "$REPO" || exit 1

# Create directories
echo -e "${YELLOW}1️⃣ Creating directories...${NC}"
mkdir -p "$BACKEND/routes/07_banquet"
mkdir -p "$BACKEND/models"
echo -e "${GREEN}✅ Directories created${NC}\n"

# Create Banquet model
echo -e "${YELLOW}2️⃣ Creating Banquet.js...${NC}"
cat > "$BACKEND/models/Banquet.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Banquet = sequelize.define('Banquet', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  organization_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'organizations', key: 'id' },
  },
  event_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  event_type: {
    type: DataTypes.ENUM('Wedding', 'Corporate', 'Birthday', 'Anniversary', 'Conference', 'Social', 'Other'),
    allowNull: false,
  },
  event_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  event_time: {
    type: DataTypes.TIME,
    allowNull: false,
  },
  expected_duration: {
    type: DataTypes.INTEGER,
    comment: 'in minutes',
  },
  expected_guests: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  confirmed_guests: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  location: {
    type: DataTypes.STRING,
  },
  description: {
    type: DataTypes.TEXT,
  },
  theme: {
    type: DataTypes.STRING,
  },
  status: {
    type: DataTypes.ENUM('enquiry', 'proposed', 'confirmed', 'in_progress', 'completed', 'cancelled'),
    defaultValue: 'enquiry',
  },
  booking_date: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  contact_person: {
    type: DataTypes.STRING,
  },
  contact_phone: {
    type: DataTypes.STRING,
  },
  contact_email: {
    type: DataTypes.STRING,
  },
  special_requirements: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'banquets',
});

export default Banquet;
ENDOFFILE
echo -e "${GREEN}✅ Banquet.js created${NC}"

# Create BanquetGuest model
echo -e "${YELLOW}3️⃣ Creating BanquetGuest.js...${NC}"
cat > "$BACKEND/models/BanquetGuest.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BanquetGuest = sequelize.define('BanquetGuest', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  banquet_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'banquets', key: 'id' },
  },
  guest_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  guest_phone: {
    type: DataTypes.STRING,
  },
  guest_email: {
    type: DataTypes.STRING,
  },
  guest_category: {
    type: DataTypes.STRING,
    comment: 'VIP, Family, Friend, Colleague',
  },
  dietary_requirements: {
    type: DataTypes.TEXT,
    comment: 'Veg, Non-Veg, Allergies, etc.',
  },
  meal_preference: {
    type: DataTypes.STRING,
  },
  table_assignment: {
    type: DataTypes.UUID,
    references: { model: 'banquet_tables', key: 'id' },
  },
  rsvp_status: {
    type: DataTypes.ENUM('pending', 'confirmed', 'declined', 'not_responded'),
    defaultValue: 'pending',
  },
  check_in_status: {
    type: DataTypes.ENUM('pending', 'checked_in', 'left'),
    defaultValue: 'pending',
  },
  check_in_time: {
    type: DataTypes.DATE,
  },
}, {
  timestamps: true,
  tableName: 'banquet_guests',
});

export default BanquetGuest;
ENDOFFILE
echo -e "${GREEN}✅ BanquetGuest.js created${NC}"

# Create BanquetMenu model
echo -e "${YELLOW}4️⃣ Creating BanquetMenu.js...${NC}"
cat > "$BACKEND/models/BanquetMenu.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BanquetMenu = sequelize.define('BanquetMenu', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  banquet_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'banquets', key: 'id' },
  },
  item_id: {
    type: DataTypes.UUID,
    comment: 'Can be from menu_items or drinks table',
  },
  item_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  item_category: {
    type: DataTypes.STRING,
    comment: 'Starter, Main, Dessert, Beverage, etc.',
  },
  item_type: {
    type: DataTypes.ENUM('restaurant', 'bar', 'custom'),
    defaultValue: 'restaurant',
  },
  quantity: {
    type: DataTypes.INTEGER,
    comment: 'per person or total',
  },
  unit_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  vegetarian: {
    type: DataTypes.BOOLEAN,
  },
  vegan: {
    type: DataTypes.BOOLEAN,
  },
  description: {
    type: DataTypes.TEXT,
  },
  sequence: {
    type: DataTypes.INTEGER,
    comment: 'course order (1=starter, 2=main)',
  },
}, {
  timestamps: true,
  tableName: 'banquet_menus',
});

export default BanquetMenu;
ENDOFFILE
echo -e "${GREEN}✅ BanquetMenu.js created${NC}"

# Create BanquetTable model
echo -e "${YELLOW}5️⃣ Creating BanquetTable.js...${NC}"
cat > "$BACKEND/models/BanquetTable.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BanquetTable = sequelize.define('BanquetTable', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  banquet_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'banquets', key: 'id' },
  },
  table_number: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  seating_capacity: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  current_occupancy: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  table_type: {
    type: DataTypes.STRING,
    comment: 'VIP, Regular, Kids, High Table',
  },
  location: {
    type: DataTypes.STRING,
    comment: 'Floor, Zone (e.g., "Main Hall - Zone A")',
  },
  status: {
    type: DataTypes.ENUM('available', 'reserved', 'occupied', 'served'),
    defaultValue: 'available',
  },
  assigned_server: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
}, {
  timestamps: true,
  tableName: 'banquet_tables',
});

export default BanquetTable;
ENDOFFILE
echo -e "${GREEN}✅ BanquetTable.js created${NC}"

# Create BanquetTimeline model
echo -e "${YELLOW}6️⃣ Creating BanquetTimeline.js...${NC}"
cat > "$BACKEND/models/BanquetTimeline.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BanquetTimeline = sequelize.define('BanquetTimeline', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  banquet_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'banquets', key: 'id' },
  },
  event_name: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'Welcome Drinks, Speeches, Dinner, Cake Cutting, DJ, etc.',
  },
  scheduled_time: {
    type: DataTypes.TIME,
    allowNull: false,
  },
  duration_minutes: {
    type: DataTypes.INTEGER,
  },
  assigned_staff: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  description: {
    type: DataTypes.TEXT,
  },
  status: {
    type: DataTypes.ENUM('pending', 'in_progress', 'completed', 'skipped'),
    defaultValue: 'pending',
  },
  notes: {
    type: DataTypes.TEXT,
  },
  sequence: {
    type: DataTypes.INTEGER,
    comment: 'Order of events',
  },
}, {
  timestamps: true,
  tableName: 'banquet_timelines',
});

export default BanquetTimeline;
ENDOFFILE
echo -e "${GREEN}✅ BanquetTimeline.js created${NC}"

# Create BanquetStaff model
echo -e "${YELLOW}7️⃣ Creating BanquetStaff.js...${NC}"
cat > "$BACKEND/models/BanquetStaff.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BanquetStaff = sequelize.define('BanquetStaff', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  banquet_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'banquets', key: 'id' },
  },
  staff_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' },
  },
  role: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'Coordinator, Server, Chef, Bartender, Decorator',
  },
  assignment_date: {
    type: DataTypes.DATE,
  },
  status: {
    type: DataTypes.ENUM('assigned', 'confirmed', 'completed', 'absent'),
    defaultValue: 'assigned',
  },
  check_in_time: {
    type: DataTypes.DATE,
  },
  check_out_time: {
    type: DataTypes.DATE,
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'banquet_staff',
});

export default BanquetStaff;
ENDOFFILE
echo -e "${GREEN}✅ BanquetStaff.js created${NC}"

# Create BanquetPayment model
echo -e "${YELLOW}8️⃣ Creating BanquetPayment.js...${NC}"
cat > "$BACKEND/models/BanquetPayment.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BanquetPayment = sequelize.define('BanquetPayment', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  banquet_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'banquets', key: 'id' },
  },
  base_cost: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false,
    comment: 'Menu cost × expected guests',
  },
  per_head_rate: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    comment: 'Final rate per person',
  },
  tax_rate: {
    type: DataTypes.DECIMAL(5, 2),
    defaultValue: 18.00,
  },
  service_charge_rate: {
    type: DataTypes.DECIMAL(5, 2),
    defaultValue: 10.00,
  },
  tax_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  service_charge: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  discount_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  total_amount: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false,
  },
  advance_paid: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  balance_due: {
    type: DataTypes.DECIMAL(12, 2),
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'partial', 'completed', 'refunded'),
    defaultValue: 'pending',
  },
  final_guest_count: {
    type: DataTypes.INTEGER,
  },
  final_amount: {
    type: DataTypes.DECIMAL(12, 2),
    comment: 'Actual amount after final guest count',
  },
}, {
  timestamps: true,
  tableName: 'banquet_payments',
});

export default BanquetPayment;
ENDOFFILE
echo -e "${GREEN}✅ BanquetPayment.js created${NC}"

# Create banquet.service.js
echo -e "${YELLOW}9️⃣ Creating banquet.service.js...${NC}"
cat > "$BACKEND/routes/07_banquet/banquet.service.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ banquet.service.js created${NC}"

# Create banquet.controller.js
echo -e "${YELLOW}1️⃣0️⃣ Creating banquet.controller.js...${NC}"
cat > "$BACKEND/routes/07_banquet/banquet.controller.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ banquet.controller.js created${NC}"

# Create banquet.routes.js
echo -e "${YELLOW}1️⃣1️⃣ Creating banquet.routes.js...${NC}"
cat > "$BACKEND/routes/07_banquet/banquet.routes.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ banquet.routes.js created${NC}"

# Create banquet.validators.js
echo -e "${YELLOW}1️⃣2️⃣ Creating banquet.validators.js...${NC}"
cat > "$BACKEND/routes/07_banquet/banquet.validators.js" << 'ENDOFFILE'
import Joi from 'joi';

export const validateCreateBanquet = (data) => {
  const schema = Joi.object({
    event_name: Joi.string().required(),
    event_type: Joi.string().required(),
    event_date: Joi.date().required(),
    event_time: Joi.string().required(),
    expected_guests: Joi.number().required().min(1),
    contact_person: Joi.string(),
    contact_phone: Joi.string(),
    contact_email: Joi.string().email(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateAddGuest = (data) => {
  const schema = Joi.object({
    guest_name: Joi.string().required(),
    guest_phone: Joi.string(),
    guest_email: Joi.string().email(),
    dietary_requirements: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateAddMenuItemToBanquet = (data) => {
  const schema = Joi.object({
    item_name: Joi.string().required(),
    item_category: Joi.string().required(),
    unit_price: Joi.number().required().positive(),
    quantity: Joi.number(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCreateTable = (data) => {
  const schema = Joi.object({
    table_number: Joi.string().required(),
    seating_capacity: Joi.number().required().min(1),
    table_type: Joi.string(),
    location: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateBanquet,
  validateAddGuest,
  validateAddMenuItemToBanquet,
  validateCreateTable,
};
ENDOFFILE
echo -e "${GREEN}✅ banquet.validators.js created${NC}"

# Update server.js
echo -e "${YELLOW}1️⃣3️⃣ Updating server.js...${NC}"
if ! grep -q "import banquetRoutes" "$BACKEND/server.js"; then
  sed -i "/import barRoutes/a import banquetRoutes from './routes/07_banquet/banquet.routes.js';" "$BACKEND/server.js"
  sed -i "/app.use('\/api\/bar'/a app.use('/api/banquets', banquetRoutes);" "$BACKEND/server.js"
  echo -e "${GREEN}✅ server.js updated${NC}"
else
  echo -e "${YELLOW}⚠️ Banquet routes already in server.js${NC}"
fi

# Git commit and push
echo -e "${YELLOW}1️⃣4️⃣ Git operations...${NC}"
git add -A
git commit -m "Phase 7: Banquet Module

- Added Banquet model
- Added BanquetGuest model
- Added BanquetMenu model
- Added BanquetTable model
- Added BanquetTimeline model
- Added BanquetStaff model
- Added BanquetPayment model
- Added banquet.service.js (business logic)
- Added banquet.controller.js (API handlers)
- Added banquet.routes.js (route definitions)
- Added banquet.validators.js (input validation)
- Integrated Banquet routes into server.js"

git push origin main 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Pushed to GitHub${NC}"
else
  echo -e "${YELLOW}⚠️ Push failed (check connection)${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ PHASE 7 DEPLOYMENT COMPLETE!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${GREEN}📌 Banquet Module Endpoints:${NC}"
echo -e "  POST   /api/banquets"
echo -e "  GET    /api/banquets"
echo -e "  GET    /api/banquets/:banquetId"
echo -e "  PUT    /api/banquets/:banquetId/status"
echo -e "  POST   /api/banquets/:banquetId/guests"
echo -e "  GET    /api/banquets/:banquetId/guests"
echo -e "  PUT    /api/banquets/guests/:guestId/rsvp"
echo -e "  PUT    /api/banquets/guests/:guestId/check-in"
echo -e "  POST   /api/banquets/:banquetId/menu"
echo -e "  GET    /api/banquets/:banquetId/menu"
echo -e "  POST   /api/banquets/:banquetId/tables"
echo -e "  GET    /api/banquets/:banquetId/tables"
echo -e "  PUT    /api/banquets/guests/:guestId/assign-table"
echo -e "  POST   /api/banquets/:banquetId/timeline"
echo -e "  GET    /api/banquets/:banquetId/timeline"
echo -e "  POST   /api/banquets/:banquetId/staff"
echo -e "  GET    /api/banquets/:banquetId/staff"
echo -e "  GET    /api/banquets/:banquetId/payment"
echo -e "  POST   /api/banquets/:banquetId/payment/advance"
echo -e "  PUT    /api/banquets/:banquetId/payment/final-count"
echo -e "  GET    /api/banquets/stats\n"

echo -e "${YELLOW}🚀 Ready for Phase 8: Billing & Accounts Module${NC}\n"
ENDOFFILE
