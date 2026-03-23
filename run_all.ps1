<#
.SYNOPSIS
    Automates the Starbucks TP setup pipeline without the need for 'make'.
    
.DESCRIPTION
    This script performs:
    1. Database Setup (Ensure DB exists and contains tables)
    2. Power BI Visuals Generation
    3. DAX Measures Injection (via Python)
    4. Business problem validation queries
#>

$ErrorActionPreference = "Stop"

# --- 0. Password Prompt (Shared across all steps) ---
if (-not $env:PGPASSWORD) {
    Write-Host "[PASSWORD] Database Credentials Required" -ForegroundColor Yellow
    $password = Read-Host -AsSecureString -Prompt "Enter PostgreSQL password for user 'postgres'"
    if (-not $password) {
        Write-Error "Password is required to proceed."
        exit 1
    }
    # Convert SecureString to plain text for the environment variable
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

# --- 1. Database Setup (Smart Check & Populate) ---
Write-Step "Ensuring database 'starbucks_dw_raw' is ready..."
try {
    # This script handles password prompt, existence check, and data population automatically
    powershell -ExecutionPolicy Bypass -File "Scripts/Ensure_DB_Ready.ps1"
    Write-Success "Raw database setup complete."
} catch {
    Write-Failure "Failed to ensure database readiness: $_"
}

# --- 2. [NEW] Physical Star Schema DDL ---
Write-Step "Creating physical analytical schema 'star'..."
try {
    powershell -ExecutionPolicy Bypass -File "Scripts/Run_SQL_Script.ps1" -SqlFile "Database/02_CREATE_STAR_SCHEMA.sql" -Database starbucks_dw_raw
    Write-Success "Star schema structure created."
} catch {
    Write-Failure "Failed to create star schema DDL."
}

# --- 3. [NEW] ETL Pipeline (Python) ---
Write-Step "Running ETL Pipeline (Raw -> Star Schema)..."
try {
    # Ensure dependencies are installed just in case
    # pip install sqlalchemy psycopg2-binary pandas -q
    python Scripts/etl_starbucks.py
    Write-Success "ETL process populated all dimension and fact tables."
} catch {
    Write-Failure "ETL pipeline failed. Check if Python dependencies (pandas, sqlalchemy, psycopg2) are installed."
}

# --- 4. Analytical Validation (Star Schema) ---
Write-Step "Running analytical queries against the Star Schema..."
try {
    # Use the new star-schema based queries
    powershell -ExecutionPolicy Bypass -File "Scripts/Run_SQL_Script.ps1" -SqlFile "Database/04_BUSINESS_QUERIES_STAR.sql" -Database starbucks_dw_raw
    Write-Success "Star schema results validated correctly."
} catch {
    Write-Failure "Analytical queries failed."
}

# --- 5. Power BI Visuals Generation (Scaffolding) ---
Write-Step "Scaffolding Power BI Visuals programmatically..."
try {
    powershell -ExecutionPolicy Bypass -File "Scripts/Create_Report_Visuals.ps1"
    Write-Success "Power BI visuals generated."
} catch {
    Write-Failure "Failed to generate visuals: $_"
}

# --- 6. DAX Measures Injection ---
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
