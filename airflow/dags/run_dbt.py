from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG('run_dbt',
         start_date=datetime(2024, 1, 1),
         schedule_interval='@daily',
         catchup=False) as dag:

    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='cd /opt/dbt && dbt run'
    )
