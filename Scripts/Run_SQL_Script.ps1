param(
    [string]$SqlFile = "Database/solve_business_problem.sql",
    [string]$Database = "starbucks_dw_raw"
)
if (-not $env:PGPASSWORD) {
    $password = Read-Host -Prompt "Enter PostgreSQL password for user 'postgres'"
    if (-not $password) {
        Write-Error "Password is required to connect to the database."
        exit 1
    }
    $env:PGPASSWORD = $password
}

Write-Host "Executing SQL script: $SqlFile..." -ForegroundColor Cyan
psql -U postgres -d $Database -f $SqlFile -P pager=off
