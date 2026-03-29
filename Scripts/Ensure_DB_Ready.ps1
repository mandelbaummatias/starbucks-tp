if (-not $env:PGPASSWORD) {
    $password = Read-Host -Prompt "Enter PostgreSQL password for user 'postgres'"
    if (-not $password) {
        Write-Error "Password is required to proceed."
        exit 1
    }
    $env:PGPASSWORD = $password
}
Write-Host "Checking for database 'starbucks_dw_raw'..." -ForegroundColor Cyan
$dbExists = psql -U postgres -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='starbucks_dw_raw'"
if ($dbExists -ne "1") {
    Write-Host "⚠️ Database 'starbucks_dw_raw' not found. Re-initializing..." -ForegroundColor Yellow
    powershell -ExecutionPolicy Bypass -File Scripts/Run_SQL_Script.ps1 -SqlFile Database/01_SETUP_DATABASE.sql -Database postgres
    Write-Host "Loading schema and data into 'starbucks_dw_raw'..." -ForegroundColor Cyan
    powershell -ExecutionPolicy Bypass -File Scripts/Run_SQL_Script.ps1 -SqlFile Database/setup_starbucks.sql -Database starbucks_dw_raw
} else {
    Write-Host "✅ Database exists." -ForegroundColor Green
    Write-Host "Checking for table 'starbucks.raw_orders'..." -ForegroundColor Cyan
    $tableExists = psql -U postgres -d starbucks_dw_raw -tAc "SELECT 1 FROM information_schema.tables WHERE table_schema='starbucks' AND table_name='raw_orders'"
    if ($tableExists -ne "1") {
        Write-Host "⚠️ Table 'starbucks.raw_orders' missing. Running setup..." -ForegroundColor Yellow
        powershell -ExecutionPolicy Bypass -File Scripts/Run_SQL_Script.ps1 -SqlFile Database/setup_starbucks.sql -Database starbucks_dw_raw
    } else {
        Write-Host "✅ Database and tables are already populated." -ForegroundColor Green
    }
}
