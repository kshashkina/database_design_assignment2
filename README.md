# Cinema Database 

## Overview

This project involves creating and populating a cinema database that stores information about clients, movies, and bookings. The project focuses on generating realistic data using the Faker library, optimizing SQL queries, and analyzing database performance through execution plan comparison.

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/kshashkina/database_design_assignment2
cd database_design_assignment2
```

### 2. Install Dependencies

Ensure you have Python 3.x installed. Run the following command to install dependencies from `requirements.txt`.

```bash
pip install -r requirements.txt
```

### 3. Setup Database

Ensure you have MySQL installed and running. Create the cinema database by running the provided SQL schema.

```bash
mysql -u root -p < databaseCreation.sql
```

Update the connection dependencies with your MySQL connection details:
```
HOST=localhost
USER=root
PASSWORD=your_password
DATABASE=cinema_db
```

### 4. Populate the Database

Run the script to insert clients, movies, and bookings data into the database.

```bash
python main.py
```

This script will insert:
- 100,000 clients
- 1,000 movies
- 100,000 bookings

### 5. Query the Database

Run both optimized and unoptimized SQL queries using MySQL Workbench or a MySQL client:

- **Unoptimized Queries**: `UnoptimizedQuery.sql`
- **Optimized Queries**: `OptimizedQuery.sql`

## Database Schema

The schema consists of three tables: `clients`, `movies`, and `bookings`.

### Table: `clients`

| Column           | Type          | Description                        |
|------------------|---------------|------------------------------------|
| `id`             | VARCHAR(36)   | Primary key, UUID of the client.   |
| `first_name`     | VARCHAR(255)  | First name of the client.          |
| `last_name`      | VARCHAR(255)  | Last name of the client.           |
| `email`          | VARCHAR(255)  | Email address of the client.       |
| `phone`          | VARCHAR(255)  | Phone number of the client.        |
| `membership_status` | ENUM        | Client membership status (vip/regular). |

### Table: `movies`

| Column           | Type          | Description                        |
|------------------|---------------|------------------------------------|
| `id`             | INT           | Primary key, auto-incremented.     |
| `title`          | VARCHAR(255)  | Title of the movie.                |
| `genre`          | VARCHAR(255)  | Genre of the movie (e.g., Action). |
| `description`    | TEXT          | Description of the movie.          |
| `release_year`   | INT           | Release year of the movie.         |

### Table: `bookings`

| Column           | Type          | Description                        |
|------------------|---------------|------------------------------------|
| `id`             | INT           | Primary key, auto-incremented.     |
| `client_id`      | VARCHAR(36)   | Foreign key referencing `clients.id`. |
| `movie_id`       | INT           | Foreign key referencing `movies.id`. |
| `booking_date`   | DATETIME      | Date and time of the booking.      |
| `seat_number`    | VARCHAR(10)   | Seat number of the booking.        |
| `price`          | DECIMAL(10,2) | Price of the ticket.               |

## Data Generation

The data in the `clients`, `movies`, and `bookings` tables is generated using the Faker library in Python. The `main.py` script performs the following:

- **Clients**: Generates 100,000 clients with random names, emails, and phone numbers.
- **Movies**: Generates 1,000 movies with random titles, genres, and release years.
- **Bookings**: Generates 100,000 bookings by randomly associating clients and movies. The booking date is within the last 3 years, and ticket prices vary between $5 and $1,000.

## Query Optimization

For query optimization indexes and CTE were used:

Here's a table comparing the unoptimized and optimized query execution plans:

---

## Execution Plan Comparison
### Unoptimized

| **Query**         | **Stage**        | **Table** | **Access Type**     | **Index**        | **Key Length** | **Rows Scanned** | **Filtered** | **Extra Information**                        |
|-------------------|------------------|-----------|---------------------|------------------|----------------|------------------|--------------|------------------------------------------------|
| **Unoptimized**   | PRIMARY          | `c`       | ALL                 | PRIMARY          | N/A            | 10,414           | 100.00%      | Using where; Using temporary; Using filesort   |
|                   | PRIMARY (subquery) | `<subquery7>` | eq_ref             | `<auto_distinct_key>` | 147            | 1                | 100.00%      |                                                |
|                   | MATERIALIZED     | `b`       | ALL                 | `client_id`      | N/A            | 99,750           | 100.00%      | Using where                                   |
|                   | SUBQUERY         | `b2`      | ALL                 | `client_id`      | N/A            | 99,750           | 33.33%       | Using where                                   |
|                   | DEPENDENT SUBQUERY | `b`     | ref                 | `client_id,movie_id` | 147          | 10               | 100.00%      | Using where                                   |
|                   | DEPENDENT SUBQUERY | `m`     | eq_ref              | PRIMARY          | 4              | 1                | 100.00%      |                                                |
|                   | DEPENDENT SUBQUERY | `b`     | ref                 | `client_id`      | 147            | 10               | 100.00%      | Using where                                   |
|                   | DEPENDENT SUBQUERY | `b`     | ref                 | `client_id`      | 147            | 10               | 100.00%      | Using where                                   |
|                   | DEPENDENT SUBQUERY | `b`     | ref                 | `client_id`      | 147            | 10               | 100.00%      | Using where                                   |

---
### Optimized


| **Query**   | **Stage**  | **Table**    | **Access Type** | **Index**                | **Key Length** | **Rows Scanned** | **Filtered** | **Extra Information**                         |
|-------------|------------|--------------|-----------------|--------------------------|----------------|------------------|--------------|-----------------------------------------------|
| **Optimized** | PRIMARY    | `<derived4>` | ALL             | N/A                      | N/A            | 98,958           | 100.00%      | Using where; Using filesort                   |
|             | PRIMARY    | `c`          | eq_ref          | PRIMARY                  | 146            | 1                | 100.00%      |                                               |
|             | DERIVED    | `m`          | ALL             | PRIMARY                  | N/A            | 1,000            | 100.00%      | Using temporary; Using filesort               |
|             | DERIVED    | `b`          | ref             | `idx_client_id, idx_movie_id` | 5           | 98               | 100.00%      | Using where                                   |
|             | SUBQUERY   | `<derived3>` | ALL             | N/A                      | N/A            | 2                | 100.00%      |                                               |
|             | DERIVED    | `b`          | range           | `idx_client_id, idx_price` | 6            | 1                | 100.00%      | Using index condition; Using where; Using temporary |

### Summary of Execution Plans

| Aspect                            | Unoptimized Query Execution Plan                             | Optimized Query Execution Plan                                |
|-----------------------------------|-------------------------------------------------------------|--------------------------------------------------------------|
| **Total Rows Scanned**            | Up to **99,750 rows** for bookings                          | **98 rows** for bookings                                      |
| **Types of Joins**                | Multiple **DEPENDENT SUBQUERY** calls                       | Reduced to **JOIN** with derived tables                       |
| **Table Scans**                   | Full table scans indicated by `ALL`                         | More selective row access indicated by `ref` and `range`     |
| **Subquery Executions**           | High number of **subqueries** executed for each client      | Consolidated into **derived tables**, reducing subquery count |
| **Use of Temporary Tables**       | Several instances of `Using temporary`                      | Reduced instances of temporary tables                         |
| **Sorting Mechanism**             | `Using filesort` in multiple instances                      | `Using filesort` present, but less impactful due to reduced data |
| **Index Utilization**             | Minimal index usage, leading to many full scans             | Effective use of indexes like `idx_client_id` and `idx_price` |
| **Execution Speed**               | Slower due to high number of operations and full scans      | Faster due to efficient access paths and reduced row counts    |
| **Overall Query Complexity**      | High complexity with many subqueries                        | Lower complexity with structured derived tables and CTEs      |

### Detailed Comparison

1. **Row Scanning and Filtering**:
   - **Unoptimized**: The execution plan shows that the database is scanning a large number of rows (up to **99,750**) due to full scans on the `bookings` table and using multiple dependent subqueries, which slows down the query significantly.
   - **Optimized**: The number of rows processed is reduced to **98**, significantly improving performance. The use of derived tables allows for more efficient data aggregation in a single pass.

2. **Subqueries vs. Derived Tables**:
   - **Unoptimized**: The execution plan indicates several dependent subqueries that run for each client, increasing the number of reads from the `bookings` table.
   - **Optimized**: The optimized version uses **derived tables** to gather necessary data in one go, reducing the overall complexity and number of times data is read from the database.

3. **Index Usage**:
   - **Unoptimized**: The lack of effective index usage is evident, with the database performing full table scans instead of leveraging available indexes.
   - **Optimized**: The optimized plan shows a significant improvement with the use of indexes (`idx_client_id`, `idx_price`), which helps the database quickly locate relevant rows, minimizing the rows processed.

4. **Temporary Tables**:
   - **Unoptimized**: The presence of `Using temporary` in multiple instances indicates that temporary tables are being used extensively, which can slow down performance.
   - **Optimized**: Although temporary tables are still present, their impact is reduced as the amount of data being processed is smaller and more targeted.

5. **Sorting and File Sorting**:
   - **Unoptimized**: The use of `Using filesort` indicates that the database had to sort a large number of rows, which can be costly in terms of performance.
   - **Optimized**: The `Using filesort` is still present but is less of an issue due to the reduced number of rows being sorted.

6. **Performance Implications**:
   - The unoptimized query is likely to experience significant delays in execution due to the high number of rows processed and multiple subqueries.
   - The optimized query will execute much faster because of fewer rows to process, effective use of indexing, and reduced complexity.

### Conclusion

The optimization efforts in the second execution plan yield significant performance improvements by:

- Reducing the total number of rows processed.
- Consolidating operations through the use of derived tables and Common Table Expressions (CTEs).
- Effectively utilizing indexes to speed up data retrieval.
- Minimizing the reliance on temporary tables and sorting operations.

Overall, this comparison highlights the importance of query structure and indexing in optimizing SQL performance, particularly in scenarios involving large datasets and complex operations.