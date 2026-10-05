import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const SubscriptionPlan = sequelize.define('SubscriptionPlan', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: {
      isIn: [['RESTAURANT_BASIC', 'RESTAURANT_PRO', 'HOTEL_BASIC', 'FULL_SERVICE']],
    },
  },
  display_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    validate: { min: 0 },
  },
  billing_cycle: {
    type: DataTypes.ENUM('monthly', 'yearly'),
    defaultValue: 'monthly',
  },
  max_users: {
    type: DataTypes.INTEGER,
    defaultValue: 10,
  },
  max_properties: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
  },
  enabled_modules: {
    type: DataTypes.JSON,
    defaultValue: [],
  },
  features: {
    type: DataTypes.JSON,
    defaultValue: {},
  },
  trial_days: {
    type: DataTypes.INTEGER,
    defaultValue: 14,
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  timestamps: true,
  tableName: 'subscription_plans',
});

export default SubscriptionPlan;
