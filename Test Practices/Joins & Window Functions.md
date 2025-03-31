# SQL JOIN Types and Window Functions Explanation

## Question #4: Different Types of JOINs

The SQL demonstrates several types of JOIN operations:

1. **INNER JOIN**: Returns only matching rows from both tables
   ```sql
   select cr.country_name, ct.continent_name
   from continents ct
   inner join countries cr on ct.continent_code = cr.continent_code;
   ```

2. **LEFT JOIN (LEFT OUTER JOIN)**: Returns all rows from the left table and matching rows from the right table
   ```sql
   select cr.country_name, ct.continent_name
   from continents ct
   left join countries cr on ct.continent_code = cr.continent_code;
   ```

3. **RIGHT JOIN (RIGHT OUTER JOIN)**: Returns all rows from the right table and matching rows from the left table
   ```sql
   select cr.country_name, ct.continent_name
   from continents ct
   right join countries cr on ct.continent_code = cr.continent_code;
   ```

4. **FULL OUTER JOIN**: Returns all rows when there's a match in either table
   ```sql
   select cr.country_name, ct.continent_name
   from continents ct
   full outer join countries cr on ct.continent_code = cr.continent_code;
   ```

5. **NATURAL JOIN**: Joins tables on columns with the same name (not recommended in practice)
   ```sql
   select cr.country_name, ct.continent_name
   from continents ct
   natural join countries cr;
   ```

6. **CROSS JOIN**: Returns Cartesian product of both tables (all possible combinations)
   ```sql
   select cr.country_name, ct.continent_name
   from continents ct
   CROSS join countries cr;
   ```

7. **SELF JOIN**: Joins a table to itself (though the example has a logical error)
   ```sql
   select cr1.country_name
   from countries cr1
   inner join countries cr2 on cr1.country_code = cr2.continent_code;
   ```

## Question #8: RANK, DENSE_RANK, and ROW_NUMBER

These window functions are used for ranking rows with subtle differences:

```sql
SELECT *
    , RANK() OVER(ORDER BY salary DESC) AS ranks
    , DENSE_RANK() OVER(ORDER BY salary DESC) AS dense_ranks
    , ROW_NUMBER() OVER(ORDER BY salary DESC) AS row_numbers
FROM managers;
```

- **RANK()**: Assigns the same rank to rows with equal values, leaving gaps in the ranking sequence
  - Example: 1, 2, 2, 4, 5

- **DENSE_RANK()**: Assigns the same rank to rows with equal values, but doesn't leave gaps
  - Example: 1, 2, 2, 3, 4

- **ROW_NUMBER()**: Assigns a unique sequential number to each row, even if values are equal
  - Example: 1, 2, 3, 4, 5

The example data would produce:
```
id | name   | salary | ranks | dense_ranks | row_numbers
1  | Jeff   | 8000   | 1     | 1           | 1
2  | Elon   | 5000   | 2     | 2           | 2
3  | Mukesh | 5000   | 2     | 2           | 3
4  | Warren | 4000   | 4     | 3           | 4
6  | Bill   | 2000   | 5     | 4           | 5
```

Note that there's a typo in the FULL OUTER JOIN example ("country_name" is misspelled as "country_name").
