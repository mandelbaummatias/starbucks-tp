.PHONY: all db_setup run_generator db_ensure db_init

# Default target runs the entire pipeline
all: run_generator db_setup
	@echo "Pipeline execution complete! You can now open Starbucks_PowerBI.pbip in Power BI Desktop."

# Target to check if DB is ready, otherwise initialize it (Smart)
db_ensure:
	@echo "Checking if database is ready..."
	@powershell -ExecutionPolicy Bypass -File Scripts/Ensure_DB_Ready.ps1

# Target to run the SQL validation tests
db_setup: db_ensure
	@echo "Running business problem validation queries..."
	@powershell -ExecutionPolicy Bypass -File Scripts/Run_SQL_Script.ps1 -SqlFile Database/solve_business_problem.sql -Database starbucks_dw_raw

# Target to recreate the database and schema
db_init:
	@echo "Initializing database (dropping and creating starbucks_dw_raw)..."
	@powershell -ExecutionPolicy Bypass -File Scripts/Run_SQL_Script.ps1 -SqlFile Database/01_SETUP_DATABASE.sql -Database postgres
	@echo "Loading schema and data..."
	@powershell -ExecutionPolicy Bypass -File Scripts/Run_SQL_Script.ps1 -SqlFile Database/setup_starbucks.sql -Database starbucks_dw_raw



# Target to dynamically scaffold visual matrices into PBIR JSON
run_generator:
	@echo "Scaffolding Power BI Visuals programmatically..."
	powershell -ExecutionPolicy Bypass -File Scripts/Create_Report_Visuals.ps1
