import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Drink = sequelize.define('Drink', {
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
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  category: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'Beer, Wine, Whiskey, Vodka, Cocktail, Non-Alcoholic',
  },
  description: {
    type: DataTypes.TEXT,
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  alcohol_percentage: {
    type: DataTypes.DECIMAL(5, 2),
  },
  volume: {
    type: DataTypes.STRING,
    comment: 'ml or oz (e.g., 30ml, 1oz)',
  },
  is_available: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  popularity_rank: {
    type: DataTypes.INTEGER,
  },
}, {
  timestamps: true,
  tableName: 'drinks',
});

export default Drink;
