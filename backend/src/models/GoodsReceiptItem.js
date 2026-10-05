import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const GoodsReceiptItem = sequelize.define('GoodsReceiptItem', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  goods_receipt_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'goods_receipts', key: 'id' },
  },
  purchase_order_item_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'purchase_order_items', key: 'id' },
  },
  quantity_received: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  quantity_accepted: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  quantity_rejected: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  unit_price: {
    type: DataTypes.DECIMAL(10, 2),
  },
  line_total: {
    type: DataTypes.DECIMAL(12, 2),
  },
  batch_number: {
    type: DataTypes.STRING,
  },
  expiry_date: {
    type: DataTypes.DATE,
  },
  quality_notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'goods_receipt_items',
});

export default GoodsReceiptItem;
