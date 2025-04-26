
  create view "bw_lab"."lab_staging"."stg_products__dbt_tmp"
    
    
  as (
    SELECT product_id, product_name, category FROM raw.products
  );