# 🔐 Phase 1: Authentication Module - Complete Implementation

## Overview
Complete authentication system with JWT, OTP, 2FA, password management, role-based access control (RBAC), and multi-tenant support.

---

## 📁 File Structure

```
backend/
├── src/
│   ├── config/
│   │   └── database.js              [09] Database setup & models
│   │
│   ├── models/
│   │   ├── User.js                  [01] User model
│   │   ├── Organization.js          [02] Organization model
│   │   ├── Role.js                  [03] Role & RolePermission models
│   │   └── OTP.js                   [05] OTP model
│   │
│   ├── routes/
│   │   └── 01_auth/
│   │       ├── auth.routes.js       [07] Auth routes
│   │       ├── auth.controller.js   [06] Auth controllers
│   │       └── auth.service.js      [04] Auth business logic
│   │
│   ├── services/
│   │   └── communication.js         [08] Email & SMS services
│   │
│   ├── middleware/
│   │   ├── auth.js                  [Existing] JWT verification
│   │   └── errorHandler.js          [Existing] Error handling
│   │
│   └── server.js                    [Existing] Main app
│
└── .env.example                      [Update with new variables]
```

---

## 🗄️ Database Tables Created

### 1. **organizations** Table
```sql
- id (UUID, Primary Key)
- name (String)
- slug (String, Unique)
- logoUrl (Text)
- email (String)
- phone (String)
- address (Text)
- city, state, country, postalCode
- gstin (String, Unique for India)
- subscriptionTier (ENUM: RESTAURANT_BASIC, HOTEL_PRO, FULL_SERVICE_PRO, etc.)
- enabledModules (JSON array)
- maxProperties, maxUsers (Integer)
- licenseStartDate, licenseExpiryDate (Date)
- status (ENUM: active, suspended, expired, trial)
- timezone (Default: Asia/Kolkata)
- language (Default: en)
- createdAt, updatedAt, createdBy, updatedBy
```

### 2. **users** Table
```sql
- id (UUID, Primary Key)
- organizationId (UUID, FK)
- firstName, lastName (String)
- email (String, Unique per org)
- phone (String)
- username (String, Unique)
- passwordHash (String)
- profilePhotoUrl (Text)
- roleId (UUID, FK)
- department (String)
- status (ENUM: active, inactive, suspended)
- emailVerified, phoneVerified (Boolean)
- twoFaEnabled (Boolean)
- twoFaMethod (ENUM: email, sms, authenticator)
- twoFaSecret (String - Encrypted)
- lastLogin, lastLoginIp (DateTime, String)
- loginAttempts, lockedUntil (Integer, DateTime)
- passwordChangedAt (DateTime)
- createdAt, updatedAt, deletedAt
```

### 3. **roles** Table
```sql
- id (UUID, Primary Key)
- organizationId (UUID, FK)
- name (String, Unique per org)
- description (Text)
- isSystemRole (Boolean)
- createdAt, updatedAt
```

### 4. **role_permissions** Table
```sql
- id (UUID, Primary Key)
- roleId (UUID, FK)
- moduleName (String) - e.g., 'pms', 'restaurant_pos', 'billing'
- permission (String) - e.g., 'VIEW', 'CREATE', 'EDIT', 'DELETE', 'APPROVE'
- createdAt
```

### 5. **otps** Table
```sql
- id (UUID, Primary Key)
- identifier (String) - Email or phone
- type (ENUM: email_verification, 2fa_login, phone_verification, forgot_password)
- otp (String - 6 digits)
- expiresAt (DateTime)
- isUsed (Boolean)
- usedAt (DateTime)
- attempts (Integer)
- createdAt
```

---

## 🔌 Installation Steps

### 1. **Install Dependencies**
```bash
cd backend
npm install
```

Required packages (add to package.json):
```json
{
  "dependencies": {
    "express": "^4.18.2",
    "sequelize": "^6.35.1",
    "pg": "^8.11.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.1.0",
    "dotenv": "^16.3.1",
    "nodemailer": "^6.9.7",
    "twilio": "^3.85.0",
    "uuid": "^9.0.0",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "express-rate-limit": "^7.1.5"
  }
}
```

### 2. **Setup Environment Variables**
Create `.env` file in backend directory:

```env
# ============ SERVER ============
NODE_ENV=development
PORT=5000
FRONTEND_URL=http://localhost:3000

# ============ DATABASE ============
DB_HOST=localhost
DB_PORT=5432
DB_NAME=hotelpro_saas
DB_USER=hotelpro
DB_PASSWORD=YourSecurePassword123
DB_AUTO_SYNC=true
DB_FORCE_SYNC=false
DB_LOGGING=false
DB_SEED=true

# ============ JWT ============
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRE=7d
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-in-production
JWT_REFRESH_EXPIRE=30d

# ============ OTP ============
OTP_EXPIRY=10

# ============ EMAIL (SMTP) ============
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
EMAIL_FROM=noreply@hotelpro.in

# ============ SMS (Twilio) ============
TWILIO_ACCOUNT_SID=your-account-sid
TWILIO_AUTH_TOKEN=your-auth-token
TWILIO_FROM_PHONE=+1234567890

# ============ SECURITY ============
BCRYPT_ROUNDS=10
```

### 3. **Create Database**
```bash
# PostgreSQL
createdb hotelpro_saas
createuser hotelpro
psql -d hotelpro_saas -c "ALTER USER hotelpro WITH PASSWORD 'YourSecurePassword123';"
```

### 4. **Run Server**
```bash
npm start
# Or with nodemon for development
npm run dev
```

---

## 📡 API Endpoints

### **PUBLIC ENDPOINTS** (No authentication required)

#### 1. **Register**
```
POST /api/auth/register

Request Body:
{
  "email": "user@example.com",
  "password": "SecurePass@123",
  "firstName": "John",
  "lastName": "Doe",
  "organizationName": "My Hotel",
  "phone": "+91-9876543210"
}

Response (201):
{
  "success": true,
  "message": "Registration successful. Please verify your email.",
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "firstName": "John",
    "organizationId": "uuid"
  }
}
```

#### 2. **Login**
```
POST /api/auth/login

Request Body:
{
  "email": "user@example.com",
  "password": "SecurePass@123"
}

Response (200):
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "firstName": "John",
      "organizationId": "uuid"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}

If 2FA enabled:
{
  "success": true,
  "message": "OTP sent to your email/phone",
  "requiresOTP": true,
  "userId": "uuid"
}
```

#### 3. **Verify OTP**
```
POST /api/auth/verify-otp

Request Body:
{
  "identifier": "user@example.com",
  "otp": "123456",
  "type": "email_verification" | "2fa_login"
}

Response (200):
{
  "success": true,
  "message": "OTP verified successfully"
}

Or for 2FA login (with token):
{
  "success": true,
  "message": "Authentication successful",
  "data": {
    "user": {...},
    "token": "..."
  }
}
```

#### 4. **Resend OTP**
```
POST /api/auth/resend-otp

Request Body:
{
  "identifier": "user@example.com",
  "type": "email_verification"
}

Response (200):
{
  "success": true,
  "message": "OTP sent",
  "data": {
    "expiresIn": 600
  }
}
```

#### 5. **Forgot Password**
```
POST /api/auth/forgot-password

Request Body:
{
  "email": "user@example.com"
}

Response (200):
{
  "success": true,
  "message": "If email exists, password reset link will be sent"
}
```

#### 6. **Reset Password**
```
POST /api/auth/reset-password

Request Body:
{
  "token": "reset-token-from-email",
  "newPassword": "NewPass@123",
  "confirmPassword": "NewPass@123"
}

Response (200):
{
  "success": true,
  "message": "Password reset successful"
}
```

#### 7. **Refresh Token**
```
POST /api/auth/refresh-token

Request Body:
{
  "refreshToken": "refresh-token"
}

Response (200):
{
  "success": true,
  "message": "Token refreshed",
  "data": {
    "token": "new-jwt-token"
  }
}
```

---

### **PROTECTED ENDPOINTS** (Requires valid JWT token)

All protected endpoints require:
```
Headers:
{
  "Authorization": "Bearer <jwt-token>"
}
```

#### 8. **Get Profile**
```
GET /api/auth/profile

Response (200):
{
  "success": true,
  "data": {
    "id": "uuid",
    "firstName": "John",
    "lastName": "Doe",
    "email": "user@example.com",
    "phone": "+91-9876543210",
    "status": "active",
    "emailVerified": true,
    "twoFaEnabled": false,
    "role": {
      "id": "uuid",
      "name": "SUPER_ADMIN",
      "description": "Full Access"
    }
  }
}
```

#### 9. **Update Profile**
```
PUT /api/auth/profile

Request Body:
{
  "firstName": "Jane",
  "lastName": "Smith",
  "phone": "+91-9876543211",
  "profilePhotoUrl": "https://..."
}

Response (200):
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {...}
}
```

#### 10. **Change Password**
```
POST /api/auth/change-password

Request Body:
{
  "oldPassword": "OldPass@123",
  "newPassword": "NewPass@123",
  "confirmPassword": "NewPass@123"
}

Response (200):
{
  "success": true,
  "message": "Password changed successfully"
}
```

#### 11. **Enable 2FA**
```
POST /api/auth/enable-2fa

Request Body:
{
  "method": "email" | "sms" | "authenticator"
}

Response (200):
{
  "success": true,
  "message": "2FA enabled",
  "data": {
    "secret": "hex-secret-for-authenticator-apps"
  }
}
```

#### 12. **Disable 2FA**
```
POST /api/auth/disable-2fa

Response (200):
{
  "success": true,
  "message": "2FA disabled"
}
```

#### 13. **Logout**
```
POST /api/auth/logout

Response (200):
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 🔐 Security Features Implemented

1. **Password Security**
   - Bcrypt hashing with 10 salt rounds
   - Password strength validation (min 8 chars)
   - Password change history
   - Forgot password with time-limited token

2. **Account Security**
   - Account lockout after 5 failed login attempts (30 min)
   - Login attempt tracking
   - Last login logging with IP address
   - Email and phone verification

3. **Two-Factor Authentication**
   - Email OTP
   - SMS OTP
   - TOTP/Authenticator apps

4. **Token Security**
   - JWT with expiration (7 days)
   - Refresh token mechanism (30 days)
   - Token verification on every request

5. **Data Security**
   - Multi-tenant isolation via organizationId
   - Soft deletes for audit trail
   - Encrypted 2FA secrets
   - Input validation and sanitization

---

## 🔗 Integration with Server

Add to your main `server.js`:

```javascript
import express from 'express';
import setupDatabase from './config/database.js';
import createAuthRoutes from './routes/01_auth/auth.routes.js';
import { EmailService, SMSService } from './services/communication.js';
import { verifyToken } from './middleware/auth.js';

const app = express();

// Middleware
app.use(express.json());

// Database setup
const { sequelize, models } = await setupDatabase();

// Initialize services
const emailService = new EmailService();
const smsService = new SMSService();

// Register auth routes
app.use('/api/auth', createAuthRoutes(models, emailService, smsService));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', module: 'auth' });
});

// Start server
app.listen(process.env.PORT || 5000, () => {
  console.log(`✅ Server running on port ${process.env.PORT || 5000}`);
});
```

---

## 🧪 Testing Authentication

### Using cURL:

```bash
# 1. Register
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test@12345",
    "firstName": "Test",
    "organizationName": "Test Hotel"
  }'

# 2. Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test@12345"
  }'

# 3. Get Profile (replace TOKEN with actual JWT)
curl -X GET http://localhost:5000/api/auth/profile \
  -H "Authorization: Bearer TOKEN"

# 4. Logout
curl -X POST http://localhost:5000/api/auth/logout \
  -H "Authorization: Bearer TOKEN"
```

---

## 📊 Default System Roles

1. **SUPER_ADMIN** - Full system access
2. **OWNER** - Organization owner
3. **GENERAL_MANAGER** - Hotel general manager
4. **FRONT_OFFICE_MANAGER** - Front office manager
5. **RECEPTIONIST** - Front desk staff
6. **RESTAURANT_MANAGER** - Restaurant manager
7. **WAITER** - Server staff
8. **CHEF** - Kitchen staff
9. **HOUSEKEEPING_STAFF** - Housekeeping team
10. **STAFF** - General staff
11. **GUEST** - Guest user

---

## ✅ Next Steps (Phase 2)

After Phase 1 (Auth) is complete:
1. **Dashboard Module** - KPIs, analytics
2. **Organization Management** - User management, roles, subscriptions
3. **PMS Module** - Room management, reservations, check-in/out
4. **More modules** following the same pattern

---

## 📝 Notes

- All times in UTC, converted to organization timezone when needed
- All IDs are UUIDs for security
- Soft deletes maintain audit trail
- Multi-tenant isolation through organizationId
- Module licensing via enabledModules JSON field
- Default demo user: demo@hotelpro.in / Demo@123456

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Database connection failed | Check PostgreSQL is running, credentials in .env |
| Email not sending | Verify SMTP credentials, enable "Less secure apps" for Gmail |
| OTP not working | Check OTP_EXPIRY in .env, verify SMS/Email service |
| JWT token invalid | Ensure JWT_SECRET is consistent, check token expiry |
| 2FA not enabling | Ensure encrypted secret storage is configured |

---

**Phase 1 Authentication module is COMPLETE! Ready for GitHub push! 🚀**
