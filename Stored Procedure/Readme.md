# How to List Procedures in PostgreSQL: Complete Guide

## **Table of Contents**
1. [Prerequisites](#prerequisites)
2. [Method 1: SQL Query (Most Flexible)](#method-1-sql-query)
3. [Method 2: psql Commands (Quick CLI)](#method-2-psql-commands)
4. [Method 3: Information Schema (Standard Compliant)](#method-3-information-schema)
5. [Method 4: Filtering Specific Procedures](#method-4-filtering)
6. [Method 5: View Procedure Definitions](#method-5-view-definitions)
7. [Bonus: Export Procedures to File](#bonus-export)
8. [Automated Script for Documentation](#automated-script)

## **Prerequisites**
```sql
-- Ensure you have:
-- 1. PostgreSQL 11+ (procedures introduced in v11)
-- 2. Sufficient privileges (USAGE on schema + EXECUTE)
-- 3. Sample procedures for testing (run these first if needed)
CREATE OR REPLACE PROCEDURE public.sample_proc1()
LANGUAGE plpgsql
AS $$ BEGIN RAISE NOTICE 'Test procedure 1'; END; $$;

CREATE OR REPLACE FUNCTION public.sample_func1()
RETURNS void
LANGUAGE plpgsql
AS $$ BEGIN RAISE NOTICE 'Test function 1'; END; $$;
```
<img width="1919" height="1139" alt="image" src="https://github.com/user-attachments/assets/c7c84369-d36b-4bb7-8386-059b0206ea6a" />


## **Method 1: SQL Query (Most Flexible)**
```sql
-- Basic list of all procedures in current database
SELECT
    n.nspname AS schema_name,
    p.proname AS procedure_name,
    CASE
        WHEN p.prokind = 'p' THEN 'PROCEDURE'
        WHEN p.prokind = 'f' THEN 'FUNCTION'
        ELSE p.prokind
    END AS object_type,
    pg_get_function_arguments(p.oid) AS arguments,
    pg_get_function_result(p.oid) AS return_type,
    l.lanname AS language,
    p.prosrc AS source_code
FROM
    pg_proc p
LEFT JOIN
    pg_namespace n ON p.pronamespace = n.oid
LEFT JOIN
    pg_language l ON p.prolang = l.oid
WHERE
    n.nspname NOT LIKE 'pg_%'  -- Exclude system schemas
    AND n.nspname != 'information_schema'
    AND p.proname NOT LIKE 'pg_%'  -- Exclude system functions
ORDER BY
    n.nspname, p.proname;

-- For procedures only (PostgreSQL 11+)
SELECT
    n.nspname AS schema_name,
    p.proname AS procedure_name,
    pg_get_function_arguments(p.oid) AS arguments,
    l.lanname AS language
FROM
    pg_proc p
JOIN
    pg_namespace n ON p.pronamespace = n.oid
JOIN
    pg_language l ON p.prolang = l.oid
WHERE
    p.prokind = 'p'  -- 'p' = procedure, 'f' = function
    AND n.nspname = 'public'  -- Filter by schema
ORDER BY
    p.proname;
```

**Sample Output:**
| schema_name | procedure_name | object_type | arguments | return_type | language | source_code |
|-------------|-----------------|-------------|-----------|-------------|----------|-------------|
| public      | sample_proc1    | PROCEDURE   |           | void        | plpgsql  | BEGIN...    |

<img width="1919" height="1141" alt="image" src="https://github.com/user-attachments/assets/d7f07b64-2d3e-429d-9024-ef2df81ec7ef" />

## **Method 2: psql Commands (Quick CLI)**
```bash
# Connect to your database
psql -U your_username -d your_database

# List all functions/procedures
\df

# List with more details
\df+

# For procedures only (PostgreSQL 11+)
\dfS p

# Filter by schema
\df public.*

# Search by name pattern
\df *proc*
```

---
## **Method 3: Information Schema (Standard Compliant)**
```sql
-- SQL standard compliant view
SELECT
    routine_schema,
    routine_name,
    routine_type,
    data_type AS return_type,
    routine_definition
FROM
    information_schema.routines
WHERE
    routine_schema = 'public'
    AND routine_type = 'PROCEDURE'  -- Use 'FUNCTION' for functions
ORDER BY
    routine_name;
```

---
## **Method 4: Filtering Specific Procedures**
```sql
-- Find procedures with specific parameters
SELECT
    n.nspname AS schema_name,
    p.proname AS procedure_name,
    pg_get_function_arguments(p.oid) AS arguments
FROM
    pg_proc p
JOIN
    pg_namespace n ON p.pronamespace = n.oid
WHERE
    p.prokind = 'p'
    AND pg_get_function_arguments(p.oid) LIKE '%integer%'  -- Filter by parameter type
ORDER BY
    p.proname;

-- Find procedures modified recently
SELECT
    n.nspname AS schema_name,
    p.proname AS procedure_name,
    p.proacl AS permissions,
    p.proconfig AS settings,
    pg_get_userbyid(p.proowner) AS owner
FROM
    pg_proc p
JOIN
    pg_namespace n ON p.pronamespace = n.oid
WHERE
    p.prokind = 'p'
    AND p.prolastmod > current_date - INTERVAL '30 days'
ORDER BY
    p.prolastmod DESC;
```

---
## **Method 5: View Procedure Definitions**
```sql
-- Get full definition of a specific procedure
SELECT
    pg_get_functiondef(p.oid) AS definition
FROM
    pg_proc p
JOIN
    pg_namespace n ON p.pronamespace = n.oid
WHERE
    p.proname = 'your_procedure_name'
    AND n.nspname = 'public';

-- Alternative with more details
SELECT
    p.proname AS name,
    pg_get_functiondef(p.oid) AS definition,
    pg_get_function_arguments(p.oid) AS arguments,
    description AS comment
FROM
    pg_proc p
LEFT JOIN
    pg_description d ON p.oid = d.objoid
LEFT JOIN
    pg_namespace n ON p.pronamespace = n.oid
WHERE
    p.proname = 'your_procedure_name'
    AND n.nspname = 'public';
```

---
## **Bonus: Export Procedures to File**
```bash
# Export all procedure definitions to a file
psql -U your_username -d your_database -c "
    SELECT pg_get_functiondef(p.oid) || ';' AS definition
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.prokind = 'p'
    AND n.nspname = 'public'
" > procedures_export.sql
```

---
## **Automated Script for Documentation**
```sql
-- Generate Markdown documentation for all procedures
SELECT
    format(
        '## %I.%I%s%s%s%s',
        n.nspname,
        p.proname,
        E'\n\n**Type:** ', CASE WHEN p.prokind = 'p' THEN 'PROCEDURE' ELSE 'FUNCTION' END,
        E'\n\n**Arguments:** ', pg_get_function_arguments(p.oid),
        E'\n\n**Returns:** ', pg_get_function_result(p.oid),
        E'\n\n**Definition:**\n```sql\n',
        pg_get_functiondef(p.oid),
        E'\n```\n\n---\n'
    ) AS markdown_doc
FROM
    pg_proc p
JOIN
    pg_namespace n ON p.pronamespace = n.oid
WHERE
    p.prokind = 'p'
    AND n.nspname = 'public'
ORDER BY
    p.proname;
```

---
## **Troubleshooting**
1. **Permission denied?**
   ```sql
   GRANT USAGE ON SCHEMA public TO your_user;
   GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO your_user;
   ```

2. **Not seeing your procedures?**
   - Verify you're connected to the correct database: `\l` then `\c your_database`
   - Check schema: `SHOW search_path;`

3. **Need more details?**
   ```sql
   -- Show extended information
   \x on  -- Expanded display in psql
   SELECT * FROM pg_proc WHERE proname = 'your_procedure';
   \x off
   ```

---
## **Key Differences: Procedures vs Functions**
| Feature        | Procedure                     | Function                     |
|----------------|-------------------------------|------------------------------|
| Return value   | No return (uses OUT params)   | Returns a value              |
| Call syntax    | `CALL proc()`                 | `SELECT func()`              |
| Transaction    | Can control transactions      | Runs in caller's transaction |
| Created in     | PostgreSQL 11+                | All versions                 |

---
## **Best Practices**
1. **Schema organization**: Use schemas to group related procedures
   ```sql
   CREATE SCHEMA reporting;
   CREATE PROCEDURE reporting.generate_report() ...
   ```

2. **Documentation**: Add comments to your procedures
   ```sql
   COMMENT ON PROCEDURE your_proc() IS 'Generates monthly sales report';
   ```

3. **Regular maintenance**:
   ```sql
   -- Find unused procedures (no dependencies)
   SELECT p.proname
   FROM pg_proc p
   LEFT JOIN pg_depend d ON p.oid = d.objid
   WHERE p.prokind = 'p'
   AND d.objid IS NULL;
   ```

---
## **GUI Tools Alternative**
If you prefer visual tools:
1. **pgAdmin**: Object browser → Procedures
2. **DBeaver**: Database → Procedures filter
3. **ERBuilder**: Reverse engineer → View procedures (as mentioned in original article)

---
## **Performance Considerations**
For large databases with many procedures:
```sql
-- Create a materialized view for frequent access
CREATE MATERIALIZED VIEW procedure_catalog AS
SELECT
    n.nspname AS schema_name,
    p.proname AS procedure_name,
    p.prokind,
    pg_get_function_arguments(p.oid) AS arguments,
    pg_get_function_result(p.oid) AS return_type,
    pg_get_userbyid(p.proowner) AS owner,
    p.prolastmod AS last_modified
FROM
    pg_proc p
JOIN
    pg_namespace n ON p.pronamespace = n.oid
WHERE
    p.prokind IN ('p', 'f')
    AND n.nspname NOT LIKE 'pg_%';

-- Refresh periodically
REFRESH MATERIALIZED VIEW procedure_catalog;
```

---
### **Final Notes**
- Procedures were introduced in PostgreSQL 11 (2018)
- For versions <11, you'll only see functions
- The `pg_catalog` tables are system tables - don't modify them directly
- Use `\ef procedure_name` in psql to edit a procedure directly
