import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Designation = sequelize.define('Designation', {
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
  designation_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  level: {
    type: DataTypes.ENUM('entry', 'junior', 'senior', 'lead', 'manager', 'head', 'director', 'executive'),
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
  },
  salary_range_min: {
    type: DataTypes.DECIMAL(12, 2),
  },
  salary_range_max: {
    type: DataTypes.DECIMAL(12, 2),
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'designations',
});

export default Designation;
