## 📘 **User Story: Track and Report Daily Sales Performance**

### **Role:**  
As a **Business Analyst**

### **Goal:**  
I want to **track daily sales performance** by product category and region,  
so that I can **identify trends, outliers, and underperforming segments**.

---

## ✅ **Acceptance Criteria**

### 1. **Data Ingestion**
- Raw `sales.csv` is loaded into PostgreSQL (`raw.sales` table)
- Sales data includes:
  - `sale_id` (int, primary key)
  - `product_name` (string)
  - `category` (string)
  - `region` (string)
  - `amount` (float)
  - `sale_date` (date)

### 2. **Data Contract**
- A contract defines:
  - `sale_id` must be unique and not null
  - `amount` must be ≥ 0
  - `category` and `region` must not be null

### 3. **Transformation**
- A DBT model called `daily_sales_summary` is created that:
  - Aggregates total sales amount by `category`, `region`, and `sale_date`
  - Filters out rows with nulls or invalid data
- Includes DBT tests for data contract rules

### 4. **Orchestration**
- An Airflow DAG runs daily:
  - Loads the CSV (if needed)
  - Runs DBT models and tests
  - Logs status

### 5. **Dashboard**
- Metabase dashboard visualizes:
  - Total sales over time
  - Breakdown by category
  - Breakdown by region
  - A filter to choose specific dates

---

## 💡 Bonus (Stretch Goals)
- Add a freshness test: flag if `sale_date` doesn’t include today’s date
- Add a notification step in Airflow if tests fail
- Track which rows are rejected (optional "quarantine" table)

Awesome! Here's everything you need to get started on your user story like a real data engineer. You'll get:

- ✅ A starter `sales.csv`
- ✅ A raw table creation SQL
- ✅ A DBT scaffold for the model and tests
- ✅ Simple Airflow DAG outline

---

## 📁 **Step 1: Starter `sales.csv`**

Save this as `data/sales.csv` in your project root (you can mount it into the Postgres container or copy it manually):

```csv
sale_id,product_name,category,region,amount,sale_date
1,Desk Lamp,Lighting,West,29.99,2025-04-17
2,Office Chair,Furniture,East,89.99,2025-04-17
3,Notebook,Stationery,North,3.50,2025-04-17
4,LED Monitor,Electronics,South,149.99,2025-04-18
5,Mouse Pad,Accessories,West,0.00,2025-04-18
6,,Electronics,South,199.99,2025-04-18
7,Pen,Stationery,,2.99,2025-04-18
8,Stapler,Stationery,East,5.50,2025-04-19
```

---

## 🧱 **Step 2: Create Raw Table in PostgreSQL**

Use this to initialize the raw table in your Postgres DB (`raw.sales`):

```sql
CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE raw.sales (
    sale_id INT PRIMARY KEY,
    product_name TEXT,
    category TEXT,
    region TEXT,
    amount NUMERIC,
    sale_date DATE
);
```

You can load the data with a tool like DBeaver, pgAdmin, or from inside the container using `COPY`.

---

## 🧪 **Step 3: DBT Scaffold**

In your DBT project (`models/staging/daily_sales_summary.sql`):

```sql
-- models/staging/daily_sales_summary.sql

WITH cleaned AS (
  SELECT
    sale_id,
    category,
    region,
    amount,
    sale_date
  FROM {{ ref('raw__sales') }}
  WHERE 
    amount >= 0 AND
    category IS NOT NULL AND
    region IS NOT NULL
)

SELECT
  category,
  region,
  sale_date,
  SUM(amount) AS total_sales
FROM cleaned
GROUP BY category, region, sale_date
ORDER BY sale_date;
```

---

### In `models/schema.yml`:

```yaml
version: 2

models:
  - name: raw__sales
    description: "Raw sales data from source CSV"
    columns:
      - name: sale_id
        tests:
          - not_null
          - unique
      - name: amount
        tests:
          - not_null
      - name: category
        tests:
          - not_null
      - name: region
        tests:
          - not_null

  - name: daily_sales_summary
    description: "Aggregated sales by category, region, and date"
    columns:
      - name: total_sales
        description: "Total sales for each group"
```

> You’ll need to create a model called `raw__sales` that just selects from `raw.sales` as a DBT source model.

---

## 🛠 **Step 4: Airflow DAG Skeleton**

```python
# dags/daily_sales_pipeline.py

from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
    dag_id='daily_sales_pipeline',
    start_date=datetime(2025, 4, 19),
    schedule_interval='@daily',
    catchup=False,
) as dag:

    dbt_run = BashOperator(
        task_id='run_dbt',
        bash_command='cd /dbt && dbt run --select daily_sales_summary'
    )

    dbt_test = BashOperator(
        task_id='test_dbt',
        bash_command='cd /dbt && dbt test'
    )

    dbt_run >> dbt_test
```

---
