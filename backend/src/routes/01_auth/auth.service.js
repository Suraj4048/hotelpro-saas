// ============================================
// 🔐 AUTHENTICATION SERVICE - Business Logic
// ============================================

import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { v4 as uuidv4 } from 'uuid';

export class AuthService {
  constructor(models, emailService, smsService) {
    this.User = models.User;
    this.Organization = models.Organization;
    this.Role = models.Role;
    this.OTP = models.OTP; // Will create this table
    this.emailService = emailService;
    this.smsService = smsService;
  }

  // ============ REGISTRATION ============

  /**
   * Register new user and organization
   */
  async registerUser(data) {
    const { email, password, firstName, lastName, organizationName, phone } = data;

    // Validate input
    if (!email || !password || !firstName || !organizationName) {
      throw new Error('Missing required fields');
    }

    // Check if email already exists
    const existingUser = await this.User.findOne({ where: { email } });
    if (existingUser) {
      throw new Error('Email already registered');
    }

    try {
      // Create organization
      const slug = organizationName.toLowerCase().replace(/\s+/g, '-');
      const organization = await this.Organization.create({
        id: uuidv4(),
        name: organizationName,
        slug: `${slug}-${Date.now()}`,
        phone: phone,
        status: 'trial',
        licenseStartDate: new Date(),
        licenseExpiryDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days trial
        enabledModules: ['authentication', 'dashboard'],
        timezone: 'Asia/Kolkata',
        language: 'en'
      });

      // Create default roles
      const superAdminRole = await this.Role.create({
        id: uuidv4(),
        organizationId: organization.id,
        name: 'SUPER_ADMIN',
        description: 'Super Admin - Full Access',
        isSystemRole: true
      });

      // Hash password
      const passwordHash = await this.hashPassword(password);

      // Create user
      const user = await this.User.create({
        id: uuidv4(),
        organizationId: organization.id,
        firstName: firstName,
        lastName: lastName || '',
        email: email,
        phone: phone || null,
        passwordHash: passwordHash,
        roleId: superAdminRole.id,
        status: 'active',
        emailVerified: false
      });

      // Generate email verification OTP
      await this.generateOTP(email, 'email_verification');

      return {
        success: true,
        message: 'Registration successful. Please verify your email.',
        user: {
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          organizationId: organization.id
        }
      };
    } catch (error) {
      throw new Error(`Registration failed: ${error.message}`);
    }
  }

  // ============ LOGIN ============

  /**
   * Authenticate user with email and password
   */
  async login(email, password) {
    if (!email || !password) {
      throw new Error('Email and password are required');
    }

    const user = await this.User.findOne({ where: { email } });

    if (!user) {
      throw new Error('User not found');
    }

    // Check if account is locked
    if (user.lockedUntil && new Date() < new Date(user.lockedUntil)) {
      const minutesLeft = Math.ceil(
        (new Date(user.lockedUntil) - new Date()) / 60000
      );
      throw new Error(`Account locked. Try again in ${minutesLeft} minutes`);
    }

    // Verify password
    const isPasswordValid = await this.comparePassword(password, user.passwordHash);

    if (!isPasswordValid) {
      // Increment failed attempts
      user.loginAttempts = (user.loginAttempts || 0) + 1;

      if (user.loginAttempts >= 5) {
        // Lock account for 30 minutes
        user.lockedUntil = new Date(Date.now() + 30 * 60 * 1000);
      }

      await user.save();
      throw new Error('Invalid password');
    }

    // Reset login attempts
    user.loginAttempts = 0;
    user.lockedUntil = null;
    user.lastLogin = new Date();
    user.lastLoginIp = null; // Set from middleware
    await user.save();

    // Check if 2FA is enabled
    if (user.twoFaEnabled) {
      // Generate and send OTP
      await this.generateOTP(email, '2fa_login');
      return {
        success: true,
        requiresOTP: true,
        message: 'OTP sent to your email/phone',
        userId: user.id
      };
    }

    // Generate JWT token
    const token = this.generateToken(user);

    return {
      success: true,
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        organizationId: user.organizationId
      },
      token: token
    };
  }

  // ============ OTP MANAGEMENT ============

  /**
   * Generate OTP
   */
  async generateOTP(identifier, type) {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiryMinutes = process.env.OTP_EXPIRY || 10;

    const otpRecord = await this.OTP.create({
      id: uuidv4(),
      identifier: identifier,
      type: type,
      otp: otp,
      expiresAt: new Date(Date.now() + expiryMinutes * 60 * 1000),
      attempts: 0,
      isUsed: false
    });

    // Send OTP via email
    const user = await this.User.findOne({ where: { email: identifier } });
    
    if (user) {
      await this.emailService.sendOTP(user.email, otp, type);
    }

    return {
      success: true,
      message: 'OTP sent',
      expiresIn: expiryMinutes * 60
    };
  }

  /**
   * Verify OTP
   */
  async verifyOTP(identifier, otp, type) {
    const otpRecord = await this.OTP.findOne({
      where: {
        identifier: identifier,
        type: type,
        isUsed: false
      }
    });

    if (!otpRecord) {
      throw new Error('OTP not found or already used');
    }

    if (new Date() > new Date(otpRecord.expiresAt)) {
      throw new Error('OTP has expired');
    }

    if (otpRecord.attempts >= 3) {
      throw new Error('Too many attempts. Please request a new OTP');
    }

    if (otpRecord.otp !== otp) {
      otpRecord.attempts += 1;
      await otpRecord.save();
      throw new Error('Invalid OTP');
    }

    // Mark OTP as used
    otpRecord.isUsed = true;
    otpRecord.usedAt = new Date();
    await otpRecord.save();

    // If email verification, mark user email as verified
    if (type === 'email_verification') {
      const user = await this.User.findOne({ where: { email: identifier } });
      if (user) {
        user.emailVerified = true;
        await user.save();
      }
    }

    return {
      success: true,
      message: 'OTP verified successfully'
    };
  }

  // ============ 2FA MANAGEMENT ============

  /**
   * Enable 2FA for user
   */
  async enable2FA(userId, method) {
    const user = await this.User.findByPk(userId);

    if (!user) {
      throw new Error('User not found');
    }

    user.twoFaEnabled = true;
    user.twoFaMethod = method;

    if (method === 'authenticator') {
      // Generate secret for authenticator apps
      const secret = crypto.randomBytes(32).toString('hex');
      user.twoFaSecret = secret; // Should be encrypted
    }

    await user.save();

    return {
      success: true,
      message: '2FA enabled',
      secret: method === 'authenticator' ? user.twoFaSecret : null
    };
  }

  /**
   * Disable 2FA for user
   */
  async disable2FA(userId) {
    const user = await this.User.findByPk(userId);

    if (!user) {
      throw new Error('User not found');
    }

    user.twoFaEnabled = false;
    user.twoFaMethod = null;
    user.twoFaSecret = null;
    await user.save();

    return {
      success: true,
      message: '2FA disabled'
    };
  }

  // ============ PASSWORD MANAGEMENT ============

  /**
   * Hash password using bcrypt
   */
  async hashPassword(password) {
    const salt = await bcrypt.genSalt(10);
    return bcrypt.hash(password, salt);
  }

  /**
   * Compare password with hash
   */
  async comparePassword(password, hash) {
    return bcrypt.compare(password, hash);
  }

  /**
   * Change password
   */
  async changePassword(userId, oldPassword, newPassword) {
    const user = await this.User.findByPk(userId);

    if (!user) {
      throw new Error('User not found');
    }

    // Verify old password
    const isValid = await this.comparePassword(oldPassword, user.passwordHash);

    if (!isValid) {
      throw new Error('Current password is incorrect');
    }

    // Hash new password
    const newHash = await this.hashPassword(newPassword);

    user.passwordHash = newHash;
    user.passwordChangedAt = new Date();
    await user.save();

    return {
      success: true,
      message: 'Password changed successfully'
    };
  }

  /**
   * Forgot password - Generate reset token
   */
  async forgotPassword(email) {
    const user = await this.User.findOne({ where: { email } });

    if (!user) {
      // Don't reveal if email exists (security)
      return {
        success: true,
        message: 'If email exists, password reset link will be sent'
      };
    }

    // Generate reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetTokenHash = crypto
      .createHash('sha256')
      .update(resetToken)
      .digest('hex');

    // Store token hash with expiry (1 hour)
    user.passwordResetToken = resetTokenHash;
    user.passwordResetExpiresAt = new Date(Date.now() + 60 * 60 * 1000);
    await user.save();

    // Send reset email
    await this.emailService.sendPasswordResetEmail(user.email, resetToken);

    return {
      success: true,
      message: 'Password reset link sent to email'
    };
  }

  /**
   * Reset password with token
   */
  async resetPassword(token, newPassword) {
    const resetTokenHash = crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');

    const user = await this.User.findOne({
      where: {
        passwordResetToken: resetTokenHash,
        passwordResetExpiresAt: {
          [this.User.sequelize.Sequelize.Op.gte]: new Date()
        }
      }
    });

    if (!user) {
      throw new Error('Invalid or expired reset token');
    }

    // Hash new password
    const newHash = await this.hashPassword(newPassword);

    user.passwordHash = newHash;
    user.passwordResetToken = null;
    user.passwordResetExpiresAt = null;
    user.passwordChangedAt = new Date();
    await user.save();

    return {
      success: true,
      message: 'Password reset successful'
    };
  }

  // ============ TOKEN MANAGEMENT ============

  /**
   * Generate JWT token
   */
  generateToken(user) {
    const payload = {
      userId: user.id,
      organizationId: user.organizationId,
      email: user.email,
      roleId: user.roleId
    };

    const token = jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRE || '7d'
    });

    return token;
  }

  /**
   * Generate refresh token
   */
  generateRefreshToken(user) {
    const payload = {
      userId: user.id,
      organizationId: user.organizationId
    };

    const token = jwt.sign(payload, process.env.JWT_REFRESH_SECRET, {
      expiresIn: process.env.JWT_REFRESH_EXPIRE || '30d'
    });

    return token;
  }

  /**
   * Verify and refresh token
   */
  async refreshToken(refreshToken) {
    try {
      const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
      const user = await this.User.findByPk(decoded.userId);

      if (!user || user.status !== 'active') {
        throw new Error('User not found or inactive');
      }

      const newToken = this.generateToken(user);

      return {
        success: true,
        token: newToken
      };
    } catch (error) {
      throw new Error(`Token refresh failed: ${error.message}`);
    }
  }

  // ============ LOGOUT ============

  /**
   * Logout user (add token to blacklist if using)
   */
  async logout(userId) {
    const user = await this.User.findByPk(userId);

    if (user) {
      user.lastLogin = new Date();
      await user.save();
    }

    return {
      success: true,
      message: 'Logged out successfully'
    };
  }
}

export default AuthService;
