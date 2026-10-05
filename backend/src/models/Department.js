import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Department = sequelize.define('Department', {
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
  department_name: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  department_code: {
    type: DataTypes.STRING,
    unique: true,
  },
  description: {
    type: DataTypes.TEXT,
  },
  head_id: {
    type: DataTypes.UUID,
    references: { model: 'users', key: 'id' },
    comment: 'Department head',
  },
  budget: {
    type: DataTypes.DECIMAL(12, 2),
    comment: 'Department budget',
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'departments',
});

export default Department;
