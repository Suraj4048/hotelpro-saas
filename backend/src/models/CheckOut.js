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
