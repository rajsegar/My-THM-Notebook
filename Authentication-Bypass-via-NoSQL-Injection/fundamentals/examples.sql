-- SQL Fundamentals Examples
-- Practice queries using the books table

-- =====================
-- CRUD
-- =====================

-- Create
INSERT INTO books (id, name, published_date, description)
VALUES (1, 'Android Security Internals', '2014-10-14', 'An In-Depth Guide to Android Security Architecture');

-- Read
SELECT * FROM books;

-- Update
UPDATE books
SET description = 'An In-Depth Guide to Android Security Architecture.'
WHERE id = 1;

-- Delete
DELETE FROM books WHERE id = 1;

-- =====================
-- CLAUSES
-- =====================

-- Remove duplicates
SELECT DISTINCT name FROM books;

-- Count grouped values
SELECT name, COUNT(*)
FROM books
GROUP BY name;

-- Sort by date
SELECT * FROM books ORDER BY published_date DESC;

-- Filter grouped results
SELECT name, COUNT(*)
FROM books
GROUP BY name
HAVING name LIKE '%Hack%';

-- =====================
-- OPERATORS
-- =====================

-- Pattern match
SELECT * FROM books WHERE description LIKE '%guide%';

-- Multiple conditions
SELECT * FROM books
WHERE category = 'Offensive Security' AND name = 'Bug Bounty Bootcamp';

-- Either condition
SELECT * FROM books
WHERE name LIKE '%Android%' OR name LIKE '%iOS%';

-- Exclude matching rows
SELECT * FROM books WHERE NOT description LIKE '%guide%';

-- Range
SELECT * FROM books WHERE id BETWEEN 2 AND 4;

-- =====================
-- FUNCTIONS
-- =====================

SELECT CONCAT(name, ' is a type of ', category, ' book.') AS book_info FROM books;

SELECT category, GROUP_CONCAT(name SEPARATOR ', ') AS books
FROM books
GROUP BY category;

SELECT SUBSTRING(published_date, 1, 4) AS published_year FROM books;

SELECT LENGTH(name) AS name_length FROM books;

SELECT COUNT(*) AS total_books FROM books;

SELECT MAX(published_date) AS latest_book FROM books;

SELECT MIN(published_date) AS earliest_book FROM books;
