const FEATURES = {
  DEMO_MODE: process.env.DEMO_MODE === 'true' || true,
  MOCK_OTP: process.env.DEMO_MODE === 'true' || true,
  AUTO_VERIFY_EMAIL: process.env.DEMO_MODE === 'true' || true,
  SKIP_2FA: process.env.DEMO_MODE === 'true' || true,
  SEND_REAL_EMAILS: process.env.DEMO_MODE !== 'true',
  SEND_REAL_SMS: process.env.DEMO_MODE !== 'true',
  SHOW_OTP_IN_CONSOLE: process.env.DEMO_MODE === 'true' || true,
  SHOW_OTP_IN_RESPONSE: process.env.DEMO_MODE === 'true' || true,
};
export default FEATURES;
