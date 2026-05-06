# TryHackMe - SQL Fundamentals

## Objective
Learn advanced SQL concepts including CRUD operations, clauses, operators, and functions applied to a real database.

## Platform
TryHackMe

## Key Concepts
- CRUD: INSERT, SELECT, UPDATE, DELETE
- DISTINCT to remove duplicates
- GROUP BY to group matching values
- HAVING to filter grouped results
- Operators: =, !=, LIKE, AND, OR, NOT, BETWEEN
- String functions: CONCAT, SUBSTRING, LENGTH, GROUP_CONCAT
- Aggregate functions: COUNT, SUM, MAX, MIN

## Commands / Queries Used

```sql
-- CRUD
INSERT INTO books (id, name, published_date, description)
VALUES (1, 'Android Security Internals', '2014-10-14', 'An In-Depth Guide to Android Security');

SELECT * FROM books;

UPDATE books
SET description = 'An In-Depth Guide to Android Security.'
WHERE id = 1;

DELETE FROM books WHERE id = 1;

-- Clauses
SELECT DISTINCT name FROM books;

SELECT name, COUNT(*) FROM books GROUP BY name;

SELECT * FROM books ORDER BY published_date DESC;

SELECT name, COUNT(*) FROM books GROUP BY name HAVING name LIKE '%Hack%';

-- Operators
SELECT * FROM books WHERE description LIKE '%guide%';
SELECT * FROM books WHERE category = 'Offensive Security' AND name = 'Bug Bounty Bootcamp';
SELECT * FROM books WHERE name LIKE '%Android%' OR name LIKE '%iOS%';
SELECT * FROM books WHERE NOT description LIKE '%guide%';
SELECT * FROM books WHERE id BETWEEN 2 AND 4;

-- Functions
SELECT CONCAT(name, ' is a type of ', category, ' book.') AS book_info FROM books;
SELECT SUBSTRING(published_date, 1, 4) AS published_year FROM books;
SELECT LENGTH(name) AS name_length FROM books;
SELECT COUNT(*) AS total_books FROM books;
SELECT MAX(published_date) AS latest_book FROM books;
SELECT MIN(published_date) AS earliest_book FROM books;
```

## What I Learned
- Always use WHERE with UPDATE and DELETE
- HAVING filters after GROUP BY; WHERE filters before
- LIKE with % wildcard is useful for partial matches
- Aggregate functions summarise data across rows
- String functions work on individual column values

## Mistakes I Made
- Used HAVING instead of WHERE for non-grouped filters
- Forgot to add WHERE on an UPDATE and changed all rows
- Mixed up SUBSTRING argument order

## Final Notes
SQL fundamentals build directly on the basics. Understanding CRUD + clauses + operators + functions covers most real-world database work and forms the foundation for SQL injection testing.
