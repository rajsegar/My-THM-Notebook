# CRUD

## Meaning
CRUD stands for the four main database operations: **Create**, **Read**, **Update**, and **Delete**.

## Why it matters
Every database application uses CRUD. It is the foundation of working with data in SQL.

## CRUD Statements

| CRUD   | SQL Statement  |
|--------|----------------|
| Create | `INSERT INTO`  |
| Read   | `SELECT`       |
| Update | `UPDATE`       |
| Delete | `DELETE`       |

## Syntax

```sql
-- Create
INSERT INTO table_name (col1, col2) VALUES ('value1', 'value2');

-- Read
SELECT * FROM table_name;

-- Update
UPDATE table_name SET col1 = 'new_value' WHERE id = 1;

-- Delete
DELETE FROM table_name WHERE id = 1;
```

## Full Example (Books Table)

```sql
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
DELETE FROM books
WHERE id = 1;
```

## Result
- INSERT adds a new row to the table
- SELECT reads and returns rows
- UPDATE modifies existing rows
- DELETE removes rows permanently

## Key Point
Always use WHERE with UPDATE and DELETE, or you will affect every row in the table.
