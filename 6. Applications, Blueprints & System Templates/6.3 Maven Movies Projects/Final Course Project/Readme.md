# Project Specification: Phase II – Strategic Asset & stakeholder Evaluation

## Project Overview

Following the initial operational audit, this second phase focuses on **Executive Due Diligence**. The goal is to provide ownership with a granular view of physical assets, localized management structures, and a deep dive into the equity and influence surrounding the organization. These requirements are designed to facilitate in-person site visits, asset valuation for insurance purposes, and a strategic assessment of market positioning.

### 1. Executive Site Visit: Management & Location Brief

To facilitate a formal introduction between the partnership and local leadership, we require a comprehensive profile for each physical retail location. This brief will serve as the itinerary for on-site inspections.

* **Requirements:** Identification of the designated Manager for each store location, paired with the complete geographical footprint including street address, district, city, and country.

### 2. Asset Catalog: Detailed Inventory Ledger

As part of the business valuation process, we must move beyond bulk counts to a detailed ledger of every individual asset. This data is critical for determining the quality and marketability of the current stock.

* **Requirements:** A granular list of every inventory item, specifying the Store ID, Inventory ID, Film Title, MPAA Rating, Rental Rate, and Replacement Cost.

### 3. Inventory Stratification: Risk & Rating Analysis

Management requires a "roll-up" of the detailed inventory list to understand the composition of the catalog. By analyzing inventory through the lens of content ratings, we can ensure each store is properly stocked for its local demographic.

* **Requirements:** A summary table showing the total count of inventory items, segmented by Store ID and Film Rating (e.g., G, PG, R).

### 4. Financial Exposure: Category & Replacement Cost Matrix

This requirement seeks to quantify the financial "hit" to the business if specific genres lose market favor. We need to identify the concentration of value across different film categories to manage departmental risk.

* **Requirements:** A multi-dimensional view providing the total number of films, the average replacement cost, and the aggregate (total) replacement cost, sliced by both Store ID and Film Category.

### 5. Customer Profile: Geographic & Status Mapping

To verify the integrity of the customer database and local market penetration, we need a verified list of our clientele. This will assist in determining if our "active" base is concentrated in specific districts or spread across the region.

* **Requirements:** Full customer names, their preferred store location, current account status (Active/Inactive), and their verified physical address (Street, City, and Country).

### 6. Revenue Integrity: Lifetime Value (LTV) Leaderboard

We are shifting from simple rental counts to a "Total Lifetime Value" metric. This allows the partnership to identify the specific individuals responsible for the bulk of the company's historical revenue.

* **Requirements:** A report listing customer names, their total lifetime rental volume, and the cumulative sum of all payments made, ordered from highest total spend to lowest.

### 7. Corporate Governance: Stakeholder & Investor Registry

For the purpose of transparency in corporate governance, the partnership requires a unified view of the individuals who hold influence or equity in the company.

* **Requirements:** A consolidated table of all Advisors and Investors. The output must distinguish the individual’s role and, for investors, specify their associated corporate entity or venture firm.

### 8. Competitive Benchmarking: Talent & Award Coverage

To assess our brand's "prestige" and catalog depth, we want to measure our coverage of highly-decorated actors. This analysis will determine if we are successfully capturing the most critically acclaimed content in the industry.

* **Requirements:** A percentage-based analysis showing our film coverage for three distinct tiers of talent: actors with three types of awards, two types of awards, and one type of award.

### Data Dictionary Supplement: Phase II

| Table Name | Key Columns for Analysis | Context |
| --- | --- | --- |
| **`address`** | `address`, `district`, `city_id` | Required for mapping store and customer locations. |
| **`city` / `country**` | `city`, `country` | Normalized tables used to provide full geographical context. |
| **`film_list`** | `title`, `rating`, `category` | A system view often used to bridge titles with their genres. |
| **`actor_award`** | `actor_id`, `awards` | The source for benchmarking talent-to-catalog coverage. |
| **`investor` / `advisor**` | `first_name`, `last_name`, `company_name` | Stakeholder tables for corporate transparency. |
