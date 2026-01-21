## Balanced Tree Sales Analytics Case Study (SQL)

## Project Purpose

This repository documents a comprehensive SQL based sales analysis performed on the `balanced_tree` dataset. The project is structured around a predefined set of business questions commonly asked by product managers, commercial teams, and leadership.

The intent is not only to answer these questions correctly, but to demonstrate:

* Clear analytical thinking
* Strong SQL fundamentals
* The ability to translate raw data into business insight
* Structured documentation suitable for handover, review, or portfolio presentation

Each section of the analysis aligns directly to a business theme and progresses from high level metrics to deeper transactional and product level insights.

## Business Questions Covered

The analysis is divided into three major sections.

### A. High Level Sales Analysis

These questions establish a macro level understanding of overall performance.

* What was the total quantity sold for all products?
* What is the total generated revenue for all products before discounts?
* What was the total discount amount for all products?

Purpose of this section:

* Quantify overall sales volume
* Understand gross revenue potential
* Measure the financial impact of discounting at an aggregate level

This section answers the question:
“How is the business performing overall?”


### B. Transaction Analysis

This section focuses on customer purchase behavior at the transaction level.

* How many unique transactions were there?
* What is the average number of unique products purchased in each transaction?
* What are the 25th, 50th, and 75th percentile values for revenue per transaction?
* What is the average discount value per transaction?
* What is the percentage split of all transactions for members vs non-members?
* What is the average revenue for member transactions and non-member transactions?

Purpose of this section:

* Understand how customers buy, not just what they buy
* Identify typical basket sizes and transaction values
* Compare member versus non-member behavior
* Measure the effectiveness of membership programs

This section answers the question:
“How do customers transact, and how does behavior differ across customer types?”

### C. Product Analysis

This section dives into product, segment, and category level performance.

* What are the top 3 products by total revenue before discount?
* What is the total quantity, revenue, and discount for each segment?
* What is the top selling product for each segment?
* What is the total quantity, revenue, and discount for each category?
* What is the top selling product for each category?
* What is the percentage split of revenue by product for each segment?
* What is the percentage split of revenue by segment for each category?
* What is the percentage split of total revenue by category?
* What is the total transaction penetration for each product?
* What is the most common combination of at least 1 quantity of any 3 products in a single transaction?

Purpose of this section:

* Identify revenue driving products
* Understand performance by segment and category
* Measure product reach and penetration
* Analyze cross product purchasing behavior

This section answers the question:
“What products matter most, and how are they purchased together?”

## Dataset Overview

The analysis is performed using two primary tables from the `balanced_tree` schema.

### `sales` Table

This table contains transaction level sales data.

Key columns:

* `txn_id` – Unique transaction identifier
* `prod_id` – Product identifier
* `qty` – Quantity purchased
* `price` – Price per unit
* `discount` – Discount percentage applied
* `member` – Indicates whether the customer is a member

This table forms the foundation for all volume, revenue, discount, and transaction level calculations.

### `product_details` Table

This table contains descriptive product metadata.

Key columns:

* `product_id` – Product identifier
* `product_name` – Product name
* `segment` – Product segment
* `category` – Product category

This table is joined to the sales data to enable product, segment, and category level analysis.

## Analysis Approach

Each question in the project follows a consistent structure:

* Clear business question
* Purpose and relevance
* SQL query used to answer the question
* Explanation of the query logic
* Interpretation of the results

This structure mirrors how analytics work is typically reviewed in professional settings and ensures the output is understandable beyond just SQL practitioners.

## Key SQL Concepts Demonstrated

This project intentionally showcases practical SQL skills used in real world analytics roles:

* Aggregations using `SUM`, `AVG`, `COUNT`
* Grouping with `GROUP BY`
* Joining fact and dimension tables
* Revenue and discount calculations
* Percentile analysis using window functions
* Conditional logic for member versus non-member analysis
* Ranking and sorting for top product identification
* Basket analysis using transaction level grouping

The SQL prioritizes readability, correctness, and explainability.

## Repository Structure

A typical structure for this project would include:

* `README.md` – Project overview and business context
* `sql/` – SQL scripts grouped by analysis section

  * `high_level_sales.sql`
  * `transaction_analysis.sql`
  * `product_analysis.sql`
* `results/` – Optional exported query outputs
* `notes/` – Optional assumptions or business interpretations

This layout supports easy navigation and future expansion.

## How to Use This Project

You can engage with this repository in several ways:

* Run the SQL scripts sequentially to follow the analytical narrative
* Use individual queries as references for common analytical patterns
* Extend the analysis with additional filters or time based dimensions
* Discuss the approach and results in interviews or technical reviews

The project is intentionally modular and extensible.

## Assumptions and Limitations

ASSUMPTION:

* Prices and discounts are applied uniformly per transaction line item
* Revenue calculations are performed before tax
* Discount percentages are stored consistently and represent percentage values

These assumptions are required due to the structure of the available data and are explicitly stated to avoid misinterpretation.

## Intended Audience

This project is suitable for:

* SQL learners seeking realistic business problems
* Data analysts building portfolio projects
* BI developers demonstrating analytical depth
* Interview panels evaluating SQL and reasoning skills

The documentation is written to be understandable by both technical and non-technical stakeholders.

## Summary

This repository demonstrates a full end to end sales analysis workflow using SQL.

It shows:

* How to translate business questions into queries
* How to structure analysis logically
* How to communicate insights clearly

The focus is not just on getting the right answers, but on explaining how and why those answers matter.
