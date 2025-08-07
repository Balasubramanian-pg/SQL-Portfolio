# SQL Data Dictionary for NYC Schools SAT Performance

## Table: `schools`

| Column Name | Data Type | Description | Example Values | Constraints |
|------------|-----------|-------------|----------------|-------------|
| `school_name` | VARCHAR | Name of the school | "Stuyvesant High School", "Brooklyn Technical High School" | NOT NULL |
| `borough` | VARCHAR | Borough where the school is located | "Manhattan", "Brooklyn", "Queens", "Bronx", "Staten Island" | NOT NULL |
| `building_code` | VARCHAR | Unique code identifying the school building | "M022", "M445", "M056" | NOT NULL |
| `average_math` | INT | Average math SAT score for the school (0-800 scale) | 754, 395, 418 | NOT NULL, CHECK (value BETWEEN 0 AND 800) |
| `average_reading` | INT | Average reading SAT score for the school (0-800 scale) | 693, 411, 428 | NOT NULL, CHECK (value BETWEEN 0 AND 800) |
| `average_writing` | INT | Average writing SAT score for the school (0-800 scale) | 693, 387, 415 | NOT NULL, CHECK (value BETWEEN 0 AND 800) |
| `percent_tested` | NUMERIC | Percentage of eligible students who completed SATs (0-100 scale) | 78.9, 65.1, NULL | NULL allowed, CHECK (value BETWEEN 0 AND 100 OR value IS NULL) |

## Key Relationships:
- Multiple schools may share the same `building_code` (as shown by the data having 375 schools but only 233 unique building codes)
- Each `borough` contains multiple schools

## Important Notes:
1. The SAT score columns (`average_math`, `average_reading`, `average_writing`) are all out of a maximum 800 points
2. The `percent_tested` column contains NULL values for some schools (20 out of 375 records)
3. The combination of `school_name` and `building_code` would likely serve as a composite key to uniquely identify schools

## Sample Query to View Schema:
```sql
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    character_maximum_length
FROM 
    information_schema.columns
WHERE 
    table_name = 'schools';
```
