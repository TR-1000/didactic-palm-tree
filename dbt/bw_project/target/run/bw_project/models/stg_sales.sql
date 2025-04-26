
  create view "bw_lab"."public"."stg_sales__dbt_tmp"
    
    
  as (
    SELECT sale_id, customer_id, product_id, quantity, sale_date FROM public.sales
  );