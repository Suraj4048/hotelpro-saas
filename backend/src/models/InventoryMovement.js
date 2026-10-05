import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const InventoryMovement = sequelize.define('InventoryMovement', {
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
  inventory_item_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'inventory', key: 'id' },
  },
  movement_date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  movement_type: {
    type: DataTypes.ENUM('inward', 'outward', 'adjustment', 'transfer'),
    allowNull: false,
  },
  reference_type: {
    type: DataTypes.ENUM('purchase_order', 'goods_receipt', 'restaurant_order', 'stock_adjustment', 'manual'),
  },
  reference_id: {
    type: DataTypes.UUID,
  },
  quantity: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  unit_cost: {
    type: DataTypes.DECIMAL(10, 2),
  },
  transaction_value: {
    type: DataTypes.DECIMAL(12, 2),
  },
  stock_before: {
    type: DataTypes.DECIMAL(10, 2),
  },
  stock_after: {
    type: DataTypes.DECIMAL(10, 2),
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'inventory_movements',
  indexes: [
    { fields: ['inventory_item_id', 'movement_date'] },
  ],
});

export default InventoryMovement;
