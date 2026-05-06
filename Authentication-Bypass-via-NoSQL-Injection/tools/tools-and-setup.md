# 🛠️ Tools & Setup Guide

> Everything you need to test NoSQL Injection — tools, setup, and tips.

---

## 🔧 Required Tools

| Tool | Purpose | Install |
|------|---------|--------|
| **Burp Suite Community** | Intercept & modify HTTP requests | [Download](https://portswigger.net/burp/communitydownload) |
| **Firefox / Chromium** | Browser with DevTools | Pre-installed |
| **Burp FoxyProxy** | Route browser traffic through Burp | [Firefox Add-on](https://addons.mozilla.org/en-US/firefox/addon/foxyproxy-standard/) |
| **jwt.io** | Decode and inspect JWT tokens | [Website](https://jwt.io) |
| **Postman** (optional) | Manual API testing | [Download](https://www.postman.com) |

---

## 🔁 Burp Suite Setup — Step by Step

### 1. Start Burp Suite
- Open Burp Suite → select **Temporary Project** → click **Start Burp**

### 2. Configure Proxy
- Go to **Proxy** tab → **Options**
- Ensure proxy listener is on `127.0.0.1:8080`

### 3. Configure Your Browser (Firefox)
- Install **FoxyProxy** extension
- Add a new proxy: `127.0.0.1` port `8080`
- Enable it when testing

### 4. Install Burp CA Certificate (for HTTPS)
1. Go to `http://burpsuite` in Firefox while proxy is on
2. Download the CA certificate
3. Firefox → Settings → Search "Certificates" → View Certificates → Import
4. Trust it for websites

### 5. Intercept a Request
- **Proxy** tab → **Intercept** → turn **ON**
- Submit the login form on the target
- Request appears in Burp — right-click → **Send to Repeater**
- Turn **Intercept OFF** again

### 6. Modify & Replay in Repeater
- Go to **Repeater** tab (`Ctrl+R`)
- Change the request body to your injection payload
- Click **Send** and view the response

---

## 🔑 Working with the Session Token

After a successful bypass, look in the **Response** tab for:

```
Set-Cookie: sessToken=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Copy the token value. To use it in follow-up requests, add it as a header:

```
Cookie: sessToken=<your_token_here>
```

Or decode it at **[jwt.io](https://jwt.io)** to view the payload claims (user role, ID, expiry).

---

## 🌐 Setting Content-Type Correctly

For JSON injection to work, the `Content-Type` header **must** be set correctly in Burp:

```
Content-Type: application/json
```

Without this, the server may not parse your `{"$ne": "x"}` as a JSON object and the injection fails.

---

## 🧪 Testing Checklist

- [ ] Burp proxy set up and browser traffic routing through it
- [ ] Target login endpoint identified (`POST /api/.../signin`)
- [ ] Request captured and sent to Repeater
- [ ] `Content-Type: application/json` confirmed in request
- [ ] `$ne` basic bypass attempted first
- [ ] Session token extracted from successful response
- [ ] JWT decoded to confirm admin role
- [ ] Protected endpoint accessed using session token
- [ ] User enumeration performed with `$nin` rounds

---

## 📦 Recommended Practice Labs

| Platform | Lab | Link |
|----------|-----|------|
| PortSwigger Web Academy | Exploiting NoSQL operator injection to bypass authentication | [Link](https://portswigger.net/web-security/nosql-injection/lab-nosql-injection-bypass-authentication) |
| PicoCTF 2024 | No Sql Injection | [Link](https://play.picoctf.org) |
| Defhawk Applied Off-Sec | Implicit Trust | Internal lab |
| HackTheBox | Various web challenges with MongoDB | [Link](https://app.hackthebox.com) |
| TryHackMe | NoSQL Injection rooms | [Link](https://tryhackme.com) |

---

## 📖 Further Reading

- [PortSwigger NoSQL Injection Theory](https://portswigger.net/web-security/nosql-injection)
- [OWASP Testing for NoSQL Injection](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/07-Input_Validation_Testing/05.6-Testing_for_NoSQL_Injection)
- [IntelligenceX — Complete NoSQL Injection Guide](https://blog.intelligencex.org/nosql-injection-vulnerabilities-complete-guide)
- [Invicti — MongoDB Operator Injection](https://www.invicti.com/web-application-vulnerabilities/authentication-bypass-via-mongodb-operator-injection)
- [express-mongo-sanitize npm](https://www.npmjs.com/package/express-mongo-sanitize)
