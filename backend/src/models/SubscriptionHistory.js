import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const SubscriptionHistory = sequelize.define('SubscriptionHistory', {
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
  client_subscription_id: {
    type: DataTypes.UUID,
    references: { model: 'client_subscriptions', key: 'id' },
  },
  event_type: {
    type: DataTypes.ENUM('subscription_created', 'subscription_upgraded', 'subscription_downgraded', 'subscription_renewed', 'subscription_cancelled', 'payment_received', 'payment_failed', 'module_enabled', 'module_disabled', 'trial_started', 'trial_ended'),
    allowNull: false,
  },
  old_plan_id: {
    type: DataTypes.UUID,
    references: { model: 'subscription_plans', key: 'id' },
  },
  new_plan_id: {
    type: DataTypes.UUID,
    references: { model: 'subscription_plans', key: 'id' },
  },
  amount: {
    type: DataTypes.DECIMAL(10, 2),
  },
  notes: {
    type: DataTypes.TEXT,
  },
  triggered_by: {
    type: DataTypes.STRING,
  },
}, {
  timestamps: true,
  tableName: 'subscription_history',
  createdAt: 'created_at',
  updatedAt: false,
});

export default SubscriptionHistory;
