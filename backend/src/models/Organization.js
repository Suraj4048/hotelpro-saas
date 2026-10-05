// ============================================
// 🏢 ORGANIZATION MODEL - Multi-tenant
// ============================================

import { DataTypes } from 'sequelize';

export const defineOrganizationModel = (sequelize) => {
  const Organization = sequelize.define('Organization', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
      allowNull: false
    },
    name: {
      type: DataTypes.STRING(255),
      allowNull: false,
      validate: {
        len: [2, 255]
      }
    },
    slug: {
      type: DataTypes.STRING(100),
      allowNull: false,
      unique: true,
      validate: {
        is: /^[a-z0-9-]+$/i
      }
    },
    logoUrl: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    website: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    phone: {
      type: DataTypes.STRING(20),
      allowNull: true
    },
    email: {
      type: DataTypes.STRING(100),
      allowNull: true,
      validate: {
        isEmail: true
      }
    },
    address: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    city: {
      type: DataTypes.STRING(50),
      allowNull: true
    },
    state: {
      type: DataTypes.STRING(50),
      allowNull: true
    },
    country: {
      type: DataTypes.STRING(50),
      allowNull: true
    },
    postalCode: {
      type: DataTypes.STRING(10),
      allowNull: true
    },
    gstin: {
      type: DataTypes.STRING(15),
      allowNull: true,
      unique: true
    },
    subscriptionTier: {
      type: DataTypes.ENUM(
        'RESTAURANT_BASIC',
        'RESTAURANT_PRO',
        'BANQUET_BASIC',
        'BANQUET_PRO',
        'HOTEL_BASIC',
        'HOTEL_PRO',
        'FULL_SERVICE_BASIC',
        'FULL_SERVICE_PRO',
        'ENTERPRISE',
        'CUSTOM'
      ),
      defaultValue: 'RESTAURANT_BASIC'
    },
    enabledModules: {
      type: DataTypes.JSON,
      defaultValue: ['authentication', 'dashboard'],
      comment: 'Array of enabled module names'
    },
    maxProperties: {
      type: DataTypes.INTEGER,
      defaultValue: 1
    },
    maxUsers: {
      type: DataTypes.INTEGER,
      defaultValue: 10
    },
    licenseStartDate: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    licenseExpiryDate: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM('active', 'suspended', 'expired', 'trial'),
      defaultValue: 'trial'
    },
    monthlyPrice: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0
    },
    timezone: {
      type: DataTypes.STRING(50),
      defaultValue: 'Asia/Kolkata'
    },
    language: {
      type: DataTypes.STRING(20),
      defaultValue: 'en'
    },
    createdBy: {
      type: DataTypes.UUID,
      allowNull: true
    },
    updatedBy: {
      type: DataTypes.UUID,
      allowNull: true
    },
    createdAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    },
    updatedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'organizations',
    timestamps: true,
    indexes: [
      {
        fields: ['status']
      },
      {
        fields: ['subscriptionTier']
      },
      {
        fields: ['slug']
      }
    ]
  });

  return Organization;
};

export default defineOrganizationModel;
