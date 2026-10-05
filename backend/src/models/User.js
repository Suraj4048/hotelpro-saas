// ============================================
// 🔐 USER MODEL - Sequelize Definition
// ============================================

import { DataTypes } from 'sequelize';

export const defineUserModel = (sequelize) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
      allowNull: false
    },
    organizationId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'organizations',
        key: 'id'
      }
    },
    firstName: {
      type: DataTypes.STRING(100),
      allowNull: false,
      validate: {
        len: [2, 100]
      }
    },
    lastName: {
      type: DataTypes.STRING(100),
      allowNull: true
    },
    email: {
      type: DataTypes.STRING(100),
      allowNull: false,
      validate: {
        isEmail: true
      },
      unique: 'unique_email_per_org'
    },
    phone: {
      type: DataTypes.STRING(20),
      allowNull: true
    },
    username: {
      type: DataTypes.STRING(50),
      allowNull: true,
      unique: true
    },
    passwordHash: {
      type: DataTypes.STRING(255),
      allowNull: false
    },
    profilePhotoUrl: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    roleId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'roles',
        key: 'id'
      }
    },
    department: {
      type: DataTypes.STRING(100),
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM('active', 'inactive', 'suspended'),
      defaultValue: 'active',
      allowNull: false
    },
    emailVerified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    phoneVerified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    twoFaEnabled: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    twoFaMethod: {
      type: DataTypes.ENUM('email', 'sms', 'authenticator'),
      allowNull: true
    },
    twoFaSecret: {
      type: DataTypes.STRING(255),
      allowNull: true,
      comment: 'Encrypted 2FA secret'
    },
    lastLogin: {
      type: DataTypes.DATE,
      allowNull: true
    },
    lastLoginIp: {
      type: DataTypes.STRING(50),
      allowNull: true
    },
    loginAttempts: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    },
    lockedUntil: {
      type: DataTypes.DATE,
      allowNull: true
    },
    passwordChangedAt: {
      type: DataTypes.DATE,
      allowNull: true
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
    },
    deletedAt: {
      type: DataTypes.DATE,
      allowNull: true
    }
  }, {
    tableName: 'users',
    timestamps: true,
    paranoid: true, // Soft deletes
    indexes: [
      {
        fields: ['organizationId']
      },
      {
        fields: ['email']
      },
      {
        fields: ['username']
      },
      {
        fields: ['status']
      }
    ]
  });

  return User;
};

export default defineUserModel;
