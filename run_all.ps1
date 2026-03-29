$ErrorActionPreference = "Stop"
if (-not $env:PGPASSWORD) {
    Write-Host "[PASSWORD] Database Credentials Required" -ForegroundColor Yellow
    $password = Read-Host -AsSecureString -Prompt "Enter PostgreSQL password for user 'postgres'"
    if (-not $password) {
        Write-Error "Password is required to proceed."
        exit 1
    }
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    $env:PGPASSWORD = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
}

function Write-Step ([string]$msg) {
    Write-Host "`n[STEP] $msg" -ForegroundColor Cyan -BackgroundColor DarkBlue
}

function Write-Success ([string]$msg) {
    Write-Host "[SUCCESS] $msg" -ForegroundColor Green
}

function Write-Failure ([string]$msg) {
    Write-Host "[FAILURE] $msg" -ForegroundColor Red
    exit 1
}

Write-Step "Ensuring database 'starbucks_dw_raw' is ready..."
try {
    powershell -ExecutionPolicy Bypass -File "Scripts/Ensure_DB_Ready.ps1"
    Write-Success "Raw database setup complete."
} catch {
    Write-Failure "Failed to ensure database readiness: $_"
}

Write-Step "Creating physical analytical schema 'star'..."
try {
    powershell -ExecutionPolicy Bypass -File "Scripts/Run_SQL_Script.ps1" -SqlFile "Database/02_CREATE_STAR_SCHEMA.sql" -Database starbucks_dw_raw
    Write-Success "Star schema structure created."
} catch {
    Write-Failure "Failed to create star schema DDL."
}

Write-Step "Running ETL Pipeline (Raw -> Star Schema)..."
try {
    python Scripts/etl_starbucks.py
    Write-Success "ETL process populated all dimension and fact tables."
} catch {
    Write-Failure "ETL pipeline failed. Check if Python dependencies (pandas, sqlalchemy, psycopg2) are installed."
}

Write-Step "Running analytical queries against the Star Schema..."
try {
    powershell -ExecutionPolicy Bypass -File "Scripts/Run_SQL_Script.ps1" -SqlFile "Database/04_BUSINESS_QUERIES_STAR.sql" -Database starbucks_dw_raw
    Write-Success "Star schema results validated correctly."
} catch {
    Write-Failure "Analytical queries failed."
}

Write-Step "Scaffolding Power BI Visuals programmatically..."
try {
    powershell -ExecutionPolicy Bypass -File "Scripts/Create_Report_Visuals.ps1"
    Write-Success "Power BI visuals generated."
} catch {
    Write-Failure "Failed to generate visuals: $_"
}

Write-Step "Injecting DAX measures into the Semantic Model..."
try {
    python inject_measures.py
    Write-Success "DAX measures injected successfully."
} catch {
    Write-Failure "Failed to inject measures. Ensure 'FactOrders.tmdl' is accessible."
}

Write-Host "`n[COMPLETED] Physical Star Schema & BI Pipeline fully ready!" -ForegroundColor Yellow
Write-Host "Action items for you:" -ForegroundColor White
Write-Host "1. Open 'Starbucks_PowerBI.pbip' in Power BI Desktop." -ForegroundColor White
Write-Host "2. Click 'Refresh' to sync your local Postgres 'star' schema data." -ForegroundColor White
Write-Host "3. Verify the 'Mapeo_de_datos.md' for table relationships." -ForegroundColor White
