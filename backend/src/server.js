// ============================================
// 🚀 HOTELPRO BACKEND - MAIN SERVER
// ============================================

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';

// Import configuration
import setupDatabase from './config/database.js';
import createAuthRoutes from './routes/01_auth/auth.routes.js';

// Import services
import { EmailService, SMSService } from './services/communication.js';

// Load environment variables
dotenv.config();

// ============================================
// INITIALIZE EXPRESS APP
// ============================================

const app = express();

// ============================================
// MIDDLEWARE
// ============================================

// Security headers
app.use(helmet());

// CORS configuration
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 attempts per 15 minutes
  message: 'Too many login attempts, please try again later.'
});

app.use('/api/', limiter);
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);

// ============================================
// REQUEST LOGGING MIDDLEWARE
// ============================================

app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// ============================================
// GLOBAL STATE
// ============================================

let dbInitialized = false;
let models = null;
let emailService = null;
let smsService = null;

// ============================================
// HEALTH CHECK ENDPOINT
// ============================================

app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    service: 'hotelpro-backend',
    version: '1.0.0',
    database: dbInitialized ? 'connected' : 'connecting...',
    environment: process.env.NODE_ENV || 'development'
  });
});

// ============================================
// DATABASE INITIALIZATION ENDPOINT
// ============================================

app.get('/api/init', async (req, res) => {
  try {
    if (dbInitialized) {
      return res.json({
        message: 'Database already initialized',
        status: 'ready',
        timestamp: new Date().toISOString()
      });
    }

    console.log('🔄 Initializing database...');

    // Setup database
    const { sequelize, models: dbModels } = await setupDatabase();
    models = dbModels;

    // Initialize services
    emailService = new EmailService();
    smsService = new SMSService();

    dbInitialized = true;

    console.log('✅ Database initialized successfully');

    res.json({
      message: 'Database initialized successfully',
      status: 'ready',
      timestamp: new Date().toISOString(),
      models: Object.keys(models)
    });
  } catch (error) {
    console.error('❌ Database initialization failed:', error.message);
    res.status(500).json({
      error: 'Database initialization failed',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// ============================================
// ROUTES
// ============================================

// Mount authentication routes (requires DB to be initialized)
app.use('/api/auth', (req, res, next) => {
  if (!dbInitialized) {
    return res.status(503).json({
      error: 'Service Unavailable',
      message: 'Database not initialized. Call /api/init first'
    });
  }
  next();
}, createAuthRoutes(models, emailService, smsService));

// API Documentation endpoint
app.get('/api/docs', (req, res) => {
  res.json({
    service: 'HotelPro Backend API',
    version: '1.0.0',
    description: 'Premium Hotel ERP/PMS SaaS Platform',
    documentation: 'See /docs/PHASE1_AUTH_IMPLEMENTATION.md',
    endpoints: {
      auth: {
        public: [
          'POST /api/auth/register',
          'POST /api/auth/login',
          'POST /api/auth/verify-otp',
          'POST /api/auth/resend-otp',
          'POST /api/auth/forgot-password',
          'POST /api/auth/reset-password',
          'POST /api/auth/refresh-token'
        ],
        protected: [
          'GET /api/auth/profile',
          'PUT /api/auth/profile',
          'POST /api/auth/change-password',
          'POST /api/auth/enable-2fa',
          'POST /api/auth/disable-2fa',
          'POST /api/auth/logout'
        ]
      },
      system: {
        public: [
          'GET /api/health',
          'GET /api/init',
          'GET /api/docs'
        ]
      }
    }
  });
});

// ============================================
// 404 HANDLER
// ============================================

app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} does not exist`,
    timestamp: new Date().toISOString()
  });
});

// ============================================
// ERROR HANDLER
// ============================================

app.use((err, req, res, next) => {
  console.error('❌ Error:', err);

  const statusCode = err.status || err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  res.status(statusCode).json({
    error: err.name || 'Error',
    message: message,
    status: statusCode,
    timestamp: new Date().toISOString(),
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// ============================================
// SERVER STARTUP
// ============================================

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || 'localhost';

const server = app.listen(PORT, () => {
  console.log('');
  console.log('╔════════════════════════════════════════════════════════╗');
  console.log('║         🚀 HOTELPRO BACKEND SERVER STARTED 🚀          ║');
  console.log('╚════════════════════════════════════════════════════════╝');
  console.log('');
  console.log(`📌 Server:       http://${HOST}:${PORT}`);
  console.log(`🔧 Environment:  ${process.env.NODE_ENV || 'development'}`);
  console.log(`💾 Database:     ${process.env.DB_NAME}`);
  console.log('');
  console.log('📚 API Endpoints:');
  console.log(`   • Health:       GET    /api/health`);
  console.log(`   • Init DB:      GET    /api/init`);
  console.log(`   • Docs:         GET    /api/docs`);
  console.log(`   • Auth:         POST   /api/auth/register`);
  console.log(`   • Login:        POST   /api/auth/login`);
  console.log('');
  console.log('📖 Documentation: See /docs/PHASE1_AUTH_IMPLEMENTATION.md');
  console.log('');
  console.log('⚙️  NEXT STEPS:');
  console.log(`   1. Visit http://${HOST}:${PORT}/api/init to initialize database`);
  console.log(`   2. Create .env file from .env.example`);
  console.log('   3. Configure email & SMS services');
  console.log('   4. Start testing API endpoints');
  console.log('');
});

// ============================================
// GRACEFUL SHUTDOWN
// ============================================

process.on('SIGTERM', () => {
  console.log('⚠️  SIGTERM received, shutting down gracefully...');
  server.close(() => {
    console.log('✅ Server shut down');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('⚠️  SIGINT received, shutting down gracefully...');
  server.close(() => {
    console.log('✅ Server shut down');
    process.exit(0);
  });
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('❌ Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

export default app;
