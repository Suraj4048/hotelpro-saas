import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const BanquetStaff = sequelize.define('BanquetStaff', {
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
  staff_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' },
  },
  role: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'Coordinator, Server, Chef, Bartender, Decorator',
  },
  assignment_date: {
    type: DataTypes.DATE,
  },
  status: {
    type: DataTypes.ENUM('assigned', 'confirmed', 'completed', 'absent'),
    defaultValue: 'assigned',
  },
  check_in_time: {
    type: DataTypes.DATE,
  },
  check_out_time: {
    type: DataTypes.DATE,
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'banquet_staff',
});

export default BanquetStaff;
