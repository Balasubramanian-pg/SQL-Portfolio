# Automotive Costs Data Analysis: 25 Questions and SQL Answers

## Basic Price Analysis

### 1. What is the average MSRP across all vehicle segments for each year?
```sql
SELECT 
    model_year, 
    ROUND(AVG(msrp), 2) AS average_price
FROM 
    vehicle_sales
GROUP BY 
    model_year
ORDER BY 
    model_year;
```

### 2. How has the median price of sedans changed over the past decade?
```sql
SELECT 
    model_year, 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY msrp) AS median_price
FROM 
    vehicle_sales
WHERE 
    segment = 'Sedan' 
    AND model_year BETWEEN YEAR(CURRENT_DATE) - 10 AND YEAR(CURRENT_DATE)
GROUP BY 
    model_year
ORDER BY 
    model_year;
```

### 3. What are the top 5 most expensive vehicle models in each segment for the current year?
```sql
WITH RankedVehicles AS (
    SELECT 
        model_name,
        manufacturer,
        segment,
        msrp,
        ROW_NUMBER() OVER (PARTITION BY segment ORDER BY msrp DESC) AS price_rank
    FROM 
        vehicle_sales
    WHERE 
        model_year = YEAR(CURRENT_DATE)
)
SELECT 
    segment,
    model_name,
    manufacturer,
    msrp
FROM 
    RankedVehicles
WHERE 
    price_rank <= 5
ORDER BY 
    segment, price_rank;
```

## Inflation Impact Analysis

### 4. How do car price increases compare to the Consumer Price Index (CPI) over time?
```sql
SELECT 
    v.model_year,
    ROUND(AVG(v.msrp), 2) AS avg_car_price,
    i.cpi_value,
    ROUND((AVG(v.msrp) / LAG(AVG(v.msrp)) OVER (ORDER BY v.model_year) - 1) * 100, 2) AS car_price_increase_pct,
    ROUND((i.cpi_value / LAG(i.cpi_value) OVER (ORDER BY i.year) - 1) * 100, 2) AS cpi_increase_pct
FROM 
    vehicle_sales v
JOIN 
    inflation_data i ON v.model_year = i.year
GROUP BY 
    v.model_year, i.cpi_value
ORDER BY 
    v.model_year;
```

### 5. What is the inflation-adjusted average price for each vehicle segment over time?
```sql
SELECT 
    v.model_year,
    v.segment,
    ROUND(AVG(v.msrp), 2) AS nominal_avg_price,
    ROUND(AVG(v.msrp) * (SELECT cpi_value FROM inflation_data WHERE year = YEAR(CURRENT_DATE)) 
          / i.cpi_value, 2) AS inflation_adjusted_price
FROM 
    vehicle_sales v
JOIN 
    inflation_data i ON v.model_year = i.year
GROUP BY 
    v.model_year, v.segment, i.cpi_value
ORDER BY 
    v.segment, v.model_year;
```

## Technological Impact Analysis

### 6. How does the presence of advanced safety features correlate with vehicle prices?
```sql
SELECT 
    feature_name,
    ROUND(AVG(CASE WHEN f.has_feature = 1 THEN v.msrp ELSE NULL END), 2) AS avg_price_with_feature,
    ROUND(AVG(CASE WHEN f.has_feature = 0 THEN v.msrp ELSE NULL END), 2) AS avg_price_without_feature,
    ROUND(AVG(CASE WHEN f.has_feature = 1 THEN v.msrp ELSE NULL END) - 
          AVG(CASE WHEN f.has_feature = 0 THEN v.msrp ELSE NULL END), 2) AS price_difference
FROM 
    vehicle_sales v
JOIN 
    vehicle_features f ON v.vehicle_id = f.vehicle_id
JOIN 
    features ft ON f.feature_id = ft.feature_id
WHERE 
    ft.feature_category = 'Safety'
    AND v.model_year = YEAR(CURRENT_DATE)
GROUP BY 
    feature_name
ORDER BY 
    price_difference DESC;
```

### 7. What is the price premium for electric vehicles compared to similar internal combustion models?
```sql
SELECT 
    v1.model_year,
    v1.segment,
    ROUND(AVG(CASE WHEN v1.fuel_type = 'Electric' THEN v1.msrp END), 2) AS avg_ev_price,
    ROUND(AVG(CASE WHEN v1.fuel_type IN ('Gasoline', 'Diesel') THEN v1.msrp END), 2) AS avg_ice_price,
    ROUND(AVG(CASE WHEN v1.fuel_type = 'Electric' THEN v1.msrp END) - 
          AVG(CASE WHEN v1.fuel_type IN ('Gasoline', 'Diesel') THEN v1.msrp END), 2) AS ev_premium
FROM 
    vehicle_sales v1
WHERE 
    v1.model_year BETWEEN YEAR(CURRENT_DATE) - 5 AND YEAR(CURRENT_DATE)
GROUP BY 
    v1.model_year, v1.segment
HAVING 
    AVG(CASE WHEN v1.fuel_type = 'Electric' THEN v1.msrp END) IS NOT NULL
    AND AVG(CASE WHEN v1.fuel_type IN ('Gasoline', 'Diesel') THEN v1.msrp END) IS NOT NULL
ORDER BY 
    v1.segment, v1.model_year;
```

### 8. How has the price of vehicles with autonomous driving features evolved over time?
```sql
SELECT 
    v.model_year,
    COUNT(DISTINCT v.vehicle_id) AS total_vehicles_with_autonomy,
    ROUND(AVG(v.msrp), 2) AS avg_price,
    ROUND(MIN(v.msrp), 2) AS min_price,
    ROUND(MAX(v.msrp), 2) AS max_price
FROM 
    vehicle_sales v
JOIN 
    vehicle_features vf ON v.vehicle_id = vf.vehicle_id
JOIN 
    features f ON vf.feature_id = f.feature_id
WHERE 
    f.feature_name LIKE '%Autonomous%' OR f.feature_name LIKE '%Self-Driving%'
GROUP BY 
    v.model_year
ORDER BY 
    v.model_year;
```

## Consumer Demand Analysis

### 9. What is the relationship between sales volume and price for different vehicle segments?
```sql
SELECT 
    segment,
    model_year,
    ROUND(AVG(msrp), 2) AS avg_price,
    SUM(sales_volume) AS total_sales,
    CORR(msrp, sales_volume) AS price_sales_correlation
FROM 
    vehicle_sales
WHERE 
    model_year BETWEEN YEAR(CURRENT_DATE) - 5 AND YEAR(CURRENT_DATE)
GROUP BY 
    segment, model_year
ORDER BY 
    segment, model_year;
```

### 10. How has the market share (by sales volume) of SUVs evolved compared to sedans, and how has this affected their prices?
```sql
WITH SegmentShares AS (
    SELECT 
        model_year,
        segment,
        SUM(sales_volume) AS segment_sales,
        SUM(SUM(sales_volume)) OVER (PARTITION BY model_year) AS total_sales,
        ROUND(AVG(msrp), 2) AS avg_price
    FROM 
        vehicle_sales
    WHERE 
        segment IN ('SUV', 'Sedan')
        AND model_year BETWEEN YEAR(CURRENT_DATE) - 10 AND YEAR(CURRENT_DATE)
    GROUP BY 
        model_year, segment
)
SELECT 
    model_year,
    segment,
    segment_sales,
    ROUND((segment_sales / total_sales) * 100, 2) AS market_share_pct,
    avg_price,
    ROUND((avg_price - LAG(avg_price) OVER (PARTITION BY segment ORDER BY model_year)) / 
          LAG(avg_price) OVER (PARTITION BY segment ORDER BY model_year) * 100, 2) AS yoy_price_change_pct
FROM 
    SegmentShares
ORDER BY 
    segment, model_year;
```

### 11. Which manufacturers have seen the highest price increases over the past 5 years?
```sql
WITH YearlyPrices AS (
    SELECT 
        manufacturer,
        model_year,
        ROUND(AVG(msrp), 2) AS avg_price
    FROM 
        vehicle_sales
    WHERE 
        model_year BETWEEN YEAR(CURRENT_DATE) - 5 AND YEAR(CURRENT_DATE)
    GROUP BY 
        manufacturer, model_year
)
SELECT 
    manufacturer,
    MIN(CASE WHEN model_year = YEAR(CURRENT_DATE) - 5 THEN avg_price END) AS price_5_years_ago,
    MAX(CASE WHEN model_year = YEAR(CURRENT_DATE) THEN avg_price END) AS current_price,
    ROUND((MAX(CASE WHEN model_year = YEAR(CURRENT_DATE) THEN avg_price END) - 
           MIN(CASE WHEN model_year = YEAR(CURRENT_DATE) - 5 THEN avg_price END)) / 
          MIN(CASE WHEN model_year = YEAR(CURRENT_DATE) - 5 THEN avg_price END) * 100, 2) AS price_increase_pct
FROM 
    YearlyPrices
GROUP BY 
    manufacturer
HAVING 
    price_5_years_ago IS NOT NULL AND current_price IS NOT NULL
ORDER BY 
    price_increase_pct DESC;
```

## Feature and Specification Analysis

### 12. How does engine horsepower correlate with vehicle price across different segments?
```sql
SELECT 
    segment,
    ROUND(AVG(horsepower), 0) AS avg_horsepower,
    ROUND(AVG(msrp), 2) AS avg_price,
    ROUND(CORR(horsepower, msrp), 4) AS horsepower_price_correlation
FROM 
    vehicle_sales v
JOIN 
    vehicle_specifications s ON v.vehicle_id = s.vehicle_id
WHERE 
    model_year = YEAR(CURRENT_DATE)
GROUP BY 
    segment
ORDER BY 
    horsepower_price_correlation DESC;
```

### 13. What is the price premium for each additional feature in luxury vehicles versus economy vehicles?
```sql
WITH FeatureCounts AS (
    SELECT 
        v.vehicle_id,
        v.msrp,
        v.segment,
        COUNT(vf.feature_id) AS feature_count,
        CASE 
            WHEN v.segment IN ('Luxury Sedan', 'Luxury SUV', 'Luxury Coupe') THEN 'Luxury'
            ELSE 'Economy' 
        END AS vehicle_class
    FROM 
        vehicle_sales v
    LEFT JOIN 
        vehicle_features vf ON v.vehicle_id = vf.vehicle_id
    WHERE 
        v.model_year = YEAR(CURRENT_DATE)
    GROUP BY 
        v.vehicle_id, v.msrp, v.segment
)
SELECT 
    vehicle_class,
    ROUND(AVG(feature_count), 1) AS avg_feature_count,
    ROUND(AVG(msrp), 2) AS avg_price,
    ROUND(
        (REGR_SLOPE(msrp, feature_count) * 
        (AVG(feature_count) + 1) + REGR_INTERCEPT(msrp, feature_count)) - 
        (REGR_SLOPE(msrp, feature_count) * 
        AVG(feature_count) + REGR_INTERCEPT(msrp, feature_count))
    , 2) AS price_per_additional_feature
FROM 
    FeatureCounts
GROUP BY 
    vehicle_class
ORDER BY 
    vehicle_class;
```

### 14. How does fuel efficiency impact the pricing of vehicles within the same segment?
```sql
SELECT 
    segment,
    NTILE(4) OVER (PARTITION BY segment ORDER BY mpg) AS efficiency_quartile,
    ROUND(AVG(mpg), 1) AS avg_mpg,
    COUNT(vehicle_id) AS vehicle_count,
    ROUND(AVG(msrp), 2) AS avg_price
FROM 
    vehicle_sales v
JOIN 
    vehicle_specifications s ON v.vehicle_id = s.vehicle_id
WHERE 
    fuel_type IN ('Gasoline', 'Diesel', 'Hybrid')
    AND model_year = YEAR(CURRENT_DATE)
GROUP BY 
    segment, efficiency_quartile
ORDER BY 
    segment, efficiency_quartile;
```

## Temporal Analysis

### 15. What is the average annual price increase rate for each vehicle segment over the past decade?
```sql
WITH YearlyPrices AS (
    SELECT 
        segment, 
        model_year,
        ROUND(AVG(msrp), 2) AS avg_price
    FROM 
        vehicle_sales
    WHERE 
        model_year BETWEEN YEAR(CURRENT_DATE) - 10 AND YEAR(CURRENT_DATE)
    GROUP BY 
        segment, model_year
)
SELECT 
    segment,
    ROUND(
        EXP(
            REGR_SLOPE(LN(avg_price), model_year) * 
            (MAX(model_year) - MIN(model_year))
        ) - 1
    , 4) * 100 AS compound_annual_growth_rate_pct,
    MIN(avg_price) AS starting_price,
    MAX(avg_price) AS ending_price
FROM 
    YearlyPrices
GROUP BY 
    segment
ORDER BY 
    compound_annual_growth_rate_pct DESC;
```

### 16. How do vehicle prices fluctuate seasonally within a year?
```sql
SELECT 
    EXTRACT(MONTH FROM sale_date) AS month,
    segment,
    ROUND(AVG(sale_price), 2) AS avg_sale_price,
    ROUND(AVG(sale_price / msrp) * 100, 2) AS avg_pct_of_msrp
FROM 
    vehicle_transactions t
JOIN 
    vehicle_sales v ON t.vehicle_id = v.vehicle_id
WHERE 
    EXTRACT(YEAR FROM sale_date) = YEAR(CURRENT_DATE) - 1
GROUP BY 
    EXTRACT(MONTH FROM sale_date), segment
ORDER BY 
    segment, month;
```

## Market Segmentation Analysis

### 17. How do prices vary across different geographical regions for the same vehicle models?
```sql
SELECT 
    r.region_name,
    v.segment,
    ROUND(AVG(t.sale_price), 2) AS avg_sale_price,
    ROUND(
        AVG(t.sale_price) / 
        (SELECT AVG(t2.sale_price) 
         FROM vehicle_transactions t2 
         JOIN vehicle_sales v2 ON t2.vehicle_id = v2.vehicle_id 
         WHERE v2.segment = v.segment AND EXTRACT(YEAR FROM t2.sale_date) = YEAR(CURRENT_DATE) - 1)
    , 4) * 100 AS relative_price_index
FROM 
    vehicle_transactions t
JOIN 
    vehicle_sales v ON t.vehicle_id = v.vehicle_id
JOIN 
    dealerships d ON t.dealership_id = d.dealership_id
JOIN 
    regions r ON d.region_id = r.region_id
WHERE 
    EXTRACT(YEAR FROM t.sale_date) = YEAR(CURRENT_DATE) - 1
GROUP BY 
    r.region_name, v.segment
ORDER BY 
    v.segment, relative_price_index DESC;
```

### 18. Which vehicle segments have the highest and lowest price variability?
```sql
SELECT 
    segment,
    COUNT(vehicle_id) AS model_count,
    ROUND(MIN(msrp), 2) AS min_price,
    ROUND(MAX(msrp), 2) AS max_price,
    ROUND(AVG(msrp), 2) AS avg_price,
    ROUND(STDDEV(msrp), 2) AS price_std_dev,
    ROUND(STDDEV(msrp) / AVG(msrp) * 100, 2) AS coefficient_of_variation
FROM 
    vehicle_sales
WHERE 
    model_year = YEAR(CURRENT_DATE)
GROUP BY 
    segment
ORDER BY 
    coefficient_of_variation DESC;
```

## Manufacturer Analysis

### 19. How do price trends differ among domestic versus foreign manufacturers?
```sql
SELECT 
    model_year,
    manufacturer_origin,
    ROUND(AVG(msrp), 2) AS avg_price,
    COUNT(DISTINCT manufacturer) AS manufacturer_count,
    COUNT(vehicle_id) AS model_count
FROM 
    vehicle_sales v
JOIN 
    manufacturers m ON v.manufacturer = m.manufacturer_name
WHERE 
    model_year BETWEEN YEAR(CURRENT_DATE) - 10 AND YEAR(CURRENT_DATE)
GROUP BY 
    model_year, manufacturer_origin
ORDER BY 
    model_year, manufacturer_origin;
```

### 20. What is the relationship between a manufacturer's market share and their average vehicle price?
```sql
WITH ManufacturerData AS (
    SELECT 
        v.manufacturer,
        SUM(v.sales_volume) AS total_sales,
        ROUND(AVG(v.msrp), 2) AS avg_price,
        (SELECT SUM(sales_volume) FROM vehicle_sales WHERE model_year = YEAR(CURRENT_DATE)) AS market_total
    FROM 
        vehicle_sales v
    WHERE 
        v.model_year = YEAR(CURRENT_DATE)
    GROUP BY 
        v.manufacturer
)
SELECT 
    manufacturer,
    total_sales,
    ROUND((total_sales / market_total) * 100, 2) AS market_share_pct,
    avg_price,
    NTILE(4) OVER (ORDER BY (total_sales / market_total)) AS market_share_quartile,
    NTILE(4) OVER (ORDER BY avg_price) AS price_quartile
FROM 
    ManufacturerData
ORDER BY 
    market_share_pct DESC;
```

## Advanced Analysis

### 21. What combination of features provides the highest return on investment in terms of resale value?
```sql
WITH ResaleData AS (
    SELECT 
        v.vehicle_id,
        v.model_name,
        v.msrp AS original_price,
        MAX(t.sale_price) AS resale_price,
        DATEDIFF(MAX(t.sale_date), MIN(t.sale_date)) / 365.0 AS age_in_years,
        ROUND((MAX(t.sale_price) / v.msrp) * 100, 2) AS value_retention_pct,
        f.feature_name
    FROM 
        vehicle_sales v
    JOIN 
        vehicle_transactions t ON v.vehicle_id = t.vehicle_id
    JOIN 
        vehicle_features vf ON v.vehicle_id = vf.vehicle_id
    JOIN 
        features f ON vf.feature_id = f.feature_id
    WHERE 
        t.transaction_type = 'Used'
    GROUP BY 
        v.vehicle_id, v.model_name, v.msrp, f.feature_name
    HAVING 
        age_in_years BETWEEN 3 AND 5
)
SELECT 
    feature_name,
    COUNT(DISTINCT vehicle_id) AS vehicle_count,
    ROUND(AVG(value_retention_pct), 2) AS avg_value_retention_pct,
    ROUND(AVG(resale_price), 2) AS avg_resale_price
FROM 
    ResaleData
GROUP BY 
    feature_name
HAVING 
    COUNT(DISTINCT vehicle_id) > 10
ORDER BY 
    avg_value_retention_pct DESC
LIMIT 20;
```

### 22. Which vehicle models have defied the typical depreciation curve?
```sql
WITH DepreciationRates AS (
    SELECT 
        v.segment,
        v.model_name,
        v.manufacturer,
        v.msrp AS original_price,
        AVG(t.sale_price) AS avg_resale_price,
        DATEDIFF(AVG(t.sale_date), MIN(v.model_year)) / 365.0 AS avg_age_in_years,
        (1 - (AVG(t.sale_price) / v.msrp)) / (DATEDIFF(AVG(t.sale_date), MIN(v.model_year)) / 365.0) AS yearly_depreciation_rate,
        AVG((SELECT AVG((1 - (t2.sale_price / v2.msrp)) / (DATEDIFF(t2.sale_date, v2.model_year) / 365.0))
             FROM vehicle_transactions t2
             JOIN vehicle_sales v2 ON t2.vehicle_id = v2.vehicle_id
             WHERE v2.segment = v.segment
             AND t2.transaction_type = 'Used')) AS segment_avg_depreciation_rate
    FROM 
        vehicle_sales v
    JOIN 
        vehicle_transactions t ON v.vehicle_id = t.vehicle_id
    WHERE 
        t.transaction_type = 'Used'
    GROUP BY 
        v.segment, v.model_name, v.manufacturer, v.msrp
    HAVING 
        COUNT(t.transaction_id) > 5
        AND avg_age_in_years BETWEEN 1 AND 10
)
SELECT 
    segment,
    model_name,
    manufacturer,
    original_price,
    avg_resale_price,
    ROUND(avg_age_in_years, 1) AS avg_age_in_years,
    ROUND(yearly_depreciation_rate * 100, 2) AS yearly_depreciation_pct,
    ROUND(segment_avg_depreciation_rate * 100, 2) AS segment_avg_depreciation_pct,
    ROUND((segment_avg_depreciation_rate - yearly_depreciation_rate) * 100, 2) AS depreciation_advantage_pct
FROM 
    DepreciationRates
WHERE 
    yearly_depreciation_rate < segment_avg_depreciation_rate
ORDER BY 
    depreciation_advantage_pct DESC
LIMIT 20;
```

### 23. How does the price elasticity of demand vary across different vehicle segments?
```sql
WITH PriceChanges AS (
    SELECT 
        v1.segment,
        v1.model_year AS year1,
        v2.model_year AS year2,
        AVG(v1.msrp) AS price1,
        AVG(v2.msrp) AS price2,
        SUM(v1.sales_volume) AS quantity1,
        SUM(v2.sales_volume) AS quantity2
    FROM 
        vehicle_sales v1
    JOIN 
        vehicle_sales v2 ON v1.segment = v2.segment AND v2.model_year = v1.model_year + 1
    WHERE 
        v1.model_year BETWEEN YEAR(CURRENT_DATE) - 10 AND YEAR(CURRENT_DATE) - 1
    GROUP BY 
        v1.segment, v1.model_year, v2.model_year
)
SELECT 
    segment,
    ROUND(AVG(
        ((quantity2 - quantity1) / quantity1) / 
        ((price2 - price1) / price1)
    ), 2) AS avg_price_elasticity,
    CASE 
        WHEN AVG(((quantity2 - quantity1) / quantity1) / ((price2 - price1) / price1)) < -1 THEN 'Elastic'
        WHEN AVG(((quantity2 - quantity1) / quantity1) / ((price2 - price1) / price1)) BETWEEN -1 AND 0 THEN 'Inelastic'
        ELSE 'Abnormal'
    END AS elasticity_type
FROM 
    PriceChanges
WHERE 
    price1 <> price2  -- Avoid division by zero
GROUP BY 
    segment
ORDER BY 
    avg_price_elasticity;
```

### 24. How has the "feature inflation" phenomenon (increasing standard features) contributed to price increases?
```sql
WITH YearlyFeatures AS (
    SELECT 
        v.model_year,
        v.segment,
        ROUND(AVG(v.msrp), 2) AS avg_price,
        AVG(feature_count.count) AS avg_feature_count
    FROM 
        vehicle_sales v
    JOIN (
        SELECT 
            vehicle_id, 
            COUNT(feature_id) AS count
        FROM 
            vehicle_features
        GROUP BY 
            vehicle_id
    ) feature_count ON v.vehicle_id = feature_count.vehicle_id
    WHERE 
        v.model_year BETWEEN YEAR(CURRENT_DATE) - 10 AND YEAR(CURRENT_DATE)
    GROUP BY 
        v.model_year, v.segment
)
SELECT 
    segment,
    MIN(model_year) AS start_year,
    MAX(model_year) AS end_year,
    MIN(avg_price) AS start_price,
    MAX(avg_price) AS end_price,
    ROUND((MAX(avg_price) - MIN(avg_price)) / MIN(avg_price) * 100, 2) AS price_increase_pct,
    MIN(avg_feature_count) AS start_feature_count,
    MAX(avg_feature_count) AS end_feature_count,
    ROUND(MAX(avg_feature_count) - MIN(avg_feature_count), 1) AS feature_count_increase,
    ROUND((MAX(avg_price) - MIN(avg_price)) / (MAX(avg_feature_count) - MIN(avg_feature_count)), 2) AS price_per_added_feature
FROM 
    YearlyFeatures
GROUP BY 
    segment
HAVING 
    MAX(avg_feature_count) > MIN(avg_feature_count)
ORDER BY 
    price_per_added_feature DESC;
```

### 25. What factors best predict whether a vehicle will maintain its value over time?
```sql
WITH ResaleFactors AS (
    SELECT 
        v.vehicle_id,
        v.manufacturer,
        v.segment,
        v.model_name,
        v.fuel_type,
        s.horsepower,
        s.mpg,
        v.msrp AS original_price,
        MAX(t.sale_price) AS last_resale_price,
        DATEDIFF(MAX(t.sale_date), MIN(v.model_year)) / 365.0 AS age_in_years,
        COUNT(DISTINCT f.feature_id) AS feature_count,
        (MAX(t.sale_price) / v.msrp) * 100 AS value_retention_pct
    FROM 
        vehicle_sales v
    JOIN 
        vehicle_transactions t ON v.vehicle_id = t.vehicle_id
    JOIN 
        vehicle_specifications s ON v.vehicle_id = s.vehicle_id
    LEFT JOIN 
        vehicle_features vf ON v.vehicle_id = vf.vehicle_id
    LEFT JOIN 
        features f ON vf.feature_id = f.feature_id
    WHERE 
        t.transaction_type = 'Used'
    GROUP BY 
        v.vehicle_id, v.manufacturer, v.segment, v.model_name, v.fuel_type, 
        s.horsepower, s.mpg, v.msrp
    HAVING 
        age_in_years BETWEEN 3 AND 7
)
SELECT 
    factor,
    COUNT(*) AS vehicle_count,
    ROUND(AVG(value_retention_pct), 2) AS avg_value_retention_pct,
    ROUND(CORR(value_metric, value_retention_pct), 4) AS correlation_with_retention
FROM (
    SELECT *, 'Segment' AS factor, segment AS factor_value, 0 AS value_metric FROM ResaleFactors
    UNION ALL
    SELECT *, 'Manufacturer' AS factor, manufacturer AS factor_value, 0 AS value_metric FROM ResaleFactors
    UNION ALL
    SELECT *, 'Fuel Type' AS factor, fuel_type AS factor_value, 0 AS value_metric FROM ResaleFactors
    UNION ALL
    SELECT *, 'Horsepower' AS factor, NULL AS factor_value, horsepower AS value_metric FROM ResaleFactors
    UNION ALL
    SELECT *, 'MPG' AS factor, NULL AS factor_value, mpg AS value_metric FROM ResaleFactors
    UNION ALL
    SELECT *, 'Original Price' AS factor, NULL AS factor_value, original_price AS value_metric FROM ResaleFactors
    UNION ALL
    SELECT *, 'Feature Count' AS factor, NULL AS factor_value, feature_count AS value_metric FROM ResaleFactors
) AS factors
GROUP BY 
    factor
ORDER BY 
    ABS(correlation_with_retention) DESC;
```
