import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const TaxConfiguration = sequelize.define('TaxConfiguration', {
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
  tax_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  tax_type: {
    type: DataTypes.ENUM('GST', 'VAT', 'SERVICE_TAX', 'OTHER'),
    allowNull: false,
  },
  tax_rate: {
    type: DataTypes.DECIMAL(5, 2),
    allowNull: false,
  },
  module: {
    type: DataTypes.ENUM('restaurant', 'bar', 'banquet', 'pms', 'manual'),
    allowNull: false,
  },
  category: {
    type: DataTypes.STRING,
    comment: 'e.g., Food, Beverage, Room, etc.',
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'tax_configurations',
});

export default TaxConfiguration;
