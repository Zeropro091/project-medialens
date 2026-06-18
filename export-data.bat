@echo off
REM ============================================================
REM  LIN (Lensa Insignia) — Full Data Migration Script
REM  Exports ALL data from local Supabase for migration
REM ============================================================
REM  Usage: Run this on the SOURCE machine (your current PC)
REM         It creates a "migration-bundle" folder with everything
REM ============================================================

set BUNDLE=migration-bundle
set DB_CONTAINER=supabase_db_lin
set STORAGE_CONTAINER=supabase_storage_lin
set TIMESTAMP=%DATE:~-4%%DATE:~-7,2%%DATE:~-10,2%

echo.
echo  ====================================
echo   LIN Data Migration Export
echo  ====================================
echo.

REM --- Create bundle directory ---
if not exist %BUNDLE% mkdir %BUNDLE%
if not exist %BUNDLE%\storage mkdir %BUNDLE%\storage

REM ============================================================
REM  STEP 1: Export Database (schema + data)
REM ============================================================
echo [1/4] Exporting database...

REM Full schema + data dump (public schema)
docker exec %DB_CONTAINER% pg_dump -U postgres -d postgres ^
  --schema=public ^
  --data-only ^
  --column-inserts ^
  --on-conflict-do-nothing ^
  -f /tmp/public_data.sql

docker cp %DB_CONTAINER%:/tmp/public_data.sql %BUNDLE%\public_data.sql
echo       - public schema data: OK

REM Auth users (critical for FK relationships)
docker exec %DB_CONTAINER% pg_dump -U postgres -d postgres ^
  --schema=auth ^
  --table=auth.users ^
  --data-only ^
  --column-inserts ^
  --on-conflict-do-nothing ^
  -f /tmp/auth_users.sql

docker cp %DB_CONTAINER%:/tmp/auth_users.sql %BUNDLE%\auth_users.sql
echo       - auth users: OK

REM Storage metadata (bucket + object records)
docker exec %DB_CONTAINER% pg_dump -U postgres -d postgres ^
  --schema=storage ^
  --data-only ^
  --column-inserts ^
  --on-conflict-do-nothing ^
  -f /tmp/storage_meta.sql

docker cp %DB_CONTAINER%:/tmp/storage_meta.sql %BUNDLE%\storage_meta.sql
echo       - storage metadata: OK

REM Full schema dump (for reference/recreation)
docker exec %DB_CONTAINER% pg_dump -U postgres -d postgres ^
  --schema=public ^
  --schema-only ^
  -f /tmp/schema.sql

docker cp %DB_CONTAINER%:/tmp/schema.sql %BUNDLE%\schema.sql
echo       - schema definition: OK

REM ============================================================
REM  STEP 2: Export Storage Files
REM ============================================================
echo [2/4] Exporting storage files...

REM Copy the entire storage volume data
docker cp %STORAGE_CONTAINER%:/var/lib/storage %BUNDLE%\storage\files 2>nul
if errorlevel 1 (
    echo       - Storage container copy failed, trying alternative...
    REM Alternative: download via API
    echo       - Will use API download method in restore script
) else (
    echo       - storage files: OK
)

REM Also download each file via the Supabase Storage API as backup
echo       - Downloading files via API...
powershell -Command ^
  "$objects = Invoke-RestMethod -Uri 'http://127.0.0.1:54821/storage/v1/object/list/images' -Method POST -ContentType 'application/json' -Body '{\"prefix\":\"\",\"limit\":1000}' -Headers @{Authorization='Bearer sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH'; apikey='sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH'}; ^
  if (-not (Test-Path '%BUNDLE%\storage\api-files')) { New-Item -ItemType Directory -Path '%BUNDLE%\storage\api-files' | Out-Null }; ^
  foreach ($obj in $objects) { ^
    if ($obj.name) { ^
      $url = 'http://127.0.0.1:54821/storage/v1/object/public/images/' + $obj.name; ^
      Invoke-WebRequest -Uri $url -OutFile ('%BUNDLE%\storage\api-files\' + $obj.name) -UseBasicParsing; ^
      Write-Host ('         Downloaded: ' + $obj.name) ^
    } ^
  }"

REM ============================================================
REM  STEP 3: Export environment config
REM ============================================================
echo [3/4] Exporting config...

copy .env %BUNDLE%\.env.source 2>nul
copy supabase\config.toml %BUNDLE%\config.toml.source 2>nul
echo       - env + config: OK

REM ============================================================
REM  STEP 4: Create restore script
REM ============================================================
echo [4/4] Creating restore script...

(
echo @echo off
echo REM ============================================================
echo REM  LIN — Data Restore Script
echo REM  Run this on the NEW server after:
echo REM    1. git clone the repo
echo REM    2. npm install
echo REM    3. supabase start
echo REM    4. Copy this migration-bundle folder to the new server
echo REM ============================================================
echo.
echo set DB_CONTAINER=supabase_db_lin
echo.
echo echo [1/5] Applying schema migrations...
echo REM Schema is applied automatically by supabase start from supabase/migrations/
echo echo       - migrations applied via supabase start
echo.
echo echo [2/5] Restoring auth users...
echo docker cp auth_users.sql %%DB_CONTAINER%%:/tmp/auth_users.sql
echo docker exec %%DB_CONTAINER%% psql -U postgres -d postgres -f /tmp/auth_users.sql
echo echo       - auth users: OK
echo.
echo echo [3/5] Restoring public data...
echo docker cp public_data.sql %%DB_CONTAINER%%:/tmp/public_data.sql
echo docker exec %%DB_CONTAINER%% psql -U postgres -d postgres -f /tmp/public_data.sql
echo echo       - public data: OK
echo.
echo echo [4/5] Restoring storage metadata...
echo docker cp storage_meta.sql %%DB_CONTAINER%%:/tmp/storage_meta.sql
echo docker exec %%DB_CONTAINER%% psql -U postgres -d postgres -f /tmp/storage_meta.sql
echo echo       - storage metadata: OK
echo.
echo echo [5/5] Restoring storage files...
echo REM Upload each file from api-files back to Supabase Storage
echo echo       - NOTE: Update the ANON_KEY below to match your NEW Supabase instance
echo set ANON_KEY=YOUR_NEW_ANON_KEY_HERE
echo set SUPABASE_URL=http://127.0.0.1:54821
echo powershell -Command "Get-ChildItem 'storage\api-files' | ForEach-Object { $uri = '%%SUPABASE_URL%%/storage/v1/object/images/' + $_.Name; Invoke-RestMethod -Uri $uri -Method POST -InFile $_.FullName -ContentType 'application/octet-stream' -Headers @{Authorization='Bearer %%ANON_KEY%%'; apikey='%%ANON_KEY%%'} }"
echo echo       - storage files: OK
echo.
echo echo.
echo echo  ========================================
echo echo   Restore complete!
echo echo   Update .env with new Supabase keys
echo echo  ========================================
) > %BUNDLE%\restore.bat

echo       - restore.bat: OK

echo.
echo  ====================================
echo   Export Complete!
echo  ====================================
echo.
echo   Bundle location: %BUNDLE%\
echo.
echo   Contents:
echo     public_data.sql    - All article, category, profile data
echo     auth_users.sql     - User accounts + passwords
echo     storage_meta.sql   - Storage bucket metadata
echo     schema.sql         - Schema reference (for debugging)
echo     storage\api-files\ - Uploaded images
echo     .env.source        - Environment variables
echo     restore.bat        - Run this on the new server
echo.
echo   To migrate:
echo     1. Copy the entire "%BUNDLE%" folder to new server
echo     2. On new server: git clone, npm install, supabase start
echo     3. Run restore.bat inside the bundle folder
echo     4. Update .env with new Supabase credentials
echo     5. npm run dev:ssr
echo.
pause
