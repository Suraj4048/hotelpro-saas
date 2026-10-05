// ============================================
// 🗄️ DATABASE CONFIGURATION & INITIALIZATION
// ============================================

import { Sequelize } from 'sequelize';
import defineUserModel from '../models/User.js';
import defineOrganizationModel from '../models/Organization.js';
import defineRoleModel, { defineRolePermissionModel } from '../models/Role.js';
import defineOTPModel from '../models/OTP.js';

/**
 * Initialize Sequelize connection
 */
export const initializeDatabase = async () => {
  const sequelize = new Sequelize(
    process.env.DB_NAME,
    process.env.DB_USER,
    process.env.DB_PASSWORD,
    {
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      dialect: 'postgres',
      logging: process.env.DB_LOGGING === 'true' ? console.log : false,
      pool: {
        max: 10,
        min: 2,
        acquire: 30000,
        idle: 10000
      },
      timestamps: true
    }
  );

  try {
    await sequelize.authenticate();
    console.log('✅ Database connection established');
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    throw error;
  }

  return sequelize;
};

/**
 * Register all models
 */
export const registerModels = (sequelize) => {
  // Define models
  const Organization = defineOrganizationModel(sequelize);
  const User = defineUserModel(sequelize);
  const Role = defineRoleModel(sequelize);
  const RolePermission = defineRolePermissionModel(sequelize);
  const OTP = defineOTPModel(sequelize);

  // ============ ASSOCIATIONS ============

  // Organization associations
  Organization.hasMany(User, {
    foreignKey: 'organizationId',
    as: 'users'
  });

  Organization.hasMany(Role, {
    foreignKey: 'organizationId',
    as: 'roles'
  });

  // User associations
  User.belongsTo(Organization, {
    foreignKey: 'organizationId',
    as: 'organization'
  });

  User.belongsTo(Role, {
    foreignKey: 'roleId',
    as: 'role'
  });

  // Role associations
  Role.hasMany(RolePermission, {
    foreignKey: 'roleId',
    as: 'permissions'
  });

  Role.belongsTo(Organization, {
    foreignKey: 'organizationId',
    as: 'organization'
  });

  RolePermission.belongsTo(Role, {
    foreignKey: 'roleId',
    as: 'role'
  });

  return {
    sequelize,
    models: {
      Organization,
      User,
      Role,
      RolePermission,
      OTP
    }
  };
};

/**
 * Sync database (create tables if they don't exist)
 */
export const syncDatabase = async (sequelize, options = {}) => {
  try {
    if (process.env.NODE_ENV === 'production') {
      console.log('⚠️  Skipping sync in production. Use migrations instead.');
      return;
    }

    await sequelize.sync({
      alter: process.env.DB_FORCE_SYNC === 'true',
      ...options
    });

    console.log('✅ Database synced successfully');
  } catch (error) {
    console.error('❌ Database sync failed:', error);
    throw error;
  }
};

/**
 * Seed default data
 */
export const seedDatabase = async (models) => {
  const { Organization, Role, User } = models;

  try {
    // Check if demo organization already exists
    const existingOrg = await Organization.findOne({
      where: { slug: 'demo-organization' }
    });

    if (existingOrg) {
      console.log('ℹ️  Demo data already exists. Skipping seed.');
      return;
    }

    // Create demo organization
    const org = await Organization.create({
      name: 'Demo Hotel',
      slug: 'demo-organization',
      email: 'demo@hotelpro.in',
      subscriptionTier: 'FULL_SERVICE_PRO',
      enabledModules: [
        'authentication',
        'dashboard',
        'pms',
        'restaurant_pos',
        'bar_pos',
        'banquet',
        'housekeeping',
        'inventory',
        'accounts_gst',
        'hr',
        'reports',
        'integrations'
      ],
      status: 'active',
      maxProperties: 5,
      maxUsers: 50
    });

    // Create default roles
    const superAdminRole = await Role.create({
      organizationId: org.id,
      name: 'SUPER_ADMIN',
      description: 'Super Administrator with full access',
      isSystemRole: true
    });

    const ownerRole = await Role.create({
      organizationId: org.id,
      name: 'OWNER',
      description: 'Organization Owner',
      isSystemRole: true
    });

    const gmRole = await Role.create({
      organizationId: org.id,
      name: 'GENERAL_MANAGER',
      description: 'General Manager',
      isSystemRole: true
    });

    // Create demo user
    const bcrypt = require('bcryptjs');
    const hashedPassword = await bcrypt.hash('Demo@123456', 10);

    const demoUser = await User.create({
      organizationId: org.id,
      firstName: 'Demo',
      lastName: 'Admin',
      email: 'demo@hotelpro.in',
      phone: '+91-9876543210',
      passwordHash: hashedPassword,
      roleId: superAdminRole.id,
      status: 'active',
      emailVerified: true,
      phoneVerified: true
    });

    console.log('✅ Database seeded successfully');
    console.log('   Demo Organization: Demo Hotel');
    console.log('   Demo User: demo@hotelpro.in / Demo@123456');

  } catch (error) {
    console.error('❌ Database seed failed:', error);
    // Don't throw - seeding failure shouldn't stop app startup
  }
};

/**
 * Complete database setup
 */
export const setupDatabase = async () => {
  // Initialize connection
  const sequelize = await initializeDatabase();

  // Register models
  const { models } = registerModels(sequelize);

  // Sync database
  if (process.env.DB_AUTO_SYNC === 'true') {
    await syncDatabase(sequelize);
  }

  // Seed demo data if enabled
  if (process.env.DB_SEED === 'true') {
    await seedDatabase(models);
  }

  return { sequelize, models };
};

export default setupDatabase;
