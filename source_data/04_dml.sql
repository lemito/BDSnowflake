INSERT INTO
    snowflake.dim_pet_types (name)
SELECT DISTINCT
    customer_pet_type
FROM
    mock_data
WHERE
    customer_pet_type IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO
    snowflake.dim_pet_breeds (pet_type_id, name)
SELECT DISTINCT
    pt.pet_type_id,
    m.customer_pet_breed
FROM
    mock_data m
    JOIN snowflake.dim_pet_types pt ON pt.name = m.customer_pet_type ON CONFLICT DO NOTHING;

INSERT INTO
    snowflake.dim_pets (pet_id, breed_id, name)
SELECT DISTINCT
    m.sale_customer_id + FLOOR((m.id - 1) / 1000) * 1000,
    pb.pet_breed_id,
    m.customer_pet_name
FROM
    mock_data m
    JOIN snowflake.dim_pet_types pt ON pt.name = m.customer_pet_type
    JOIN snowflake.dim_pet_breeds pb ON pb.name = m.customer_pet_breed
    AND pb.pet_type_id = pt.pet_type_id ON CONFLICT DO NOTHING;

INSERT INTO
    snowflake.dim_countries (name)
SELECT DISTINCT
    val
FROM
    (
        SELECT
            customer_country AS val
        FROM
            mock_data
        UNION
        SELECT
            store_country
        FROM
            mock_data
        UNION
        SELECT
            supplier_country
        FROM
            mock_data
    ) t
WHERE
    val IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO
    snowflake.dim_states (name, country_id)
SELECT DISTINCT
    m.store_state,
    c.country_id
FROM
    mock_data m
    JOIN snowflake.dim_countries c ON c.name = m.store_country
WHERE
    m.store_state IS NOT NULL
UNION
SELECT
    'N/A',
    country_id
FROM
    snowflake.dim_countries ON CONFLICT DO NOTHING;

INSERT INTO
    snowflake.dim_cities (name, state_id)
SELECT DISTINCT
    m.store_city,
    s.state_id
FROM
    mock_data m
    JOIN snowflake.dim_countries c ON c.name = m.store_country
    JOIN snowflake.dim_states s ON s.name = m.store_state
    AND s.country_id = c.country_id ON CONFLICT DO NOTHING;

INSERT INTO
    snowflake.dim_cities (name, state_id)
SELECT DISTINCT
    m.supplier_city,
    s.state_id
FROM
    mock_data m
    JOIN snowflake.dim_countries c ON c.name = m.supplier_country
    JOIN snowflake.dim_states s ON s.name = 'N/A'
    AND s.country_id = c.country_id ON CONFLICT DO NOTHING;

INSERT INTO
    snowflake.dim_cities (name, state_id)
SELECT
    'Unknown City',
    state_id
FROM
    snowflake.dim_states ON CONFLICT DO NOTHING;

INSERT INTO
    snowflake.dim_suppliers (name, contact, email, phone, address, city_id)
SELECT DISTINCT
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    ci.city_id
FROM
    mock_data m
    JOIN snowflake.dim_countries co ON co.name = m.supplier_country
    JOIN snowflake.dim_states st ON st.country_id = co.country_id
    JOIN snowflake.dim_cities ci ON ci.name = m.supplier_city
    AND ci.state_id = st.state_id ON CONFLICT DO NOTHING;

INSERT INTO
    snowflake.dim_customers (
        customer_id,
        first_name,
        last_name,
        email,
        age,
        city_id,
        postal_code,
        pet_id
    )
SELECT DISTINCT
    m.sale_customer_id + FLOOR((m.id - 1) / 1000) * 1000,
    m.customer_first_name,
    m.customer_last_name,
    m.customer_email,
    m.customer_age,
    ci.city_id,
    m.customer_postal_code,
    m.sale_customer_id + FLOOR((m.id - 1) / 1000) * 1000
FROM
    mock_data m
    JOIN snowflake.dim_countries co ON co.name = m.customer_country
    JOIN snowflake.dim_states st ON st.name = 'N/A'
    AND st.country_id = co.country_id
    JOIN snowflake.dim_cities ci ON ci.name = 'Unknown City'
    AND ci.state_id = st.state_id
WHERE
    m.sale_customer_id IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO
    snowflake.dim_sellers (
        seller_id,
        first_name,
        last_name,
        email,
        city_id,
        postal_code
    )
SELECT DISTINCT
    m.sale_seller_id + FLOOR((m.id - 1) / 1000) * 1000,
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    (
        SELECT
            city_id
        FROM
            snowflake.dim_cities
        WHERE
            name = 'Unknown City'
        LIMIT
            1
    ),
    m.seller_postal_code
FROM
    mock_data m
WHERE
    m.sale_seller_id IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO
    snowflake.dim_products (
        product_id,
        name,
        price,
        weight,
        color_id,
        size,
        brand_id,
        material_id,
        release_date,
        supplier_id
    )
SELECT DISTINCT
    m.sale_product_id + FLOOR((m.id - 1) / 1000) * 1000,
    m.product_name,
    m.product_price,
    m.product_weight,
    (
        SELECT
            color_id
        FROM
            snowflake.dim_colors
        WHERE
            name = m.product_color
        LIMIT
            1
    ),
    m.product_size,
    (
        SELECT
            brand_id
        FROM
            snowflake.dim_brands
        WHERE
            name = m.product_brand
        LIMIT
            1
    ),
    (
        SELECT
            material_id
        FROM
            snowflake.dim_materials
        WHERE
            name = m.product_material
        LIMIT
            1
    ),
    CASE
        WHEN m.product_release_date ~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN to_date (m.product_release_date, 'FMMM/FMDD/YYYY')
        ELSE NULL
    END,
    (
        SELECT
            supplier_id
        FROM
            snowflake.dim_suppliers
        WHERE
            email = m.supplier_email
        LIMIT
            1
    )
FROM
    mock_data m
WHERE
    m.sale_product_id IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO
    snowflake.fact_sales (
        customer_id,
        seller_id,
        product_id,
        store_id,
        quantity,
        total_price,
        date
    )
SELECT
    m.sale_customer_id + FLOOR((m.id - 1) / 1000) * 1000,
    m.sale_seller_id + FLOOR((m.id - 1) / 1000) * 1000,
    m.sale_product_id + FLOOR((m.id - 1) / 1000) * 1000,
    st.store_id,
    m.sale_quantity,
    m.sale_total_price,
    CASE
        WHEN m.sale_date ~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN to_date (m.sale_date, 'FMMM/FMDD/YYYY')
        ELSE NULL
    END
FROM
    mock_data m
    JOIN snowflake.dim_stores st ON st.email = m.store_email ON CONFLICT DO NOTHING;

\echo 'All saved'
