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