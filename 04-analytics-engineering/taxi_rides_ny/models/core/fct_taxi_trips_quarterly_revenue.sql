{{
    config(
        materialized= 'table'
    )
}}

WITH quarterly_revenue AS
(
    SELECT
        service_type,
        EXTRACT(YEAR FROM pickup_datetime) as year,
        EXTRACT(QUARTER FROM pickup_datetime) as quarter,
        SUM(total_amount) as revenue
    FROM
        {{ ref('fact_trips') }}
    WHERE
        EXTRACT(YEAR FROM pickup_datetime) IN (2019, 2020)
    GROUP BY
        service_type, year, quarter
),

quarterly_growth AS
(
    SELECT
        service_type,
        year,
        quarter,
        revenue,
        LAG(revenue) OVER (PARTITION BY service_type, quarter ORDER BY year) AS prev_year_revenue,
        (revenue - LAG(revenue) OVER (PARTITION BY service_type, quarter ORDER BY year)) /
        NULLIF(LAG(revenue) OVER (PARTITION BY service_type, quarter ORDER BY year), 0) AS yoy_growth
    FROM
        quarterly_revenue
)
SELECT * FROM quarterly_growth
