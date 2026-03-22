# Script: Ensure_DB_Ready.ps1
# Purpose: Check if the database and required tables exist. If not, perform initialization.
# Requires PGPASSWORD to be set or will prompt via Run_SQL_Script.ps1.

# 1. Ask for password if not set (reusing our existing helper)
if (-not $env:PGPASSWORD) {
    $password = Read-Host -Prompt "Enter PostgreSQL password for user 'postgres'"
    if (-not $password) {
        Write-Error "Password is required to proceed."
        exit 1
    }
    $env:PGPASSWORD = $password
}

# 2. Check if the database 'starbucks_dw_raw' exists
Write-Host "Checking for database 'starbucks_dw_raw'..." -ForegroundColor Cyan
$dbExists = psql -U postgres -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='starbucks_dw_raw'"

if ($dbExists -ne "1") {
    Write-Host "⚠️ Database 'starbucks_dw_raw' not found. Re-initializing..." -ForegroundColor Yellow
    powershell -ExecutionPolicy Bypass -File Scripts/Run_SQL_Script.ps1 -SqlFile Database/01_SETUP_DATABASE.sql -Database postgres
    
    # After creation, we MUST load the schema
    Write-Host "Loading schema and data into 'starbucks_dw_raw'..." -ForegroundColor Cyan
    powershell -ExecutionPolicy Bypass -File Scripts/Run_SQL_Script.ps1 -SqlFile Database/setup_starbucks.sql -Database starbucks_dw_raw
} else {
    Write-Host "✅ Database exists." -ForegroundColor Green
    
    # 3. Check if 'starbucks.raw_orders' table exists in the existing database
    Write-Host "Checking for table 'starbucks.raw_orders'..." -ForegroundColor Cyan
    $tableExists = psql -U postgres -d starbucks_dw_raw -tAc "SELECT 1 FROM information_schema.tables WHERE table_schema='starbucks' AND table_name='raw_orders'"
    
    if ($tableExists -ne "1") {
        Write-Host "⚠️ Table 'starbucks.raw_orders' missing. Running setup..." -ForegroundColor Yellow
        powershell -ExecutionPolicy Bypass -File Scripts/Run_SQL_Script.ps1 -SqlFile Database/setup_starbucks.sql -Database starbucks_dw_raw
    } else {
        Write-Host "✅ Database and tables are already populated." -ForegroundColor Green
    }
}
