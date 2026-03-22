# 🛠️ Alternatives for Users Without 'make'

This document provides two ways to run the **Starbucks TP** project without the `make` utility:
1.  **🚀 Executive Option (One-Click)**: Run everything via a single script.
2.  **📋 Manual Step-by-Step**: Control every phase manually.

---

## 🚀 Option 1: Executive Option (Automated)

If you'd like to run the entire pipeline at once, we've provided automated scripts:

### A. For Windows (Double-Click)
Run `run_all.bat` from the root directory.

### B. For PowerShell users
```powershell
./run_all.ps1
```

---

## 📋 Option 2: Manual Step-by-Step Guide

If you prefer to run each step manually, follow the sequence below. All commands assume you are in the project root directory.

### 1. Initialize the Database
Drops and recreates the `starbucks_dw_raw` database, then loads the schema and data.
```powershell
# Create the DB
powershell -ExecutionPolicy Bypass -File Scripts/Run_SQL_Script.ps1 -SqlFile Database/01_SETUP_DATABASE.sql -Database postgres

# Load schema and 100k records
powershell -ExecutionPolicy Bypass -File Scripts/Run_SQL_Script.ps1 -SqlFile Database/setup_starbucks.sql -Database starbucks_dw_raw
```

### 2. Validate & Setup Database
Ensures the database is ready and runs validation queries for business problem resolution.
```powershell
# Check DB health
powershell -ExecutionPolicy Bypass -File Scripts/Ensure_DB_Ready.ps1

# Run business problem validation
powershell -ExecutionPolicy Bypass -File Scripts/Run_SQL_Script.ps1 -SqlFile Database/solve_business_problem.sql -Database starbucks_dw_raw
```

### 3. Generate Power BI Visuals
Uses the PBIR format to scaffold the visual reports programmatically.
```powershell
powershell -ExecutionPolicy Bypass -File Scripts/Create_Report_Visuals.ps1
```

### 4. Inject DAX Measures
Injects the advanced analytics measures directly into the Power BI Semantic Model.
```powershell
python inject_measures.py
```

---

## 🤖 Agent Execution Guide

If you are an AI assistant executing this project, follow this logic:

1.  **Check Prerequisites**: Ensure Postgres and Python are environment-ready.
2.  **Run Pipeline**: Execute `run_all.ps1`.
3.  **Confirm Results**: Verify the console output shows "✅ Measures injected successfully!".
4.  **Halt**: Do not attempt to open the `.pbip` file; instead, confirm to the user that the background work is done and they can now open Power BI.

---

## 💡 Pro Tip: How to get 'make' on Windows
If you'd like to use the `make` shortcuts in the future:
- **Chocolatey**: `choco install make`
- **Winget**: `winget install GnuWin32.Make`
- **Scoop**: `scoop install make`
