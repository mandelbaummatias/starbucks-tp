import pandas as pd
from sqlalchemy import create_engine

CONNECTION_STRING = "postgresql+psycopg2://postgres:123456@localhost:5432/starbucks_dw_raw"
engine = create_engine(CONNECTION_STRING)

df = pd.read_sql("SELECT customer_id_pk, store_id_pk FROM star.fact_orders LIMIT 5", engine)
print("FactOrders DB Types:")
print(df.dtypes)
print(df)

df_dim = pd.read_sql("SELECT * FROM star.dim_customer LIMIT 5", engine)
print("\nDimCustomer DB Types:")
print(df_dim.dtypes)
print(df_dim)
