CREATE SCHEMA IF NOT EXISTS raw AUTHORIZATION bw_user;
CREATE SCHEMA IF NOT EXISTS lab AUTHORIZATION bw_user;

CREATE TABLE raw.customers (
  customer_id SERIAL PRIMARY KEY,
  name TEXT,
  region TEXT
);

INSERT INTO raw.customers (name, region) VALUES
('Alice', 'North'),
('Bob', 'South'),
('Carol', 'East');

CREATE TABLE raw.products (
  product_id SERIAL PRIMARY KEY,
  product_name TEXT,
  category TEXT
);

INSERT INTO raw.products (product_name, category) VALUES
('Widget', 'Gadget'),
('Gizmo', 'Gadget'),
('Thingy', 'Tool');

CREATE TABLE raw.sales (
  sale_id SERIAL PRIMARY KEY,
  customer_id INTEGER REFERENCES raw.customers(customer_id),
  product_id INTEGER REFERENCES raw.products(product_id),
  quantity INTEGER,
  sale_date DATE
);

INSERT INTO raw.sales (customer_id, product_id, quantity, sale_date) VALUES
(1, 1, 10, '2024-01-01'),
(2, 2, 5, '2024-01-02'),
(3, 3, 2, '2024-01-03');
