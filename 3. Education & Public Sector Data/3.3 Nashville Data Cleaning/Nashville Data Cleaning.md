# SQL Data Cleaning Project: Nashville Housing Data

## Project Overview
This SQL script performs comprehensive data cleaning on the Nashville housing dataset, demonstrating various data cleaning techniques and SQL skills including:
- Standardizing date formats
- Populating missing data
- Splitting columns
- Handling categorical values
- Removing duplicates
- Dropping unnecessary columns

## Data Cleaning Steps

### 1. Standardize Date Format
```sql
SELECT `Sale Date` 
FROM nashville_housing;

-- Convert to proper date format
SELECT `Sale Date`, CONVERT(`Sale Date`, DATE)
FROM nashville_housing;

UPDATE nashville_housing 
SET `Sale Date` = CONVERT(`Sale Date`, DATE);
```

### 2. Populate Missing Property Address Data
```sql
-- Identify null property addresses
SELECT * 
FROM nashville_housing
WHERE `Property Address` IS NULL
ORDER BY `Parcel ID`;

-- Self-join to find matching parcel IDs with addresses
SELECT 
    a.`Parcel ID`,
    a.`Property Address`,
    b.`Parcel ID`,
    b.`Property Address`,
    IFNULL(a.`Property Address`, b.`Property Address`) AS `Address To Be Filled`
FROM nashville_housing a
JOIN nashville_housing b
    ON a.`Parcel ID` = b.`Parcel ID` 
    AND a.Column1 != b.Column1 
WHERE a.`Property Address` IS NULL;

-- Update null addresses with matching parcel ID addresses
UPDATE a 
SET a.`Property Address` = IFNULL(a.`Property Address`, b.`Property Address`)
FROM nashville_housing a
JOIN nashville_housing b
    ON a.`Parcel ID` = b.`Parcel ID` 
    AND a.Column1 != b.Column1 
WHERE a.`Property Address` IS NULL;
```

### 3. Split Address into Individual Columns
```sql
-- Split Property Address into Address and City
SELECT 
    SUBSTRING(`Property Address`, 1, LOCATE(',', `Property Address`) - 1) AS Address,
    SUBSTRING(`Property Address`, LOCATE(',', `Property Address`) + 1, LENGTH(`Property Address`)) AS City
FROM nashville_housing;

-- Add new columns and populate them
ALTER TABLE nashville_housing 
ADD `Property Split Address` VARCHAR(255);

UPDATE nashville_housing 
SET `Property Split Address` = SUBSTRING(`Property Address`, 1, LOCATE(',', `Property Address`) - 1);

ALTER TABLE nashville_housing 
ADD `Property City` VARCHAR(255);

UPDATE nashville_housing 
SET `Property City` = SUBSTRING(`Property Address`, LOCATE(',', `Property Address`) + 1, LENGTH(`Property Address`));

-- Create function to split Owner Address
CREATE FUNCTION SPLIT_STR(
  x VARCHAR(255),
  delim VARCHAR(12),
  pos INT
)
RETURN VARCHAR(255)
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
       LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
       delim, '');

-- Split Owner Address into Address, City, State
SELECT
    SPLIT_STR(`Owner Address`, ',', 1),
    SPLIT_STR(`Owner Address`, ',', 2),
    SPLIT_STR(`Owner Address`, ',', 3)
FROM nashville_housing;

-- Add and populate new columns
ALTER TABLE nashville_housing 
ADD `Owner Split Address` VARCHAR(255);

UPDATE nashville_housing 
SET `Owner Split Address` = SPLIT_STR(`Owner Address`, ',', 1);

ALTER TABLE nashville_housing 
ADD `Owner City` VARCHAR(255);

UPDATE nashville_housing 
SET `Owner City` = SPLIT_STR(`Owner Address`, ',', 2);

ALTER TABLE nashville_housing 
ADD `Owner State` VARCHAR(255);

UPDATE nashville_housing 
SET `Owner State` = SPLIT_STR(`Owner Address`, ',', 3);
```

### 4. Standardize "Sold as Vacant" Field
```sql
-- Check current values and counts
SELECT DISTINCT(`Sold As Vacant`), COUNT(`Sold As Vacant`) 
FROM nashville_housing 
GROUP BY `Sold As Vacant` 
ORDER BY `Sold As Vacant`;

-- Convert Y/N to Yes/No
SELECT `Sold As Vacant`,
CASE 
    WHEN `Sold As Vacant` = 'Y' THEN 'Yes'
    WHEN `Sold As Vacant` = 'N' THEN 'No'
    ELSE `Sold As Vacant`
END AS standardized
FROM nashville_housing;

UPDATE nashville_housing 
SET `Sold As Vacant` = CASE 
    WHEN `Sold As Vacant` = 'Y' THEN 'Yes'
    WHEN `Sold As Vacant` = 'N' THEN 'No'
    ELSE `Sold As Vacant`
END;
```

### 5. Remove Duplicates
```sql
-- Identify duplicates using CTE
WITH RowNumCTE AS (
    SELECT *, 
        ROW_NUMBER() OVER(
            PARTITION BY
                `Parcel ID`,
                `Property Address`,
                `Sale Price`, 
                `Sale Date`,
                `Legal Reference`
            ORDER BY Column1
        ) row_num
    FROM nashville_housing
)
-- Delete duplicate rows
DELETE FROM RowNumCTE
WHERE row_num > 1;
```

### 6. Delete Unused Columns
```sql
-- Remove columns that have been split or are no longer needed
ALTER TABLE nashville_housing 
DROP COLUMN `Owner Address`, 
DROP COLUMN `Tax District`, 
DROP COLUMN `Property Address`, 
DROP COLUMN `Sale Date`;
```

## Key SQL Skills Demonstrated
1. **Data Type Conversion**: Converting date formats
2. **Handling NULL Values**: Populating missing addresses
3. **String Manipulation**: Splitting address columns
4. **User-Defined Functions**: Creating a string splitting function
5. **Data Standardization**: Converting Y/N to Yes/No
6. **Duplicate Management**: Identifying and removing duplicates
7. **Schema Modification**: Adding and dropping columns

This comprehensive cleaning process ensures the Nashville housing data is properly structured, consistent, and ready for analysis.