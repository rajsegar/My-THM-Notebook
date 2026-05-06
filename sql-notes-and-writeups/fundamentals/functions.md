# Functions

## Meaning
SQL functions perform operations on data. There are two main types: string functions and aggregate functions.

---

## String Functions

### CONCAT()
**Meaning:** Combines two or more strings into one.
```sql
SELECT CONCAT(name, ' is a type of ', category, ' book.') AS book_info FROM books;
```

### GROUP_CONCAT()
**Meaning:** Combines values from multiple rows into one string.
```sql
SELECT category, GROUP_CONCAT(name SEPARATOR ', ') AS books
FROM books
GROUP BY category;
```

### SUBSTRING()
**Meaning:** Extracts part of a string.
```sql
SELECT SUBSTRING(published_date, 1, 4) AS published_year FROM books;
```
**Key point:** SUBSTRING(column, start_position, length)

### LENGTH()
**Meaning:** Returns the number of characters in a string.
```sql
SELECT LENGTH(name) AS name_length FROM books;
```

---

## Aggregate Functions

### COUNT()
**Meaning:** Counts the number of rows.
```sql
SELECT COUNT(*) AS total_books FROM books;
```

### SUM()
**Meaning:** Adds up all values in a column.
```sql
SELECT SUM(price) AS total_price FROM books;
```

### MAX()
**Meaning:** Returns the highest value.
```sql
SELECT MAX(published_date) AS latest_book FROM books;
```

### MIN()
**Meaning:** Returns the lowest value.
```sql
SELECT MIN(published_date) AS earliest_book FROM books;
```

---

## Key Point
Aggregate functions (COUNT, SUM, MAX, MIN) work on groups of rows. String functions (CONCAT, LENGTH, SUBSTRING) work on individual values.
