import re

file_path = r"c:\Users\Pc\Downloads\prueba audio\starbucks-tp\proyecto.md"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Fix Dimension entity structures
content = content.replace("string customer_id PK", "int customer_id_pk PK\n\nstring customer_id")
content = content.replace("string store_id PK", "int store_id_pk PK\n\nstring store_id")

content = content.replace(
"""DIM_DATE {

int date_id PK

date order_date""",
"""DIM_DATE {

int date_id PK

date full_date"""
)

# Fix Markdown Table keys
content = content.replace(
"""| **customer_id (PK)** | VARCHAR  | customer_id        |
| ---                  | ---      | ---                |""",
"""| **customer_id_pk (PK)** | INT      | Surrogate key       |
| ---                     | ---      | ---                 |
| customer_id             | VARCHAR  | customer_id         |
| ---                     | ---      | ---                 |"""
)

content = content.replace(
"""| **store_id (PK)**   | VARCHAR  | store_id            |
| ---                 | ---      | ---                 |""",
"""| **store_id_pk (PK)**    | INT      | Surrogate key       |
| ---                     | ---      | ---                 |
| store_id                | VARCHAR  | store_id            |
| ---                     | ---      | ---                 |"""
)

content = content.replace(
"""| **date_id (PK)** | INT      | Surrogate key                 |
| ---              | ---      | ---                           |
| order_date       | DATE     | order_date                    |""",
"""| **date_id (PK)** | INT      | Surrogate key                 |
| ---              | ---      | ---                           |
| full_date        | DATE     | order_date                    |"""
)

# Fix HTML tables and text regarding _sk to _id and _id_pk nomenclature
content = content.replace("channel_sk", "channel_id")
content = content.replace("store_sk", "store_id_pk")
content = content.replace("customer_sk", "customer_id_pk")
content = content.replace("date_sk", "date_id")
content = content.replace("time_sk", "time_id")

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Successfully patched proyecto.md")
