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
