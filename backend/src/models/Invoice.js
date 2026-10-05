import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Invoice = sequelize.define('Invoice', {
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
  invoice_number: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
    comment: 'Auto-generated: INV-YYYY-XXXXX',
  },
  invoice_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  bill_to: {
    type: DataTypes.STRING,
    comment: 'Customer name or guest name',
  },
  reference_type: {
    type: DataTypes.ENUM('restaurant_order', 'bar_order', 'banquet', 'room_booking', 'manual'),
    comment: 'Where invoice originated',
  },
  reference_id: {
    type: DataTypes.UUID,
    comment: 'ID of order/booking',
  },
  subtotal: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
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
  paid_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'partial', 'paid'),
    defaultValue: 'pending',
  },
  invoice_status: {
    type: DataTypes.ENUM('draft', 'issued', 'paid', 'cancelled', 'refunded'),
    defaultValue: 'draft',
  },
  due_date: {
    type: DataTypes.DATE,
  },
  notes: {
    type: DataTypes.TEXT,
  },
  created_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
}, {
  timestamps: true,
  tableName: 'invoices',
});

export default Invoice;
