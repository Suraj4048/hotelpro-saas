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
