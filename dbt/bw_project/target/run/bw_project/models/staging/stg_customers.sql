
  create view "bw_lab"."lab_staging"."stg_customers__dbt_tmp"
    
    
  as (
    SELECT customer_id, name, region FROM raw.customers
  );