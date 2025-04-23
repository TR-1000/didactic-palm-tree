# 🆓 Open-Source Alternatives to SAP BW/4HANA

If you're building a personal lab for SAP data engineering on your own hardware, here's an open-source stack that mimics SAP BW/4HANA capabilities.

---

## 🔧 Open-Source Component Mapping

| SAP BW/4HANA Feature        | Open-Source Alternative                            | Description |
|-----------------------------|-----------------------------------------------------|-------------|
| Data Warehouse              | **PostgreSQL** / **Apache Hive** / **Druid**       | Core OLAP engine; Druid supports cube-like queries. |
| ETL / Data Pipelines        | **Apache Airflow**, **Talend Open Studio**, **Meltano**, **Apache NiFi** | Workflow orchestration and transformation tools. |
| InfoObjects / Modeling      | **DBT (Data Build Tool)**                           | SQL-based data modeling and transformation logic. |
| Metadata / Governance       | **Apache Atlas**, **Amundsen**                     | Metadata cataloging, lineage, and governance. |
| Reporting & Dashboards      | **Apache Superset**, **Metabase**, **Redash**       | BI dashboards, visualizations, SQL-based reporting. |
| Front-End / UI5 Simulation  | **OpenUI5**                                        | For building Fiori-style UIs and apps. |

---

## 🧪 Docker-Based Lab Setup

Here's a minimal stack to simulate BW/4HANA:

| Tool        | Purpose                              | Port |
|-------------|---------------------------------------|------|
| PostgreSQL  | Central data warehouse                | 5432 |
| Airflow     | ETL orchestration (like process chains) | 8080 |
| DBT         | Data modeling (InfoObjects, ADSOs)     | CLI  |
| Metabase    | BI reporting and dashboards            | 3000 |

---

## 📦 docker-compose.yml (base setup)
Here's a base docker-compose.yml to get started:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: bw_postgres
    environment:
      POSTGRES_USER: bw_user
      POSTGRES_PASSWORD: bw_pass
      POSTGRES_DB: bw_lab
    ports:
      - "5432:5432"
    volumes:
      - ./postgres/init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped

  airflow:
    image: apache/airflow:2.7.1-python3.10
    container_name: bw_airflow
    depends_on:
      - postgres
    environment:
      AIRFLOW__CORE__EXECUTOR: SequentialExecutor
      AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: postgresql+psycopg2://bw_user:bw_pass@postgres:5432/bw_lab
      AIRFLOW__CORE__FERNET_KEY: 'fernet_key_here'
      AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION: 'false'
      AIRFLOW__CORE__LOAD_EXAMPLES: 'false'
    volumes:
      - ./airflow/dags:/opt/airflow/dags
    ports:
      - "8080:8080"
    command: >
      bash -c "
      airflow db migrate &&
      airflow users create --username admin --password admin --firstname Air --lastname Flow --role Admin --email admin@example.com &&
      airflow webserver & airflow scheduler"
    restart: unless-stopped

  metabase:
    image: metabase/metabase
    container_name: bw_metabase
    ports:
      - "3000:3000"
    environment:
      MB_DB_FILE: /metabase-data/metabase.db
    volumes:
      - metabase_data:/metabase-data
    restart: unless-stopped

  dbt:
    image: ghcr.io/dbt-labs/dbt-postgres:1.7.5
    container_name: bw_dbt
    volumes:
      - ./dbt:/usr/app
    working_dir: /usr/app
    depends_on:
      - postgres
    entrypoint: ["tail", "-f", "/dev/null"]  # Keeps the container running for exec
    restart: unless-stopped

volumes:
  metabase_data:
```

## 🐳 Start and stop the lab:

```bash
docker-compose up -d
```

```bash
docker-compose down
```

## 🧹 Optional: Clean Slate

Want to wipe everything and start fresh?

```bash
docker-compose down -v  # Stops containers and removes volumes (includes DB data)
docker-compose up --build
```
⚠️ This will delete all database data, including your sales table!

---

## 🗂️ Suggested Folder Structure

```bash
bw4hana-openlab/
├── docker-compose.yml
├── airflow/
│   └── dags/
├── dbt/
│   └── project/
├── metabase/
└── postgres/
    └── init.sql
```



