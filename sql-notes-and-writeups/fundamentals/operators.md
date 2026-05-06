# Operators

## Meaning
Operators are used in SQL WHERE clauses to compare values and filter rows more precisely.

## Comparison Operators

| Operator | Meaning                  | Example                        |
|----------|--------------------------|--------------------------------|
| `=`      | Equal to                 | `WHERE id = 1`                 |
| `!=`     | Not equal to             | `WHERE id != 1`                |
| `>`      | Greater than             | `WHERE price > 10`             |
| `<`      | Less than                | `WHERE price < 10`             |
| `>=`     | Greater than or equal    | `WHERE price >= 10`            |
| `<=`     | Less than or equal       | `WHERE price <= 10`            |

## Logical Operators

### AND
**Meaning:** All conditions must be true.
```sql
SELECT * FROM books
WHERE category = 'Offensive Security' AND name = 'Bug Bounty Bootcamp';
```

### OR
**Meaning:** At least one condition must be true.
```sql
SELECT * FROM books
WHERE name LIKE '%Android%' OR name LIKE '%iOS%';
```

### NOT
**Meaning:** Excludes matching rows.
```sql
SELECT * FROM books
WHERE NOT description LIKE '%guide%';
```

## Pattern Matching

### LIKE
**Meaning:** Matches a pattern using wildcards.
- `%` = any number of characters
- `_` = exactly one character

```sql
-- Find books with 'guide' in description
SELECT * FROM books
WHERE description LIKE '%guide%';
```

## Range

### BETWEEN
**Meaning:** Matches values within a range (inclusive).
```sql
SELECT * FROM books
WHERE id BETWEEN 2 AND 4;
```

## Key Point
Combine operators for precise filtering. Use AND when all conditions must match, OR when any one is enough.
