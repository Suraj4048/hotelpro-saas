import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Employee = sequelize.define('Employee', {
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
  user_id: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
  },
  employee_code: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
  },
  first_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  last_name: {
    type: DataTypes.STRING,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  phone: {
    type: DataTypes.STRING,
  },
  date_of_birth: {
    type: DataTypes.DATE,
  },
  gender: {
    type: DataTypes.ENUM('male', 'female', 'other'),
  },
  department_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'departments', key: 'id' },
  },
  designation_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'designations', key: 'id' },
  },
  reporting_to_id: {
    type: DataTypes.UUID,
    references: { model: 'employees', key: 'id' },
    comment: 'Manager/Supervisor ID',
  },
  employment_type: {
    type: DataTypes.ENUM('full_time', 'part_time', 'contract', 'temporary'),
    defaultValue: 'full_time',
  },
  date_of_joining: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  date_of_exit: {
    type: DataTypes.DATE,
  },
  address: {
    type: DataTypes.TEXT,
  },
  city: {
    type: DataTypes.STRING,
  },
  state: {
    type: DataTypes.STRING,
  },
  country: {
    type: DataTypes.STRING,
  },
  pan: {
    type: DataTypes.STRING,
    comment: 'PAN number',
  },
  aadhar: {
    type: DataTypes.STRING,
    comment: 'Aadhar number',
  },
  bank_account: {
    type: DataTypes.STRING,
  },
  ifsc_code: {
    type: DataTypes.STRING,
  },
  emergency_contact_name: {
    type: DataTypes.STRING,
  },
  emergency_contact_phone: {
    type: DataTypes.STRING,
  },
  base_salary: {
    type: DataTypes.DECIMAL(12, 2),
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive', 'on_leave', 'terminated'),
    defaultValue: 'active',
  },
}, {
  timestamps: true,
  tableName: 'employees',
});

export default Employee;
