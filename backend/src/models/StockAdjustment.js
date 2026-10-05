import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const StockAdjustment = sequelize.define('StockAdjustment', {
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
  adjustment_number: {
    type: DataTypes.STRING,
    unique: true,
  },
  inventory_item_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'inventory', key: 'id' },
  },
  adjustment_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  adjustment_type: {
    type: DataTypes.ENUM('addition', 'reduction', 'correction'),
    allowNull: false,
  },
  reason: {
    type: DataTypes.ENUM('stock_count', 'damage', 'theft', 'expired', 'return_to_vendor', 'correction', 'other'),
    allowNull: false,
  },
  quantity_before: {
    type: DataTypes.DECIMAL(10, 2),
  },
  adjustment_quantity: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  quantity_after: {
    type: DataTypes.DECIMAL(10, 2),
  },
  cost_impact: {
    type: DataTypes.DECIMAL(12, 2),
  },
  notes: {
    type: DataTypes.TEXT,
  },
  adjusted_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  approved_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  status: {
    type: DataTypes.ENUM('pending', 'approved', 'rejected'),
    defaultValue: 'pending',
  },
}, {
  timestamps: true,
  tableName: 'stock_adjustments',
});

export default StockAdjustment;
