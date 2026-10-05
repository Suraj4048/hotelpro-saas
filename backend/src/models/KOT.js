import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const KOT = sequelize.define('KOT', {
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
  order_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'orders', key: 'id' },
  },
  kot_number: {
    type: DataTypes.STRING,
    unique: true,
  },
  status: {
    type: DataTypes.ENUM('sent', 'acknowledged', 'preparing', 'ready', 'cancelled'),
    defaultValue: 'sent',
  },
  items_count: {
    type: DataTypes.INTEGER,
  },
  sent_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  acknowledged_at: {
    type: DataTypes.DATE,
  },
  ready_at: {
    type: DataTypes.DATE,
  },
}, {
  timestamps: true,
  tableName: 'kots',
});

export default KOT;
