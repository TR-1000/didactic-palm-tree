
  create view "bw_lab"."lab_staging"."stg_sales__dbt_tmp"
    
    
  as (
    SELECT sale_id, customer_id, product_id, quantity, sale_date FROM raw.sales
  );