import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const InventoryCategory = sequelize.define('InventoryCategory', {
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
  category_name: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  category_type: {
    type: DataTypes.ENUM('food', 'beverage', 'supplies', 'equipment', 'other'),
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'inventory_categories',
});

export default InventoryCategory;
