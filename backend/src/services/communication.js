// ============================================
// 📧 EMAIL & SMS SERVICES
// ============================================

import nodemailer from 'nodemailer';
import twilio from 'twilio';

// ============================================
// EMAIL SERVICE
// ============================================

export class EmailService {
  constructor() {
    this.transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT,
      secure: process.env.SMTP_SECURE === 'true',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS
      }
    });

    this.fromEmail = process.env.EMAIL_FROM || 'noreply@hotelpro.in';
    this.companyName = 'HotelPro';
  }

  /**
   * Send OTP via email
   */
  async sendOTP(email, otp, type) {
    const typeMessages = {
      'email_verification': 'Email Verification',
      '2fa_login': '2FA Verification',
      'phone_verification': 'Phone Verification',
      'forgot_password': 'Password Reset'
    };

    const subject = `${typeMessages[type] || 'Verification'} Code`;

    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px;">
          <h2 style="color: #333;">Your ${typeMessages[type] || 'Verification'} Code</h2>
          
          <p style="color: #666; margin-bottom: 30px;">
            Use the code below to ${typeMessages[type]?.toLowerCase() || 'verify'}:
          </p>
          
          <div style="background-color: #007bff; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 30px;">
            <h1 style="margin: 0; font-size: 48px; letter-spacing: 10px;">${otp}</h1>
          </div>
          
          <p style="color: #666; font-size: 14px;">
            This code is valid for 10 minutes only.
          </p>
          
          <p style="color: #666; font-size: 14px; margin-top: 30px;">
            If you didn't request this code, please ignore this email.
          </p>
          
          <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
          
          <p style="color: #999; font-size: 12px; text-align: center;">
            © ${new Date().getFullYear()} ${this.companyName}. All rights reserved.
          </p>
        </div>
      </div>
    `;

    try {
      await this.transporter.sendMail({
        from: this.fromEmail,
        to: email,
        subject: subject,
        html: htmlContent
      });

      console.log(`OTP sent to ${email}`);
      return true;
    } catch (error) {
      console.error(`Failed to send OTP to ${email}:`, error);
      return false;
    }
  }

  /**
   * Send password reset email
   */
  async sendPasswordResetEmail(email, resetToken) {
    const resetLink = `${process.env.FRONTEND_URL}/auth/reset-password?token=${resetToken}`;

    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px;">
          <h2 style="color: #333;">Password Reset Request</h2>
          
          <p style="color: #666; margin-bottom: 20px;">
            We received a request to reset your password. Click the link below to reset it:
          </p>
          
          <div style="text-align: center; margin: 30px 0;">
            <a href="${resetLink}" style="background-color: #28a745; color: white; padding: 12px 30px; text-decoration: none; border-radius: 4px; display: inline-block;">
              Reset Password
            </a>
          </div>
          
          <p style="color: #666; font-size: 14px; word-break: break-all;">
            Or copy this link: ${resetLink}
          </p>
          
          <p style="color: #666; font-size: 14px; margin-top: 30px;">
            This link is valid for 1 hour only.
          </p>
          
          <p style="color: #999; font-size: 12px; margin-top: 30px;">
            If you didn't request this, please ignore this email.
          </p>
          
          <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
          
          <p style="color: #999; font-size: 12px; text-align: center;">
            © ${new Date().getFullYear()} ${this.companyName}. All rights reserved.
          </p>
        </div>
      </div>
    `;

    try {
      await this.transporter.sendMail({
        from: this.fromEmail,
        to: email,
        subject: 'Password Reset Request',
        html: htmlContent
      });

      console.log(`Password reset email sent to ${email}`);
      return true;
    } catch (error) {
      console.error(`Failed to send reset email to ${email}:`, error);
      return false;
    }
  }

  /**
   * Send welcome email
   */
  async sendWelcomeEmail(email, firstName) {
    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px;">
          <h2 style="color: #333;">Welcome to ${this.companyName}!</h2>
          
          <p style="color: #666; margin-bottom: 20px;">
            Hi ${firstName},
          </p>
          
          <p style="color: #666; margin-bottom: 20px;">
            Your account has been successfully created. You can now log in and start using ${this.companyName}.
          </p>
          
          <div style="text-align: center; margin: 30px 0;">
            <a href="${process.env.FRONTEND_URL}/auth/login" style="background-color: #007bff; color: white; padding: 12px 30px; text-decoration: none; border-radius: 4px; display: inline-block;">
              Go to Login
            </a>
          </div>
          
          <p style="color: #666; font-size: 14px; margin-top: 30px;">
            If you have any questions, please contact our support team.
          </p>
          
          <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
          
          <p style="color: #999; font-size: 12px; text-align: center;">
            © ${new Date().getFullYear()} ${this.companyName}. All rights reserved.
          </p>
        </div>
      </div>
    `;

    try {
      await this.transporter.sendMail({
        from: this.fromEmail,
        to: email,
        subject: `Welcome to ${this.companyName}!`,
        html: htmlContent
      });

      console.log(`Welcome email sent to ${email}`);
      return true;
    } catch (error) {
      console.error(`Failed to send welcome email to ${email}:`, error);
      return false;
    }
  }
}

// ============================================
// SMS SERVICE
// ============================================

export class SMSService {
  constructor() {
    this.twilioClient = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );
    this.fromPhone = process.env.TWILIO_FROM_PHONE;
  }

  /**
   * Send OTP via SMS
   */
  async sendOTP(phone, otp) {
    try {
      await this.twilioClient.messages.create({
        body: `Your HotelPro verification code is: ${otp}. Valid for 10 minutes.`,
        from: this.fromPhone,
        to: phone
      });

      console.log(`OTP SMS sent to ${phone}`);
      return true;
    } catch (error) {
      console.error(`Failed to send OTP SMS to ${phone}:`, error);
      return false;
    }
  }

  /**
   * Send alert SMS
   */
  async sendAlert(phone, message) {
    try {
      await this.twilioClient.messages.create({
        body: message,
        from: this.fromPhone,
        to: phone
      });

      console.log(`Alert SMS sent to ${phone}`);
      return true;
    } catch (error) {
      console.error(`Failed to send alert SMS to ${phone}:`, error);
      return false;
    }
  }
}

export default {
  EmailService,
  SMSService
};
