import os
import re

sql_file = r"c:\Users\Pc\Downloads\prueba audio\starbucks-tp\Database\02_CREATE_STAR_SCHEMA.sql"
tmdl_dir = r"c:\Users\Pc\Downloads\prueba audio\starbucks-tp\Starbucks_PowerBI.SemanticModel\definition\tables"

with open(sql_file, "r") as f:
    sql_text = f.read()

# Extract tables and their columns using basic regex
sql_tables = {}
for match in re.finditer(r"CREATE TABLE star\.(\w+)\s*\((.*?)\);", sql_text, re.DOTALL):
    table_name = match.group(1)
    columns_text = match.group(2)
    columns = {}
    for line in columns_text.split("\n"):
        line = line.strip()
        if not line or line.startswith("UNIQUE"): continue
        parts = line.split()
        if len(parts) >= 2:
            col_name = parts[0]
            col_type = parts[1]
            columns[col_name.lower()] = col_type.lower()
    sql_tables[table_name.lower()] = columns

# Extract TMDL tables and columns
tmdl_tables = {}
for tmdl_file in os.listdir(tmdl_dir):
    if not tmdl_file.endswith(".tmdl"): continue
    if tmdl_file.startswith("LocalDate") or tmdl_file.startswith("DateTable"): continue
    
    table_name = tmdl_file.replace(".tmdl", "").lower()
    with open(os.path.join(tmdl_dir, tmdl_file), "r", encoding="utf-8") as f:
        tmdl_text = f.read()
    
    columns = {}
    current_col = None
    for line in tmdl_text.split("\n"):
        line = line.strip()
        if line.startswith("column "):
            current_col = line[7:]
        elif line.startswith("dataType: ") and current_col:
            columns[current_col.lower()] = line[10:]
            current_col = None
            
    tmdl_tables[table_name] = columns

print("=== Comparing SQL to TMDL ===")
for table, sql_cols in sql_tables.items():
    tmdl_table = table.replace("_", "")
    print(f"\nTable: {table} (TMDL: {tmdl_table})")
    if tmdl_table not in tmdl_tables:
        print(f"  Missing in TMDL: {tmdl_table}")
        continue
    
    tmdl_cols = tmdl_tables[tmdl_table]
    for col, sql_type in sql_cols.items():
        if col not in tmdl_cols:
            print(f"  MISSING IN TMDL: {col} ({sql_type})")
        else:
            tmdl_type = tmdl_cols[col]
            print(f"  Both have {col}: SQL={sql_type}, TMDL={tmdl_type}")
            
    for col in tmdl_cols:
        if col not in sql_cols:
            print(f"  ONLY IN TMDL: {col} ({tmdl_cols[col]})")

print("\ntmdl tables source analysis:")
for tmdl_file in os.listdir(tmdl_dir):
    if not tmdl_file.endswith(".tmdl"): continue
    if tmdl_file.startswith("LocalDate") or tmdl_file.startswith("DateTable"): continue
    with open(os.path.join(tmdl_dir, tmdl_file), "r", encoding="utf-8") as f:
        if "vw_orders_starbucks" in f.read():
            print(f"  WARNING: {tmdl_file} sources from vw_orders_starbucks instead of star schema!")
