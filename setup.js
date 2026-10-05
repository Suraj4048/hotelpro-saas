const fs = require('fs');

const files = [
  "backend/src/config/database.js",
  "backend/src/models/User.js",
  "backend/src/models/Organization.js",
  "backend/src/models/Role.js",
  "backend/src/models/OTP.js",
  "backend/src/routes/01_auth/auth.service.js",
  "backend/src/routes/01_auth/auth.controller.js",
  "backend/src/routes/01_auth/auth.routes.js",
  "backend/src/services/communication.js",
  "backend/src/server.js",
  "backend/package.json",
  "backend/.env.example",
  "backend/.gitignore",
  "docs/PHASE1_AUTH_IMPLEMENTATION.md",
  "docs/GITHUB_PUSH_CHECKLIST.md",
  "docs/AUTH_FLOW_ARCHITECTURE.md",
  "frontend/.gitkeep",
  "README.md",
  ".gitignore",
  "LICENSE"
];

files.forEach(path => {
  const dir = path.substring(0, path.lastIndexOf('/'));
  if(dir) fs.mkdirSync(dir, { recursive: true });
  if(!fs.existsSync(path)) fs.writeFileSync(path, `// ${path} - auto created`);
});

console.log("Ho gaya! Saare 20 files ban gaye ✅");
