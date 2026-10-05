import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Bar = sequelize.define('Bar', {
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
  location: {
    type: DataTypes.STRING,
  },
  opening_time: {
    type: DataTypes.TIME,
  },
  closing_time: {
    type: DataTypes.TIME,
  },
  currency: {
    type: DataTypes.STRING,
    defaultValue: 'INR',
  },
  tax_rate: {
    type: DataTypes.DECIMAL(5, 2),
    defaultValue: 18.00,
  },
  service_charge_rate: {
    type: DataTypes.DECIMAL(5, 2),
    defaultValue: 0.00,
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'bars',
});

export default Bar;
