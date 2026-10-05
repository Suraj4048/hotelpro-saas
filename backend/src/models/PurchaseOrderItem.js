import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const PurchaseOrderItem = sequelize.define('PurchaseOrderItem', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  purchase_order_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'purchase_orders', key: 'id' },
  },
  inventory_item_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'inventory', key: 'id' },
  },
  quantity_ordered: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  quantity_received: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  unit_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  line_total: {
    type: DataTypes.DECIMAL(12, 2),
  },
  unit: {
    type: DataTypes.STRING,
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'purchase_order_items',
});

export default PurchaseOrderItem;
