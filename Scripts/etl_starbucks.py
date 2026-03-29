import sys
import pandas as pd
from sqlalchemy import create_engine, text


DB_HOST     = "localhost"
DB_PORT     = 5432
DB_NAME     = "starbucks_dw_raw"
DB_USER     = "postgres"
DB_PASSWORD = "123456"

CONNECTION_STRING = (
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

def get_engine():
    engine = create_engine(CONNECTION_STRING, future=True)
    print(f"[ETL] Connected to {DB_NAME} @ {DB_HOST}:{DB_PORT}")
    return engine


def truncate_and_insert(engine, df: pd.DataFrame, schema: str, table: str) -> None:
    with engine.begin() as conn:
        conn.execute(text(f'TRUNCATE TABLE {schema}.{table} RESTART IDENTITY CASCADE'))
    df.to_sql(table, engine, schema=schema, if_exists="append", index=False, method="multi")
    print(f"[ETL]   → {schema}.{table}: {len(df):,} rows loaded.")


def extract(engine) -> pd.DataFrame:
    print("[ETL] Extracting from starbucks.raw_orders …")
    df = pd.read_sql("SELECT * FROM starbucks.raw_orders", engine)
    print(f"[ETL]   → {len(df):,} rows extracted.")
    return df



def build_dim_channel(df: pd.DataFrame) -> pd.DataFrame:
    channels = (
        df[["order_channel", "order_ahead"]]
        .drop_duplicates()
        .sort_values(["order_channel", "order_ahead"])
        .reset_index(drop=True)
    )
    channels.index += 1
    channels.insert(0, "channel_id", channels.index)
    channels = channels.rename(columns={"order_ahead": "is_order_ahead"})
    return channels


def build_dim_store(df: pd.DataFrame) -> pd.DataFrame:
    stores = (
        df[["store_id", "store_location_type", "region"]]
        .drop_duplicates(subset=["store_id"])
        .sort_values("store_id")
        .reset_index(drop=True)
    )
    stores.index += 1
    stores.insert(0, "store_id_pk", stores.index)
    return stores


def build_dim_customer(df: pd.DataFrame) -> pd.DataFrame:
    customers = (
        df[["customer_id", "customer_age_group", "customer_gender", "is_rewards_member"]]
        .drop_duplicates(subset=["customer_id"])
        .sort_values("customer_id")
        .reset_index(drop=True)
    )
    customers.index += 1
    customers.insert(0, "customer_id_pk", customers.index)
    return customers


def build_dim_date(df: pd.DataFrame) -> pd.DataFrame:
    dates = df[["order_date", "day_of_week"]].drop_duplicates(subset=["order_date"]).copy()
    dates["full_date"]    = pd.to_datetime(dates["order_date"])
    dates["date_id"]      = dates["full_date"].dt.strftime("%Y%m%d").astype(int)
    dates["day_of_month"] = dates["full_date"].dt.day
    dates["month_num"]    = dates["full_date"].dt.month
    dates["quarter_num"]  = dates["full_date"].dt.quarter
    dates["year_num"]     = dates["full_date"].dt.year
    return (
        dates[["date_id", "full_date", "day_of_week",
               "day_of_month", "month_num", "quarter_num", "year_num"]]
        .sort_values("date_id")
        .reset_index(drop=True)
    )


def build_dim_time(df: pd.DataFrame) -> pd.DataFrame:
    """Hour-of-day grain; one row per hour (0–23)."""
    def classify(hour: int) -> str:
        if   7  <= hour <=  9: return "Morning Rush"
        elif 10 <= hour <= 13: return "Mid-Day"
        elif 14 <= hour <= 17: return "Afternoon"
        elif 18 <= hour <= 21: return "Evening"
        else:                   return "Other"

    hours = sorted(df["order_time"].apply(
        lambda t: t.hour if hasattr(t, "hour") else pd.to_datetime(str(t)).hour
    ).unique())

    dim_time = pd.DataFrame({"time_id": hours})
    dim_time["hour_of_day"] = dim_time["time_id"]
    dim_time["order_time"]  = dim_time["hour_of_day"].apply(lambda h: f"{h:02d}:00:00")
    dim_time["time_period"] = dim_time["hour_of_day"].apply(classify)
    return dim_time.reset_index(drop=True)


def build_fact(df: pd.DataFrame,
               dim_channel: pd.DataFrame,
               dim_store: pd.DataFrame,
               dim_customer: pd.DataFrame,
               dim_date: pd.DataFrame,
               dim_time: pd.DataFrame) -> pd.DataFrame:
    """Merge dimensions back into raw rows, replace natural keys with surrogate keys."""
    fact = df.copy()

    # --- derive keys used for merges ---
    fact["full_date"] = pd.to_datetime(fact["order_date"])
    fact["date_id"]   = fact["full_date"].dt.strftime("%Y%m%d").astype(int)
    fact["time_id"]   = fact["order_time"].apply(
        lambda t: t.hour if hasattr(t, "hour") else pd.to_datetime(str(t)).hour
    )

    # --- merge channel (on channel name AND order ahead tag) ---
    fact = fact.merge(dim_channel[["channel_id", "order_channel", "is_order_ahead"]],
                      left_on=["order_channel", "order_ahead"],
                      right_on=["order_channel", "is_order_ahead"],
                      how="left")

    # --- merge store ---
    fact = fact.merge(dim_store[["store_id_pk", "store_id"]],
                      on="store_id", how="left")

    # --- merge customer ---
    fact = fact.merge(dim_customer[["customer_id_pk", "customer_id"]],
                      on="customer_id", how="left")

    # --- merge date ---
    fact = fact.merge(dim_date[["date_id"]],
                      on="date_id", how="left")

    # --- merge time (just validate time_id exists in dim) ---
    fact = fact.merge(dim_time[["time_id"]],
                      on="time_id", how="left")
    fact_out = fact[[
        "order_id",
        "channel_id", "store_id_pk", "customer_id_pk", "date_id", "time_id",
        "order_time", "drink_category", "has_food_item",
        "cart_size", "num_customizations", "total_spend",
        "fulfillment_time_min", "customer_satisfaction"
    ]].copy()
    fk_cols = ["channel_id", "store_id_pk", "customer_id_pk", "date_id", "time_id"]
    nulls = fact_out[fk_cols].isnull().sum()
    if nulls.any():
        print(f"[ETL] ⚠  NULL foreign keys detected:\n{nulls[nulls > 0]}")
    else:
        print("[ETL]   ✔  All foreign keys resolved — no NULLs.")

    return fact_out


def load(engine, dims: dict, fact: pd.DataFrame) -> None:
    print("[ETL] Loading dimensions …")
    for table_name, df in dims.items():
        truncate_and_insert(engine, df, "star", table_name)

    print("[ETL] Loading fact table …")
    truncate_and_insert(engine, fact, "star", "fact_orders")


def verify(engine, raw_count: int) -> None:
    print("\n[ETL] ── Verification ─────────────────────────────────────")
    with engine.connect() as conn:
        fact_count = conn.execute(text("SELECT COUNT(*) FROM star.fact_orders")).scalar()
    match = "✔ MATCH" if fact_count == raw_count else "✗ MISMATCH"
    print(f"[ETL]   raw_orders: {raw_count:,}  |  fact_orders: {fact_count:,}  →  {match}")
    null_query = """
    SELECT
        SUM(CASE WHEN channel_id  IS NULL THEN 1 ELSE 0 END) AS null_channel,
        SUM(CASE WHEN store_id_pk IS NULL THEN 1 ELSE 0 END) AS null_store,
        SUM(CASE WHEN customer_id_pk IS NULL THEN 1 ELSE 0 END) AS null_customer,
        SUM(CASE WHEN date_id     IS NULL THEN 1 ELSE 0 END) AS null_date,
        SUM(CASE WHEN time_id     IS NULL THEN 1 ELSE 0 END) AS null_time
    FROM star.fact_orders;
    """
    with engine.connect() as conn:
        row = conn.execute(text(null_query)).fetchone()
    print(f"[ETL]   NULL FKs → channel:{row[0]} store:{row[1]} customer:{row[2]} date:{row[3]} time:{row[4]}")
    old_q = """
    SELECT order_channel,
           ROUND(AVG(fulfillment_time_min)::numeric, 2) AS avg_time
    FROM starbucks.vw_orders_starbucks
    GROUP BY order_channel ORDER BY order_channel;
    """
    new_q = """
    SELECT dc.order_channel,
           ROUND(AVG(fo.fulfillment_time_min)::numeric, 2) AS avg_time
    FROM star.fact_orders fo
    JOIN star.dim_channel dc USING (channel_id)
    GROUP BY dc.order_channel ORDER BY dc.order_channel;
    """
    with engine.connect() as conn:
        old_df = pd.read_sql(old_q, conn)
        new_df = pd.read_sql(new_q, conn)

    comparison = old_df.merge(new_df, on="order_channel", suffixes=("_view", "_star"))
    comparison["delta"] = (comparison["avg_time_view"] - comparison["avg_time_star"]).abs()
    print(comparison.to_string(index=False))
    if (comparison["delta"] == 0).all():
        print("[ETL]   ✔  Results are identical — ETL is consistent.")
    else:
        print("[ETL]   ⚠  Discrepancies found — investigate transforms.")
    print("[ETL] ────────────────────────────────────────────────────────\n")

def main():
    print("=" * 60)
    print("  Starbucks ETL Pipeline — Star Schema Load")
    print("=" * 60)
    engine = get_engine()
    raw_df    = extract(engine)
    raw_count = len(raw_df)
    print("[ETL] Building dimensions …")
    dim_channel  = build_dim_channel(raw_df)
    dim_store    = build_dim_store(raw_df)
    dim_customer = build_dim_customer(raw_df)
    dim_date     = build_dim_date(raw_df)
    dim_time     = build_dim_time(raw_df)

    print("[ETL] Building fact table …")
    fact = build_fact(raw_df, dim_channel, dim_store, dim_customer, dim_date, dim_time)
    dims = {
        "dim_channel":  dim_channel,
        "dim_store":    dim_store,
        "dim_customer": dim_customer,
        "dim_date":     dim_date,
        "dim_time":     dim_time,
    }

    # 3. Load
    load(engine, dims, fact)

    # 4. Verify
    verify(engine, raw_count)

    print("[ETL] Pipeline completed successfully.")


if __name__ == "__main__":
    main()
