CREATE SCHEMA IF NOT EXISTS snowflake;

CREATE TABLE
    snowflake.dim_countries (
        country_id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE
    );

CREATE TABLE
    snowflake.dim_states (
        state_id SERIAL PRIMARY KEY,
        country_id INTEGER REFERENCES snowflake.dim_countries (country_id),
        name VARCHAR(100) NOT NULL,
        UNIQUE (name, country_id)
    );

CREATE TABLE
    snowflake.dim_cities (
        city_id SERIAL PRIMARY KEY,
        state_id INTEGER REFERENCES snowflake.dim_states (state_id),
        name VARCHAR(100) NOT NULL,
        UNIQUE (name, state_id)
    );

CREATE TABLE
    snowflake.dim_pet_types (
        pet_type_id SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE
    );

CREATE TABLE
    snowflake.dim_pet_breeds (
        pet_breed_id SERIAL PRIMARY KEY,
        pet_type_id INTEGER REFERENCES snowflake.dim_pet_types (pet_type_id),
        name VARCHAR(100) NOT NULL,
        UNIQUE (name, pet_type_id)
    );

CREATE TABLE
    snowflake.dim_pets (
        pet_id SERIAL PRIMARY KEY,
        name VARCHAR(100),
        breed_id INTEGER REFERENCES snowflake.dim_pet_breeds (pet_breed_id)
    );

CREATE TABLE
    snowflake.dim_product_categories (
        category_id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE
    );

CREATE TABLE
    snowflake.dim_pet_categories (
        pet_category_id SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE
    );

CREATE TABLE
    snowflake.dim_colors (
        color_id SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE
    );

CREATE TABLE
    snowflake.dim_brands (
        brand_id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE
    );

CREATE TABLE
    snowflake.dim_materials (
        material_id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE
    );

CREATE TABLE
    snowflake.dim_suppliers (
        supplier_id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL UNIQUE,
        contact VARCHAR(255),
        email VARCHAR(255) UNIQUE,
        phone VARCHAR(50),
        address TEXT,
        city_id INTEGER REFERENCES snowflake.dim_cities (city_id)
    );

CREATE TABLE
    snowflake.dim_customers (
        customer_id SERIAL PRIMARY KEY,
        first_name VARCHAR(100),
        last_name VARCHAR(100),
        email VARCHAR(255) NOT NULL UNIQUE,
        age INTEGER,
        city_id INTEGER REFERENCES snowflake.dim_cities (city_id),
        postal_code VARCHAR(20),
        pet_id INTEGER REFERENCES snowflake.dim_pets (pet_id)
    );

CREATE TABLE
    snowflake.dim_sellers (
        seller_id SERIAL PRIMARY KEY,
        first_name VARCHAR(100),
        last_name VARCHAR(100),
        email VARCHAR(255) NOT NULL UNIQUE,
        city_id INTEGER REFERENCES snowflake.dim_cities (city_id),
        postal_code VARCHAR(20)
    );

CREATE TABLE
    snowflake.dim_stores (
        store_id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        location VARCHAR(255),
        city_id INTEGER REFERENCES snowflake.dim_cities (city_id),
        phone VARCHAR(50),
        email VARCHAR(255) UNIQUE
    );

CREATE TABLE
    snowflake.dim_products (
        product_id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        pet_category_id INTEGER REFERENCES snowflake.dim_pet_categories (pet_category_id),
        category_id INTEGER REFERENCES snowflake.dim_product_categories (category_id),
        price DECIMAL(10, 2),
        weight DECIMAL(10, 2),
        color_id INTEGER REFERENCES snowflake.dim_colors (color_id),
        size VARCHAR(50),
        brand_id INTEGER REFERENCES snowflake.dim_brands (brand_id),
        material_id INTEGER REFERENCES snowflake.dim_materials (material_id),
        description TEXT,
        rating DECIMAL(3, 1),
        reviews INTEGER,
        release_date DATE,
        expiry_date DATE,
        supplier_id INTEGER REFERENCES snowflake.dim_suppliers (supplier_id)
    );

CREATE TABLE
    snowflake.fact_sales (
        sale_id SERIAL PRIMARY KEY,
        customer_id INTEGER REFERENCES snowflake.dim_customers (customer_id),
        seller_id INTEGER REFERENCES snowflake.dim_sellers (seller_id),
        product_id INTEGER REFERENCES snowflake.dim_products (product_id),
        store_id INTEGER REFERENCES snowflake.dim_stores (store_id),
        quantity INTEGER,
        total_price DECIMAL(10, 2),
        date DATE,
        UNIQUE (customer_id, product_id, date)
    );

\echo 'All created'
