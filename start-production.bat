@echo off
title Lensa Insignia - Production Server
cd /d "%~dp0"

echo ============================================
echo   Lensa Insignia - Production Startup
echo ============================================
echo.

:: -------------------------------------------------
:: 1. Check Docker is running (needed for Supabase)
:: -------------------------------------------------
echo [1/4] Checking Docker status...
docker info >nul 2>&1
if errorlevel 1 (
    echo   WARNING: Docker is not running.
    echo   Starting Docker Desktop...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    echo   Waiting for Docker to start (30 seconds)...
    timeout /t 30 /nobreak >nul
    docker info >nul 2>&1
    if errorlevel 1 (
        echo   ERROR: Docker failed to start. Start Docker Desktop manually.
        pause
        exit /b 1
    )
)
echo   Docker is running.
echo.

:: -------------------------------------------------
:: 2. Start Supabase (Docker containers)
:: -------------------------------------------------
echo [2/4] Starting Supabase containers...
supabase start >nul 2>&1
if errorlevel 1 (
    echo   WARNING: Supabase may already be running or failed to start.
    echo   Attempting to continue...
) else (
    echo   Supabase started successfully.
)
echo.

:: -------------------------------------------------
:: 3. Build SSR production bundle (if needed)
:: -------------------------------------------------
echo [3/4] Checking SSR build...
if not exist "dist\server\entry-server.js" (
    echo   SSR build not found. Building now...
    call npm run build:ssr
    if errorlevel 1 (
        echo   ERROR: SSR build failed. Run 'npm run build:ssr' manually.
        pause
        exit /b 1
    )
    echo   SSR build complete.
) else (
    echo   SSR build exists.
)
echo.

:: -------------------------------------------------
:: 4. Start PM2 processes (SSR server + Cloudflare tunnel)
:: -------------------------------------------------
echo [4/4] Starting PM2 processes...
pm2 start ecosystem.config.cjs
if errorlevel 1 (
    echo   ERROR: PM2 failed to start processes.
    pause
    exit /b 1
)
echo.

:: -------------------------------------------------
:: Save PM2 process list (for auto-recovery)
:: -------------------------------------------------
pm2 save

echo ============================================
echo   All services are running!
echo.
echo   Local:      http://localhost:3000
echo   Live:       https://lensainsignia.com
echo.
echo   PM2 Status: pm2 status
echo   PM2 Logs:   pm2 logs
echo ============================================
echo.
pause
