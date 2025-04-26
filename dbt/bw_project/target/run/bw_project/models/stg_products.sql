
  create view "bw_lab"."public"."stg_products__dbt_tmp"
    
    
  as (
    SELECT product_id, product_name, category FROM public.products
  );