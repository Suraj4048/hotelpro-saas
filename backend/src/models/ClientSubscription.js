import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const ClientSubscription = sequelize.define('ClientSubscription', {
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
  subscription_plan_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'subscription_plans', key: 'id' },
  },
  status: {
    type: DataTypes.ENUM('trial', 'active', 'paused', 'cancelled', 'expired'),
    defaultValue: 'trial',
  },
  current_period_start: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  current_period_end: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  trial_end_date: {
    type: DataTypes.DATE,
  },
  auto_renew: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  billing_email: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  payment_method: {
    type: DataTypes.ENUM('credit_card', 'bank_transfer', 'upi', 'manual'),
    defaultValue: 'manual',
  },
  notes: {
    type: DataTypes.TEXT,
  },
  cancelled_at: {
    type: DataTypes.DATE,
  },
  cancelled_reason: {
    type: DataTypes.TEXT,
  },
}, {
  timestamps: true,
  tableName: 'client_subscriptions',
});

export default ClientSubscription;
