WITH sales AS (
  SELECT * FROM "bw_lab"."public"."stg_sales"
),
customers AS (
  SELECT * FROM "bw_lab"."public"."stg_customers"
),
products AS (
  SELECT * FROM "bw_lab"."public"."stg_products"
)

SELECT
  s.sale_id,
  s.sale_date,
  c.name AS customer_name,
  c.region,
  p.product_name,
  p.category,
  s.quantity
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id