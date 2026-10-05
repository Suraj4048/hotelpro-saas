import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Salary = sequelize.define('Salary', {
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
  salary_month: {
    type: DataTypes.DATE,
    allowNull: false,
    comment: 'Month for which salary is paid',
  },
  base_salary: {
    type: DataTypes.DECIMAL(12, 2),
    allowNull: false,
  },
  dearness_allowance: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  house_rent_allowance: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  other_allowances: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  total_earnings: {
    type: DataTypes.DECIMAL(12, 2),
  },
  pf_deduction: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  it_deduction: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  other_deductions: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  total_deductions: {
    type: DataTypes.DECIMAL(12, 2),
  },
  net_salary: {
    type: DataTypes.DECIMAL(12, 2),
  },
  working_days: {
    type: DataTypes.INTEGER,
    comment: 'Days worked in month',
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'processing', 'paid', 'failed'),
    defaultValue: 'pending',
  },
  payment_date: {
    type: DataTypes.DATE,
  },
  notes: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'salary',
  indexes: [
    { fields: ['employee_id', 'salary_month'] },
  ],
});

export default Salary;
