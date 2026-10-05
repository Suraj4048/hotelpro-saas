#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}🚀 Phase 3: Admin Panel Deployment${NC}"
echo -e "${YELLOW}========================================${NC}\n"

REPO="/workspaces/hotelpro-saas"
BACKEND="$REPO/backend/src"

cd "$REPO" || exit 1

# Create directories
echo -e "${YELLOW}1️⃣ Creating directories...${NC}"
mkdir -p "$BACKEND/routes/03_admin"
mkdir -p "$BACKEND/models"
mkdir -p "$BACKEND/middleware"
echo -e "${GREEN}✅ Directories created${NC}\n"

# Create SubscriptionPlan model
echo -e "${YELLOW}2️⃣ Creating SubscriptionPlan.js...${NC}"
cat > "$BACKEND/models/SubscriptionPlan.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ SubscriptionPlan.js created${NC}"

# Create ClientSubscription model
echo -e "${YELLOW}3️⃣ Creating ClientSubscription.js...${NC}"
cat > "$BACKEND/models/ClientSubscription.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ ClientSubscription.js created${NC}"

# Create SubscriptionHistory model
echo -e "${YELLOW}4️⃣ Creating SubscriptionHistory.js...${NC}"
cat > "$BACKEND/models/SubscriptionHistory.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ SubscriptionHistory.js created${NC}"

# Create admin.service.js (truncated for brevity)
echo -e "${YELLOW}5️⃣ Creating admin.service.js...${NC}"
cat > "$BACKEND/routes/03_admin/admin.service.js" << 'ENDOFFILE'
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
ENDOFFILE
echo -e "${GREEN}✅ admin.service.js created${NC}"

# Create admin.controller.js
echo -e "${YELLOW}6️⃣ Creating admin.controller.js...${NC}"
cat > "$BACKEND/routes/03_admin/admin.controller.js" << 'ENDOFFILE'
import * as adminService from './admin.service.js';

export const getAllPlans = async (req, res) => {
  try {
    const plans = await adminService.getAllPlans();
    return res.json({ success: true, data: plans });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getAllClients = async (req, res) => {
  try {
    const { status, search } = req.query;
    const clients = await adminService.getAllClients({ status, search });
    return res.json({ success: true, data: clients, count: clients.length });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const getClientById = async (req, res) => {
  try {
    const { clientId } = req.params;
    const client = await adminService.getClientById(clientId);
    if (!client) return res.status(404).json({ success: false, error: 'Client not found' });
    return res.json({ success: true, data: client });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export const createClientSubscription = async (req, res) => {
  try {
    const { clientId } = req.params;
    const { planId, billingEmail } = req.body;
    if (!planId) return res.status(400).json({ success: false, error: 'planId required' });
    const subscription = await adminService.createClientSubscription(clientId, planId, billingEmail);
    return res.status(201).json({ success: true, data: subscription });
  } catch (error) {
    return res.status(400).json({ success: false, error: error.message });
  }
};

export const getAdminDashboard = async (req, res) => {
  try {
    const dashboard = await adminService.getAdminDashboard();
    return res.json({ success: true, data: dashboard });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
};

export default {
  getAllPlans, getAllClients, getClientById, createClientSubscription, getAdminDashboard,
};
ENDOFFILE
echo -e "${GREEN}✅ admin.controller.js created${NC}"

# Create admin.routes.js
echo -e "${YELLOW}7️⃣ Creating admin.routes.js...${NC}"
cat > "$BACKEND/routes/03_admin/admin.routes.js" << 'ENDOFFILE'
import express from 'express';
import * as adminController from './admin.controller.js';
import { checkRoleAccess } from '../../middleware/authMiddleware.js';

const router = express.Router();
router.use(checkRoleAccess('SUPER_ADMIN'));

router.get('/plans', adminController.getAllPlans);
router.get('/clients', adminController.getAllClients);
router.get('/clients/:clientId', adminController.getClientById);
router.post('/clients/:clientId/subscription', adminController.createClientSubscription);
router.get('/dashboard', adminController.getAdminDashboard);

export default router;
ENDOFFILE
echo -e "${GREEN}✅ admin.routes.js created${NC}"

# Create admin.validators.js
echo -e "${YELLOW}8️⃣ Creating admin.validators.js...${NC}"
cat > "$BACKEND/routes/03_admin/admin.validators.js" << 'ENDOFFILE'
import Joi from 'joi';

export const validateToggleModule = (data) => {
  const schema = Joi.object({
    moduleName: Joi.string().required(),
    enable: Joi.boolean().required(),
  });
  return schema.validate(data, { abortEarly: false });
};

export default { validateToggleModule };
ENDOFFILE
echo -e "${GREEN}✅ admin.validators.js created${NC}"

# Update server.js
echo -e "${YELLOW}9️⃣ Updating server.js...${NC}"
if ! grep -q "import adminRoutes" "$BACKEND/server.js"; then
  sed -i "/import dashboardRoutes/a import adminRoutes from './routes/03_admin/admin.routes.js';" "$BACKEND/server.js"
  sed -i "/app.use('\/api\/dashboard'/a app.use('/api/admin', adminRoutes);" "$BACKEND/server.js"
  echo -e "${GREEN}✅ server.js updated${NC}"
else
  echo -e "${YELLOW}⚠️ Admin routes already in server.js${NC}"
fi

# Git commit and push
echo -e "${YELLOW}🔟 Git operations...${NC}"
git add -A
git commit -m "Phase 3: Admin Panel & Subscription Management

- Added SubscriptionPlan model
- Added ClientSubscription model  
- Added SubscriptionHistory model
- Added admin.service.js, admin.controller.js
- Added admin.routes.js, admin.validators.js
- Integrated admin panel to server.js"

git push origin main 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Pushed to GitHub${NC}"
else
  echo -e "${YELLOW}⚠️ Push failed (check connection)${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ PHASE 3 DEPLOYMENT COMPLETE!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${GREEN}📌 Admin Routes Ready:${NC}"
echo -e "  GET    /api/admin/plans"
echo -e "  GET    /api/admin/clients"
echo -e "  GET    /api/admin/clients/:clientId"
echo -e "  POST   /api/admin/clients/:clientId/subscription"
echo -e "  GET    /api/admin/dashboard\n"

echo -e "${YELLOW}🚀 Ready for Phase 4: PMS Module${NC}\n"
