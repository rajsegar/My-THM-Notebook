<h1 align="center">SQL Notes and Writeups</h1>

<p align="center">
  Beginner-friendly SQL notes, practice queries, and hands-on writeups for learning database fundamentals.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Focus-SQL-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Level-Beginner%20to%20Intermediate-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Topics-Databases%20%7C%20CRUD%20%7C%20Clauses-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" />
  <img src="https://img.shields.io/badge/TryHackMe-Labs-red?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Status-Active%20Learning-success?style=for-the-badge" />
</p>

---

## Overview

This repository documents my SQL learning journey in a structured and practical way.

It contains:
- Beginner SQL notes
- Practice queries
- Database fundamentals
- TryHackMe-style lab writeups
- Quick revision cheatsheets

The goal of this repo is to build a strong foundation in SQL and database concepts while keeping notes simple, clear, and easy to revise.

---

## Objectives

- Understand what databases are
- Learn tables, rows, and columns
- Understand relational database structure
- Practice SQL syntax
- Learn CRUD operations
- Use filtering, sorting, and grouping
- Build a revision-friendly knowledge base

---

## Repository Structure

```bash
sql-notes-and-writeups/
├── README.md
├── basics/
│   ├── database-basics.md
│   ├── sql-basics.md
│   └── cafe-examples.sql
├── fundamentals/
│   ├── crud.md
│   ├── clauses.md
│   ├── operators.md
│   ├── functions.md
│   └── examples.sql
├── labs/
│   ├── tryhackme-sql-basics.md
│   └── tryhackme-sql-fundamentals.md
└── cheatsheets/
    └── sql-cheatsheet.md
```

---

## Topics Covered

### 1. Database Basics
- What a database is
- Why databases matter
- Tables, rows, and columns
- Structured vs non-structured data
- Primary keys and foreign keys

### 2. SQL Basics
- `SELECT`
- `FROM`
- `WHERE`
- `ORDER BY`

### 3. CRUD Operations
- `INSERT INTO`
- `SELECT`
- `UPDATE`
- `DELETE`

### 4. Clauses
- `DISTINCT`
- `GROUP BY`
- `ORDER BY`
- `HAVING`

### 5. Operators
- `=` `!=` `>` `<` `>=` `<=`
- `LIKE`
- `AND` `OR` `NOT`
- `BETWEEN`

### 6. Functions
- `COUNT()` `SUM()` `MAX()` `MIN()`
- `LENGTH()` `SUBSTRING()` `CONCAT()` `GROUP_CONCAT()`

---

## Sample Queries

```sql
SELECT * FROM Orders;

SELECT drink, price FROM Orders;

SELECT * FROM Orders
WHERE drink = 'Coffee';

SELECT * FROM Orders
ORDER BY price DESC;

SELECT DISTINCT name FROM books;

SELECT name, COUNT(*)
FROM books
GROUP BY name;
```

---

## Lab Writeups

This repository includes writeups from hands-on SQL learning labs.

Each lab note includes:
- Room objective
- Important concepts
- Queries used
- Mistakes made
- Lessons learned
- Personal summary

---

## Why This Repo Matters

SQL is important in both offensive and defensive security work.

Understanding databases helps with:
- Web application testing
- SQL injection understanding
- Log and data analysis
- Authentication systems
- Security investigations
- Better application security awareness

---

## Future Plans

- Add SQL joins
- Add subqueries
- Add more practice datasets
- Add SQL injection notes
- Add database security concepts
- Add interview-style SQL questions

---

## Author

**Rajsegar**
Cybersecurity learner | SQL learner | Documentation-focused

GitHub: [https://github.com/rajsegar/sql-notes-and-writeups](https://github.com/rajsegar/sql-notes-and-writeups)

---

## License

This project is licensed under the MIT License.
