import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BarOrderItem = sequelize.define('BarOrderItem', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  bar_order_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'bar_orders', key: 'id' },
  },
  drink_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'drinks', key: 'id' },
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  unit_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  special_instructions: {
    type: DataTypes.TEXT,
    comment: 'e.g., Extra ice, No ice, Salt rim',
  },
  status: {
    type: DataTypes.ENUM('pending', 'preparing', 'ready', 'served', 'cancelled'),
    defaultValue: 'pending',
  },
}, {
  timestamps: true,
  tableName: 'bar_order_items',
});

export default BarOrderItem;
