import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BanquetMenu = sequelize.define('BanquetMenu', {
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
  item_id: {
    type: DataTypes.UUID,
    comment: 'Can be from menu_items or drinks table',
  },
  item_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  item_category: {
    type: DataTypes.STRING,
    comment: 'Starter, Main, Dessert, Beverage, etc.',
  },
  item_type: {
    type: DataTypes.ENUM('restaurant', 'bar', 'custom'),
    defaultValue: 'restaurant',
  },
  quantity: {
    type: DataTypes.INTEGER,
    comment: 'per person or total',
  },
  unit_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  vegetarian: {
    type: DataTypes.BOOLEAN,
  },
  vegan: {
    type: DataTypes.BOOLEAN,
  },
  description: {
    type: DataTypes.TEXT,
  },
  sequence: {
    type: DataTypes.INTEGER,
    comment: 'course order (1=starter, 2=main)',
  },
}, {
  timestamps: true,
  tableName: 'banquet_menus',
});

export default BanquetMenu;
