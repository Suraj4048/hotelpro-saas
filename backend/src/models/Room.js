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
