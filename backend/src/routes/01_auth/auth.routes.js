// ============================================
// 🔐 AUTHENTICATION ROUTES
// ============================================

import express from 'express';
import AuthController from './auth.controller.js';
import AuthService from './auth.service.js';
import { verifyToken } from '../middleware/auth.js';

export const createAuthRoutes = (models, emailService, smsService) => {
  const router = express.Router();

  // Initialize service and controller
  const authService = new AuthService(models, emailService, smsService);
  const authController = new AuthController(authService);

  // ============ PUBLIC ROUTES ============

  /**
   * POST /api/auth/register
   * Register new user and organization
   * Body: { email, password, firstName, lastName, organizationName, phone }
   */
  router.post('/register', (req, res, next) => {
    authController.register(req, res).catch(next);
  });

  /**
   * POST /api/auth/login
   * Authenticate user
   * Body: { email, password }
   */
  router.post('/login', (req, res, next) => {
    authController.login(req, res).catch(next);
  });

  /**
   * POST /api/auth/verify-otp
   * Verify OTP
   * Body: { identifier, otp, type }
   */
  router.post('/verify-otp', (req, res, next) => {
    authController.verifyOTP(req, res).catch(next);
  });

  /**
   * POST /api/auth/resend-otp
   * Resend OTP
   * Body: { identifier, type }
   */
  router.post('/resend-otp', (req, res, next) => {
    authController.resendOTP(req, res).catch(next);
  });

  /**
   * POST /api/auth/forgot-password
   * Request password reset
   * Body: { email }
   */
  router.post('/forgot-password', (req, res, next) => {
    authController.forgotPassword(req, res).catch(next);
  });

  /**
   * POST /api/auth/reset-password
   * Reset password with token
   * Body: { token, newPassword, confirmPassword }
   */
  router.post('/reset-password', (req, res, next) => {
    authController.resetPassword(req, res).catch(next);
  });

  /**
   * POST /api/auth/refresh-token
   * Refresh JWT token
   * Body: { refreshToken }
   */
  router.post('/refresh-token', (req, res, next) => {
    authController.refreshToken(req, res).catch(next);
  });

  // ============ PROTECTED ROUTES ============
  // All routes below require valid JWT token

  /**
   * POST /api/auth/logout
   * Logout user
   * Headers: { Authorization: 'Bearer <token>' }
   */
  router.post('/logout', verifyToken, (req, res, next) => {
    authController.logout(req, res).catch(next);
  });

  /**
   * GET /api/auth/profile
   * Get current user profile
   * Headers: { Authorization: 'Bearer <token>' }
   */
  router.get('/profile', verifyToken, (req, res, next) => {
    authController.getProfile(req, res).catch(next);
  });

  /**
   * PUT /api/auth/profile
   * Update user profile
   * Headers: { Authorization: 'Bearer <token>' }
   * Body: { firstName, lastName, phone, profilePhotoUrl }
   */
  router.put('/profile', verifyToken, (req, res, next) => {
    authController.updateProfile(req, res).catch(next);
  });

  /**
   * POST /api/auth/enable-2fa
   * Enable 2FA
   * Headers: { Authorization: 'Bearer <token>' }
   * Body: { method } - 'email' | 'sms' | 'authenticator'
   */
  router.post('/enable-2fa', verifyToken, (req, res, next) => {
    authController.enable2FA(req, res).catch(next);
  });

  /**
   * POST /api/auth/disable-2fa
   * Disable 2FA
   * Headers: { Authorization: 'Bearer <token>' }
   */
  router.post('/disable-2fa', verifyToken, (req, res, next) => {
    authController.disable2FA(req, res).catch(next);
  });

  /**
   * POST /api/auth/change-password
   * Change password
   * Headers: { Authorization: 'Bearer <token>' }
   * Body: { oldPassword, newPassword, confirmPassword }
   */
  router.post('/change-password', verifyToken, (req, res, next) => {
    authController.changePassword(req, res).catch(next);
  });

  return router;
};

export default createAuthRoutes;
