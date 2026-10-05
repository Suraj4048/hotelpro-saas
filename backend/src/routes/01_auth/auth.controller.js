import FEATURES from '../config/features.js';
// ============================================
// 🔐 AUTHENTICATION CONTROLLER
// ============================================

import { asyncHandler } from '../middleware/errorHandler.js';
import ApiError from '../middleware/errorHandler.js';

export class AuthController {
  constructor(authService) {
    this.authService = authService;
  }

  // ============ REGISTRATION ============

  /**
   * POST /api/auth/register
   * Register new user and organization
   */
  register = asyncHandler(async (req, res) => {
    const { email, password, firstName, lastName, organizationName, phone } = req.body;

    // Validate input
    if (!email || !password || !firstName || !organizationName) {
      throw new ApiError(400, 'Missing required fields');
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      throw new ApiError(400, 'Invalid email format');
    }

    // Validate password strength
    if (password.length < 8) {
      throw new ApiError(400, 'Password must be at least 8 characters');
    }

    const result = await this.authService.registerUser({
      email,
      password,
      firstName,
      lastName,
      organizationName,
      phone
    });

    res.status(201).json({
      success: true,
      message: result.message,
      data: result.user
    });
  });

  // ============ LOGIN ============

  /**
   * POST /api/auth/login
   * Authenticate user
   */
  login = asyncHandler(async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
      throw new ApiError(400, 'Email and password are required');
    }

    const result = await this.authService.login(email, password);

    if (result.requiresOTP) {
      return res.status(200).json({
        success: true,
        message: result.message,
        requiresOTP: true,
        userId: result.userId
      });
    }

    res.status(200).json({
      success: true,
      message: result.message,
      data: {
        user: result.user,
        token: result.token
      }
    });
  });

  // ============ OTP VERIFICATION ============

  /**
   * POST /api/auth/verify-otp
   * Verify OTP for email verification or 2FA
   */
  verifyOTP = asyncHandler(async (req, res) => {
    const { identifier, otp, type } = req.body;

    if (!identifier || !otp || !type) {
      throw new ApiError(400, 'Identifier, OTP, and type are required');
    }

    const result = await this.authService.verifyOTP(identifier, otp, type);

    // If 2FA verification, generate token
    if (type === '2fa_login') {
      const user = await this.authService.User.findOne({
        where: { email: identifier }
      });

      const token = this.authService.generateToken(user);

      return res.status(200).json({
        success: true,
        message: 'Authentication successful',
        data: {
          user: {
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            organizationId: user.organizationId
          },
          token: token
        }
      });
    }

    res.status(200).json({
      success: true,
      message: result.message
    });
  });

  /**
   * POST /api/auth/resend-otp
   * Resend OTP
   */
  resendOTP = asyncHandler(async (req, res) => {
    const { identifier, type } = req.body;

    if (!identifier || !type) {
      throw new ApiError(400, 'Identifier and type are required');
    }

    const result = await this.authService.generateOTP(identifier, type);

    res.status(200).json({
      success: true,
      message: result.message,
      data: {
        expiresIn: result.expiresIn
      }
    });
  });

  // ============ 2FA MANAGEMENT ============

  /**
   * POST /api/auth/enable-2fa
   * Enable 2FA for authenticated user
   */
  enable2FA = asyncHandler(async (req, res) => {
    const { method } = req.body;
    const userId = req.user.userId;

    if (!method) {
      throw new ApiError(400, 'Method is required (email, sms, authenticator)');
    }

    const result = await this.authService.enable2FA(userId, method);

    res.status(200).json({
      success: true,
      message: result.message,
      data: {
        secret: result.secret // For authenticator apps
      }
    });
  });

  /**
   * POST /api/auth/disable-2fa
   * Disable 2FA for authenticated user
   */
  disable2FA = asyncHandler(async (req, res) => {
    const userId = req.user.userId;

    const result = await this.authService.disable2FA(userId);

    res.status(200).json({
      success: true,
      message: result.message
    });
  });

  // ============ PASSWORD MANAGEMENT ============

  /**
   * POST /api/auth/change-password
   * Change password for authenticated user
   */
  changePassword = asyncHandler(async (req, res) => {
    const { oldPassword, newPassword, confirmPassword } = req.body;
    const userId = req.user.userId;

    if (!oldPassword || !newPassword) {
      throw new ApiError(400, 'Old and new passwords are required');
    }

    if (newPassword !== confirmPassword) {
      throw new ApiError(400, 'Passwords do not match');
    }

    if (newPassword.length < 8) {
      throw new ApiError(400, 'New password must be at least 8 characters');
    }

    const result = await this.authService.changePassword(
      userId,
      oldPassword,
      newPassword
    );

    res.status(200).json({
      success: true,
      message: result.message
    });
  });

  /**
   * POST /api/auth/forgot-password
   * Request password reset
   */
  forgotPassword = asyncHandler(async (req, res) => {
    const { email } = req.body;

    if (!email) {
      throw new ApiError(400, 'Email is required');
    }

    const result = await this.authService.forgotPassword(email);

    res.status(200).json({
      success: true,
      message: result.message
    });
  });

  /**
   * POST /api/auth/reset-password
   * Reset password with token
   */
  resetPassword = asyncHandler(async (req, res) => {
    const { token, newPassword, confirmPassword } = req.body;

    if (!token || !newPassword) {
      throw new ApiError(400, 'Token and new password are required');
    }

    if (newPassword !== confirmPassword) {
      throw new ApiError(400, 'Passwords do not match');
    }

    if (newPassword.length < 8) {
      throw new ApiError(400, 'Password must be at least 8 characters');
    }

    const result = await this.authService.resetPassword(token, newPassword);

    res.status(200).json({
      success: true,
      message: result.message
    });
  });

  // ============ TOKEN MANAGEMENT ============

  /**
   * POST /api/auth/refresh-token
   * Refresh JWT token
   */
  refreshToken = asyncHandler(async (req, res) => {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      throw new ApiError(400, 'Refresh token is required');
    }

    const result = await this.authService.refreshToken(refreshToken);

    res.status(200).json({
      success: true,
      message: 'Token refreshed',
      data: {
        token: result.token
      }
    });
  });

  // ============ LOGOUT ============

  /**
   * POST /api/auth/logout
   * Logout user
   */
  logout = asyncHandler(async (req, res) => {
    const userId = req.user.userId;

    const result = await this.authService.logout(userId);

    res.status(200).json({
      success: true,
      message: result.message
    });
  });

  // ============ PROFILE ============

  /**
   * GET /api/auth/profile
   * Get current user profile
   */
  getProfile = asyncHandler(async (req, res) => {
    const userId = req.user.userId;

    const user = await this.authService.User.findByPk(userId, {
      attributes: {
        exclude: ['passwordHash']
      },
      include: [
        {
          association: 'role',
          attributes: ['id', 'name', 'description']
        }
      ]
    });

    if (!user) {
      throw new ApiError(404, 'User not found');
    }

    res.status(200).json({
      success: true,
      data: user
    });
  });

  /**
   * PUT /api/auth/profile
   * Update user profile
   */
  updateProfile = asyncHandler(async (req, res) => {
    const userId = req.user.userId;
    const { firstName, lastName, phone, profilePhotoUrl } = req.body;

    const user = await this.authService.User.findByPk(userId);

    if (!user) {
      throw new ApiError(404, 'User not found');
    }

    // Update allowed fields only
    if (firstName) user.firstName = firstName;
    if (lastName) user.lastName = lastName;
    if (phone) user.phone = phone;
    if (profilePhotoUrl) user.profilePhotoUrl = profilePhotoUrl;

    user.updatedBy = userId;
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: user
    });
  });
}

export default AuthController;
