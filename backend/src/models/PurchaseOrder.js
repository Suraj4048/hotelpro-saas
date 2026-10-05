import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const PurchaseOrder = sequelize.define('PurchaseOrder', {
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
  po_number: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
  },
  vendor_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'vendors', key: 'id' },
  },
  po_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  expected_delivery_date: {
    type: DataTypes.DATE,
  },
  subtotal: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  tax_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  tax_rate: {
    type: DataTypes.DECIMAL(5, 2),
    defaultValue: 18.00,
  },
  total_amount: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  status: {
    type: DataTypes.ENUM('draft', 'sent', 'confirmed', 'partially_received', 'received', 'cancelled', 'invoiced'),
    defaultValue: 'draft',
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
  tableName: 'purchase_orders',
});

export default PurchaseOrder;
