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
    Write-Host "🔐 Database Credentials Required" -ForegroundColor Yellow
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
    Write-Host "`n🚀 STEP: $msg" -ForegroundColor Cyan -BackgroundColor DarkBlue
}

function Write-Success ([string]$msg) {
    Write-Host "✅ $msg" -ForegroundColor Green
}

function Write-Failure ([string]$msg) {
    Write-Host "❌ $msg" -ForegroundColor Red
    exit 1
}

# --- 1. Database Setup (Smart Check & Populate) ---
Write-Step "Ensuring database 'starbucks_dw_raw' is ready..."
try {
    # This script handles password prompt, existence check, and data population automatically
    powershell -ExecutionPolicy Bypass -File "Scripts/Ensure_DB_Ready.ps1"
    Write-Success "Database setup complete."
} catch {
    Write-Failure "Failed to ensure database readiness: $_"
}

# --- 2. Database Validation & Business Queries ---
Write-Step "Running business problem validation queries..."
try {
    # Re-runs solve_business_problem.sql to ensure logic is correct
    powershell -ExecutionPolicy Bypass -File "Scripts/Run_SQL_Script.ps1" -SqlFile "Database/solve_business_problem.sql" -Database starbucks_dw_raw
    Write-Success "Validation queries executed."
} catch {
    Write-Failure "Failed to run validation queries: $_"
}

# --- 3. Power BI Visuals Generation ---
Write-Step "Scaffolding Power BI Visuals programmatically..."
try {
    powershell -ExecutionPolicy Bypass -File "Scripts/Create_Report_Visuals.ps1"
    Write-Success "Power BI visuals generated."
} catch {
    Write-Failure "Failed to generate visuals: $_"
}

# --- 4. DAX Measures Injection ---
Write-Step "Injecting DAX measures via Python..."
try {
    python inject_measures.py
    Write-Success "Measures injected successfully."
} catch {
    Write-Failure "Failed to inject measures. Ensure Python is installed and 'inject_measures.py' is in the root."
}

Write-Host "`n✨ Pipeline execution complete! ✨" -ForegroundColor Yellow
Write-Host "Action items for you:" -ForegroundColor White
Write-Host "1. Open 'Starbucks_PowerBI.pbip' in Power BI Desktop." -ForegroundColor White
Write-Host "2. Click 'Refresh' to sync your local Postgres data." -ForegroundColor White
