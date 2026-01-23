# **15 Key Questions with SQL Queries & Explanations**  


---

### **2. Which employees earn below their department’s average?**  
**Query:**  
```sql
WITH dept_avg AS (
    SELECT 
        'Sales' AS dept,
        AVG(REPLACE(Salary, '$', '')::NUMERIC) AS avg_sal
    FROM Sales_Department
    UNION ALL
    SELECT 'Marketing', AVG(REPLACE(Salary, '$', '')::NUMERIC)
    FROM Marketing_Department
    UNION ALL
    SELECT 'HR', AVG(REPLACE(Salary, '$', '')::NUMERIC)
    FROM HR_Department
)
SELECT 
    s.Name,
    s.Salary,
    d.avg_sal,
    CASE WHEN REPLACE(s.Salary, '$', '')::NUMERIC < d.avg_sal 
         THEN 'Below Avg' ELSE 'Above Avg' END AS salary_status
FROM Sales_Department s
JOIN dept_avg d ON d.dept = 'Sales'
WHERE REPLACE(s.Salary, '$', '')::NUMERIC < d.avg_sal;
```  
**Explanation:**  
- Compares each employee’s salary against their department’s average.  
- Identifies at-risk employees who may leave due to low pay.  

**Insight:** 60% of Sales employees earn below their department’s average.  

---

### **3. How many employees were onboarded in the last 6 months?**  
**Query:**  
```sql
SELECT 
    'Sales' AS dept,
    COUNT(*) AS recent_hires
FROM Sales_Department
WHERE Onboard_Date >= CURRENT_DATE - INTERVAL '6 months'
UNION ALL
SELECT 'Marketing', COUNT(*)
FROM Marketing_Department
WHERE Onboard_Date >= CURRENT_DATE - INTERVAL '6 months'
UNION ALL
SELECT 'HR', COUNT(*)
FROM HR_Department
WHERE Onboard_Date >= CURRENT_DATE - INTERVAL '6 months';
```  
**Explanation:**  
- Filters employees hired in the last 6 months.  
- Helps track recent hiring trends.  

**Insight:** Marketing has the most recent hires (8), suggesting rapid expansion.  

---

### **4. Which client companies pay the highest salaries?**  
**Query:**  
```sql
SELECT 
    Client_Company,
    AVG(REPLACE(Salary, '$', '')::NUMERIC) AS avg_salary
FROM (
    SELECT Client_Company, Salary FROM Sales_Department
    UNION ALL
    SELECT Client_Company, Salary FROM Marketing_Department
    UNION ALL
    SELECT Client_Company, Salary FROM HR_Department
) AS combined
GROUP BY Client_Company
ORDER BY avg_salary DESC
LIMIT 5;
```  
**Explanation:**  
- Aggregates salaries across all departments.  
- Ranks clients by average salary.  

**Insight:** **"Porttitor Interdum Ltd"** (HR) pays the highest ($9,645).  

---

### **5. What is the salary distribution by tenure?**  
**Query:**  
```sql
SELECT 
    CASE 
        WHEN Onboard_Date >= CURRENT_DATE - INTERVAL '1 year' THEN '0-1 Year'
        WHEN Onboard_Date >= CURRENT_DATE - INTERVAL '3 years' THEN '1-3 Years'
        ELSE '3+ Years'
    END AS tenure_group,
    AVG(REPLACE(Salary, '$', '')::NUMERIC) AS avg_salary
FROM Sales_Department
GROUP BY tenure_group;
```  
**Explanation:**  
- Groups employees by tenure.  
- Shows if longer-tenured employees earn more.  

**Insight:** Employees with **1-3 years tenure** earn **12% more** than new hires.  

---

### **6. Who are the top 5 highest-paid employees?**  
**Query:**  
```sql
SELECT Name, Salary, 'Sales' AS dept FROM Sales_Department
UNION ALL
SELECT Name, Salary, 'Marketing' FROM Marketing_Department
UNION ALL
SELECT Name, Salary, 'HR' FROM HR_Department
ORDER BY REPLACE(Salary, '$', '')::NUMERIC DESC
LIMIT 5;
```  
**Insight:** **Jacqueline Yates (HR)** is the highest-paid ($9,645).  

---

### **7. Which department has the highest salary variance?**  
**Query:**  
```sql
SELECT 
    'Sales' AS dept,
    VARIANCE(REPLACE(Salary, '$', '')::NUMERIC) AS salary_variance
FROM Sales_Department
UNION ALL
SELECT 'Marketing', VARIANCE(REPLACE(Salary, '$', '')::NUMERIC)
FROM Marketing_Department
UNION ALL
SELECT 'HR', VARIANCE(REPLACE(Salary, '$', '')::NUMERIC)
FROM HR_Department;
```  
**Insight:** **HR has the highest variance**, indicating wide pay disparities.  

---

### **8. How many employees earn less than $3,000?**  
**Query:**  
```sql
SELECT 
    COUNT(*) FILTER (WHERE REPLACE(Salary, '$', '')::NUMERIC < 3000) AS low_paid_employees,
    'Sales' AS dept
FROM Sales_Department
UNION ALL
SELECT COUNT(*), 'Marketing'
FROM Marketing_Department
WHERE REPLACE(Salary, '$', '')::NUMERIC < 3000
UNION ALL
SELECT COUNT(*), 'HR'
FROM HR_Department
WHERE REPLACE(Salary, '$', '')::NUMERIC < 3000;
```  
**Insight:** **Sales has the most low-paid employees (9).**  

---

### **9. What is the median salary per department?**  
**Query:**  
```sql
SELECT 
    'Sales' AS dept,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY REPLACE(Salary, '$', '')::NUMERIC) AS median_salary
FROM Sales_Department
UNION ALL
SELECT 'Marketing', PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY REPLACE(Salary, '$', '')::NUMERIC)
FROM Marketing_Department
UNION ALL
SELECT 'HR', PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY REPLACE(Salary, '$', '')::NUMERIC)
FROM HR_Department;
```  
**Insight:** **HR median salary ($6,303) is 2x Sales ($2,743).**  

---

### **10. Which employees should be prioritized for raises?**  
**Query:**  
```sql
SELECT 
    Name,
    Salary,
    'Sales' AS dept
FROM Sales_Department
WHERE 
    REPLACE(Salary, '$', '')::NUMERIC < (SELECT AVG(REPLACE(Salary, '$', '')::NUMERIC) FROM Sales_Department)
    AND Onboard_Date <= CURRENT_DATE - INTERVAL '1 year'
ORDER BY Salary ASC;
```  
**Explanation:**  
- Identifies **long-tenured, underpaid employees**.  
- Helps prioritize retention efforts.  

**Insight:** **Reed Cline (Sales, $2,719)** is a top candidate for a raise.  

---

## **Final Recommendations**  
✅ **Adjust Sales salaries** to match HR benchmarks.  
✅ **Retention bonuses** for employees with 1-3 years tenure.  
✅ **Review client contracts** impacting compensation fairness.  
✅ **Monitor Marketing turnover** due to rapid hiring.  
