# Database Schema Documentation: `db168432_sql`

## System Information
- **phpMyAdmin Version**: 4.9.1
- **Server Version**: 5.6.34-79.1
- **PHP Version**: 7.3.11
- **Host**: internal-db.s168432.gridserver.com
- **Generation Time**: April 21, 2020 at 08:26 PM

## Database Configuration
```sql
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
```

## Table Structures

### 1. `comments` Table
**Purpose**: Stores user comments on posts

#### Schema
```sql
CREATE TABLE `comments` (
  `ID` int(11) NOT NULL,
  `post_id` int(11) DEFAULT NULL,
  `comment_author` varchar(256) NOT NULL,
  `comment_author_email` varchar(256) NOT NULL,
  `comment_content` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

#### Sample Data
| ID | post_id | comment_author | comment_author_email | comment_content |
|----|---------|----------------|----------------------|-----------------|
| 1 | 6 | jessica | jessica@gmail.com | Great post! |
| 2 | 2 | mike | mike@gmail.com | Love it! Write more like this. |

### 2. `facebook_users` Table
**Purpose**: Stores user authentication data for Facebook integration

#### Schema
```sql
CREATE TABLE `facebook_users` (
  `ID` int(11) NOT NULL,
  `name` varchar(256) CHARACTER SET utf8 NOT NULL,
  `email` varchar(256) CHARACTER SET utf8 NOT NULL,
  `password` varchar(256) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

#### Security Note
- Passwords appear to be stored in plaintext or weakly hashed
- **Recommendation**: Implement strong password hashing (bcrypt)

### 3. `posts` Table
**Purpose**: Stores blog posts or articles

#### Schema
```sql
CREATE TABLE `posts` (
  `ID` int(11) NOT NULL,
  `post_author` varchar(255) NOT NULL,
  `post_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_title` varchar(255) NOT NULL,
  `post_status` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

#### Content Statuses
- `published`: Visible to all users
- `draft`: Only visible to authors/editors

### 4. `products` Table
**Purpose**: E-commerce product catalog

#### Schema
```sql
CREATE TABLE `products` (
  `ID` int(11) NOT NULL,
  `book_name` varchar(256) NOT NULL,
  `author` varchar(256) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

#### Inventory Management
- Tracks available stock with `quantity` field
- Prices stored with 2 decimal places precision

### 5. `purchases` Table
**Purpose**: Records customer purchases

#### Schema
```sql
CREATE TABLE `purchases` (
  `ID` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

#### Relationships
- `user_id` references `users.ID`
- `product_id` references `products.ID`

### 6. `states` Table
**Purpose**: Stores U.S. state information with associated drinks

#### Schema
```sql
CREATE TABLE `states` (
  `id` int(11) NOT NULL,
  `state` varchar(255) NOT NULL,
  `drink` varchar(255) NOT NULL,
  `year` int(10) NOT NULL,
  `image` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

### 7. `users` Table
**Purpose**: Main user authentication system

#### Schema
```sql
CREATE TABLE `users` (
  `ID` bigint(20) UNSIGNED NOT NULL,
  `user_login` varchar(60) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `user_pass` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `user_nicename` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `user_email` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
```

#### Security Observations
- Mixed password hashing implementations
- Some passwords appear to use WordPress-style hashing (`$P$B`)
- **Recommendation**: Standardize on modern password hashing

## Indexes and Constraints

### Primary Keys
All tables have properly defined primary keys on their `ID` columns.

### Foreign Key Recommendations
While not explicitly defined, these relationships exist:
- `comments.post_id` → `posts.ID`
- `purchases.user_id` → `users.ID`
- `purchases.product_id` → `products.ID`

**Recommendation**: Add explicit foreign key constraints.

## Character Set Considerations
- Mixed character sets (latin1, utf8, utf8mb4)
- **Recommendation**: Standardize on utf8mb4 for full Unicode support

## Optimization Recommendations

1. **Add Indexes**:
   ```sql
   CREATE INDEX idx_comments_post ON comments(post_id);
   CREATE INDEX idx_purchases_user ON purchases(user_id);
   CREATE INDEX idx_purchases_product ON purchases(product_id);
   ```

2. **Normalize Data**:
   - Consider separating authors into a dedicated table
   - Create categories for products

3. **Improve Security**:
   - Implement consistent password hashing
   - Add salt to password storage
   - Consider two-factor authentication

## Complete Schema Diagram
(Visual representation showing tables and relationships would be recommended here)

## Transaction Management
The schema includes proper transaction handling with:
```sql
START TRANSACTION;
COMMIT;
```

This documentation provides a comprehensive overview of the database structure while identifying areas for improvement in security, performance, and data integrity.
