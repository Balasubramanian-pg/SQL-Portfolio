# Tools, Conversions And Vendor Specifics

This directory serves as a comprehensive resource for database management, specifically focusing on the transition between SQL-based relational models and NoSQL environments, alongside advanced SQL objects.

## Directory Structure

### 8.1 MongoDB And NoSQL

* MongoDB: Core configuration guides and documentation for MongoDB implementation.
* Sql To Mongodb Cheat Sheet Duplicate.pdf: A quick-reference mapping guide for translating SQL concepts (Tables, Rows, Joins) into MongoDB equivalents (Collections, Documents, Aggregations).

### 8.3 Stored Procedures Triggers Views

This section covers advanced, server-side database logic and schema design:

* Stored Procedure: Reusable, pre-compiled SQL code blocks for optimized performance.
* Tables And Schemas: Definition files and architecture designs for relational data models.
* Trigger / Triggers: Automation scripts that execute in response to specific table events.
* Views: Virtual tables used to simplify data access and encapsulate complex query logic.

### Reference Scripts

* sql_tutorial_working.sql: The main database script containing setup steps and tutorial exercises.
* sql_tutorial_trimmed.sql: A streamlined version of the script focused strictly on essential operations.

## Getting Started

### Relational Database Setup

1. Open your SQL client or CLI tool.
2. Execute sql_tutorial_working.sql to build the baseline schema and populate sample data.
3. Explore the subfolders under 8.3 to apply specific triggers, views, and stored procedures to the environment.

### NoSQL Migration

When transitioning from relational schemas to document-based structures, use the SQL to MongoDB Cheat Sheet to understand how tabular rows translate into nested BSON documents and how to approach schema design without traditional foreign key constraints.
