import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Vendor = sequelize.define('Vendor', {
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
  vendor_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  vendor_code: {
    type: DataTypes.STRING,
    unique: true,
  },
  contact_person: {
    type: DataTypes.STRING,
  },
  phone: {
    type: DataTypes.STRING,
  },
  email: {
    type: DataTypes.STRING,
  },
  address: {
    type: DataTypes.TEXT,
  },
  city: {
    type: DataTypes.STRING,
  },
  gst_number: {
    type: DataTypes.STRING,
  },
  payment_terms: {
    type: DataTypes.STRING,
    comment: 'Net 30, COD, etc.',
  },
  credit_limit: {
    type: DataTypes.DECIMAL(12, 2),
  },
  outstanding_balance: {
    type: DataTypes.DECIMAL(12, 2),
    defaultValue: 0,
  },
  vendor_type: {
    type: DataTypes.ENUM('food_supplier', 'beverage_supplier', 'general_supplies', 'equipment', 'other'),
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  rating: {
    type: DataTypes.DECIMAL(3, 1),
    comment: '1-5 stars',
  },
}, {
  timestamps: true,
  tableName: 'vendors',
});

export default Vendor;
