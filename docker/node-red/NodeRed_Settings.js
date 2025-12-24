// Minimal Node-RED settings template
// Copied into the Node-RED data volume as settings.js
const fs = require('fs');

module.exports = {
  uiPort: process.env.PORT || 1880,
  httpAdminRoot: '/admin',
  httpNodeRoot: '/api',
  logging: { console: { level: 'info' } },

  // HTTPS server (uncomment if using built-in TLS)
  // Node-RED will use the certs copied to /data/certs/
  https: {
    key: fs.existsSync('/data/certs/privkey.pem') ? fs.readFileSync('/data/certs/privkey.pem') : null,
    cert: fs.existsSync('/data/certs/fullchain.pem') ? fs.readFileSync('/data/certs/fullchain.pem') : null
  },

  // Allow anonymous access (no admin auth) — adjust for production
  adminAuth: null,

  // Optional: enable websockets for dashboard if needed (handled by nodes)
};
