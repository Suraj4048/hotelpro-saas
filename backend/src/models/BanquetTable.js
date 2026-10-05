import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BanquetTable = sequelize.define('BanquetTable', {
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
  table_number: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  seating_capacity: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  current_occupancy: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  table_type: {
    type: DataTypes.STRING,
    comment: 'VIP, Regular, Kids, High Table',
  },
  location: {
    type: DataTypes.STRING,
    comment: 'Floor, Zone (e.g., "Main Hall - Zone A")',
  },
  status: {
    type: DataTypes.ENUM('available', 'reserved', 'occupied', 'served'),
    defaultValue: 'available',
  },
  assigned_server: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
}, {
  timestamps: true,
  tableName: 'banquet_tables',
});

export default BanquetTable;
