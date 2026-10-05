import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BarCounter = sequelize.define('BarCounter', {
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
  bar_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'bars', key: 'id' },
  },
  counter_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  counter_number: {
    type: DataTypes.STRING,
  },
  section: {
    type: DataTypes.STRING,
  },
  status: {
    type: DataTypes.ENUM('available', 'occupied', 'maintenance'),
    defaultValue: 'available',
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'bar_counters',
});

export default BarCounter;
