SELECT
    COUNT(DISTINCT CASE WHEN event_name = 'view' THEN user_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN user_id END) AS carts,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_id END) AS purchases
FROM cleaned_data;

-- Step 2: Session-Level Flags

SELECT
    session_id,
    MAX(CASE WHEN event_name = 'view' THEN 1 ELSE 0 END) AS view_flag,
    MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS cart_flag,
    MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchase_flag
FROM cleaned_data
GROUP BY session_id;

-- Step 3: Session Counts

SELECT
    COUNT(*) AS total_sessions,
    SUM(view_flag) AS view_sessions,
    SUM(cart_flag) AS cart_sessions,
    SUM(purchase_flag) AS purchase_sessions
FROM (
    SELECT
        session_id,
        MAX(CASE WHEN event_name = 'view' THEN 1 ELSE 0 END) AS view_flag,
        MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS cart_flag,
        MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchase_flag
    FROM cleaned_data
    GROUP BY session_id
) s;

-- Step 4: Session-Level Conversion Rates

SELECT
    cart_sessions / view_sessions AS view_to_cart,
    purchase_sessions / cart_sessions AS cart_to_purchase,
    purchase_sessions / view_sessions AS overall_conversion
FROM (
    SELECT
        SUM(view_flag) AS view_sessions,
        SUM(cart_flag) AS cart_sessions,
        SUM(purchase_flag) AS purchase_sessions
    FROM (
        SELECT
            session_id,
            MAX(CASE WHEN event_name = 'view' THEN 1 ELSE 0 END) AS view_flag,
            MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS cart_flag,
            MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchase_flag
        FROM cleaned_data
        GROUP BY session_id
    ) s
) f;


-- segmented funnel in sql

-- Step 5: Funnel by Device Type

SELECT
    device_type,
    SUM(view_flag) AS view_sessions,
    SUM(cart_flag) AS cart_sessions,
    SUM(purchase_flag) AS purchase_sessions,
    
    SUM(cart_flag) * 1.0 / SUM(view_flag) AS view_to_cart,
    SUM(purchase_flag) * 1.0 / SUM(cart_flag) AS cart_to_purchase,
    SUM(purchase_flag) * 1.0 / SUM(view_flag) AS overall_conversion

FROM (
    SELECT
        session_id,
        MAX(device_type) AS device_type,

        MAX(CASE WHEN event_name = 'view' THEN 1 ELSE 0 END) AS view_flag,
        MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS cart_flag,
        MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchase_flag

    FROM cleaned_data
    GROUP BY session_id
) s

GROUP BY device_type;

-- Step 6: Funnel by Traffic Source

SELECT
    traffic_source,
    SUM(view_flag) AS view_sessions,
    SUM(cart_flag) AS cart_sessions,
    SUM(purchase_flag) AS purchase_sessions,

    SUM(cart_flag) * 1.0 / SUM(view_flag) AS view_to_cart,
    SUM(purchase_flag) * 1.0 / SUM(cart_flag) AS cart_to_purchase,
    SUM(purchase_flag) * 1.0 / SUM(view_flag) AS overall_conversion

FROM (
    SELECT
        session_id,
        MAX(traffic_source) AS traffic_source,

        MAX(CASE WHEN event_name = 'view' THEN 1 ELSE 0 END) AS view_flag,
        MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS cart_flag,
        MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchase_flag

    FROM cleaned_data
    GROUP BY session_id
) s

GROUP BY traffic_source;

-- Step 7: Funnel by Country

SELECT
    country,
    SUM(view_flag) AS view_sessions,
    SUM(cart_flag) AS cart_sessions,
    SUM(purchase_flag) AS purchase_sessions,

    SUM(cart_flag) * 1.0 / SUM(view_flag) AS view_to_cart,
    SUM(purchase_flag) * 1.0 / SUM(cart_flag) AS cart_to_purchase,
    SUM(purchase_flag) * 1.0 / SUM(view_flag) AS overall_conversion

FROM (
    SELECT
        session_id,
        MAX(country) AS country,

        MAX(CASE WHEN event_name = 'view' THEN 1 ELSE 0 END) AS view_flag,
        MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS cart_flag,
        MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchase_flag

    FROM cleaned_data
    GROUP BY session_id
) s

GROUP BY country;