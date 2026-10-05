import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Inventory = sequelize.define('Inventory', {
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
  category_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'inventory_categories', key: 'id' },
  },
  item_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  item_code: {
    type: DataTypes.STRING,
    unique: true,
    comment: 'SKU or item code',
  },
  description: {
    type: DataTypes.TEXT,
  },
  unit: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'kg, liter, box, piece, etc.',
  },
  quantity_in_stock: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  par_level: {
    type: DataTypes.DECIMAL(10, 2),
    comment: 'Ideal quantity to maintain',
  },
  reorder_point: {
    type: DataTypes.DECIMAL(10, 2),
    comment: 'Trigger point for purchase order',
  },
  reorder_quantity: {
    type: DataTypes.DECIMAL(10, 2),
    comment: 'Quantity to order when stock falls below reorder point',
  },
  cost_per_unit: {
    type: DataTypes.DECIMAL(10, 2),
  },
  opening_stock: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  last_count_date: {
    type: DataTypes.DATE,
  },
  last_purchase_date: {
    type: DataTypes.DATE,
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'inventory',
});

export default Inventory;
