import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const MenuItem = sequelize.define('MenuItem', {
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
  restaurant_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'restaurants', key: 'id' },
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
  },
  category: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  veg: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  preparation_time: {
    type: DataTypes.INTEGER,
    comment: 'in minutes',
  },
  is_available: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'menu_items',
});

export default MenuItem;
