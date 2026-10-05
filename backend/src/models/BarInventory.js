import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BarInventory = sequelize.define('BarInventory', {
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
  drink_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'drinks', key: 'id' },
  },
  quantity_in_stock: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  minimum_level: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  unit: {
    type: DataTypes.STRING,
    comment: 'Bottle, Liter, ml, oz',
  },
  cost_per_unit: {
    type: DataTypes.DECIMAL(10, 2),
  },
  last_restock_date: {
    type: DataTypes.DATE,
  },
  expiry_date: {
    type: DataTypes.DATE,
  },
}, {
  timestamps: true,
  tableName: 'bar_inventory',
});

export default BarInventory;
