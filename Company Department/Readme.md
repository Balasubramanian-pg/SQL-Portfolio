# Employee Compensation and Retention Analysis Using SQL (Snowflake)

## 1. Project Overview

Employee retention is one of the most critical challenges faced by modern organizations. High attrition not only increases hiring and onboarding costs, but also leads to knowledge loss, reduced team morale, and inconsistent client delivery. This project focuses on analyzing employee compensation and retention patterns using SQL, with Snowflake as the primary data warehouse.

The organization has observed noticeably higher turnover in Sales and Marketing departments, while the Human Resources department remains relatively stable. Leadership suspects that compensation disparities, onboarding timing, and client assignment patterns may be contributing to these trends. This project aims to validate or refute those assumptions through a structured, data-driven analysis.

The outcome of this project is a set of actionable insights that leadership can use to optimize compensation strategy, reduce voluntary attrition, and improve workforce stability.

This README serves as a comprehensive explanation of the business problem, data model, analytical approach, SQL logic, assumptions, limitations, and potential extensions of the analysis.

## 2. Business Problem Statement

The company is experiencing uneven employee turnover across departments. While some teams maintain healthy retention levels, others face frequent resignations, particularly within the first year of employment.

The business challenges include:

* Rising replacement and recruitment costs
* Loss of experienced employees in revenue-critical departments
* Difficulty maintaining consistent client relationships
* Potential internal inequity in compensation structures

Leadership believes the root causes may include:

* Unequal salary distribution across departments
* Employees joining at lower compensation levels compared to peers
* New hires leaving before completing one year of tenure
* Certain client assignments being associated with higher pay or better career growth

This project investigates these hypotheses using historical employee data.

## 3. Key Business Questions

The analysis is designed to answer the following questions:

1. Are certain departments systematically underpaid compared to others?
2. Which employees are at risk of leaving due to low compensation?
3. Does onboarding date and tenure length impact employee retention risk?
4. Are high-performing or high-paid employees concentrated around specific client companies?
5. How can compensation structures be optimized to improve fairness and retention?

Each question is mapped to specific SQL-based analyses described later in this document.

## 4. Project Objectives

The primary objectives of this project are:

* Identify compensation disparities across departments
* Quantify retention risk using measurable indicators
* Highlight employees who may require compensation review
* Surface patterns between client assignments and salary levels
* Provide data-backed recommendations to leadership

Secondary objectives include:

* Demonstrating strong SQL modeling and analytical skills
* Applying Snowflake-specific SQL features where appropriate
* Creating reusable and extensible analytical logic

## 5. Scope of Analysis

Included in scope:

* Full-time employees only
* Active and recently exited employees if available
* Salary, department, client, onboarding date, and performance-related attributes
* SQL-based analysis within Snowflake

Out of scope:

* Qualitative factors such as job satisfaction surveys
* External labor market benchmarking data
* Predictive machine learning models
* Non-SQL tools such as Python or BI dashboards

## 6. Technology Stack

The project is implemented entirely using SQL in Snowflake.

Core technologies:

* Snowflake Data Warehouse
* ANSI-compliant SQL
* Snowflake-specific functions such as:

  * DATEADD
  * DATEDIFF
  * WINDOW FUNCTIONS
  * COMMON TABLE EXPRESSIONS
  * QUALIFY

No external orchestration, scripting, or visualization tools are required for the core analysis.

## 7. Assumptions

The analysis is based on the following assumptions:

* Salary values represent annual fixed compensation
* Higher salary is generally associated with higher retention
* Employees with tenure less than 12 months are at higher attrition risk
* Department and client assignments are accurate and current
* Performance ratings, if available, are standardized

ASSUMPTION: Voluntary and involuntary attrition are not differentiated unless explicitly stated in the data.

These assumptions are necessary due to data limitations and should be revisited if additional attributes become available.

## 8. Data Model Overview

The project assumes a simplified HR data model that may resemble the following structure.

### 8.1 Employees Table

Key fields:

* employee_id
* employee_name
* department
* job_title
* salary
* hire_date
* termination_date
* client_company
* performance_rating

### 8.2 Derived Fields

During analysis, additional fields are derived:

* tenure_in_months
* tenure_bucket
* salary_vs_department_avg
* retention_risk_flag
* retention_risk_score

No physical transformations are applied. All derived fields are computed using SQL queries.

## 9. Data Preparation and Cleaning

Before analysis, the following preparation steps are applied:

* Ensure salary values are numeric and non-null
* Standardize department names
* Convert hire_date to DATE data type
* Filter out contractors or interns if present
* Handle null client assignments explicitly

Example preparation logic includes:

* Using COALESCE to handle missing salary or department
* Casting date fields appropriately
* Filtering to active employees when required

These steps ensure consistent and reliable analysis.

## 10. Analytical Approach Overview

The analysis follows a structured, layered approach:

1. Baseline descriptive statistics
2. Department-level salary benchmarking
3. Tenure and onboarding analysis
4. Client-based salary distribution
5. Retention risk scoring
6. Compensation optimization recommendations

Each step builds on the previous one using Common Table Expressions to maintain clarity and reusability.

## 11. Salary Benchmarking Analysis

### 11.1 Objective

To determine whether certain departments are underpaid relative to others and to the company-wide average.

### 11.2 Methodology

* Calculate average salary per department
* Compare each department’s average against:

  * Overall company average
  * Other departments

### 11.3 Key Metrics

* Department average salary
* Salary variance from company average
* Rank of departments by compensation

### 11.4 Interpretation

Departments with consistently lower averages may indicate:

* Budget constraints
* Market misalignment
* Historical underinvestment

This analysis directly addresses the first business question.

## 12. Individual Compensation Positioning

### 12.1 Objective

Identify employees earning below their department average.

### 12.2 Methodology

* Use window functions to compute department average salary
* Calculate each employee’s difference from that average
* Flag employees earning significantly less

### 12.3 Business Value

This allows HR to:

* Identify fairness gaps
* Prioritize compensation reviews
* Reduce risk of dissatisfaction-driven exits

## 13. Tenure and Onboarding Analysis

### 13.1 Objective

Understand how onboarding date and tenure length correlate with retention risk.

### 13.2 Methodology

* Calculate tenure using DATEDIFF
* Categorize employees into tenure buckets:

  * Less than 6 months
  * 6 to 12 months
  * 1 to 3 years
  * More than 3 years

### 13.3 Insights

* High concentration of exits in early tenure often signals onboarding or compensation issues
* Stable long-tenure population indicates organizational health

This analysis supports the third business question.

## 14. Recent Hire Risk Identification

### 14.1 Objective

Flag employees onboarded in the last 12 months.

### 14.2 Methodology

* Filter hire_date within the last 12 months
* Combine with salary positioning metrics

### 14.3 Interpretation

Employees who are both:

* Recently onboarded
* Paid below department average

represent a high-priority risk segment.

## 15. Client Impact Analysis

### 15.1 Objective

Determine whether certain client assignments correlate with higher compensation.

### 15.2 Methodology

* Group employees by client_company
* Calculate average salary per client
* Compare across clients and departments

### 15.3 Business Implications

Findings may reveal:

* Premium clients attracting higher-paid talent
* Internal inequities in client staffing
* Potential morale issues for underpaid client teams

This addresses the fourth business question.

## 16. Performance and Compensation Alignment

### 16.1 Objective

Assess whether high-performing employees are compensated fairly.

### 16.2 Methodology

* Compare performance ratings against salary
* Identify high performers below department average salary

### 16.3 Value

Misalignment between performance and pay is a strong predictor of attrition.

## 17. Retention Risk Scoring Framework

### 17.1 Objective

Create a simple, interpretable retention risk score.

### 17.2 Risk Factors

Each employee is evaluated on:

* Below-average salary
* Tenure under 12 months
* Assignment to lower-paying clients
* High performance with low pay

### 17.3 Scoring Logic

Each risk factor contributes one point.
Higher scores indicate higher attrition risk.

ASSUMPTION: All risk factors are weighted equally.

## 18. Retention Risk Categorization

Employees are categorized as:

* Low Risk
* Medium Risk
* High Risk

This enables targeted HR interventions rather than broad, costly adjustments.

## 19. Compensation Optimization Recommendations

### 19.1 Department-Level Adjustments

* Review pay bands in Sales and Marketing
* Align department averages closer to company median

### 19.2 Individual-Level Adjustments

* Prioritize high-risk, high-performing employees
* Adjust salaries for underpaid recent hires

### 19.3 Client Staffing Strategy

* Rebalance compensation across client teams
* Ensure demanding clients do not rely solely on underpaid staff

## 20. Snowflake-Specific Implementation Notes

### 20.1 Performance Considerations

* Use CTEs for readability, not performance
* Materialize intermediate results if datasets are large
* Leverage clustering on department or hire_date if needed

### 20.2 SQL Features Used

* WINDOW FUNCTIONS
* DATE FUNCTIONS
* QUALIFY
* CASE STATEMENTS

All logic is Snowflake-compatible and portable.

## 21. Validation and Quality Checks

Validation steps include:

* Cross-checking salary aggregates
* Verifying tenure calculations
* Ensuring no duplicate employee records

Any anomalies are flagged for data review.

## 22. Limitations

This analysis does not account for:

* External market salary benchmarks
* Non-monetary benefits
* Managerial quality
* Career growth opportunities

Results should be interpreted as directional insights rather than absolute truths.

## 23. Ethical Considerations

* Compensation data is sensitive
* Results should be shared only with authorized stakeholders
* Analysis should support fairness, not discrimination

## 24. How This Project Can Be Extended

Future enhancements may include:

* Integration with exit interview data
* Predictive attrition modeling
* Time-series analysis of salary growth
* Visualization in BI tools

## 25. Interview Talking Points

This project demonstrates:

* Strong SQL fundamentals
* Business-driven analytics
* Clear reasoning and structured problem solving
* Practical HR domain understanding

## 26. Conclusion

This HR Analytics project uses SQL and Snowflake to translate raw employee data into meaningful retention insights. By systematically analyzing compensation, tenure, and client assignments, the project provides leadership with a clear view of where and why attrition risk exists.

Most importantly, it moves beyond descriptive reporting and delivers actionable recommendations that can directly improve employee satisfaction, retention, and organizational stability.

This README documents not just what was done, but why it was done, how it was implemented, and how it can be evolved further.
