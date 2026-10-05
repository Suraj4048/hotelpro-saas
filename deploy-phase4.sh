#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}🏨 Phase 4: PMS Module Deployment${NC}"
echo -e "${YELLOW}========================================${NC}\n"

REPO="/workspaces/hotelpro-saas"
BACKEND="$REPO/backend/src"

cd "$REPO" || exit 1

# Create directories
echo -e "${YELLOW}1️⃣ Creating directories...${NC}"
mkdir -p "$BACKEND/routes/04_pms"
mkdir -p "$BACKEND/models"
echo -e "${GREEN}✅ Directories created${NC}\n"

# Create RoomType model
echo -e "${YELLOW}2️⃣ Creating RoomType.js...${NC}"
cat > "$BACKEND/models/RoomType.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const RoomType = sequelize.define('RoomType', {
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
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
  },
  base_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  max_occupancy: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  amenities: {
    type: DataTypes.JSON,
    defaultValue: [],
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'room_types',
});

export default RoomType;
ENDOFFILE
echo -e "${GREEN}✅ RoomType.js created${NC}"

# Create Room model
echo -e "${YELLOW}3️⃣ Creating Room.js...${NC}"
cat > "$BACKEND/models/Room.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Room = sequelize.define('Room', {
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
  room_type_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'room_types', key: 'id' },
  },
  room_number: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  floor: {
    type: DataTypes.INTEGER,
  },
  status: {
    type: DataTypes.ENUM('available', 'occupied', 'maintenance', 'blocked'),
    defaultValue: 'available',
  },
  current_guest_id: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'rooms',
});

export default Room;
ENDOFFILE
echo -e "${GREEN}✅ Room.js created${NC}"

# Create Reservation model
echo -e "${YELLOW}4️⃣ Creating Reservation.js...${NC}"
cat > "$BACKEND/models/Reservation.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Reservation = sequelize.define('Reservation', {
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
  guest_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  guest_email: {
    type: DataTypes.STRING,
  },
  guest_phone: {
    type: DataTypes.STRING,
  },
  room_type_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'room_types', key: 'id' },
  },
  check_in_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  check_out_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  number_of_guests: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('pending', 'confirmed', 'checked_in', 'checked_out', 'cancelled'),
    defaultValue: 'pending',
  },
  total_price: {
    type: DataTypes.DECIMAL(10, 2),
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'reservations',
});

export default Reservation;
ENDOFFILE
echo -e "${GREEN}✅ Reservation.js created${NC}"

# Create CheckIn model
echo -e "${YELLOW}5️⃣ Creating CheckIn.js...${NC}"
cat > "$BACKEND/models/CheckIn.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const CheckIn = sequelize.define('CheckIn', {
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
  reservation_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'reservations', key: 'id' },
  },
  room_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'rooms', key: 'id' },
  },
  actual_check_in_time: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  room_condition: {
    type: DataTypes.STRING,
  },
  key_issued: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'check_ins',
});

export default CheckIn;
ENDOFFILE
echo -e "${GREEN}✅ CheckIn.js created${NC}"

# Create CheckOut model
echo -e "${YELLOW}6️⃣ Creating CheckOut.js...${NC}"
cat > "$BACKEND/models/CheckOut.js" << 'ENDOFFILE'
import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const CheckOut = sequelize.define('CheckOut', {
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
  check_in_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'check_ins', key: 'id' },
  },
  room_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'rooms', key: 'id' },
  },
  actual_check_out_time: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  room_condition: {
    type: DataTypes.STRING,
  },
  key_returned: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  damage_charges: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'check_outs',
});

export default CheckOut;
ENDOFFILE
echo -e "${GREEN}✅ CheckOut.js created${NC}"

# Create pms.service.js
echo -e "${YELLOW}7️⃣ Creating pms.service.js...${NC}"
cat > "$BACKEND/routes/04_pms/pms.service.js" << 'ENDOFFILE'
import RoomType from '../../models/RoomType.js';
import Room from '../../models/Room.js';
import Reservation from '../../models/Reservation.js';
import CheckIn from '../../models/CheckIn.js';
import CheckOut from '../../models/CheckOut.js';
import { Op } from 'sequelize';

// Room Types
export const getAllRoomTypes = async (orgId) => {
  return await RoomType.findAll({
    where: { organization_id: orgId, is_active: true },
  });
};

export const createRoomType = async (orgId, data) => {
  return await RoomType.create({ organization_id: orgId, ...data });
};

// Rooms
export const getAllRooms = async (orgId) => {
  return await Room.findAll({
    where: { organization_id: orgId },
    include: [RoomType],
  });
};

export const getRoomsByStatus = async (orgId, status) => {
  return await Room.findAll({
    where: { organization_id: orgId, status },
    include: [RoomType],
  });
};

export const createRoom = async (orgId, data) => {
  return await Room.create({ organization_id: orgId, ...data });
};

export const updateRoomStatus = async (roomId, status) => {
  const room = await Room.findByPk(roomId);
  if (!room) throw new Error('Room not found');
  return await room.update({ status });
};

// Reservations
export const createReservation = async (orgId, data) => {
  const checkInDate = new Date(data.check_in_date);
  const checkOutDate = new Date(data.check_out_date);
  const nights = Math.ceil((checkOutDate - checkInDate) / (1000 * 60 * 60 * 24));
  
  const roomType = await RoomType.findByPk(data.room_type_id);
  const totalPrice = roomType.base_price * nights;

  return await Reservation.create({
    organization_id: orgId,
    ...data,
    total_price: totalPrice,
  });
};

export const getReservations = async (orgId, filters = {}) => {
  const where = { organization_id: orgId };
  if (filters.status) where.status = filters.status;
  if (filters.check_in_date) {
    where.check_in_date = {
      [Op.gte]: new Date(filters.check_in_date),
    };
  }

  return await Reservation.findAll({
    where,
    include: [RoomType],
    order: [['check_in_date', 'ASC']],
  });
};

export const getTodayArrivals = async (orgId) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);

  return await Reservation.findAll({
    where: {
      organization_id: orgId,
      check_in_date: { [Op.between]: [today, tomorrow] },
      status: { [Op.in]: ['confirmed', 'pending'] },
    },
    include: [RoomType],
  });
};

export const getTodayDepartures = async (orgId) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);

  return await Reservation.findAll({
    where: {
      organization_id: orgId,
      check_out_date: { [Op.between]: [today, tomorrow] },
      status: { [Op.in]: ['checked_in'] },
    },
    include: [RoomType],
  });
};

// Check-In
export const checkInGuest = async (orgId, data) => {
  const reservation = await Reservation.findByPk(data.reservation_id);
  if (!reservation) throw new Error('Reservation not found');

  const checkIn = await CheckIn.create({
    organization_id: orgId,
    ...data,
  });

  await reservation.update({ status: 'checked_in' });
  await Room.update({ status: 'occupied', current_guest_id: data.room_id }, 
    { where: { id: data.room_id } });

  return checkIn;
};

// Check-Out
export const checkOutGuest = async (orgId, data) => {
  const checkIn = await CheckIn.findByPk(data.check_in_id);
  if (!checkIn) throw new Error('Check-in not found');

  const checkOut = await CheckOut.create({
    organization_id: orgId,
    ...data,
  });

  const reservation = await Reservation.findByPk(checkIn.reservation_id);
  await reservation.update({ status: 'checked_out' });
  
  await Room.update({ status: 'available', current_guest_id: null },
    { where: { id: data.room_id } });

  return checkOut;
};

// Occupancy Stats
export const getOccupancyStats = async (orgId) => {
  const totalRooms = await Room.count({ where: { organization_id: orgId } });
  const occupiedRooms = await Room.count({ 
    where: { organization_id: orgId, status: 'occupied' } 
  });
  const availableRooms = await Room.count({
    where: { organization_id: orgId, status: 'available' }
  });

  return {
    totalRooms,
    occupiedRooms,
    availableRooms,
    occupancyRate: totalRooms > 0 ? ((occupiedRooms / totalRooms) * 100).toFixed(2) : 0,
  };
};

export default {
  getAllRoomTypes, createRoomType,
  getAllRooms, getRoomsByStatus, createRoom, updateRoomStatus,
  createReservation, getReservations, getTodayArrivals, getTodayDepartures,
  checkInGuest, checkOutGuest,
  getOccupancyStats,
};
ENDOFFILE
echo -e "${GREEN}✅ pms.service.js created${NC}"

# Create pms.controller.js
echo -e "${YELLOW}8️⃣ Creating pms.controller.js...${NC}"
cat > "$BACKEND/routes/04_pms/pms.controller.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ pms.controller.js created${NC}"

# Create pms.routes.js
echo -e "${YELLOW}9️⃣ Creating pms.routes.js...${NC}"
cat > "$BACKEND/routes/04_pms/pms.routes.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ pms.routes.js created${NC}"

# Create pms.validators.js
echo -e "${YELLOW}🔟 Creating pms.validators.js...${NC}"
cat > "$BACKEND/routes/04_pms/pms.validators.js" << 'ENDOFFILE'
import Joi from 'joi';

export const validateCreateReservation = (data) => {
  const schema = Joi.object({
    guest_name: Joi.string().required(),
    guest_email: Joi.string().email(),
    guest_phone: Joi.string(),
    room_type_id: Joi.string().uuid().required(),
    check_in_date: Joi.date().required(),
    check_out_date: Joi.date().required(),
    number_of_guests: Joi.number().required(),
    notes: Joi.string(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCheckIn = (data) => {
  const schema = Joi.object({
    reservation_id: Joi.string().uuid().required(),
    room_id: Joi.string().uuid().required(),
    room_condition: Joi.string(),
    key_issued: Joi.boolean(),
  });
  return schema.validate(data, { abortEarly: false });
};

export const validateCheckOut = (data) => {
  const schema = Joi.object({
    check_in_id: Joi.string().uuid().required(),
    room_id: Joi.string().uuid().required(),
    room_condition: Joi.string(),
    key_returned: Joi.boolean(),
    damage_charges: Joi.number().min(0),
  });
  return schema.validate(data, { abortEarly: false });
};

export default {
  validateCreateReservation,
  validateCheckIn,
  validateCheckOut,
};
ENDOFFILE
echo -e "${GREEN}✅ pms.validators.js created${NC}"

# Update server.js
echo -e "${YELLOW}1️⃣1️⃣ Updating server.js...${NC}"
if ! grep -q "import pmsRoutes" "$BACKEND/server.js"; then
  sed -i "/import adminRoutes/a import pmsRoutes from './routes/04_pms/pms.routes.js';" "$BACKEND/server.js"
  sed -i "/app.use('\/api\/admin'/a app.use('/api/pms', pmsRoutes);" "$BACKEND/server.js"
  echo -e "${GREEN}✅ server.js updated${NC}"
else
  echo -e "${YELLOW}⚠️ PMS routes already in server.js${NC}"
fi

# Git commit and push
echo -e "${YELLOW}1️⃣2️⃣ Git operations...${NC}"
git add -A
git commit -m "Phase 4: PMS Module - Property Management System

- Added RoomType model
- Added Room model
- Added Reservation model
- Added CheckIn model
- Added CheckOut model
- Added pms.service.js (business logic)
- Added pms.controller.js (API handlers)
- Added pms.routes.js (route definitions)
- Added pms.validators.js (input validation)
- Integrated PMS routes into server.js"

git push origin main 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Pushed to GitHub${NC}"
else
  echo -e "${YELLOW}⚠️ Push failed (check connection)${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ PHASE 4 DEPLOYMENT COMPLETE!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${GREEN}📌 PMS Routes Ready:${NC}"
echo -e "  GET    /api/pms/room-types"
echo -e "  POST   /api/pms/room-types"
echo -e "  GET    /api/pms/rooms"
echo -e "  GET    /api/pms/rooms/status/:status"
echo -e "  POST   /api/pms/rooms"
echo -e "  PUT    /api/pms/rooms/:roomId/status"
echo -e "  POST   /api/pms/reservations"
echo -e "  GET    /api/pms/reservations"
echo -e "  GET    /api/pms/arrivals/today"
echo -e "  GET    /api/pms/departures/today"
echo -e "  POST   /api/pms/check-in"
echo -e "  POST   /api/pms/check-out"
echo -e "  GET    /api/pms/occupancy\n"

echo -e "${YELLOW}🚀 Ready for Phase 5: Restaurant POS Module${NC}\n"
ENDOFFILE
