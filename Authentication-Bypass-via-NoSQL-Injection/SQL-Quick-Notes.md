# 📝 SQL Quick Notes

## What is a Database?
An organised collection of structured data stored digitally. Data is stored in **tables** (like spreadsheets) made up of **rows** (records) and **columns** (fields/types).

- **Relational DB (SQL)** – structured, tabular, uses relationships between tables
- **Non-Relational DB (NoSQL)** – flexible, non-tabular (e.g. JSON/document format)

## Keys
- **Primary Key** – uniquely identifies each row in a table (e.g. `id`)
- **Foreign Key** – links a column in one table to the primary key of another table

---

## 🗄️ Database Statements

| Command | Purpose |
|---|---|
| `CREATE DATABASE db_name;` | Create a new database |
| `SHOW DATABASES;` | List all databases |
| `USE db_name;` | Set active database |
| `DROP DATABASE db_name;` | Delete a database |

## 🗂️ Table Statements

| Command | Purpose |
|---|---|
| `CREATE TABLE t (col datatype);` | Create a table with columns |
| `SHOW TABLES;` | List tables in active DB |
| `DESCRIBE table_name;` | Show columns and types |
| `ALTER TABLE t ADD col INT;` | Add a new column |
| `DROP TABLE table_name;` | Delete a table |

---

## ✏️ CRUD Operations

| Operation | SQL | Purpose |
|---|---|---|
| **Create** | `INSERT INTO t (col1) VALUES (val1);` | Add a new record |
| **Read** | `SELECT * FROM t;` | Retrieve records |
| **Update** | `UPDATE t SET col=val WHERE id=1;` | Modify a record |
| **Delete** | `DELETE FROM t WHERE id=1;` | Remove a record |

---

## 🔍 Clauses

| Clause | Example | Purpose |
|---|---|---|
| `WHERE` | `WHERE name = 'Coffee'` | Filter rows by condition |
| `DISTINCT` | `SELECT DISTINCT name FROM t;` | Remove duplicate results |
| `ORDER BY` | `ORDER BY price ASC/DESC` | Sort results |
| `GROUP BY` | `GROUP BY category` | Group rows together |
| `HAVING` | `HAVING name LIKE '%Hack%'` | Filter after grouping |

---

## ⚙️ Operators

| Operator | Example | Meaning |
|---|---|---|
| `LIKE` | `WHERE name LIKE '%hack%'` | Pattern match |
| `AND` | `WHERE a=1 AND b=2` | Both conditions must be true |
| `OR` | `WHERE a=1 OR b=2` | Either condition true |
| `NOT` | `WHERE NOT desc LIKE '%guide%'` | Exclude a condition |
| `BETWEEN` | `WHERE id BETWEEN 2 AND 4` | Value within a range |
| `=`, `!=` | `WHERE id != 3` | Equal / Not equal |
| `<`, `>` | `WHERE date > '2020-01-01'` | Less / Greater than |
| `<=`, `>=` | `WHERE date >= '2021-01-01'` | Less/Greater than or equal |

---

## 🔧 Functions

### String Functions
| Function | Example | Purpose |
|---|---|---|
| `CONCAT()` | `CONCAT(name, " - ", category)` | Join strings together |
| `GROUP_CONCAT()` | `GROUP_CONCAT(name SEPARATOR ", ")` | Merge rows into one string |
| `SUBSTRING()` | `SUBSTRING(date, 1, 4)` | Extract part of a string |
| `LENGTH()` | `LENGTH(name)` | Count characters in a string |

### Aggregate Functions
| Function | Example | Purpose |
|---|---|---|
| `COUNT()` | `COUNT(*) AS total` | Count number of rows |
| `SUM()` | `SUM(price) AS total_price` | Sum of a numeric column |
| `MAX()` | `MAX(published_date)` | Highest / latest value |
| `MIN()` | `MIN(published_date)` | Lowest / earliest value |

---

## 💡 Quick Example Query (Combined)
```sql
SELECT name, COUNT(*) 
FROM books
WHERE category = 'Offensive Security'
GROUP BY name
HAVING name LIKE '%Hack%'
ORDER BY name ASC;
```
This filters offensive security books, groups them by name, keeps only ones with "Hack" in the title, and sorts alphabetically.
