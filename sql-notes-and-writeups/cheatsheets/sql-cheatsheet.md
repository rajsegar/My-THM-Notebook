# SQL Cheatsheet

Quick revision reference for all core SQL topics.

---

## SELECT
```sql
SELECT * FROM table_name;
SELECT column1, column2 FROM table_name;
```

## WHERE
```sql
SELECT * FROM table_name WHERE condition;
SELECT * FROM table_name WHERE column = 'value';
```

## ORDER BY
```sql
SELECT * FROM table_name ORDER BY column ASC;
SELECT * FROM table_name ORDER BY column DESC;
```

---

## CRUD
```sql
-- Create
INSERT INTO table_name (col1, col2) VALUES ('a', 'b');

-- Read
SELECT * FROM table_name;

-- Update
UPDATE table_name SET col1 = 'x' WHERE id = 1;

-- Delete
DELETE FROM table_name WHERE id = 1;
```

---

## Clauses
```sql
-- Distinct
SELECT DISTINCT column FROM table_name;

-- Group By
SELECT column, COUNT(*) FROM table_name GROUP BY column;

-- Having
SELECT column, COUNT(*) FROM table_name GROUP BY column HAVING condition;

-- Order By
SELECT * FROM table_name ORDER BY column DESC;
```

---

## Operators
```sql
-- Comparison
WHERE id = 1
WHERE id != 1
WHERE price > 10
WHERE price < 10
WHERE price >= 10
WHERE price <= 10

-- Pattern
WHERE name LIKE '%hack%'

-- Logical
WHERE col1 = 'a' AND col2 = 'b'
WHERE col1 = 'a' OR col1 = 'b'
WHERE NOT col1 LIKE '%guide%'

-- Range
WHERE id BETWEEN 2 AND 4
```

---

## Functions
```sql
-- String
SELECT CONCAT(col1, ' ', col2) FROM table_name;
SELECT SUBSTRING(column, 1, 4) FROM table_name;
SELECT LENGTH(column) FROM table_name;
SELECT GROUP_CONCAT(column SEPARATOR ', ') FROM table_name GROUP BY other_col;

-- Aggregate
SELECT COUNT(*) FROM table_name;
SELECT SUM(column) FROM table_name;
SELECT MAX(column) FROM table_name;
SELECT MIN(column) FROM table_name;
```

---

## Database Setup
```sql
CREATE DATABASE db_name;
SHOW DATABASES;
USE db_name;

CREATE TABLE table_name (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    date DATE
);

SHOW TABLES;
DESCRIBE table_name;
ALTER TABLE table_name ADD column_name INT;
```

---

## Clause Order
```sql
SELECT column
FROM table
WHERE condition
GROUP BY column
HAVING condition
ORDER BY column;
```
