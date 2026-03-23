import psycopg2
conn = psycopg2.connect("host=localhost dbname=starbucks_dw_raw user=postgres password=123456")
cur = conn.cursor()
cur.execute("SELECT column_name, data_type FROM information_schema.columns WHERE table_schema='star' AND table_name='fact_orders' ORDER BY ordinal_position;")
cols = cur.fetchall()
print("Table Structure:")
for c in cols:
    print(f" - {c[0]} ({c[1]})")

cur.execute("SELECT * FROM star.fact_orders LIMIT 1;")
row = cur.fetchone()
print("\nFirst row values:")
for i, val in enumerate(row):
    print(f" - {cols[i][0]}: {val} (Type: {type(val)})")
conn.close()
