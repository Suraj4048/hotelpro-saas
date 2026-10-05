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
