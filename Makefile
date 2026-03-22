.PHONY: all db_setup run_generator

# Default target runs the entire pipeline
all: run_generator
	@echo "Pipeline execution complete! You can now open Starbucks_PowerBI.pbip in Power BI Desktop."

# Target to run the SQL validation tests
db_setup:
	@echo "Connecting to PostgreSQL and running the business problem solutions..."
	@echo "Requires psql to be installed and in your system PATH."
	psql -U postgres -d starbucks_dw_raw -f Database/solve_business_problem.sql

# Target to dynamically scaffold visual matrices into PBIR JSON
run_generator:
	@echo "Scaffolding Power BI Visuals programmatically..."
	powershell -ExecutionPolicy Bypass -File Scripts/Create_Report_Visuals.ps1
