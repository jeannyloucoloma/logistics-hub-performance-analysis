# Logistics Hub Performance Analysis
**Data Analyst Portfolio Project | Excel • SQL • Power BI**

End-to-end data analysis project focused on identifying the main drivers of delivery delays in a logistics hub environment.

## Main Insight
The hub itself is not the source of delivery delays.  
External factors — especially traffic, weather, and geographic area — are the main drivers of performance variability.

## Project Objective
This project was developed to:
- evaluate hub operational efficiency
- identify the main drivers of delivery delays
- distinguish internal bottlenecks from external risk factors

## Tools Used
- Excel — data cleaning, feature engineering, KPI structuring
- SQL (PostgreSQL) — KPI calculations, aggregations, CASE WHEN, window functions, HAVING
- Power BI — dashboard design and KPI visualization

## Dataset
- Source: Amazon Delivery Dataset (Kaggle)
- Size: 5,000 orders

## Key KPIs
- Avg Delivery Time
- On-Time Rate
- Avg Yard Waiting Time
- Avg Dock Operation Time
- Avg Hub Turnaround Time

## Key Findings
- Hub operations are not the bottleneck: turnaround remains stable (~47–48 min)
- Traffic is the primary driver of delivery delays (+41 min under high traffic)
- Weather has a secondary but significant impact, especially under low-visibility conditions
- Semi-urban areas show the highest delivery times (~2x vs other areas)
- Delivery performance deteriorates when external risk factors overlap

## SQL Analysis Included
The SQL file contains:
- operational KPI summary
- hub performance by hour
- hub congestion analysis
- traffic impact analysis
- weather impact analysis
- geographic performance analysis
- peak vs off-peak analysis
- combined external factors analysis

## Dashboard
The Power BI dashboard provides an interactive view of:
- hub efficiency KPIs
- peak vs off-peak performance
- traffic impact on delivery time
- geographic bottlenecks
- end-to-end performance overview

## Files
- `logistics_hub_queries.sql` — SQL queries used for the analysis
- `logistics_hub_dataset.xlsx` — Excel file with cleaned data and pivot tables
- `logistics_hub_dashboard.pbix` — Power BI dashboard
- `logistics_hub_performance_analysis.pdf` — final presentation
- `logistics_hub_dashboard_preview.png` — Power BI dashboard overview
