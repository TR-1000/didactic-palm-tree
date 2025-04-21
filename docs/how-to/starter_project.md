# 🚀 BW/4HANA Open Source Lab – Project Overview

Here's a complete sample project that simulates a mini **BW/4HANA-style pipeline** using:

| Tool        | Purpose                                      |
|-------------|----------------------------------------------|
| **PostgreSQL** | Stores master & transaction data            |
| **DBT**        | Models InfoObjects (master), ADSOs (facts), and reporting layers |
| **Airflow**    | Runs a DAG to trigger DBT transformations   |
| **Metabase**   | Visualizes final outputs                    |

---

## 📊 Scenario: Sales Analytics

We simulate the following:

- Customer Master  
- Product Master  
- Sales Transactions  
- Reporting model joining all the above  

---

## ✅ Project Structure

```
bw4hana-openlab/
├── docker-compose.yml
├── postgres/
│   └── init.sql
├── dbt/
│   ├── bw_project/
│   │   ├── models/
│   │   │   ├── stg_customers.sql
│   │   │   ├── stg_products.sql
│   │   │   ├── stg_sales.sql
│   │   │   └── rpt_sales_summary.sql
│   │   └── dbt_project.yml
│   └── profiles.yml
├── airflow/
│   └── dags/
│       └── run_dbt.py
└── metabase/
```

---

## 🛠 1. Sample `init.sql` (PostgreSQL Seed Data)

```sql
CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  name TEXT,
  region TEXT
);

INSERT INTO customers (name, region) VALUES
('Alice', 'North'),
('Bob', 'South'),
('Carol', 'East');

CREATE TABLE products (
  product_id SERIAL PRIMARY KEY,
  product_name TEXT,
  category TEXT
);

INSERT INTO products (product_name, category) VALUES
('Widget', 'Gadget'),
('Gizmo', 'Gadget'),
('Thingy', 'Tool');

CREATE TABLE sales (
  sale_id SERIAL PRIMARY KEY,
  customer_id INTEGER REFERENCES customers(customer_id),
  product_id INTEGER REFERENCES products(product_id),
  quantity INTEGER,
  sale_date DATE
);

INSERT INTO sales (customer_id, product_id, quantity, sale_date) VALUES
(1, 1, 10, '2024-01-01'),
(2, 2, 5, '2024-01-02'),
(3, 3, 2, '2024-01-03');
```

---

## 🧮 2. DBT Models (`dbt/bw_project/models/`)

### `stg_customers.sql`

```sql
SELECT customer_id, name, region FROM public.customers;
```

### `stg_products.sql`

```sql
SELECT product_id, product_name, category FROM public.products;
```

### `stg_sales.sql`

```sql
SELECT sale_id, customer_id, product_id, quantity, sale_date FROM public.sales;
```

### `rpt_sales_summary.sql`

```sql
WITH sales AS (
  SELECT * FROM {{ ref('stg_sales') }}
),
customers AS (
  SELECT * FROM {{ ref('stg_customers') }}
),
products AS (
  SELECT * FROM {{ ref('stg_products') }}
)

SELECT
  s.sale_id,
  s.sale_date,
  c.name AS customer_name,
  c.region,
  p.product_name,
  p.category,
  s.quantity
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id;
```

---

## ⚙️ 3. DBT `dbt_project.yml`

```yaml
name: 'bw_project'
version: '1.0'
config-version: 2

profile: 'bw_project'

models:
  bw_project:
    +materialized: view
```

---

## 🔐 4. DBT `profiles.yml`

Place this at `dbt/profiles.yml`:

```yaml
bw_project:
  target: dev
  outputs:
    dev:
      type: postgres
      host: postgres
      user: bw_user
      password: bw_pass
      port: 5432
      dbname: bw_lab
      schema: public
```

---

## 🪄 5. Airflow DAG (`airflow/dags/run_dbt.py`)

```python
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 1, 1),
}

with DAG('run_dbt_project', default_args=default_args, schedule_interval=None, catchup=False) as dag:
    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='cd /usr/app/bw_project && dbt run',
        docker_url='bw_dbt',
    )
```

> 🖱 Manually trigger this DAG in Airflow UI to run the DBT pipeline.

---

## 📈 6. Metabase Setup

- Visit: [http://localhost:3000](http://localhost:3000)
- Connect Metabase to PostgreSQL:
  - **Host**: `postgres`
  - **User**: `bw_user`
  - **Password**: `bw_pass`
  - **Database**: `bw_lab`
- Explore the `rpt_sales_summary` view for reporting


# 🧱 BW/4HANA Lab – Multi-Schema Expansion

We're now introducing **LSA++-inspired schemas** for better separation of concerns:

| Schema      | Purpose                          |
|-------------|----------------------------------|
| `raw`       | Source-level raw data            |
| `staging`   | Cleaned/transformed data         |
| `lab`       | Reporting-ready views            |

---

## ✅ PostgreSQL Schema Initialization (`postgres/init.sql`)

```sql
-- Create schemas
CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA lab;

-- Raw layer tables
CREATE TABLE raw.customers (
  customer_id SERIAL PRIMARY KEY,
  name TEXT,
  region TEXT
);

INSERT INTO raw.customers (name, region) VALUES
('Alice', 'North'),
('Bob', 'South'),
('Carol', 'East');

CREATE TABLE raw.products (
  product_id SERIAL PRIMARY KEY,
  product_name TEXT,
  category TEXT
);

INSERT INTO raw.products (product_name, category) VALUES
('Widget', 'Gadget'),
('Gizmo', 'Gadget'),
('Thingy', 'Tool');

CREATE TABLE raw.sales (
  sale_id SERIAL PRIMARY KEY,
  customer_id INTEGER,
  product_id INTEGER,
  quantity INTEGER,
  sale_date DATE
);

INSERT INTO raw.sales (customer_id, product_id, quantity, sale_date) VALUES
(1, 1, 10, '2024-01-01'),
(2, 2, 5, '2024-01-02'),
(3, 3, 2, '2024-01-03');
```

---

## 📁 Updated DBT Models Structure

```
models/
├── staging/
│   ├── stg_customers.sql
│   ├── stg_products.sql
│   └── stg_sales.sql
└── reporting/
    └── rpt_sales_summary.sql
```

---

### `staging/stg_customers.sql`

```sql
SELECT customer_id, name, region FROM raw.customers;
```

---

### `staging/stg_products.sql`

```sql
SELECT product_id, product_name, category FROM raw.products;
```

---

### `staging/stg_sales.sql`

```sql
SELECT sale_id, customer_id, product_id, quantity, sale_date FROM raw.sales;
```

---

### `reporting/rpt_sales_summary.sql`

```sql
WITH sales AS (
  SELECT * FROM {{ ref('stg_sales') }}
),
customers AS (
  SELECT * FROM {{ ref('stg_customers') }}
),
products AS (
  SELECT * FROM {{ ref('stg_products') }}
)

SELECT
  s.sale_id,
  s.sale_date,
  c.name AS customer_name,
  c.region,
  p.product_name,
  p.category,
  s.quantity
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id;
```

---

## ⚙️ `dbt_project.yml`

```yaml
name: 'bw_project'
version: '1.0'
config-version: 2

profile: 'bw_project'

models:
  bw_project:
    staging:
      +schema: staging
      +materialized: view
    reporting:
      +schema: lab
      +materialized: view
```

---

## 🔐 DBT `profiles.yml`

(unchanged)

```yaml
bw_project:
  target: dev
  outputs:
    dev:
      type: postgres
      host: postgres
      user: bw_user
      password: bw_pass
      port: 5432
      dbname: bw_lab
      schema: public  # overridden per model
```

---



