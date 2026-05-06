# SQL Basics

## Meaning
SQL (Structured Query Language) is used to interact with databases. It lets you create, read, update, and delete data.

## Core Commands

### SELECT
**Meaning:** Choose what data to show.
**Syntax:** `SELECT column FROM table;`
**Example:** `SELECT drink, price FROM Orders;`
**Key point:** Used in almost every SQL query.

### FROM
**Meaning:** Choose which table to read from.
**Example:** `SELECT * FROM Orders;`
**Key point:** Always comes after SELECT.

### WHERE
**Meaning:** Keep only rows that match a condition.
**Example:** `SELECT * FROM Orders WHERE drink = 'Coffee';`
**Key point:** Filters rows before returning results.

### ORDER BY
**Meaning:** Sort the result.
**Example:** `SELECT * FROM Orders ORDER BY price DESC;`
**Key point:** ASC = low to high, DESC = high to low.

## Memory Trick
First pick data with **SELECT**, then say where it comes from with **FROM**, then filter with **WHERE**, then sort with **ORDER BY**.

## Sample Queries

```sql
-- Show everything
SELECT * FROM Orders;

-- Show only chosen columns
SELECT drink, price FROM Orders;

-- Filter rows
SELECT * FROM Orders WHERE drink = 'Coffee';

-- Sort lowest to highest
SELECT * FROM Orders ORDER BY price;

-- Sort highest to lowest
SELECT * FROM Orders ORDER BY price DESC;

-- Filter and sort together
SELECT * FROM Orders WHERE drink = 'Coffee' ORDER BY price DESC;
```

## Database Setup Commands

```sql
-- Create a database
CREATE DATABASE thm_bookmarket_db;

-- Show databases
SHOW DATABASES;

-- Use a database
USE thm_bookmarket_db;

-- Create a table
CREATE TABLE book_inventory (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    book_name VARCHAR(255) NOT NULL,
    publication_date DATE
);

-- Show tables
SHOW TABLES;

-- Describe table structure
DESCRIBE book_inventory;

-- Add a new column
ALTER TABLE book_inventory
ADD page_count INT;
```
