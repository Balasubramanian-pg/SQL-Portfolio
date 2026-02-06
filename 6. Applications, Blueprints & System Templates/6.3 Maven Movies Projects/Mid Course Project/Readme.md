# Project Specification: Maven Movies Operational & Risk Analysis

## Project Overview

This project involves a comprehensive data audit of the **Maven Movies** rental system. As the business prepares for its annual performance review and scales its security infrastructure, the Business Intelligence team is required to extract specific datasets that bridge the gap between operational logistics, customer engagement, and financial liability.

The following requirements represent the core business questions that must be answered using the `mavenmovies` database schema.

### 1. Human Resources: Staff Directory

To streamline internal communications and ensure organizational transparency, we require a master list of all current employees. The output should facilitate a quick reference for corporate management to identify which personnel are assigned to specific retail branches.

* **Requirements:** Full names (first and last), official email addresses, and associated store identification numbers.

### 2. Logistics: Inventory Distribution

Effective supply chain management requires an understanding of how physical assets are distributed across the company's footprint. We need to evaluate the stock volume at each location to determine if inventory is balanced or if certain stores require replenishment.

* **Requirements:** A comparative count of total inventory items held at Store 1 versus Store 2.

### 3. Sales & Marketing: Customer Engagement

The marketing department is refining its "Active User" campaigns. To allocate budget effectively, we need to know the current reach of each store based on active accounts rather than just historical sign-ups.

* **Requirements:** A breakdown of active customer counts, categorized by their home store.

### 4. Risk Management: Data Breach Liability

In compliance with evolving data privacy regulations, the legal department must quantify our "threat surface." In the event of a security compromise, we need a baseline metric of how many unique customer records (specifically email addresses) are at risk within our centralized database.

* **Requirements:** A cumulative count of all customer email addresses stored in the system.

### 5. Product Management: Catalog Diversity & Breadth

A diverse catalog is a primary driver of customer retention. Management needs to assess if our inventory offers enough variety to satisfy different demographics. This requires looking at both the volume of unique titles and the breadth of genres available.

* **Requirements:** * A count of unique film titles available at each store.
* A system-wide count of unique film categories (genres) offered to the public.



### 6. Finance: Asset Valuation & Replacement Costs

To maintain accurate insurance coverage and depreciation schedules, the finance team needs to understand the replacement value of the entire film library. We are looking for the "extremes" of our pricing and the overall average to forecast potential loss impact.

* **Requirements:** The minimum replacement cost, the maximum replacement cost, and the average replacement cost across the entire film catalog.

### 7. Internal Audit: Fraud Prevention & Payment Benchmarks

To minimize the risk of internal fraud or unauthorized transaction overrides, we are implementing new payment monitoring thresholds. We need historical payment data to set realistic "maximum" flags and to understand standard transaction behavior.

* **Requirements:** The average payment amount processed to date and the single highest payment value recorded in the system.

### 8. CRM: Customer Lifetime Value (CLV)

Identifying our "Power Users" is essential for the upcoming loyalty rewards program. We need to rank our customer base by their historical engagement levels to distinguish between casual renters and high-volume contributors.

* **Requirements:** A comprehensive list of all customer IDs paired with their total lifetime rental counts, ordered from the highest volume of rentals to the lowest.

