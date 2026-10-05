// ============================================
// 📱 OTP MODEL - One Time Passwords
// ============================================

import { DataTypes } from 'sequelize';

export const defineOTPModel = (sequelize) => {
  const OTP = sequelize.define('OTP', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    identifier: {
      type: DataTypes.STRING(100),
      allowNull: false,
      comment: 'Email or phone number'
    },
    type: {
      type: DataTypes.ENUM(
        'email_verification',
        '2fa_login',
        'phone_verification',
        'forgot_password'
      ),
      allowNull: false
    },
    otp: {
      type: DataTypes.STRING(6),
      allowNull: false
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: false
    },
    isUsed: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    usedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    attempts: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      comment: 'Number of incorrect attempts'
    },
    createdAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    tableName: 'otps',
    timestamps: false,
    indexes: [
      {
        fields: ['identifier', 'type']
      },
      {
        fields: ['expiresAt']
      }
    ]
  });

  return OTP;
};

export default defineOTPModel;
