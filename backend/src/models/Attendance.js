import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Attendance = sequelize.define('Attendance', {
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
  employee_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'employees', key: 'id' },
  },
  attendance_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  check_in_time: {
    type: DataTypes.TIME,
  },
  check_out_time: {
    type: DataTypes.TIME,
  },
  status: {
    type: DataTypes.ENUM('present', 'absent', 'late', 'half_day', 'work_from_home'),
    defaultValue: 'absent',
  },
  hours_worked: {
    type: DataTypes.DECIMAL(5, 2),
  },
  location: {
    type: DataTypes.STRING,
    comment: 'Office/Remote/Field',
  },
  notes: {
    type: DataTypes.TEXT,
  },
  approved_by: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
}, {
  timestamps: true,
  tableName: 'attendance',
  indexes: [
    { fields: ['employee_id', 'attendance_date'] },
  ],
});

export default Attendance;
