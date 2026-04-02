-- =========================================
-- LOGISTICS HUB PERFORMANCE ANALYSIS
-- End-to-end SQL queries for KPI analysis
-- Dataset: Amazon Delivery Dataset (Kaggle)
-- Tool: PostgreSQL
-- Author: Jeanny Lou Coloma
-- =========================================

-- PROJECT OVERVIEW
-- This analysis evaluates logistics hub performance
-- and identifies key drivers of delivery delays.
-- Focus: operational efficiency vs external factors

-- ================================
-- 0. Operational KPI Summary
-- ================================

-- Provides a high-level summary of the main operational KPIs.
SELECT
    COUNT(order_id) AS total_orders,
    ROUND(AVG(delivery_time_min), 0) AS avg_delivery_time,
    ROUND(AVG(yard_waiting_time_min), 0) AS avg_yard_wait,
    ROUND(AVG(dock_operation_time_min), 0) AS avg_dock_time,
    ROUND(AVG(hub_turnaround_time_min), 0) AS avg_hub_turnaround
FROM deliveries;


-- ================================
-- 1. Hub Performance by Hour
-- ================================

-- Analyzes order volume, hub process times, on-time rate,
-- and hourly delivery risk classification.
SELECT 
    hour,
    COUNT(order_id) AS total_orders,

    ROUND(
        COUNT(order_id) * 100.0 / SUM(COUNT(order_id)) OVER (),
        0
    ) AS pct_of_total,

    RANK() OVER (ORDER BY COUNT(order_id) DESC) AS hour_rank,

    ROUND(AVG(delivery_time_min), 0) AS avg_delivery_time,
    ROUND(AVG(yard_waiting_time_min), 0) AS avg_yard_wait,
    ROUND(AVG(dock_operation_time_min), 0) AS avg_dock_time,
    ROUND(AVG(hub_turnaround_time_min), 0) AS avg_turnaround,

    ROUND(
        SUM(
            CASE 
                WHEN on_time_status = 'On Time' THEN 1 
                ELSE 0 
            END
        ) * 100.0 / COUNT(order_id),
        0
    ) AS on_time_rate_pct,

    CASE
        WHEN AVG(delivery_time_min) >= 130 THEN 'Critical'
        WHEN AVG(delivery_time_min) >= 115 THEN 'Warning'
        ELSE 'Stable'
    END AS risk_level

FROM deliveries
GROUP BY hour
ORDER BY hour;


-- ================================
-- 2. Hub Congestion Analysis
-- ================================

-- Breaks down hub process times by hour
-- to assess internal bottlenecks vs delivery performance
SELECT
    hour,
    ROUND(AVG(yard_waiting_time_min), 0) AS avg_yard_wait,
    ROUND(AVG(dock_operation_time_min), 0) AS avg_dock_time,
    ROUND(AVG(hub_turnaround_time_min), 0) AS avg_turnaround,
    ROUND(AVG(delivery_time_min), 0) AS avg_delivery_time,
    ROUND(
        AVG(delivery_time_min) - AVG(hub_turnaround_time_min),
        0
    ) AS outbound_time_after_hub
FROM deliveries
GROUP BY hour
ORDER BY hour;


-- ================================
-- 3. Traffic Impact Analysis
-- ================================

-- Measures delivery performance by traffic condition,
-- including delay vs low-traffic baseline and on-time rate.
SELECT 
    traffic_condition,

    ROUND(AVG(delivery_time_min), 0) AS avg_delivery_time,

    ROUND(
        AVG(delivery_time_min) 
        - MIN(AVG(delivery_time_min)) OVER (),
        0
    ) AS extra_time_vs_low,

    ROUND(
        (
            AVG(delivery_time_min) 
            - MIN(AVG(delivery_time_min)) OVER ()
        ) * 100.0
        / MIN(AVG(delivery_time_min)) OVER (),
        0
    ) AS pct_increase_vs_low,

    ROUND(
        SUM(
            CASE 
                WHEN on_time_status = 'On Time' THEN 1 
                ELSE 0 
            END
        ) * 100.0 / COUNT(order_id),
        0
    ) AS on_time_rate_pct

FROM deliveries
GROUP BY traffic_condition
ORDER BY avg_delivery_time DESC;


-- ================================
-- 4. Weather Impact Analysis
-- ================================

-- Compares delivery time by weather condition,
-- using sunny weather as baseline.
SELECT 
    weather_condition,

    ROUND(AVG(delivery_time_min), 0) AS avg_delivery_time,

    ROUND(
        AVG(delivery_time_min)
        - MIN(AVG(delivery_time_min)) OVER (),
        0
    ) AS extra_minutes_vs_sunny,

    ROUND(
        SUM(
            CASE 
                WHEN on_time_status = 'On Time' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(order_id),
        0
    ) AS on_time_rate_pct

FROM deliveries
GROUP BY weather_condition
ORDER BY avg_delivery_time DESC;


-- ================================
-- 5. Geographic Performance Analysis
-- ================================

-- Analyzes delivery performance across geographic areas,
-- highlighting how area impacts delivery time and on-time rate
-- across different vehicle types
SELECT
    geographic_area,
    vehicle,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(delivery_time_min), 0) AS avg_delivery_time,
    ROUND(
        SUM(
            CASE
                WHEN on_time_status = 'On Time' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(order_id),
        0
    ) AS on_time_rate_pct

FROM deliveries
GROUP BY geographic_area, vehicle
HAVING COUNT(order_id) >= 50
ORDER BY geographic_area, avg_delivery_time DESC;


-- ================================
-- 6. Peak vs Off-Peak Analysis
-- ================================

-- Compares delivery performance between peak and off-peak periods,
-- including hub metrics and overall service level.
SELECT
    peak_status,
    COUNT(order_id) AS total_orders,

    ROUND(AVG(delivery_time_min), 0) AS avg_delivery_time,
    ROUND(AVG(yard_waiting_time_min), 0) AS avg_yard_wait,
    ROUND(AVG(hub_turnaround_time_min), 0) AS avg_turnaround,

    ROUND(
        SUM(
            CASE 
                WHEN on_time_status = 'On Time' THEN 1 
                ELSE 0 
            END
        ) * 100.0 / COUNT(order_id),
        0
    ) AS on_time_rate_pct,

    CASE
        WHEN AVG(delivery_time_min) > 120 THEN 'Critical'
        WHEN AVG(delivery_time_min) BETWEEN 110 AND 120 THEN 'Moderate'
        ELSE 'Stable'
    END AS performance_flag

FROM deliveries
GROUP BY peak_status
ORDER BY avg_delivery_time DESC;


-- ================================
-- 7. Combined External Factors Analysis
-- ================================

-- Identifies worst-case delivery scenarios by combining
-- traffic conditions, weather, and geographic area.
SELECT
    geographic_area,
    traffic_condition,
    weather_condition,

    COUNT(order_id) AS total_orders,

    ROUND(AVG(delivery_time_min), 0) AS avg_delivery_time,

    ROUND(
        SUM(
            CASE 
                WHEN on_time_status = 'On Time' THEN 1 
                ELSE 0 
            END
        ) * 100.0 / COUNT(order_id),
        0
    ) AS on_time_rate_pct,

    ROUND(AVG(yard_waiting_time_min), 0) AS avg_yard_wait,
    ROUND(AVG(dock_operation_time_min), 0) AS avg_dock_time,
    ROUND(AVG(hub_turnaround_time_min), 0) AS avg_turnaround,

    CASE
        WHEN AVG(delivery_time_min) > 150 THEN 'Critical'
        WHEN AVG(delivery_time_min) > 130 THEN 'Warning'
        ELSE 'Normal'
    END AS risk_level

FROM deliveries
GROUP BY geographic_area, traffic_condition, weather_condition
HAVING COUNT(order_id) >= 20
ORDER BY avg_delivery_time DESC
LIMIT 10;