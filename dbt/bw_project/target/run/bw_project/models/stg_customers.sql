
  create view "bw_lab"."public"."stg_customers__dbt_tmp"
    
    
  as (
    SELECT customer_id, name, region FROM public.customers
  );