# Database Schema Documentation: Facebook Users Table

## Overview
This document provides a detailed breakdown of the `facebook_users` table structure and configuration in the `db168432_sql` database.

## Database Configuration

### Initial Settings
```sql
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";
```

### Character Set Configuration
```sql
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
```

## Table Structure

### Table Creation Statement
```sql
CREATE TABLE `facebook_users` (
  `ID` int(11) NOT NULL,
  `name` varchar(256) CHARACTER SET utf8 NOT NULL,
  `email` varchar(256) CHARACTER SET utf8 NOT NULL,
  `password` varchar(256) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

### Column Specifications

| Column Name | Data Type | Length | Nullable | Character Set | Description |
|-------------|-----------|--------|----------|---------------|-------------|
| ID          | int       | 11     | NOT NULL | -             | Primary key user identifier |
| name        | varchar   | 256    | NOT NULL | utf8          | User's display name |
| email       | varchar   | 256    | NOT NULL | utf8          | User's email address |
| password    | varchar   | 256    | NOT NULL | utf8          | Hashed password |

### Storage Engine
- **Engine:** InnoDB
- **Default charset:** latin1 (for table), utf8 for individual columns

## Sample Data

### Initial Data Insertion
```sql
INSERT INTO `facebook_users` (`ID`, `name`, `email`, `password`) VALUES
(1, 'chris', 'chris@gmail.com', '1234'),
(3, 'mattan', 'mattan@gmail.com', '1234e41234e41234e41234e41234e4');
```

### Current User Records

| ID | name   | email            | password                         |
|----|--------|------------------|----------------------------------|
| 1  | chris  | chris@gmail.com  | 1234                             |
| 3  | mattan | mattan@gmail.com | 1234e41234e41234e41234e41234e4   |

## Indexes and Constraints

### Primary Key
```sql
ALTER TABLE `facebook_users`
  ADD PRIMARY KEY (`ID`);
```

### Auto-increment Configuration
```sql
ALTER TABLE `facebook_users`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
```

## Security Considerations

1. **Password Storage**:
   - Currently stores passwords in what appears to be plaintext or weak hashing
   - **Recommendation**: Implement strong hashing (bcrypt, Argon2)

2. **Character Sets**:
   - Mixed character sets (utf8 for columns, latin1 for table)
   - **Recommendation**: Standardize on utf8mb4 for full Unicode support

3. **Email Validation**:
   - No apparent constraints on email format
   - **Recommendation**: Add validation or use proper email data type

## Transaction Management
```sql
COMMIT;
```

## Final Configuration Restoration
```sql
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
```

## Suggested Improvements

1. **Add Additional Fields**:
   ```sql
   ALTER TABLE `facebook_users`
     ADD `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     ADD `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
   ```

2. **Implement Proper Authentication**:
   ```sql
   ALTER TABLE `facebook_users`
     MODIFY `password` VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL;
   ```

3. **Add Unique Constraints**:
   ```sql
   ALTER TABLE `facebook_users`
     ADD UNIQUE KEY `unique_email` (`email`);
   ```

This documentation provides a comprehensive view of the current implementation while highlighting areas for security and functionality improvements.
