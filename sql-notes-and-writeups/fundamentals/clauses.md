# Clauses

## Meaning
Clauses are keywords added to SQL queries to control how data is selected, grouped, sorted, and filtered.

## Main Clauses

### DISTINCT
**Meaning:** Removes duplicate rows from results.
**Syntax:** `SELECT DISTINCT column FROM table;`
**Example:**
```sql
SELECT DISTINCT name FROM books;
```
**Key point:** Only returns unique values.

---

### GROUP BY
**Meaning:** Groups rows that have the same value in a column.
**Syntax:** `SELECT column, COUNT(*) FROM table GROUP BY column;`
**Example:**
```sql
SELECT name, COUNT(*)
FROM books
GROUP BY name;
```
**Key point:** Usually used with aggregate functions like COUNT(), SUM(), MAX().

---

### ORDER BY
**Meaning:** Sorts the result set.
**Syntax:** `SELECT * FROM table ORDER BY column ASC|DESC;`
**Example:**
```sql
SELECT *
FROM books
ORDER BY published_date DESC;
```
**Key point:** ASC = ascending (default), DESC = descending.

---

### HAVING
**Meaning:** Filters grouped results after aggregation.
**Syntax:** `SELECT column, COUNT(*) FROM table GROUP BY column HAVING condition;`
**Example:**
```sql
SELECT name, COUNT(*)
FROM books
GROUP BY name
HAVING name LIKE '%Hack%';
```
**Key point:** HAVING filters after GROUP BY. WHERE filters before grouping.

---

## Clause Order in a Query

```sql
SELECT column
FROM table
WHERE condition
GROUP BY column
HAVING condition
ORDER BY column;
```

## Key Point
Remember the order: SELECT > FROM > WHERE > GROUP BY > HAVING > ORDER BY
