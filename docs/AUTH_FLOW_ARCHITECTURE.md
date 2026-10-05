# 🔐 Authentication Flow & System Architecture

---

## 🔄 Registration Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      USER REGISTRATION                           │
└─────────────────────────────────────────────────────────────────┘

1. USER SUBMITS REGISTRATION DATA
   ├─ Email
   ├─ Password
   ├─ First Name
   ├─ Organization Name
   └─ Phone (optional)

                    ↓
                    
2. BACKEND VALIDATION (auth.controller.js)
   ├─ Check required fields
   ├─ Validate email format
   ├─ Validate password strength (min 8 chars)
   └─ Check if email already exists

                    ↓
                    
3. CREATE ORGANIZATION (auth.service.js)
   ├─ Generate unique slug
   ├─ Set trial period (30 days)
   ├─ Enable default modules: [auth, dashboard]
   ├─ Set timezone: Asia/Kolkata
   └─ Status: trial

                    ↓
                    
4. CREATE DEFAULT ROLE
   └─ SUPER_ADMIN role with full permissions

                    ↓
                    
5. HASH PASSWORD (bcryptjs)
   ├─ Generate salt (10 rounds)
   └─ Hash with salt

                    ↓
                    
6. CREATE USER
   ├─ Link to organization
   ├─ Link to SUPER_ADMIN role
   ├─ Status: active
   ├─ emailVerified: false
   └─ Save to users table

                    ↓
                    
7. GENERATE & SEND EMAIL OTP
   ├─ Generate 6-digit OTP
   ├─ Save to otps table with 10min expiry
   ├─ Send via SMTP (Nodemailer)
   └─ Type: email_verification

                    ↓
                    
8. RETURN SUCCESS
   └─ Message: "Registration successful. Please verify your email."

┌─────────────────────────────────────────────────────────────────┐
│               USER NOW VERIFIES EMAIL WITH OTP                   │
│              (See OTP Verification Flow Below)                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔑 Login Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER LOGIN                               │
└─────────────────────────────────────────────────────────────────┘

1. USER SUBMITS LOGIN DATA
   ├─ Email
   └─ Password

                    ↓
                    
2. FIND USER IN DATABASE
   ├─ Query: SELECT * FROM users WHERE email = ?
   ├─ If not found: Throw error "User not found"
   └─ If found: Continue to step 3

                    ↓
                    
3. CHECK ACCOUNT STATUS
   ├─ If account locked:
   │  └─ Throw error "Account locked for X minutes"
   └─ If locked ended:
      └─ Reset lock, continue

                    ↓
                    
4. VERIFY PASSWORD
   ├─ Compare submitted password with stored hash
   ├─ If invalid:
   │  ├─ Increment loginAttempts
   │  ├─ If attempts >= 5:
   │  │  └─ Lock account for 30 minutes
   │  └─ Throw error "Invalid password"
   └─ If valid: Continue to step 5

                    ↓
                    
5. RESET FAILED ATTEMPTS
   ├─ Set loginAttempts = 0
   ├─ Clear lockedUntil
   ├─ Update lastLogin = now()
   ├─ Save lastLoginIp (from middleware)
   └─ Save user record

                    ↓
                    
6. CHECK 2FA STATUS
   └─ If twoFaEnabled = true:
      ├─ Generate OTP
      ├─ Send via email/SMS
      ├─ Return: { requiresOTP: true, userId }
      └─ User must verify OTP to get token (see OTP flow)

                    ↓
                    
7. GENERATE JWT TOKEN
   ├─ Payload:
   │  ├─ userId
   │  ├─ organizationId
   │  ├─ email
   │  └─ roleId
   ├─ Sign with JWT_SECRET
   ├─ Expiry: 7 days
   └─ Return token

                    ↓
                    
8. RETURN SUCCESS WITH TOKEN
   └─ {
      "user": { id, email, firstName, organizationId },
      "token": "eyJhbGc..."
    }

┌─────────────────────────────────────────────────────────────────┐
│       TOKEN IS USED IN ALL FUTURE REQUESTS AS                    │
│       Authorization: Bearer <token>                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📱 OTP Verification Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    OTP VERIFICATION                              │
│               (Email Verification or 2FA Login)                  │
└─────────────────────────────────────────────────────────────────┘

1. USER SUBMITS OTP
   ├─ Identifier: email or phone
   ├─ OTP: 6-digit code
   └─ Type: email_verification | 2fa_login

                    ↓
                    
2. FIND OTP RECORD
   ├─ Query: SELECT * FROM otps 
   │  WHERE identifier = ? AND type = ? AND isUsed = false
   ├─ If not found: Error "OTP not found or already used"
   └─ If found: Continue

                    ↓
                    
3. CHECK OTP EXPIRY
   ├─ If now() > expiresAt:
   │  └─ Error "OTP has expired"
   └─ If valid: Continue

                    ↓
                    
4. CHECK ATTEMPT LIMIT
   ├─ If attempts >= 3:
   │  └─ Error "Too many attempts"
   └─ If valid: Continue

                    ↓
                    
5. VERIFY OTP CODE
   ├─ If submitted OTP != stored OTP:
   │  ├─ Increment attempts
   │  ├─ Save record
   │  └─ Error "Invalid OTP"
   └─ If matches: Continue

                    ↓
                    
6. MARK OTP AS USED
   ├─ Set isUsed = true
   ├─ Set usedAt = now()
   └─ Save record

                    ↓
                    
7. IF EMAIL VERIFICATION
   ├─ Find user with this email
   ├─ Set emailVerified = true
   ├─ Save user
   └─ Return success

                    ↓
                    
8. IF 2FA LOGIN
   ├─ Find user with this email
   ├─ Generate JWT token
   └─ Return token with user data

```

---

## 🔐 Password Reset Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    PASSWORD RESET                                │
└─────────────────────────────────────────────────────────────────┘

FORGOT PASSWORD:
1. User submits email
2. Find user (don't reveal if found)
3. Generate reset token:
   ├─ Random 32-byte hex string
   └─ Hash with SHA256
4. Store hash with 1-hour expiry
5. Send email with reset link
6. Return generic success message

                    ↓
                    
RESET PASSWORD:
1. User clicks email link with token
2. User submits new password + token
3. Hash token and find matching record
4. Check if token not expired
5. Hash new password
6. Update passwordHash
7. Clear reset token
8. Update passwordChangedAt
9. Return success
10. User can login with new password

```

---

## 🔄 Token Refresh Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    TOKEN REFRESH                                 │
│             (7-day token expiry management)                      │
└─────────────────────────────────────────────────────────────────┘

1. TOKEN APPROACHING EXPIRY
   └─ Frontend detects: 1 day left

                    ↓
                    
2. SEND REFRESH TOKEN REQUEST
   ├─ Endpoint: POST /api/auth/refresh-token
   └─ Body: { refreshToken: "..." }

                    ↓
                    
3. VERIFY REFRESH TOKEN
   ├─ Decode with JWT_REFRESH_SECRET
   ├─ If invalid/expired: Error
   └─ Extract userId

                    ↓
                    
4. VERIFY USER STILL EXISTS
   ├─ Query user by id
   ├─ If not found: Error
   └─ If status != active: Error

                    ↓
                    
5. GENERATE NEW JWT TOKEN
   └─ Same payload as original

                    ↓
                    
6. RETURN NEW TOKEN
   └─ Frontend updates Authorization header

┌─────────────────────────────────────────────────────────────────┐
│          REFRESH TOKEN VALID FOR 30 DAYS                         │
│          JWT TOKEN VALID FOR 7 DAYS                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔒 2FA Enabling Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    ENABLE 2FA                                    │
│             (Email, SMS, or Authenticator)                       │
└─────────────────────────────────────────────────────────────────┘

METHOD 1: EMAIL OTP
1. User selects "Email" method
2. Backend:
   ├─ Set twoFaEnabled = true
   ├─ Set twoFaMethod = "email"
   └─ Save user
3. From now on, login requires OTP verification

                    ↓

METHOD 2: SMS OTP
1. User selects "SMS" method
2. Backend:
   ├─ Set twoFaEnabled = true
   ├─ Set twoFaMethod = "sms"
   ├─ Verify phone number first (separate OTP flow)
   └─ Save user
3. From now on, login sends OTP to registered phone

                    ↓

METHOD 3: AUTHENTICATOR (TOTP)
1. User selects "Authenticator" method
2. Backend:
   ├─ Generate 32-byte random secret
   ├─ Set twoFaSecret = encrypted_secret
   ├─ Set twoFaEnabled = true
   ├─ Set twoFaMethod = "authenticator"
   └─ Return secret to frontend
3. Frontend:
   ├─ Displays QR code (from secret)
   ├─ User scans with Google Authenticator/Authy
   ├─ User enters 6-digit code from app
   ├─ Backend verifies code
   └─ Confirm 2FA enabled
4. From now on, login requires authenticator code

```

---

## 🏗️ System Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                        CLIENT (Browser/App)                          │
│                                                                      │
│  Login Form → Auth State → JWT Token → Authorization Header         │
└────────────────────────────────┬─────────────────────────────────────┘
                                 │
                    HTTP/HTTPS (REST API)
                                 │
┌────────────────────────────────▼─────────────────────────────────────┐
│                      EXPRESS SERVER (Port 5000)                       │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │              MIDDLEWARE LAYER                               │  │
│  │  ├─ express.json()          [Parse requests]              │  │
│  │  ├─ cors()                   [Allow cross-origin]         │  │
│  │  ├─ helmet()                 [Security headers]           │  │
│  │  ├─ verifyToken              [JWT verification]           │  │
│  │  └─ errorHandler             [Error handling]             │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                 │                                   │
│                    ↓                                                │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │         ROUTES (01_auth/auth.routes.js)                     │  │
│  │  ├─ POST /api/auth/register         [Public]              │  │
│  │  ├─ POST /api/auth/login            [Public]              │  │
│  │  ├─ POST /api/auth/verify-otp       [Public]              │  │
│  │  ├─ POST /api/auth/forgot-password  [Public]              │  │
│  │  ├─ POST /api/auth/reset-password   [Public]              │  │
│  │  ├─ POST /api/auth/refresh-token    [Public]              │  │
│  │  ├─ GET  /api/auth/profile          [Protected]           │  │
│  │  ├─ PUT  /api/auth/profile          [Protected]           │  │
│  │  ├─ POST /api/auth/change-password  [Protected]           │  │
│  │  ├─ POST /api/auth/enable-2fa       [Protected]           │  │
│  │  ├─ POST /api/auth/disable-2fa      [Protected]           │  │
│  │  └─ POST /api/auth/logout           [Protected]           │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                 │                                   │
│                    ↓                                                │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │      CONTROLLERS (01_auth/auth.controller.js)               │  │
│  │  ├─ register()                                              │  │
│  │  ├─ login()                                                 │  │
│  │  ├─ verifyOTP()                                             │  │
│  │  ├─ resendOTP()                                             │  │
│  │  ├─ enable2FA()                                             │  │
│  │  ├─ disable2FA()                                            │  │
│  │  ├─ changePassword()                                        │  │
│  │  ├─ forgotPassword()                                        │  │
│  │  ├─ resetPassword()                                         │  │
│  │  ├─ refreshToken()                                          │  │
│  │  ├─ getProfile()                                            │  │
│  │  ├─ updateProfile()                                         │  │
│  │  └─ logout()                                                │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                 │                                   │
│                    ↓                                                │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │       SERVICES (01_auth/auth.service.js)                    │  │
│  │  ├─ registerUser()                                          │  │
│  │  ├─ login()                                                 │  │
│  │  ├─ generateOTP()                                           │  │
│  │  ├─ verifyOTP()                                             │  │
│  │  ├─ enable2FA()                                             │  │
│  │  ├─ disable2FA()                                            │  │
│  │  ├─ hashPassword()                                          │  │
│  │  ├─ comparePassword()                                       │  │
│  │  ├─ changePassword()                                        │  │
│  │  ├─ forgotPassword()                                        │  │
│  │  ├─ resetPassword()                                         │  │
│  │  ├─ generateToken()                                         │  │
│  │  ├─ generateRefreshToken()                                  │  │
│  │  ├─ refreshToken()                                          │  │
│  │  └─ logout()                                                │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                 │                                   │
│                    ↓                                                │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │          EXTERNAL SERVICES                                  │  │
│  │  ├─ EmailService (Nodemailer)                              │  │
│  │  │   ├─ sendOTP()                                          │  │
│  │  │   ├─ sendPasswordResetEmail()                           │  │
│  │  │   └─ sendWelcomeEmail()                                 │  │
│  │  │                                                          │  │
│  │  └─ SMSService (Twilio)                                    │  │
│  │      ├─ sendOTP()                                          │  │
│  │      └─ sendAlert()                                        │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                 │                                   │
│                    ↓                                                │
│                                                                      │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
                    PostgreSQL Database Connection
                                   │
┌──────────────────────────────────▼──────────────────────────────────┐
│                    POSTGRESQL DATABASE                              │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │  users       │  │ organizations│  │   roles      │              │
│  │  ─────────   │  │ ──────────── │  │  ──────────  │              │
│  │  id (PK)     │  │  id (PK)     │  │  id (PK)     │              │
│  │  email       │  │  name        │  │  name        │              │
│  │  password    │  │  slug        │  │  orgId (FK)  │              │
│  │  firstName   │  │  subscTier   │  │              │              │
│  │  roleId (FK) │  │  enabledMods │  └──────────────┘              │
│  │  2faEnabled  │  │  status      │                                │
│  │  orgId (FK)  │  │              │   ┌──────────────┐             │
│  │  ...         │  │  ...         │   │ otps         │             │
│  │              │  │              │   │ ──────────   │             │
│  └──────────────┘  └──────────────┘   │ id (PK)      │             │
│                                        │ identifier   │             │
│  ┌──────────────────────────────┐    │ otp          │             │
│  │  role_permissions            │    │ expiresAt    │             │
│  │  ────────────────────────────│    │ isUsed       │             │
│  │  id (PK)                     │    │ ...          │             │
│  │  roleId (FK)                 │    └──────────────┘             │
│  │  moduleName                  │                                 │
│  │  permission                  │                                 │
│  │  (e.g., pms: VIEW/CREATE)    │                                 │
│  └──────────────────────────────┘                                 │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Security Layers

```
┌─────────────────────────────────────────────────────────┐
│                SECURITY LAYERS                          │
└─────────────────────────────────────────────────────────┘

LAYER 1: HTTPS/TLS
└─ All traffic encrypted in transit

LAYER 2: INPUT VALIDATION
├─ Email format
├─ Password strength
├─ OTP format
└─ Data type validation

LAYER 3: AUTHENTICATION
├─ Email/password login
├─ OTP verification (email/SMS)
├─ 2FA (TOTP/Authenticator)
└─ JWT token with expiry

LAYER 4: ACCOUNT PROTECTION
├─ Bcrypt password hashing (10 rounds)
├─ Account lockout (5 failed attempts)
├─ Password change history
└─ Login tracking (IP, timestamp)

LAYER 5: TOKEN SECURITY
├─ JWT signed with secret
├─ Token expiry (7 days)
├─ Refresh token mechanism
└─ Token validation on each request

LAYER 6: AUTHORIZATION
├─ Role-based access control (RBAC)
├─ Module-level permissions
├─ Resource-level access checks
└─ Soft deletes for audit trail

LAYER 7: DATA PROTECTION
├─ Multi-tenant isolation
├─ Encrypted 2FA secrets
├─ No sensitive data in logs
└─ Soft deletes maintain history

LAYER 8: RATE LIMITING
├─ Login attempt limits
├─ OTP attempt limits
└─ General API rate limiting (in middleware)
```

---

## 📊 Database Relationships

```
organizations (1) ──────────► (N) users
    │                            │
    │                            ├─► [email verified]
    │                            ├─► [2FA enabled]
    │                            └─► [login tracking]
    │
    └───────────────────► (N) roles
                            │
                            └─► (N) role_permissions
                                  (module:permission pairs)

otps (N) ─────────────────► (1) user
    ├─ email_verification
    ├─ 2fa_login
    ├─ phone_verification
    └─ forgot_password
```

---

## ✅ Ready for Production

All security layers implemented:
- ✅ Password hashing with bcrypt
- ✅ JWT token management
- ✅ OTP generation & verification
- ✅ 2FA support
- ✅ Account lockout mechanism
- ✅ Input validation
- ✅ Multi-tenant isolation
- ✅ Role-based access control
- ✅ Error handling
- ✅ Audit logging (soft deletes)

---

**Phase 1 Authentication Module - Complete & Secure! 🔐**
