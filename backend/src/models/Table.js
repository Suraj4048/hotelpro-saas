import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Table = sequelize.define('Table', {
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
  table_number: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  section: {
    type: DataTypes.STRING,
  },
  capacity: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('available', 'occupied', 'reserved', 'maintenance'),
    defaultValue: 'available',
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'tables',
});

export default Table;
