import os
current_dir = os.path.dirname(os.path.abspath(__file__))
tmdl_path = os.path.join(current_dir, "Starbucks_PowerBI.SemanticModel", "definition", "tables", "FactOrders.tmdl")

measures_to_add = """
	measure 'Avg Fulfillment Time' = AVERAGE(FactOrders[fulfillment_time_min])
		formatString: 0.00
		lineageTag: a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d

	measure 'Morning Rush Avg' = CALCULATE([Avg Fulfillment Time], DimTime[time_period] = "Morning Rush")
		formatString: 0.00

	measure 'Complexity vs Delay Correlation' = VAR Correlation = COALESCE(CORRELATE(FactOrders, FactOrders[num_customizations], FactOrders[fulfillment_time_min]), 0) RETURN Correlation
"""

def inject_measures():
    if not os.path.exists(tmdl_path):
        print(f"Error: {tmdl_path} not found.")
        return
    with open(tmdl_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    if "measure 'Avg Fulfillment Time'" in "".join(lines):
        print("Measures already injected.")
        return
    insert_pos = 0
    for i, line in enumerate(lines):
        if 'column' in line:
            insert_pos = i
        if 'partition' in line:
            insert_pos = i - 1
            break
    lines.insert(insert_pos + 1, measures_to_add)
    
    with open(tmdl_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print("Medidas inyectadas exitosamente en el modelo .pbip")

if __name__ == "__main__":
    inject_measures()
