# PostgreSQL Triggers: Complete Guide with Examples

---
## **Table of Contents**
1. [Trigger Fundamentals](#fundamentals)
2. [Setup: Tables for Examples](#setup-tables)
3. [Basic Trigger Examples](#basic-triggers)
4. [Advanced Trigger Types](#advanced-triggers)
5. [Trigger Management](#trigger-management)
6. [Performance Considerations](#performance)
7. [Debugging Triggers](#debugging)
8. [Real-World Use Cases](#use-cases)
9. [Security Considerations](#security)
10. [Complete Example: Audit System](#audit-system)

---
## **1. Trigger Fundamentals** <a name="fundamentals"></a>

### **Trigger Components**
```sql
CREATE TRIGGER trigger_name
[BEFORE|AFTER|INSTEAD OF] [INSERT|UPDATE|DELETE|TRUNCATE]
ON table_name
[FOR [EACH] {ROW|STATEMENT}]
[WHEN (condition)]
EXECUTE {FUNCTION|PROCEDURE} function_name();
```

### **Trigger Types**
| Type | Timing | Event | Granularity |
|------|--------|-------|-------------|
| BEFORE | Before operation | INSERT/UPDATE/DELETE | ROW/STATEMENT |
| AFTER | After operation | INSERT/UPDATE/DELETE | ROW/STATEMENT |
| INSTEAD OF | Instead of operation | INSERT/UPDATE/DELETE | ROW |
| TRUNCATE | Before/After truncate | TRUNCATE | STATEMENT |

### **Trigger Functions**
```sql
CREATE FUNCTION trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    -- Trigger logic here
    RETURN NEW;  -- For BEFORE triggers on INSERT/UPDATE
    -- RETURN OLD; -- For BEFORE triggers on DELETE
    -- RETURN NULL; -- To skip operation
END;
$$ LANGUAGE plpgsql;
```

---
## **2. Setup: Tables for Examples** <a name="setup-tables"></a>

```sql
-- Create a demo database
CREATE DATABASE trigger_demo;
\c trigger_demo

-- Employees table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    salary DECIMAL(10, 2) CHECK (salary > 0),
    department_id INTEGER,
    hire_date DATE DEFAULT CURRENT_DATE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) DEFAULT CURRENT_USER
);

-- Departments table
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    manager_id INTEGER REFERENCES employees(employee_id),
    budget DECIMAL(12, 2),
    location VARCHAR(100)
);

-- Salary history table
CREATE TABLE salary_history (
    history_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id),
    old_salary DECIMAL(10, 2),
    new_salary DECIMAL(10, 2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50) DEFAULT CURRENT_USER,
    reason VARCHAR(200)
);

-- Audit log table
CREATE TABLE audit_log (
    audit_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id INTEGER,
    action VARCHAR(10) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_data JSONB,
    new_data JSONB,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_user VARCHAR(50) DEFAULT CURRENT_USER
);

-- Products table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    category VARCHAR(50),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order items table
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(10, 2) DEFAULT 0.00,
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Orders table (referenced by order_items)
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pending',
    total_amount DECIMAL(10, 2),
    CONSTRAINT valid_status CHECK (status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'))
);

-- Customers table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    credit_limit DECIMAL(10, 2),
    account_status VARCHAR(20) DEFAULT 'Active' CHECK (account_status IN ('Active', 'Inactive', 'Suspended'))
);

-- Create indexes for performance
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_email ON employees(email);
CREATE INDEX idx_salary_history_employee ON salary_history(employee_id);
CREATE INDEX idx_audit_log_table ON audit_log(table_name);
CREATE INDEX idx_audit_log_timestamp ON audit_log(action_timestamp);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_order_items_product ON order_items(product_id);
```

---
## **3. Basic Trigger Examples** <a name="basic-triggers"></a>

### **1. Automatic Timestamp Update**
```sql
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to employees table
CREATE TRIGGER trigger_update_employee_timestamp
BEFORE UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- Apply to products table
CREATE TRIGGER trigger_update_product_timestamp
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();
```

### **2. Salary History Tracking**
```sql
CREATE OR REPLACE FUNCTION log_salary_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.salary <> OLD.salary THEN
        INSERT INTO salary_history(employee_id, old_salary, new_salary, reason)
        VALUES (OLD.employee_id, OLD.salary, NEW.salary, 'Regular salary update');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_salary_change
BEFORE UPDATE ON employees
FOR EACH ROW
WHEN (OLD.salary IS DISTINCT FROM NEW.salary)
EXECUTE FUNCTION log_salary_change();
```

### **3. Prevent Invalid Data**
```sql
CREATE OR REPLACE FUNCTION prevent_salary_decrease()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.salary < OLD.salary THEN
        RAISE EXCEPTION 'Salary cannot be decreased. Old: %, New: %',
            OLD.salary, NEW.salary;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_prevent_salary_decrease
BEFORE UPDATE ON employees
FOR EACH ROW
WHEN (NEW.salary < OLD.salary)
EXECUTE FUNCTION prevent_salary_decrease();
```

### **4. Automatic Field Population**
```sql
CREATE OR REPLACE FUNCTION set_employee_full_name()
RETURNS TRIGGER AS $$
BEGIN
    -- This would require adding a full_name column to the employees table
    -- ALTER TABLE employees ADD COLUMN full_name VARCHAR(100);
    NEW.full_name = NEW.first_name || ' ' || NEW.last_name;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Uncomment after adding full_name column
-- CREATE TRIGGER trigger_set_full_name
-- BEFORE INSERT OR UPDATE ON employees
-- FOR EACH ROW
-- EXECUTE FUNCTION set_employee_full_name();
```

### **5. Data Validation**
```sql
CREATE OR REPLACE FUNCTION validate_email_format()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email !~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
        RAISE EXCEPTION 'Invalid email format: %', NEW.email;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_email
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION validate_email_format();

CREATE TRIGGER trigger_validate_customer_email
BEFORE INSERT OR UPDATE ON customers
FOR EACH ROW
EXECUTE FUNCTION validate_email_format();
```

---
## **4. Advanced Trigger Types** <a name="advanced-triggers"></a>

### **1. Statement-Level Trigger**
```sql
CREATE OR REPLACE FUNCTION log_bulk_employee_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log(table_name, action, action_timestamp)
    VALUES ('employees', 'BULK_UPDATE', CURRENT_TIMESTAMP);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_bulk_employee_changes
AFTER UPDATE ON employees
FOR EACH STATEMENT
EXECUTE FUNCTION log_bulk_employee_changes();
```

### **2. Conditional Trigger (WHEN Clause)**
```sql
CREATE OR REPLACE FUNCTION notify_large_salary_increase()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.salary > OLD.salary * 1.2 THEN
        -- In a real system, you might send an email or notification
        RAISE NOTICE 'Large salary increase (>20%) for employee %: % to %',
            NEW.employee_id, OLD.salary, NEW.salary;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_large_increase
BEFORE UPDATE ON employees
FOR EACH ROW
WHEN (NEW.salary > OLD.salary * 1.2)
EXECUTE FUNCTION notify_large_salary_increase();
```

### **3. Cross-Table Trigger**
```sql
CREATE OR REPLACE FUNCTION update_department_budget()
RETURNS TRIGGER AS $$
DECLARE
    total_salary DECIMAL(12, 2);
BEGIN
    -- Calculate total salary for department
    SELECT COALESCE(SUM(salary), 0) INTO total_salary
    FROM employees
    WHERE department_id = NEW.department_id;

    -- Update department budget (assuming budget should be 1.5x total salary)
    UPDATE departments
    SET budget = total_salary * 1.5
    WHERE department_id = NEW.department_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_department_budget
AFTER INSERT OR UPDATE ON employees
FOR EACH ROW
WHEN (NEW.department_id IS NOT NULL)
EXECUTE FUNCTION update_department_budget();
```

### **4. INSTEAD OF Trigger (for Views)**
```sql
-- First create a view
CREATE VIEW employee_directory AS
SELECT employee_id, first_name, last_name, email, department_id
FROM employees
WHERE is_active = TRUE;

-- Create INSTEAD OF trigger for the view
CREATE OR REPLACE FUNCTION employee_directory_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert into the underlying table with default values
    INSERT INTO employees(
        first_name, last_name, email, department_id,
        salary, hire_date, is_active
    ) VALUES (
        NEW.first_name, NEW.last_name, NEW.email, NEW.department_id,
        50000,  -- Default salary
        CURRENT_DATE,
        TRUE     -- Active by default
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_employee_directory_insert
INSTEAD OF INSERT ON employee_directory
FOR EACH ROW
EXECUTE FUNCTION employee_directory_insert();
```

### **5. Transition Table Trigger (PostgreSQL 10+)**
```sql
CREATE OR REPLACE FUNCTION log_employee_changes()
RETURNS TRIGGER AS $$
BEGIN
    -- Log all changes to employees table
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log(table_name, record_id, action, old_data)
        VALUES ('employees', OLD.employee_id, 'DELETE', to_jsonb(OLD));

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log(table_name, record_id, action, old_data, new_data)
        VALUES ('employees', NEW.employee_id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));

    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log(table_name, record_id, action, new_data)
        VALUES ('employees', NEW.employee_id, 'INSERT', NULL, to_jsonb(NEW));
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_employee_changes
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_changes();
```

### **6. Recursive Trigger**
```sql
-- First enable recursive triggers if needed
-- ALTER TABLE employees ENABLE TRIGGER ALL;

CREATE OR REPLACE FUNCTION cascade_department_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.manager_id <> OLD.manager_id THEN
        -- Update all employees in this department to have the new manager
        UPDATE employees
        SET manager_id = NEW.manager_id
        WHERE department_id = NEW.department_id
        AND employee_id <> NEW.manager_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Note: This could cause infinite recursion if not careful
-- CREATE TRIGGER trigger_cascade_department_changes
-- AFTER UPDATE ON departments
-- FOR EACH ROW
-- WHEN (NEW.manager_id IS DISTINCT FROM OLD.manager_id)
-- EXECUTE FUNCTION cascade_department_changes();
```

---
## **5. Trigger Management** <a name="trigger-management"></a>

### **List All Triggers**
```sql
-- Method 1: Using information_schema
SELECT
    event_object_table AS table_name,
    trigger_name,
    event_manipulation AS event,
    action_timing AS timing,
    action_statement AS function_call
FROM
    information_schema.triggers
WHERE
    trigger_schema = 'public'
ORDER BY
    event_object_table, trigger_name;

-- Method 2: Using pg_trigger
SELECT
    tgname AS trigger_name,
    relname AS table_name,
    CASE tgtype & 1 WHEN 1 THEN 'INSERT' ELSE '' END ||
    CASE tgtype & 2 WHEN 2 THEN 'DELETE' ELSE '' END ||
    CASE tgtype & 4 WHEN 4 THEN 'UPDATE' ELSE '' END ||
    CASE tgtype & 8 WHEN 8 THEN 'TRUNCATE' ELSE '' END AS events,
    CASE tgtype & 16 WHEN 16 THEN 'BEFORE' ELSE 'AFTER' END AS timing,
    CASE tgtype & 32 WHEN 32 THEN 'ROW' ELSE 'STATEMENT' END AS level,
    proname AS function_name
FROM
    pg_trigger
JOIN
    pg_class ON tgrelid = pg_class.oid
JOIN
    pg_proc ON tgfoid = pg_proc.oid
WHERE
    relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY
    relname, tgname;
```

### **Disable/Enable Triggers**
```sql
-- Disable a specific trigger
ALTER TABLE employees DISABLE TRIGGER trigger_update_employee_timestamp;

-- Disable all triggers on a table
ALTER TABLE employees DISABLE TRIGGER ALL;

-- Enable a specific trigger
ALTER TABLE employees ENABLE TRIGGER trigger_update_employee_timestamp;

-- Enable all triggers on a table
ALTER TABLE employees ENABLE TRIGGER ALL;
```

### **Rename a Trigger**
```sql
ALTER TRIGGER trigger_update_employee_timestamp
ON employees RENAME TO trigger_employee_timestamp_update;
```

### **Drop a Trigger**
```sql
DROP TRIGGER IF EXISTS trigger_update_employee_timestamp ON employees;
```

---
## **6. Performance Considerations** <a name="performance"></a>

### **Trigger Performance Tips**
```sql
-- 1. Use STATEMENT-level triggers when possible for bulk operations
CREATE OR REPLACE FUNCTION log_bulk_operations()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO operation_log(table_name, operation, rows_affected, operation_time)
    VALUES (TG_TABLE_NAME, TG_OP, (SELECT count(*) FROM employees), CURRENT_TIMESTAMP);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_bulk_operations
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH STATEMENT
EXECUTE FUNCTION log_bulk_operations();

-- 2. Avoid complex operations in triggers
-- Bad: Performing many subqueries or updates
-- Good: Keep triggers simple and fast

-- 3. Consider deferring constraints
ALTER TABLE employees
ADD CONSTRAINT chk_salary_positive
CHECK (salary > 0) DEFERRABLE INITIALLY DEFERRED;

-- 4. Use conditional triggers to avoid unnecessary execution
CREATE TRIGGER trigger_conditional_update
BEFORE UPDATE ON employees
FOR EACH ROW
WHEN (NEW.salary IS DISTINCT FROM OLD.salary)
EXECUTE FUNCTION log_salary_change();

-- 5. Monitor trigger performance
EXPLAIN ANALYZE
UPDATE employees SET salary = salary * 1.05 WHERE department_id = 1;
```

### **Trigger Overhead Example**
```sql
-- Create a test table
CREATE TABLE trigger_test (
    id SERIAL PRIMARY KEY,
    data TEXT,
    updated_at TIMESTAMP
);

-- Create a simple trigger
CREATE OR REPLACE FUNCTION update_timestamp_test()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_timestamp_test
BEFORE UPDATE ON trigger_test
FOR EACH ROW
EXECUTE FUNCTION update_timestamp_test();

-- Test performance with and without trigger
-- With trigger enabled:
\timing on
UPDATE trigger_test SET data = 'test' WHERE id < 10000;

-- With trigger disabled:
ALTER TABLE trigger_test DISABLE TRIGGER trigger_update_timestamp_test;
UPDATE trigger_test SET data = 'test' WHERE id < 10000;
```

---
## **7. Debugging Triggers** <a name="debugging"></a>

### **Debugging Techniques**
```sql
-- 1. Use RAISE NOTICE for debugging
CREATE OR REPLACE FUNCTION debug_employee_update()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Old salary: %, New salary: %', OLD.salary, NEW.salary;
    RAISE NOTICE 'Employee: % %', NEW.first_name, NEW.last_name;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Log to a debug table
CREATE TABLE trigger_debug (
    debug_id SERIAL PRIMARY KEY,
    trigger_name VARCHAR(100),
    table_name VARCHAR(100),
    operation VARCHAR(10),
    debug_data JSONB,
    debug_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION debug_to_table()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO trigger_debug(trigger_name, table_name, operation, debug_data)
    VALUES (
        TG_NAME,
        TG_TABLE_NAME,
        TG_OP,
        jsonb_build_object(
            'old', OLD,
            'new', NEW,
            'when', TG_WHEN,
            'level', TG_LEVEL
        )
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 3. Use exception blocks
CREATE OR REPLACE FUNCTION safe_employee_update()
RETURNS TRIGGER AS $$
BEGIN
    BEGIN
        -- Your trigger logic here
        NEW.last_updated = CURRENT_TIMESTAMP;

        -- Potential error
        IF NEW.salary < 0 THEN
            RAISE EXCEPTION 'Salary cannot be negative';
        END IF;

        RETURN NEW;
    EXCEPTION WHEN OTHERS THEN
        -- Log the error
        INSERT INTO trigger_errors(error_time, table_name, error_message)
        VALUES (CURRENT_TIMESTAMP, 'employees', SQLERRM);

        -- Re-raise the exception
        RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

-- 4. Check trigger execution with pg_stat_user_functions
SELECT * FROM pg_stat_user_functions
WHERE funcname LIKE '%trigger%';
```

### **Common Trigger Errors**
| Error | Cause | Solution |
|-------|-------|----------|
| `tuple already updated` | Trigger modifies same row | Use BEFORE trigger or restructure logic |
| `infinite recursion` | Trigger causes itself to fire | Add condition or use ENABLE/DISABLE |
| `permission denied` | Insufficient privileges | Grant appropriate permissions |
| `null value violates constraint` | Trigger sets NULL in NOT NULL column | Add NULL checks in trigger |
| `cache lookup failed` | Missing referenced table | Verify all referenced objects exist |

---
## **8. Real-World Use Cases** <a name="use-cases"></a>

### **1. Audit Trail System**
```sql
-- Enhanced audit trigger
CREATE OR REPLACE FUNCTION comprehensive_audit()
RETURNS TRIGGER AS $$
DECLARE
    audit_record RECORD;
BEGIN
    -- For INSERT operations
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (
            table_name, record_id, action, new_data, action_timestamp
        ) VALUES (
            TG_TABLE_NAME, NEW.employee_id, 'INSERT', to_jsonb(NEW), CURRENT_TIMESTAMP
        );

    -- For UPDATE operations
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (
            table_name, record_id, action, old_data, new_data, action_timestamp
        ) VALUES (
            TG_TABLE_NAME, NEW.employee_id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW), CURRENT_TIMESTAMP
        );

    -- For DELETE operations
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (
            table_name, record_id, action, old_data, action_timestamp
        ) VALUES (
            TG_TABLE_NAME, OLD.employee_id, 'DELETE', to_jsonb(OLD), CURRENT_TIMESTAMP
        );
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply to multiple tables
CREATE TRIGGER trigger_audit_employees
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW EXECUTE FUNCTION comprehensive_audit();

CREATE TRIGGER trigger_audit_departments
AFTER INSERT OR UPDATE OR DELETE ON departments
FOR EACH ROW EXECUTE FUNCTION comprehensive_audit();

CREATE TRIGGER trigger_audit_products
AFTER INSERT OR UPDATE OR DELETE ON products
FOR EACH ROW EXECUTE FUNCTION comprehensive_audit();
```

### **2. Data Replication**
```sql
-- Create a replica table
CREATE TABLE employees_replica (LIKE employees);

-- Create replication trigger
CREATE OR REPLACE FUNCTION replicate_employees()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO employees_replica VALUES (NEW.*);
    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE employees_replica SET
            first_name = NEW.first_name,
            last_name = NEW.last_name,
            email = NEW.email,
            salary = NEW.salary,
            department_id = NEW.department_id,
            hire_date = NEW.hire_date,
            last_updated = NEW.last_updated,
            created_by = NEW.created_by
        WHERE employee_id = NEW.employee_id;
    ELSIF TG_OP = 'DELETE' THEN
        DELETE FROM employees_replica
        WHERE employee_id = OLD.employee_id;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_replicate_employees
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW EXECUTE FUNCTION replicate_employees();
```

### **3. Soft Delete Implementation**
```sql
-- Add is_deleted column to employees
ALTER TABLE employees ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;

-- Create soft delete trigger
CREATE OR REPLACE FUNCTION soft_delete_employee()
RETURNS TRIGGER AS $$
BEGIN
    -- Instead of deleting, mark as deleted
    UPDATE employees SET
        is_deleted = TRUE,
        last_updated = CURRENT_TIMESTAMP
    WHERE employee_id = OLD.employee_id;

    RETURN OLD;  -- Return OLD to indicate no actual delete
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_soft_delete_employee
INSTEAD OF DELETE ON employees
FOR EACH ROW EXECUTE FUNCTION soft_delete_employee();

-- Create a view for active employees
CREATE VIEW active_employees AS
SELECT * FROM employees WHERE is_deleted = FALSE;
```

### **4. Automatic Data Archiving**
```sql
-- Create archive table
CREATE TABLE employees_archive (LIKE employees);
ALTER TABLE employees_archive ADD COLUMN archive_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Create archiving trigger
CREATE OR REPLACE FUNCTION archive_old_employees()
RETURNS TRIGGER AS $$
DECLARE
    employee_record employees%ROWTYPE;
BEGIN
    -- Check if employee is being marked as inactive
    IF NEW.is_active = FALSE AND OLD.is_active = TRUE THEN
        -- Archive the employee record
        INSERT INTO employees_archive SELECT OLD.*;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_archive_employees
BEFORE UPDATE ON employees
FOR EACH ROW
WHEN (NEW.is_active = FALSE AND OLD.is_active = TRUE)
EXECUTE FUNCTION archive_old_employees();
```

### **5. Inventory Management**
```sql
-- Trigger to update stock when order items are added
CREATE OR REPLACE FUNCTION update_product_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- For INSERT operations (new order items)
    IF TG_OP = 'INSERT' THEN
        UPDATE products
        SET stock_quantity = stock_quantity - NEW.quantity,
            last_updated = CURRENT_TIMESTAMP
        WHERE product_id = NEW.product_id;

    -- For UPDATE operations (changed quantities)
    ELSIF TG_OP = 'UPDATE' THEN
        -- Adjust stock based on quantity change
        UPDATE products
        SET stock_quantity = stock_quantity + (OLD.quantity - NEW.quantity),
            last_updated = CURRENT_TIMESTAMP
        WHERE product_id = NEW.product_id;

    -- For DELETE operations (removed order items)
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE products
        SET stock_quantity = stock_quantity + OLD.quantity,
            last_updated = CURRENT_TIMESTAMP
        WHERE product_id = OLD.product_id;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_product_stock
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW EXECUTE FUNCTION update_product_stock();

-- Trigger to prevent negative stock
CREATE OR REPLACE FUNCTION prevent_negative_stock()
RETURNS TRIGGER AS $$
DECLARE
    available_stock INTEGER;
BEGIN
    -- Check available stock for INSERT/UPDATE
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NEW.quantity > OLD.quantity) THEN
        SELECT stock_quantity INTO available_stock
        FROM products
        WHERE product_id = NEW.product_id;

        IF available_stock < NEW.quantity THEN
            RAISE EXCEPTION 'Insufficient stock for product % (available: %, requested: %)',
                NEW.product_id, available_stock, NEW.quantity;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_prevent_negative_stock
BEFORE INSERT OR UPDATE ON order_items
FOR EACH ROW EXECUTE FUNCTION prevent_negative_stock();
```

### **6. Automatic Notification System**
```sql
-- Create notifications table
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notification_type VARCHAR(50),
    reference_id INTEGER,
    reference_table VARCHAR(50)
);

-- Trigger for salary change notifications
CREATE OR REPLACE FUNCTION notify_salary_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.salary <> OLD.salary THEN
        INSERT INTO notifications (
            user_id, message, notification_type, reference_id, reference_table
        ) VALUES (
            NEW.employee_id,
            format('Your salary has been updated from $%.2f to $%.2f', OLD.salary, NEW.salary),
            'SALARY_CHANGE',
            NEW.employee_id,
            'employees'
        );

        -- Also notify the manager if this is a significant change
        IF NEW.salary > OLD.salary * 1.1 THEN  -- More than 10% increase
            INSERT INTO notifications (
                user_id, message, notification_type, reference_id, reference_table
            ) VALUES (
                (SELECT manager_id FROM departments WHERE department_id = NEW.department_id),
                format('Salary for % % increased by more than 10%% to $%.2f',
                      NEW.first_name, NEW.last_name, NEW.salary),
                'SALARY_ALERT',
                NEW.employee_id,
                'employees'
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_salary_change
AFTER UPDATE ON employees
FOR EACH ROW
WHEN (NEW.salary IS DISTINCT FROM OLD.salary)
EXECUTE FUNCTION notify_salary_change();
```

---
## **9. Security Considerations** <a name="security"></a>

### **Secure Trigger Practices**
```sql
-- 1. Use DEFINER rights carefully
CREATE OR REPLACE FUNCTION secure_employee_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the user has permission to update this employee
    IF NOT EXISTS (
        SELECT 1 FROM user_permissions
        WHERE user_id = current_setting('app.current_user_id')::integer
        AND (permission = 'admin' OR
             (permission = 'department_manager' AND
              NEW.department_id IN (
                  SELECT department_id FROM departments
                  WHERE manager_id = current_setting('app.current_user_id')::integer
              ))
            )
    ) THEN
        RAISE EXCEPTION 'You do not have permission to update this employee';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Validate all inputs in triggers
CREATE OR REPLACE FUNCTION validate_employee_data()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate email format
    IF NEW.email !~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
        RAISE EXCEPTION 'Invalid email format';
    END IF;

    -- Validate salary range
    IF NEW.salary < 0 OR NEW.salary > 1000000 THEN
        RAISE EXCEPTION 'Salary out of valid range (0-1,000,000)';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Use row-level security with triggers
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

CREATE POLICY employee_access_policy ON employees
    USING (created_by = current_user OR pg_has_role(current_user, 'admin', 'member'));

-- 4. Log sensitive operations
CREATE OR REPLACE FUNCTION log_sensitive_operations()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND (NEW.salary <> OLD.salary OR NEW.department_id <> OLD.department_id) THEN
        INSERT INTO sensitive_operation_log (
            table_name, record_id, operation, old_data, new_data, user_id
        ) VALUES (
            TG_TABLE_NAME, NEW.employee_id, TG_OP,
            to_jsonb(OLD), to_jsonb(NEW), current_setting('app.current_user_id')::integer
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_sensitive_operations
AFTER UPDATE ON employees
FOR EACH ROW EXECUTE FUNCTION log_sensitive_operations();
```

---
## **10. Complete Example: Audit System** <a name="audit-system"></a>

### **Enhanced Audit System Implementation**

```sql
-- 1. Create comprehensive audit tables
CREATE TABLE audit_logs (
    audit_id BIGSERIAL PRIMARY KEY,
    schema_name VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id TEXT,
    action VARCHAR(10) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')),
    action_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    transaction_id BIGINT,
    application_user VARCHAR(100),
    client_address INET,
    old_data JSONB,
    new_data JSONB,
    changed_fields JSONB
);

CREATE INDEX idx_audit_logs_table ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(action_timestamp);
CREATE INDEX idx_audit_logs_transaction ON audit_logs(transaction_id);

-- 2. Create a function to capture changed fields
CREATE OR REPLACE FUNCTION get_changed_fields(OLD JSONB, NEW JSONB)
RETURNS JSONB AS $$
DECLARE
    result JSONB := '{}'::jsonb;
    old_key TEXT;
    old_value JSONB;
    new_value JSONB;
BEGIN
    FOR old_key, old_value IN SELECT * FROM jsonb_each(OLD)
    LOOP
        new_value := NEW->>old_key;

        -- Only compare if the key exists in NEW
        IF NEW ? old_key THEN
            IF old_value <> new_value THEN
                result := result || jsonb_build_object(
                    old_key,
                    jsonb_build_object(
                        'old', old_value,
                        'new', new_value
                    )
                );
            END IF;
        ELSE
            -- Key was deleted
            result := result || jsonb_build_object(
                old_key,
                jsonb_build_object(
                    'old', old_value,
                    'new', NULL
                )
            );
        END IF;
    END LOOP;

    -- Check for new fields in NEW that weren't in OLD
    FOR old_key, new_value IN SELECT * FROM jsonb_each(NEW)
    LOOP
        IF NOT OLD ? old_key THEN
            result := result || jsonb_build_object(
                old_key,
                jsonb_build_object(
                    'old', NULL,
                    'new', new_value
                )
            );
        END IF;
    END LOOP;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 3. Create the master audit trigger function
CREATE OR REPLACE FUNCTION audit_trail()
RETURNS TRIGGER AS $$
DECLARE
    audit_record RECORD;
BEGIN
    -- For INSERT operations
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_logs (
            schema_name, table_name, record_id, action,
            old_data, new_data, changed_fields, application_user, client_address, transaction_id
        ) VALUES (
            TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW.employee_id::TEXT, 'INSERT',
            NULL, to_jsonb(NEW), NULL,
            current_user, inet_client_addr(), txid_current()
        );

    -- For UPDATE operations
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_logs (
            schema_name, table_name, record_id, action,
            old_data, new_data, changed_fields, application_user, client_address, transaction_id
        ) VALUES (
            TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW.employee_id::TEXT, 'UPDATE',
            to_jsonb(OLD), to_jsonb(NEW), get_changed_fields(to_jsonb(OLD), to_jsonb(NEW)),
            current_user, inet_client_addr(), txid_current()
        );

    -- For DELETE operations
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_logs (
            schema_name, table_name, record_id, action,
            old_data, new_data, changed_fields, application_user, client_address, transaction_id
        ) VALUES (
            TG_TABLE_SCHEMA, TG_TABLE_NAME, OLD.employee_id::TEXT, 'DELETE',
            to_jsonb(OLD), NULL, NULL,
            current_user, inet_client_addr(), txid_current()
        );
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Create a function to apply audit triggers to a table
CREATE OR REPLACE FUNCTION setup_audit_triggers(p_table_name TEXT)
RETURNS VOID AS $$
BEGIN
    EXECUTE format('
        CREATE TRIGGER audit_%s_trigger
        AFTER INSERT OR UPDATE OR DELETE ON %I
        FOR EACH ROW EXECUTE FUNCTION audit_trail()',
        replace(p_table_name, '.', '_'), p_table_name);
END;
$$ LANGUAGE plpgsql;

-- 5. Apply audit triggers to our tables
SELECT setup_audit_triggers('employees');
SELECT setup_audit_triggers('departments');
SELECT setup_audit_triggers('products');
SELECT setup_audit_triggers('customers');
SELECT setup_audit_triggers('orders');
SELECT setup_audit_triggers('order_items');

-- 6. Create a function to restore data from audit logs
CREATE OR REPLACE FUNCTION restore_from_audit(
    p_table_name TEXT,
    p_record_id TEXT,
    p_audit_id BIGINT
) RETURNS VOID AS $$
DECLARE
    old_data JSONB;
    new_data JSONB;
    query TEXT;
BEGIN
    -- Get the audit record
    SELECT old_data, new_data INTO old_data, new_data
    FROM audit_logs
    WHERE audit_id = p_audit_id;

    -- Determine the appropriate restore action
    IF (SELECT action FROM audit_logs WHERE audit_id = p_audit_id) = 'DELETE' THEN
        -- Restore a deleted record
        query := format('INSERT INTO %I SELECT * FROM jsonb_populate_record(NULL::%I, $1)',
                       p_table_name, p_table_name);
        EXECUTE query USING old_data;

    ELSIF (SELECT action FROM audit_logs WHERE audit_id = p_audit_id) = 'UPDATE' THEN
        -- Revert an update
        query := format('UPDATE %I SET %s WHERE %s = $1',
                       p_table_name,
                       (SELECT string_agg(format('%I = $1->>''%s''', attname, attname), ', ')
                        FROM pg_attribute
                        WHERE attrelid = p_table_name::regclass
                        AND attnum > 0
                        AND NOT attisdropped),
                       (SELECT a.attname
                        FROM pg_attribute a
                        WHERE a.attrelid = p_table_name::regclass
                        AND a.attname LIKE '%id'
                        AND a.attnum > 0
                        LIMIT 1));
        EXECUTE query USING old_data, p_record_id;

    ELSIF (SELECT action FROM audit_logs WHERE audit_id = p_audit_id) = 'INSERT' THEN
        -- Delete a mistakenly inserted record
        query := format('DELETE FROM %I WHERE %s = $1',
                       p_table_name,
                       (SELECT a.attname
                        FROM pg_attribute a
                        WHERE a.attrelid = p_table_name::regclass
                        AND a.attname LIKE '%id'
                        AND a.attnum > 0
                        LIMIT 1));
        EXECUTE query USING p_record_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 7. Create a view for audit reporting
CREATE VIEW audit_report AS
SELECT
    audit_id,
    schema_name || '.' || table_name AS full_table_name,
    record_id,
    action,
    action_timestamp,
    transaction_id,
    application_user,
    client_address,
    jsonb_pretty(old_data) AS old_data,
    jsonb_pretty(new_data) AS new_data,
    jsonb_pretty(changed_fields) AS changed_fields
FROM
    audit_logs
ORDER BY
    action_timestamp DESC;

-- 8. Create a function to get change history for a record
CREATE OR REPLACE FUNCTION get_record_history(
    p_table_name TEXT,
    p_record_id TEXT
) RETURNS TABLE (
    audit_id BIGINT,
    action VARCHAR(10),
    action_timestamp TIMESTAMP WITH TIME ZONE,
    changed_fields JSONB,
    old_data JSONB,
    new_data JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        audit_id,
        action,
        action_timestamp,
        changed_fields,
        old_data,
        new_data
    FROM
        audit_logs
    WHERE
        table_name = p_table_name
        AND record_id = p_record_id
    ORDER BY
        action_timestamp DESC;
END;
$$ LANGUAGE plpgsql;
```

---
## **Sample Data for Testing Triggers**

```sql
-- Insert sample departments
INSERT INTO departments (department_name, budget, location) VALUES
('Engineering', 1000000, 'Building A'),
('Marketing', 500000, 'Building B'),
('Sales', 750000, 'Building C'),
('Human Resources', 300000, 'Building A'),
('Finance', 400000, 'Building B');

-- Insert sample employees
INSERT INTO employees (first_name, last_name, email, salary, department_id, hire_date) VALUES
('John', 'Smith', 'john.smith@example.com', 85000, 1, CURRENT_DATE - INTERVAL '5 years'),
('Jane', 'Doe', 'jane.doe@example.com', 95000, 1, CURRENT_DATE - INTERVAL '3 years'),
('Robert', 'Johnson', 'robert.johnson@example.com', 75000, 2, CURRENT_DATE - INTERVAL '4 years'),
('Emily', 'Davis', 'emily.davis@example.com', 80000, 3, CURRENT_DATE - INTERVAL '2 years'),
('Michael', 'Brown', 'michael.brown@example.com', 120000, 1, CURRENT_DATE - INTERVAL '6 years'),
('Sarah', 'Wilson', 'sarah.wilson@example.com', 70000, 2, CURRENT_DATE - INTERVAL '1 year'),
('David', 'Taylor', 'david.taylor@example.com', 90000, 3, CURRENT_DATE - INTERVAL '3 years'),
('Jessica', 'Anderson', 'jessica.anderson@example.com', 65000, 4, CURRENT_DATE - INTERVAL '2 years'),
('Thomas', 'Martinez', 'thomas.martinez@example.com', 110000, 5, CURRENT_DATE - INTERVAL '7 years'),
('Lisa', 'Robinson', 'lisa.robinson@example.com', 82000, 1, CURRENT_DATE - INTERVAL '4 years');

-- Update department managers
UPDATE departments SET manager_id =
    (SELECT employee_id FROM employees WHERE email = 'michael.brown@example.com')
WHERE department_id = 1;

UPDATE departments SET manager_id =
    (SELECT employee_id FROM employees WHERE email = 'jane.doe@example.com')
WHERE department_id = 2;

UPDATE departments SET manager_id =
    (SELECT employee_id FROM employees WHERE email = 'david.taylor@example.com')
WHERE department_id = 3;

-- Insert sample products
INSERT INTO products (product_name, price, stock_quantity, category) VALUES
('Laptop Pro', 1299.99, 50, 'Electronics'),
('Smartphone X', 899.99, 100, 'Electronics'),
('Desk Chair', 199.99, 30, 'Furniture'),
('Coffee Maker', 89.99, 40, 'Appliances'),
('Wireless Headphones', 149.99, 60, 'Electronics'),
('Standing Desk', 349.99, 15, 'Furniture'),
('Blender', 79.99, 25, 'Appliances'),
('Monitor', 249.99, 20, 'Electronics'),
('Keyboard', 49.99, 50, 'Accessories'),
('Mouse', 29.99, 80, 'Accessories');

-- Insert sample customers
INSERT INTO customers (customer_name, email, phone, credit_limit) VALUES
('Acme Corporation', 'contact@acme.com', '555-123-4567', 10000.00),
('Globex Inc', 'sales@globex.com', '555-234-5678', 15000.00),
('Initech', 'orders@initech.com', '555-345-6789', 20000.00),
('Wayne Enterprises', 'purchasing@wayne.com', '555-456-7890', 50000.00),
('Stark Industries', 'procurement@stark.com', '555-567-8901', 100000.00),
('Oscorp', 'orders@oscorp.com', '555-678-9012', 25000.00),
('Umbrella Corp', 'purchasing@umbrella.com', '555-789-0123', 30000.00),
('Cyberdyne Systems', 'orders@cyberdyne.com', '555-890-1234', 15000.00),
('Tyrell Corporation', 'procurement@tyrell.com', '555-901-2345', 20000.00),
('Weyland-Yutani', 'purchasing@weyland.com', '555-012-3456', 50000.00);

-- Insert sample orders
INSERT INTO orders (customer_id, order_date, status, total_amount) VALUES
((SELECT customer_id FROM customers WHERE email = 'contact@acme.com'),
 CURRENT_DATE - INTERVAL '30 days', 'Delivered', 2499.98),

((SELECT customer_id FROM customers WHERE email = 'sales@globex.com'),
 CURRENT_DATE - INTERVAL '15 days', 'Delivered', 1799.97),

((SELECT customer_id FROM customers WHERE email = 'orders@initech.com'),
 CURRENT_DATE - INTERVAL '7 days', 'Shipped', 3299.96),

((SELECT customer_id FROM customers WHERE email = 'purchasing@wayne.com'),
 CURRENT_DATE - INTERVAL '2 days', 'Processing', 5999.95),

((SELECT customer_id FROM customers WHERE email = 'procurement@stark.com'),
 CURRENT_DATE - INTERVAL '1 day', 'Pending', 12499.90);

-- Insert sample order items
-- Get order IDs first
WITH order_ids AS (
    SELECT order_id, customer_id FROM orders
)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    o.order_id,
    (SELECT product_id FROM products ORDER BY random() LIMIT 1),
    FLOOR(random() * 3 + 1),  -- 1-3 items
    (SELECT price FROM products WHERE product_id =
        (SELECT product_id FROM products ORDER BY random() LIMIT 1))
FROM
    order_ids o
-- Join with products to get actual prices
ON CONFLICT DO NOTHING;

-- Update order items with correct prices
UPDATE order_items oi
SET unit_price = p.price
FROM products p
WHERE oi.product_id = p.product_id;

-- Update order amounts based on order items
UPDATE orders o
SET total_amount = (
    SELECT COALESCE(SUM(oi.quantity * oi.unit_price), 0)
    FROM order_items oi
    WHERE oi.order_id = o.order_id
);
```

---
## **Testing the Triggers**

```sql
-- Test 1: Update an employee salary (should log to salary_history and audit_logs)
UPDATE employees
SET salary = 90000
WHERE email = 'john.smith@example.com';

-- Verify the salary history
SELECT * FROM salary_history WHERE employee_id =
    (SELECT employee_id FROM employees WHERE email = 'john.smith@example.com');

-- Verify the audit log
SELECT * FROM audit_logs WHERE table_name = 'employees' ORDER BY action_timestamp DESC LIMIT 1;

-- Test 2: Try to decrease salary (should fail)
BEGIN;
UPDATE employees
SET salary = 80000
WHERE email = 'john.smith@example.com';
-- Should rollback due to the prevent_salary_decrease trigger
ROLLBACK;

-- Test 3: Insert a new employee (should log to audit)
INSERT INTO employees (first_name, last_name, email, salary, department_id)
VALUES ('William', 'Lee', 'william.lee@example.com', 75000, 1);

-- Verify the audit log
SELECT * FROM audit_logs WHERE table_name = 'employees' ORDER BY action_timestamp DESC LIMIT 1;

-- Test 4: Update department budget (should recalculate based on employee salaries)
UPDATE employees
SET salary = 95000
WHERE email = 'jane.doe@example.com';

-- Check the department budget was updated
SELECT * FROM departments WHERE department_id = 1;

-- Test 5: Try to insert an order item with insufficient stock
BEGIN;
-- First check current stock
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity > 0 LIMIT 1;

-- Then try to order more than available
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (
    (SELECT order_id FROM orders LIMIT 1),
    (SELECT product_id FROM products WHERE stock_quantity > 0 LIMIT 1),
    1000,  -- More than available stock
    (SELECT price FROM products WHERE stock_quantity > 0 LIMIT 1)
);
-- Should fail due to prevent_negative_stock trigger
ROLLBACK;

-- Test 6: Update a product price (should update timestamp)
UPDATE products
SET price = 1399.99
WHERE product_name = 'Laptop Pro';

-- Verify the timestamp was updated
SELECT product_name, last_updated FROM products WHERE product_name = 'Laptop Pro';

-- Test 7: Delete an employee (should soft delete and archive)
-- First enable the soft delete trigger if not already enabled
UPDATE employees SET is_active = FALSE
WHERE email = 'william.lee@example.com';

-- Check if archived
SELECT * FROM employees_archive;

-- Check if marked as deleted
SELECT is_deleted FROM employees WHERE email = 'william.lee@example.com';

-- Test 8: View the audit trail for a specific employee
SELECT * FROM get_record_history('employees',
    (SELECT employee_id::TEXT FROM employees WHERE email = 'john.smith@example.com' LIMIT 1));
```

---
## **Trigger Best Practices Summary**

1. **Keep triggers simple**: Complex business logic belongs in application code
2. **Document triggers**: Add comments explaining purpose and behavior
3. **Test thoroughly**: Triggers can be hard to debug - test all edge cases
4. **Consider performance**: Statement-level triggers are often better for bulk operations
5. **Handle errors gracefully**: Use exception blocks to log errors
6. **Avoid recursion**: Be careful with triggers that might cause themselves to fire
7. **Use conditional triggers**: The WHEN clause can improve performance
8. **Monitor trigger activity**: Use pg_stat_user_functions to track execution
9. **Consider alternatives**: Sometimes constraints, rules, or application logic are better
10. **Version control**: Include trigger definitions in your database version control

---
## **Complete Trigger Reference Table**

| Trigger Type | Timing | Event | Use Case |
|--------------|--------|-------|----------|
| BEFORE INSERT | Before row inserted | INSERT | Set default values, validate data |
| AFTER INSERT | After row inserted | INSERT | Log changes, update related tables |
| BEFORE UPDATE | Before row updated | UPDATE | Validate changes, calculate fields |
| AFTER UPDATE | After row updated | UPDATE | Log changes, update related tables |
| BEFORE DELETE | Before row deleted | DELETE | Validate deletion, archive data |
| AFTER DELETE | After row deleted | DELETE | Log deletion, update related tables |
| INSTEAD OF | Instead of operation | INSERT/UPDATE/DELETE | Implement updatable views |
| BEFORE TRUNCATE | Before truncate | TRUNCATE | Validate truncate operation |
| AFTER TRUNCATE | After truncate | TRUNCATE | Log truncate operation |

---
## **Final Notes**

This comprehensive guide provides:
1. **Complete trigger examples** for all common use cases
2. **Ready-to-use tables** with proper constraints
3. **Sample data** for testing
4. **Debugging techniques** for troubleshooting
5. **Performance considerations** for production use
6. **Security best practices** for sensitive operations
7. **Complete audit system** implementation

The triggers cover:
- Automatic field updates
- Data validation
- Audit trailing
- Business logic enforcement
- Cross-table operations
- Soft deletes
- Inventory management
- Notification systems

To use this guide:
1. Create the database and tables
2. Apply the triggers to your tables
3. Insert the sample data
4. Run the test cases to verify behavior
5. Adapt the examples to your specific requirements

Would you like me to:
1. Add more specific trigger examples for your use case?
2. Provide additional debugging techniques?
3. Create more complex business logic examples?
4. Add examples for specific industries (healthcare, finance, etc.)?
