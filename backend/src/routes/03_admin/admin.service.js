import Organization from '../../models/Organization.js';
import SubscriptionPlan from '../../models/SubscriptionPlan.js';
import ClientSubscription from '../../models/ClientSubscription.js';
import SubscriptionHistory from '../../models/SubscriptionHistory.js';
import { Op } from 'sequelize';

export const getAllPlans = async () => {
  return await SubscriptionPlan.findAll({
    where: { is_active: true },
    order: [['price', 'ASC']],
  });
};

export const getAllClients = async (filters = {}) => {
  const where = {};
  if (filters.status) where.status = filters.status;
  if (filters.search) {
    where[Op.or] = [
      { name: { [Op.iLike]: `%${filters.search}%` } },
      { email: { [Op.iLike]: `%${filters.search}%` } },
    ];
  }
  return await Organization.findAll({
    where,
    include: [{ model: ClientSubscription, include: [SubscriptionPlan] }],
    order: [['created_at', 'DESC']],
  });
};

export const getClientById = async (clientId) => {
  return await Organization.findByPk(clientId, {
    include: [{ model: ClientSubscription, include: [SubscriptionPlan] }],
  });
};

export const createClientSubscription = async (clientId, planId, billingEmail) => {
  const plan = await SubscriptionPlan.findByPk(planId);
  const client = await Organization.findByPk(clientId);
  
  const now = new Date();
  const trialEndDate = new Date(now.getTime() + plan.trial_days * 24 * 60 * 60 * 1000);
  const periodEndDate = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

  const subscription = await ClientSubscription.create({
    organization_id: clientId,
    subscription_plan_id: planId,
    status: 'trial',
    billing_email: billingEmail || client.email,
    current_period_start: now,
    current_period_end: periodEndDate,
    trial_end_date: trialEndDate,
  });

  await client.update({ enabled_modules: plan.enabled_modules });
  
  await SubscriptionHistory.create({
    organization_id: clientId,
    client_subscription_id: subscription.id,
    event_type: 'subscription_created',
    new_plan_id: planId,
    triggered_by: 'admin_action',
  });

  return subscription;
};

export const getAdminDashboard = async () => {
  const totalClients = await Organization.count();
  const activeSubscriptions = await ClientSubscription.count({ where: { status: 'active' } });
  const trialSubscriptions = await ClientSubscription.count({ where: { status: 'trial' } });

  const totalRevenue = await ClientSubscription.findAll({
    where: { status: 'active' },
    include: [{ model: SubscriptionPlan, attributes: ['price'] }],
    raw: true,
  }).then(subs => subs.reduce((sum, sub) => sum + (sub['SubscriptionPlan.price'] || 0), 0));

  return {
    totalClients,
    activeSubscriptions,
    trialSubscriptions,
    totalRevenue: parseFloat(totalRevenue),
    mrr: parseFloat(totalRevenue),
  };
};

export default {
  getAllPlans, getAllClients, getClientById, createClientSubscription, getAdminDashboard,
};
