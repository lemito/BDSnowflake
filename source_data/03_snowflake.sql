\echo 'dw create schema'
CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE dw.dim_suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255),
    supplier_contact VARCHAR(255),
    supplier_email VARCHAR(255),
    supplier_phone VARCHAR(50),
    supplier_address TEXT,
    supplier_city VARCHAR(100),
    supplier_country VARCHAR(100)
);

CREATE TABLE dw.dim_stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(255),
    store_location VARCHAR(255),
    store_city VARCHAR(100),
    store_state VARCHAR(100),
    store_country VARCHAR(100),
    store_phone VARCHAR(50),
    store_email VARCHAR(255)
);

CREATE TABLE dw.dim_customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INT,
    email VARCHAR(255),
    country VARCHAR(100),
    postal_code VARCHAR(50),
    pet_type VARCHAR(50),
    pet_name VARCHAR(100),
    pet_breed VARCHAR(100)
);

CREATE TABLE dw.dim_sellers (
    seller_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    country VARCHAR(100),
    postal_code VARCHAR(50)
);

CREATE TABLE dw.dim_products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255),
    product_category VARCHAR(100),
    pet_category VARCHAR(100),
    price DECIMAL(10, 2),
    weight DECIMAL(10, 2),
    color VARCHAR(50),
    size VARCHAR(50),
    brand VARCHAR(100),
    material VARCHAR(100),
    description TEXT,
    rating DECIMAL(3, 1),
    reviews INT,
    release_date DATE,
    expiry_date DATE,
    supplier_id SERIAL REFERENCES dw.dim_suppliers (supplier_id)
);

CREATE TABLE dw.fact_sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id SERIAL REFERENCES dw.dim_customers (customer_id),
    seller_id SERIAL REFERENCES dw.dim_sellers (seller_id),
    product_id SERIAL REFERENCES dw.dim_products (product_id),
    store_id SERIAL REFERENCES dw.dim_stores (store_id),
    sale_date DATE,
    sale_quantity INT,
    sale_total_price DECIMAL(10, 2)
);