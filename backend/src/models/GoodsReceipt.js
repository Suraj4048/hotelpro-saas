import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const GoodsReceipt = sequelize.define('GoodsReceipt', {
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
  gr_number: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
  },
  purchase_order_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'purchase_orders', key: 'id' },
  },
  receipt_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  vendor_invoice_number: {
    type: DataTypes.STRING,
  },
  vendor_invoice_date: {
    type: DataTypes.DATE,
  },
  received_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  status: {
    type: DataTypes.ENUM('pending_inspection', 'inspected', 'accepted', 'rejected', 'partial'),
    defaultValue: 'pending_inspection',
  },
  total_received_amount: {
    type: DataTypes.DECIMAL(12, 2),
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'goods_receipts',
});

export default GoodsReceipt;
