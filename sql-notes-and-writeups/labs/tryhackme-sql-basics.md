# TryHackMe - SQL Basics

## Objective
Learn the foundational SQL commands used to interact with databases, including how to select, filter, and sort data.

## Platform
TryHackMe

## Key Concepts
- What SQL is and why it is used
- Tables, rows, and columns
- SELECT and FROM
- WHERE clause for filtering
- ORDER BY for sorting
- Creating databases and tables
- Using ALTER TABLE to modify structure

## Commands / Queries Used

```sql
-- Show all data
SELECT * FROM Orders;

-- Show specific columns
SELECT drink, price FROM Orders;

-- Filter rows
SELECT * FROM Orders WHERE drink = 'Coffee';

-- Sort ascending
SELECT * FROM Orders ORDER BY price;

-- Sort descending
SELECT * FROM Orders ORDER BY price DESC;

-- Filter and sort combined
SELECT * FROM Orders WHERE drink = 'Coffee' ORDER BY price DESC;

-- Create database
CREATE DATABASE thm_bookmarket_db;

-- Use database
USE thm_bookmarket_db;

-- Create table
CREATE TABLE book_inventory (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    book_name VARCHAR(255) NOT NULL,
    publication_date DATE
);

-- Describe table
DESCRIBE book_inventory;

-- Add column
ALTER TABLE book_inventory ADD page_count INT;
```

## What I Learned
- SELECT picks the columns to display
- FROM specifies which table to read
- WHERE filters rows based on a condition
- ORDER BY sorts results ASC or DESC
- CREATE DATABASE and CREATE TABLE build the structure
- ALTER TABLE modifies existing table structure

## Mistakes I Made
- Forgot the semicolon at the end of queries
- Used WHERE after ORDER BY (wrong order)
- Confused ASC and DESC initially

## Final Notes
SQL basics are the foundation for everything else. Getting SELECT, FROM, WHERE, and ORDER BY right first makes the rest much easier.
