# Chicago Crime & Weather 2021 Analysis  
*Structured as Question → SQL Query → Result/Solution*

---

### 1. Total Reported Crimes  
**Question**: How many total crimes were reported in 2021?  
**Query**:  
```sql
SELECT count(crime_id) AS "total reported crimes"
FROM crimes;
```  
**Solution**:  
202,536 crimes were reported in 2021.

---

### 2. Violent Crime Breakdown  
**Question**: What is the count of Homicides, Batteries, and Assaults?  
**Query**:  
```sql
SELECT 
    crime_type,
    count(*) AS n_crimes
FROM crimes
WHERE crime_type IN ('homicide', 'battery', 'assault')
GROUP BY crime_type
ORDER BY n_crimes DESC;
```  
**Solution**:  
| Crime Type | Count  |
|------------|--------|
| Battery    | 39,988 |
| Assault    | 20,086 |
| Homicide   | 803    |

---

### 3. Highest Crime Communities  
**Question**: Which 10 communities had the most crimes (with population/density)?  
**Query**:  
```sql
SELECT 
    community_name AS community,
    population,
    density,
    count(*) AS reported_crimes
FROM chicago_crimes
GROUP BY community_name, population, density
ORDER BY reported_crimes DESC
LIMIT 10;
```  
**Solution**:  
Top 3:  
1. **Austin** (11,341 crimes | Pop: 96,557 | Density: 13,504/sq mi)  
2. **Near North Side** (8,126 crimes | Pop: 105,481 | Density: 38,497/sq mi)  
3. **South Shore** (7,272 crimes | Pop: 53,971 | Density: 18,420/sq mi)  

---

### 4. Monthly Crime Trends  
**Question**: Which month had the most crimes?  
**Query**:  
```sql
SELECT
    to_char(CRIME_DATE::timestamp, 'Month') AS month,
    COUNT(*) AS n_crimes
FROM chicago_crimes
GROUP BY month
ORDER BY n_crimes DESC;
```  
**Solution**:  
**October** had the highest crime volume (19,018 crimes).  

---

### 5. Homicide & Temperature  
**Question**: Which month had the most homicides, and what were the temperatures?  
**Query**:  
```sql
SELECT
    to_char(CRIME_DATE, 'Month') AS month,
    COUNT(*) AS n_homicides,
    ROUND(AVG(temp_high), 1) AS avg_high_temp
FROM chicago_crimes
WHERE crime_type = 'homicide'
GROUP BY month
ORDER BY n_homicides DESC;
```  
**Solution**:  
**July** had the most homicides (112) with an average high of **82.6°F**.

---

### 6. Street Crime Hotspots  
**Question**: Which streets had the most reported crimes?  
**Query**:  
```sql
SELECT
    street_name,
    count(*) AS n_crimes
FROM chicago_crimes
GROUP BY street_name
ORDER BY count(*) DESC
LIMIT 5;
```  
**Solution**:  
1. Michigan Ave (3,257 crimes)  
2. State St (2,858 crimes)  
3. Halsted St (2,329 crimes)  

---

### 7. Domestic Violence Percentage  
**Question**: What percentage of crimes were domestic-related?  
**Query**:  
```sql
SELECT
    ROUND(100 * COUNT(*) FILTER (WHERE domestic = true) / COUNT(*)::numeric, 2) 
    AS domestic_percentage
FROM chicago_crimes;
```  
**Solution**:  
**21.8%** of all crimes were domestic-related.

---

### 8. Weather Extremes  
**Question**: How did crime compare on the hottest vs. coldest days?  
**Query**:  
```sql
-- Hottest day (95°F)
SELECT COUNT(*) FROM chicago_crimes WHERE temp_high = 95; 
-- Coldest day (4°F)
SELECT COUNT(*) FROM chicago_crimes WHERE temp_high = 4;
```  
**Solution**:  
- **Hottest day**: 552 crimes  
- **Coldest day**: 402 crimes  

---

### Key Insights  
1. **Geographic**: Austin neighborhood is a high-priority area.  
2. **Temporal**: Crime peaks in warmer months (July-October).  
3. **Prevention**: Michigan Ave needs theft-deterrence strategies.  
4. **Domestic**: Over 1 in 5 crimes involve domestic violence.  
