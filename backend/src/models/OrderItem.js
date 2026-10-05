import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const OrderItem = sequelize.define('OrderItem', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  order_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'orders', key: 'id' },
  },
  menu_item_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'menu_items', key: 'id' },
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
  },
  status: {
    type: DataTypes.ENUM('pending', 'preparing', 'ready', 'served', 'cancelled'),
    defaultValue: 'pending',
  },
}, {
  timestamps: true,
  tableName: 'order_items',
});

export default OrderItem;
