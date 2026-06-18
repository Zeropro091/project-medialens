/**
 * PM2 Ecosystem Configuration for Lensa Insignia
 *
 * Manages the production SSR server and Cloudflare tunnel as PM2 processes.
 * 
 * Commands:
 *   pm2 start ecosystem.config.cjs        — Start all processes
 *   pm2 stop ecosystem.config.cjs         — Stop all processes
 *   pm2 restart ecosystem.config.cjs      — Restart all processes
 *   pm2 logs                              — View logs
 *   pm2 status                            — Check process status
 *   pm2 save                              — Save process list for auto-restart on boot
 *   pm2 startup                           — Generate auto-start script (run as admin)
 */

// Ensure logs directory exists
const fs = require('fs');
const path = require('path');
const logDir = path.join(__dirname, 'logs');
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

module.exports = {
  apps: [
    {
      name: 'lin-app',
      script: 'server.ts',
      interpreter: './node_modules/.bin/tsx',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
      },
      // Restart if process exits
      autorestart: true,
      // Watch for file changes (disabled in production)
      watch: false,
      // Max memory before auto-restart
      max_memory_restart: '512M',
      // Log configuration
      error_file: './logs/lin-app-error.log',
      out_file: './logs/lin-app-out.log',
      merge_logs: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      // Delay between restarts to avoid rapid restart loops
      restart_delay: 3000,
      // Max restarts in a row before backing off
      max_restarts: 10,
    },
    {
      name: 'cloudflare-tunnel',
      // cloudflared is a native Windows binary, not a Node.js script
      script: 'cloudflared',
      args: ['tunnel', 'run'],
      exec_interpreter: 'none',
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      error_file: './logs/tunnel-error.log',
      out_file: './logs/tunnel-out.log',
      merge_logs: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      restart_delay: 5000,
      max_restarts: 10,
    },
  ],
};
