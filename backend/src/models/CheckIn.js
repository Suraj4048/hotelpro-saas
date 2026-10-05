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
