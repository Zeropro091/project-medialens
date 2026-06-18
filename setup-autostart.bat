@echo off
title Lensa Insignia - Auto-Start Setup
cd /d "%~dp0"

echo ============================================
echo   Lensa Insignia - Auto-Start Configuration
echo ============================================
echo.
echo This script configures everything to start automatically
echo when your PC boots up.
echo.
echo Services managed by PM2:
echo   [1] SSR Server (lin-app)  - Express server on port 3000
echo   [2] Cloudflare Tunnel     - Exposes lensainsignia.com
echo.
echo Docker Desktop handles Supabase database automatically.
echo.
echo NOTE: Run this script AS ADMINISTRATOR (right-click ^> Run as admin)
echo       for the PM2 startup configuration to work.
echo.

:: -------------------------------------------------
:: Step 1: Create log directory
:: -------------------------------------------------
echo [Step 1] Creating log directory...
if not exist "logs" mkdir logs
echo   Log directory ready.
echo.

:: -------------------------------------------------
:: Step 2: Configure PM2 startup daemon
:: -------------------------------------------------
echo [Step 2] Configuring PM2 auto-start daemon...
pm2 startup
if errorlevel 1 (
    echo   WARNING: PM2 startup configuration had issues.
    echo   Try running this script as Administrator.
) else (
    echo   PM2 daemon configured to start on boot.
)
echo.

:: -------------------------------------------------
:: Step 3: Create startup shortcut for PM2 process restoration
:: -------------------------------------------------
echo [Step 3] Creating startup shortcut (restores PM2 processes on login)...
powershell -Command ^
    $WshShell = New-Object -ComObject WScript.Shell; ^
    $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\LensaInsignia-SSR.lnk'); ^
    $Shortcut.TargetPath = 'cmd.exe'; ^
    $Shortcut.Arguments = '/c cd /d "%~dp0" && pm2 resurrect'; ^
    $Shortcut.WorkingDirectory = '%~dp0'; ^
    $Shortcut.WindowStyle = 7; ^
    $Shortcut.Description = 'Lensa Insignia SSR Server + Cloudflare Tunnel (PM2)'; ^
    $Shortcut.Save()
if errorlevel 1 (
    echo   WARNING: Could not create startup shortcut.
    echo   You can manually add 'pm2 resurrect' to your Startup folder.
) else (
    echo   Startup shortcut created successfully.
)
echo.

:: -------------------------------------------------
:: Step 4: Verify the tunnel configuration
:: -------------------------------------------------
echo [Step 4] Verifying Cloudflare Tunnel configuration...
cloudflared tunnel info dc6820e6-043b-4fa4-ac16-9960157efd89 >nul 2>&1
if errorlevel 1 (
    echo   WARNING: Could not verify tunnel. Check .cloudflared\config.yml
) else (
    echo   Tunnel configuration verified.
)
echo.

:: -------------------------------------------------
:: Step 5: Build SSR for production (if not already built)
:: -------------------------------------------------
echo [Step 5] Checking SSR production build...
if not exist "dist\server\entry-server.js" (
    echo   Building SSR production bundle...
    call npm run build:ssr
    if errorlevel 1 (
        echo   WARNING: SSR build failed. Run 'npm run build:ssr' manually.
    ) else (
        echo   SSR production build complete.
    )
) else (
    echo   SSR production build exists (run 'npm run build:ssr' to rebuild if needed).
)
echo.

:: -------------------------------------------------
:: Verify Cloudflare tunnel is NOT installed as Windows service
:: (to avoid conflict with PM2-managed tunnel)
:: -------------------------------------------------
sc query CloudflareTunnel >nul 2>&1
if not errorlevel 1 (
    echo NOTE: Cloudflare Tunnel Windows service exists.
    echo   To avoid conflict with PM2, you can remove it:
    echo     cloudflared service uninstall
    echo   (Requires Administrator - only do this if the PM2 tunnel works)
)
echo.

:: -------------------------------------------------
:: Summary
:: -------------------------------------------------
echo ============================================
echo   Auto-Start Configuration Complete!
echo.
echo   What will start automatically:
echo.
echo   [1] Docker Desktop (via Windows Startup settings)
echo   [2] PM2 daemon (via pm2 startup)
echo   [3] SSR Server + Tunnel (via Startup folder ^> pm2 resurrect)
echo.
echo   ~ How to use ~
echo.
echo   FIRST TIME SETUP:
echo     1. Run: start-production.bat
echo        (This builds + starts everything. Run ONCE only.)
echo.
echo   AFTER REBOOT:
echo     - Everything should start automatically within ~30 seconds
echo     - Verify: Visit https://lensainsignia.com
echo     - Check:   pm2 status
echo.
echo   MANUAL COMMANDS:
echo     pm2 status                    — Check all processes
echo     pm2 logs                      — View live logs
echo     pm2 restart lin-app            — Restart just the server
echo     start-production.bat          — Full manual startup
echo ============================================
echo.
pause
