import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BarOrder = sequelize.define('BarOrder', {
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
  counter_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'bar_counters', key: 'id' },
  },
  order_number: {
    type: DataTypes.STRING,
    unique: true,
  },
  status: {
    type: DataTypes.ENUM('open', 'pending', 'completed', 'cancelled'),
    defaultValue: 'open',
  },
  subtotal: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  tax_amount: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  service_charge: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  total_amount: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'paid', 'partial', 'refunded'),
    defaultValue: 'pending',
  },
  ordered_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  number_of_guests: {
    type: DataTypes.INTEGER,
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'bar_orders',
});

export default BarOrder;
