# OWASP Top 10 2025 — THM Notebook

> **Goal:** A practical, CTF/CPENT-oriented reference. Each section follows:
> `Idea → Why It Matters → Common Patterns → Pentester Checklist → THM Lab Mapping → Mitigation`

---

## 📌 Table of Contents

| # | Room Theme | Categories |
|---|-----------|------------|
| 1 | [IAAA Failures](#-iaaa-failures) | A01, A07, A09 |
| 2 | [Application Design Flaws](#-application-design-flaws) | A02, A03, A04, A06, A10 |
| 3 | [Insecure Data Handling](#-insecure-data-handling) | A04, A05, A08 |
| 4 | [At-a-Glance Table](#-at-a-glance-summary-table) | All 10 |
| 5 | [IAAA Model Reference](#-iaaa-model-reference) | Concept |
| 6 | [Practice Resources](#-practice-resources) | THM Links |

---

## 🔐 IAAA Model Reference

IAAA is the backbone of application security. You cannot skip a level — each depends on the one before it.

| Layer | What It Is | Example |
|-------|-----------|---------|
| **Identity** | Unique account representing a person or service | UserID, email, service account |
| **Authentication** | Proving that identity | Password, OTP, passkey, certificate |
| **Authorisation** | What that identity is allowed to do | RBAC roles, access rules, ABAC policies |
| **Accountability** | Recording & alerting on who did what, when, and from where | Logs, SIEM alerts, audit trails |

> 💡 **One-liner to remember:** _"If identity and authentication are weak, authorisation and accountability are meaningless."_

---

## 🔓 IAAA Failures

> **TryHackMe Room:** [OWASP Top 10 2025: IAAA Failures](https://tryhackme.com/room/owasptopten2025one)
> **Categories Covered:** A01, A07, A09

---

### A01 — Broken Access Control

**📖 Idea in one sentence**
> The server does not reliably enforce "who can access what" on every request — the client is trusted too much.

**❓ Why It Matters**
Access control is the gatekeeper of your data. When it breaks, any user can read, modify, or delete data that belongs to others — or escalate their own privileges to admin level. This has been **#1 on OWASP** for multiple years because it is extremely common and deeply damaging.

**🔍 Common Patterns**

| Type | Description | Example |
|------|-------------|---------|
| **IDOR** | Changing an object ID gives access to another user's data | `/accounts?id=7` → `/accounts?id=6` |
| **Horizontal escalation** | Same privilege, different user's data | Normal user reads another user's orders |
| **Vertical escalation** | Low-priv user gains admin-only capabilities | Normal user calls `/admin/deleteUser` |
| **UI-based security** | Buttons hidden in front-end, but endpoints are unprotected | Removing `disabled` attribute reveals admin panel |
| **Multi-tenant leaks** | Tenant A can query tenant B's data due to missing filters | Missing `WHERE tenant_id = ?` in DB query |
| **Path traversal via IDOR** | Object references embedded in file paths or filenames | `?file=user_7.pdf` → `?file=user_6.pdf` |

**🧪 Pentester Checklist**

```
[ ] Change numeric IDs in URL, JSON body, headers, and cookies
[ ] Try UUID/hash enumeration (sometimes predictable or brute-forceable)
[ ] Replay admin-level actions (delete, approve, export) as a normal user
[ ] Remove or modify role fields (isAdmin=true, role=admin) in requests
[ ] Find hidden endpoints in JS source, /api/docs, or Swagger UI
[ ] Test all HTTP methods (GET/POST/PUT/DELETE/PATCH) on same endpoint
[ ] Check if object ownership is validated server-side, not just client-side
[ ] Test indirect references: profile images, attachments, tickets
```

**🏴 THM Lab Mapping**
- Lab: Play with `accountID` in the URL on the static site
- Pattern: `accountID=1` → enumerate → find account with > $1M balance
- Attack type: **IDOR → Horizontal Privilege Escalation**
- Key lesson: *The server never verified that the logged-in user owns the account being requested.*

**🛡️ Mitigation**
- Enforce server-side access checks on **every** request — never trust the client
- Use indirect object references (map internal IDs to random tokens per session)
- Deny by default: if no explicit permission exists, deny access
- Log all access control failures and alert on anomalies

---

### A07 — Authentication Failures

**📖 Idea in one sentence**
> The app cannot reliably prove or bind identity — login, registration, and session flows have logic or configuration flaws.

**❓ Why It Matters**
Authentication is the proof layer of IAAA. If an attacker can bypass it — whether through logic bugs, weak credentials, or session mishandling — they inherit full access as that user. Many real-world breaches start here.

**🔍 Common Patterns**

| Pattern | Description |
|---------|-------------|
| **Username enumeration** | Different error messages or timing for valid vs invalid usernames |
| **No rate limiting / lockout** | Brute force or credential stuffing is unrestricted |
| **Canonicalisation bugs** | `admin` and `aDmiN` treated as different identities |
| **Session not rotated** | Same session ID before and after login / privilege change |
| **Weak credential policies** | Short passwords, no complexity, no MFA |
| **Insecure "remember me"** | Long-lived persistent tokens stored insecurely |
| **Logic flaws in registration** | Register a username that conflicts with an existing privileged account |

**🧪 Pentester Checklist**

```
[ ] Test valid vs invalid username → compare HTTP status, body, response time
[ ] Run a slow/small wordlist against login — does lockout trigger?
[ ] Try username variants: Admin, ADMIN, aDmiN, admin@domain.com vs Admin@domain.com
[ ] Register a username that resembles an existing privileged account
[ ] Confirm session ID changes on: login, logout, password change, role change
[ ] Check "remember me" token entropy and storage (cookie flags: HttpOnly, Secure, SameSite)
[ ] Test password reset flow: predictable tokens, token reuse, no expiry
[ ] Check if 2FA can be skipped by directly navigating to post-auth pages
```

**🏴 THM Lab Mapping**
- Lab: Register `aDmiN` on the static site and attempt login as admin
- Pattern: App lacks canonical uniqueness enforcement → identity collision → auth bypass
- Key lesson: *Usernames must be normalised (lowercased) before uniqueness checks. The DB should enforce a unique index on the canonical form.*

**🛡️ Mitigation**
- Enforce unique indexes on the **canonical (normalised)** form of usernames
- Rate-limit and lock out brute-force attempts; alert on anomalies
- Rotate session IDs on login, logout, and privilege/password changes
- Use multi-factor authentication (MFA) for all sensitive accounts
- Never reveal whether a username exists in error messages

---

### A09 — Logging & Alerting Failures

**📖 Idea in one sentence**
> The app doesn't properly record or alert on important security events, so defenders cannot detect or investigate attacks.

**❓ Why It Matters**
Accountability is the final layer of IAAA. Without it, you cannot prove what happened, who did it, or when — making forensic investigation and incident response nearly impossible. Attackers exploit this by knowing they can operate undetected.

**🔍 Common Patterns**

| Failure | Impact |
|---------|--------|
| No logs for failed/successful logins | Brute force goes undetected |
| No alerts on privilege changes or new admin creation | Insider threats and escalation invisible |
| Logs stored on the same box as the app | Attacker can tamper or delete evidence |
| Vague/generic log messages | "Error occurred" tells defenders nothing useful |
| Short log retention | Incidents discovered late cannot be investigated |
| No centralised logging (SIEM) | Correlated attacks across services are invisible |

**🧪 Pentester Checklist**

```
[ ] Run a brute force — do logs capture: IP, username, timestamp, outcome?
[ ] Change a password / role — is there a log entry with actor + target + time?
[ ] Check where logs are stored — on the app server itself (bad) or shipped off-host?
[ ] Look for verbose error messages that expose system internals (stack traces, paths)
[ ] Verify log retention policy — can you find events from 30+ days ago?
[ ] Test whether logs are write-protected / append-only or can be modified
[ ] Check for alerting on: failed login bursts, new admin creation, role changes
```

**🏴 THM Lab Mapping**
- Lab: Investigate logs on the static site and answer forensic questions
- Pattern: Good logs let you reconstruct: *which user, which IP, which endpoint, what time*
- Key lesson: *If key fields (IP, username, action, timestamp) are missing from logs, reconstruction is impossible — attackers become invisible.*

**🛡️ Mitigation**
- Log the **full auth lifecycle**: login attempts (success/fail), password changes, MFA events, role changes, admin actions
- Centralise logs **off-host** (SIEM, Splunk, CloudWatch) with tamper protection
- Alert on anomalies: login bursts, privilege escalation, unusual geo/IP, new admin creation
- Enforce log retention policies appropriate to your compliance requirements

---

## 🏗️ Application Design Flaws

> **TryHackMe Room:** [OWASP Top 10 2025: Application Design Flaws](https://tryhackme.com/jr/owasptopten2025two)
> **Categories Covered:** A02, A03, A04, A06, A10

---

### A02 — Security Misconfiguration

**📖 Idea in one sentence**
> Systems are deployed with unsafe defaults, incomplete settings, or exposed services — not code bugs, but setup mistakes.

**❓ Why It Matters**
Modern apps depend on complex stacks — cloud services, containers, APIs, third-party plugins. A single misconfigured permission, open storage bucket, or exposed admin panel can be the entry point into an entire system.

**🔍 Common Patterns**

```
- Default credentials left unchanged (admin/admin, root/root)
- Unnecessary services or endpoints exposed to the internet
- Publicly accessible cloud storage (S3, Azure Blob, GCP buckets)
- Verbose error messages exposing stack traces, paths, or version info
- Exposed admin panels (/admin, /phpmyadmin, /wp-admin)
- Missing security headers (CSP, HSTS, X-Frame-Options)
- Outdated frameworks, libraries, or containers with known CVEs
- Unrestricted CORS policies or missing authentication on API endpoints
- Exposed AI/ML endpoints without access controls
```

**🧪 Pentester Checklist**

```
[ ] Scan for default/common paths: /admin, /setup, /debug, /api/docs, /.env
[ ] Try default credentials on all login forms found
[ ] Enumerate open ports and services — are any unnecessary?
[ ] Look for publicly accessible cloud storage buckets (tools: GrayhatWarfare, S3Scanner)
[ ] Trigger errors intentionally — do they expose stack traces or versions?
[ ] Check response headers for missing security headers
[ ] Test CORS: can you make cross-origin requests from an arbitrary domain?
[ ] Look for exposed .git, .env, backup files in web root
```

**🏴 Real-World Example**
- 2017 Uber breach: public AWS S3 bucket contained driver/rider PII — no credentials needed, just direct download.

**🛡️ Mitigation**
- Harden defaults: remove unused services, change all default credentials
- Enforce least privilege on cloud storage and IAM roles
- Hide error details from end users; log them server-side only
- Automate security checks (IaC scanning, CSPM) in CI/CD pipelines

---

### A03 — Software Supply Chain Failures

**📖 Idea in one sentence**
> The app trusts third-party code, dependencies, or build pipelines without integrity verification.

**🔍 Common Patterns**

```
- Using vulnerable or unmaintained open-source dependencies
- No verification of package integrity (checksums, signed packages)
- CI/CD pipeline with write access to production using weak credentials
- Pulling base Docker images from unverified sources
- Unsigned or unverified software updates accepted automatically
```

**🧪 Pentester Checklist**

```
[ ] Check package.json, requirements.txt, pom.xml for outdated dependencies
[ ] Run: npm audit / pip-audit / trivy for known CVEs in dependencies
[ ] Look for leaked CI/CD secrets in .github/workflows, Jenkinsfile, .gitlab-ci.yml
[ ] Check if build/deploy scripts pull from untrusted registries
[ ] Verify whether update mechanisms check signatures or hashes
```

**🛡️ Mitigation**
- Pin dependency versions and verify integrity with checksums/signatures
- Use SBOM (Software Bill of Materials) and scan regularly
- Protect CI/CD pipelines with strong authentication and least privilege
- Use verified/official base images; scan containers before deployment

---

### A04 — Cryptographic Failures (Design Angle)

**📖 Idea in one sentence**
> Encryption is used incorrectly or not at all — weak algorithms, hard-coded keys, or poor key management expose sensitive data.

**🔍 Common Patterns**

```
- Using deprecated algorithms: MD5, SHA-1, DES, 3DES, ECB mode
- Hard-coded secrets in source code or config files
- No encryption for sensitive data at rest or in transit
- Self-signed or expired TLS certificates
- Weak key derivation (short keys, no salting, predictable derivation)
- Rolling your own cryptographic algorithm
- AI/ML systems with unprotected model parameters or secrets in prompts
```

**🧪 Pentester Checklist**

```
[ ] Check JS/source/config/git history for hard-coded API keys, passwords, tokens
[ ] Test TLS: protocol version, cipher suites, certificate validity (testssl.sh, sslyze)
[ ] Look for Base64-encoded "secrets" (not encryption — just encoding)
[ ] Check password storage: are hashes salted? What algorithm? (bcrypt vs MD5)
[ ] Try to derive or guess encryption keys from observable patterns
[ ] Check for secrets in Docker images, environment variables, /proc/*/environ
```

**🏴 THM Lab Mapping**
- Lab: Note-sharing app uses weak shared derivative key — derive the key and decrypt all notes to find the flag
- Key lesson: *Crypto must use proper key management + modern algorithms. Never "roll your own."*

**🛡️ Mitigation**
- Use strong modern algorithms: AES-GCM, ChaCha20-Poly1305, TLS 1.3
- Use key management services: AWS KMS, Azure Key Vault, HashiCorp Vault
- Hash passwords with: bcrypt, scrypt, or Argon2 (never MD5/SHA-1)
- Never embed secrets in source code — use environment variables or secrets managers
- Rotate keys/secrets regularly; maintain a certificate/key inventory

---

### A06 — Insecure Design

**📖 Idea in one sentence**
> Flaws in logic or architecture are built into the system from the start — you can't patch a broken design.

**🔍 Common Patterns**

```
- Missing threat modelling during development
- Business logic flaws (approval/recovery flows with no abuse-case review)
- Backend APIs with no authentication (assumed only app will call them)
- AI components with unchecked authority over internal APIs or actions
- Prompt injection: user input blended with system prompts
- Blind trust in model output without human review
- Test/debug bypasses left in production
- Missing rate limits on sensitive business actions (transfer money, reset password)
```

**🧪 Pentester Checklist**

```
[ ] Map all API endpoints — do any lack authentication/authorisation?
[ ] Test multi-step flows: can you jump steps or replay them out of order?
[ ] Look for business logic abuse: negative quantities, price manipulation, coupon stacking
[ ] Test AI inputs: can you override system prompts or extract hidden instructions?
[ ] Check recovery/approval flows for missing abuse-case controls
[ ] Look for debug/test endpoints left in production (/debug, /test, /dev)
```

**🏴 Real-World Example**
- Clubhouse (early): backend API had no auth — anyone could query user data, room info, and "private" conversations directly without using the app.

**🛡️ Mitigation**
- Build threat modelling into every stage of development
- Define security requirements per feature before implementation
- Apply principle of least privilege to users, APIs, and services
- Treat all AI model inputs/outputs as untrusted; validate and filter
- Separate system prompts from user content in LLM applications
- Require human review for high-risk AI-triggered actions

---

### A10 — Mishandling of Exceptional Conditions

**📖 Idea in one sentence**
> The app fails unsafely on errors or edge cases — exceptions bypass security controls or leak sensitive info.

**🔍 Common Patterns**

```
- Errors that cause fail-open behaviour (access granted on exception)
- Stack traces exposing internal paths, versions, or credentials in responses
- Unhandled exceptions that skip authentication/authorisation checks
- Null pointer / type confusion that changes application behaviour
- Race conditions triggered by concurrent requests on critical operations
```

**🧪 Pentester Checklist**

```
[ ] Send unexpected inputs: null values, empty strings, very large numbers, special chars
[ ] Trigger errors intentionally — what does the response reveal?
[ ] Test concurrent requests on sensitive operations (race conditions)
[ ] Check whether error paths bypass auth or access control
[ ] Look for differences in behaviour between error states and normal states
```

**🛡️ Mitigation**
- Always fail closed: deny access on exception, never grant it
- Catch and handle all exceptions; log server-side, show generic messages to users
- Test edge cases and failure paths as part of QA and security testing

---

## 💉 Insecure Data Handling

> **TryHackMe Room:** [OWASP Top 10 2025: Insecure Data Handling](https://tryhackme.com/room/owasptopten2025three)
> **Categories Covered:** A04, A05, A08

---

### A04 — Cryptographic Failures (Data Handling Angle)

> See also [A04 in Design Flaws](#a04--cryptographic-failures-design-angle) — same vulnerability, different context.

**📖 Idea in one sentence**
> Sensitive data is not adequately protected because encryption is absent, weak, or incorrectly implemented.

**🏴 THM Lab Mapping**
- Lab: Note-sharing app at `http://10.82.157.136:8001`
- Pattern: Weak shared derivative key used to "protect" notes → derive key → decrypt all notes → find flag
- Key lesson: *Crypto without proper key management is not security — it's a false sense of security.*

**🧪 Quick Attack Steps for This Type**

```
1. Identify the encryption scheme in use (check JS, source, API responses)
2. Look for hardcoded keys, weak key derivation, or shared keys
3. Derive or guess the key
4. Decrypt all protected objects and look for flags/sensitive data
```

---

### A05 — Injection

**📖 Idea in one sentence**
> The app passes user input directly into an interpreter (SQL, shell, template, AI prompt) without safe separation or validation.

**❓ Why It Matters**
Injection has appeared on every OWASP Top 10 list. In 2025, it appears **twice** — once for classic injection (A05) and once through insecure design (A06 covers prompt injection). It remains one of the most exploited vulnerability classes.

**🔍 Types of Injection**

| Type | Target | Example Payload |
|------|--------|-----------------|
| SQL Injection | Database | `' OR 1=1 --` |
| Command Injection | OS shell | `; cat /etc/passwd` |
| SSTI | Template engine | `{{7*7}}` → `49` |
| Prompt Injection | LLM/AI | `Ignore previous instructions and...` |
| LDAP Injection | Directory service | `*)(uid=*))(|(uid=*` |
| XPath Injection | XML data | `' or '1'='1` |

**🧪 Pentester Checklist**

```
[ ] Identify all input points: forms, URL params, headers, cookies, JSON fields
[ ] Test for SQLi: ', ", --, OR 1=1, UNION SELECT
[ ] Test for SSTI: {{7*7}}, ${7*7}, #{7*7}, <%= 7*7 %> — look for 49 in response
[ ] Test for CMDi: ; id, | whoami, && ls, `id`
[ ] Test for prompt injection in AI-powered features
[ ] Check whether error messages confirm the injection type (stack traces, DB errors)
[ ] Escalate: from detection → data extraction → file read → RCE
```

**🏴 THM Lab Mapping**
- Lab: SSTI challenge at `http://10.82.157.136:8000`
- Pattern: User input rendered by template engine without sanitisation
- Goal: Read `flag.txt` from the same directory as the web app
- Typical SSTI escalation path:

```
Test: {{7*7}} → confirms template is rendering input
Read: {{config}} or {{request.application.__globals__}} → explore objects  
RCE: Use OS module access through __mro__ chain to execute: cat flag.txt
```

**🛡️ Mitigation**
- Use **parameterised queries** / prepared statements — never build queries by string concatenation
- Avoid functions that pass user input to the shell; use safe APIs
- Validate and sanitise all input: enforce type, length, format, and allowed characters
- Use allowlists, not denylists for input validation
- Treat AI model inputs as untrusted; separate system prompts from user content

---

### A08 — Software or Data Integrity Failures

**📖 Idea in one sentence**
> The app relies on code, updates, or serialised data without verifying their authenticity or integrity — trusting that it hasn't been tampered with.

**🔍 Common Patterns**

```
- Deserialising attacker-controlled data (pickle, Java serialisation, YAML unsafe load)
- Software updates pulled without signature/hash verification
- CI/CD pipelines that trust unverified artefacts
- Loading JS libraries from unverified CDNs without SRI hashes
- Accepting serialised objects (base64-encoded) from user input
```

**🧪 Pentester Checklist**

```
[ ] Look for serialised objects in cookies, JSON fields, POST bodies (base64, binary blobs)
[ ] Identify the serialisation format: Python pickle, Java ObjectInputStream, PHP serialize()
[ ] Check for unsafe deserialisers: pickle.loads(), yaml.load(), unserialize() 
[ ] Generate a malicious payload and inject it
[ ] Look for CI/CD pipeline files — can you inject a malicious step?
[ ] Check JS includes for missing SRI (integrity=) attributes
```

**🏴 THM Lab Mapping**
- Lab: Python deserialisation at `http://10.82.157.136:8002`
- Pattern: App deserialises user-submitted Python pickle data without validation
- Goal: Craft a pickle payload that reads `flag.txt`

```python
# Malicious pickle payload pattern:
import pickle, os, base64

class Exploit(object):
    def __reduce__(self):
        return (os.system, ('cat flag.txt',))

payload = base64.b64encode(pickle.dumps(Exploit()))
print(payload)
# Submit this payload to the application
```

**🛡️ Mitigation**
- Never deserialise untrusted data — treat all incoming serialised objects as hostile
- Use safe serialisation formats (JSON) over binary formats when possible
- Verify integrity of software updates with cryptographic signatures
- Use SRI hashes for externally loaded scripts
- Apply integrity checks (checksums) to build artefacts in CI/CD

---

## 📊 At-a-Glance Summary Table

| ID | Category | IAAA Layer | Classic Attack Example | Mitigation in One Line |
|----|----------|-----------|----------------------|----------------------|
| **A01** | Broken Access Control | Authorisation | IDOR: change `id=7` → `id=6` to read another user's data | Server-side checks on every request; deny by default |
| **A02** | Security Misconfiguration | All layers | Default creds, open S3 bucket, exposed /admin | Harden defaults; automate config scanning in CI/CD |
| **A03** | Software Supply Chain Failures | Integrity | Malicious npm package executes on install | Pin deps; verify signatures; scan SBOM regularly |
| **A04** | Cryptographic Failures | Auth/Data | MD5 passwords cracked offline; hardcoded AES key | Use bcrypt/Argon2; AES-GCM; manage keys with KMS |
| **A05** | Injection | Input handling | SSTI: `{{7*7}}` → RCE → read `flag.txt` | Parameterised queries; input validation/sanitisation |
| **A06** | Insecure Design | Architecture | Unauth API endpoint; prompt injection on LLM | Threat model every feature; validate all AI I/O |
| **A07** | Authentication Failures | Authentication | Register `aDmiN` to hijack `admin` account | Canonical uniqueness; rate limits; rotate sessions |
| **A08** | Software/Data Integrity Failures | Integrity | Python pickle RCE via malicious deserialised object | Never deserialise untrusted data; verify signatures |
| **A09** | Logging & Alerting Failures | Accountability | Brute force undetected; no logs to investigate | Log full auth lifecycle; centralise; alert on anomalies |
| **A10** | Mishandling Exceptional Conditions | All layers | Exception causes fail-open: auth bypass on error | Fail closed; catch all exceptions; generic user errors |

---

## 🔗 Practice Resources

### TryHackMe Rooms

| Topic | Link |
|-------|------|
| IAAA & Identity Management | https://tryhackme.com/room/iaaaidm |
| OWASP Top 10 2025: IAAA Failures | https://tryhackme.com/room/owasptopten2025one |
| OWASP Top 10 2025: Application Design Flaws | https://tryhackme.com/jr/owasptopten2025two |
| OWASP Top 10 2025: Insecure Data Handling | https://tryhackme.com/room/owasptopten2025three |
| Broken Access Control | https://tryhackme.com/room/owaspbrokenaccesscontrol |
| IDOR | https://tryhackme.com/room/idor |
| Authentication Bypass | https://tryhackme.com/room/authenticationbypass |
| Multi-Factor Authentication | https://tryhackme.com/room/multifactorauthentications |
| Logging for Accountability | https://tryhackme.com/room/loggingforaccountability |
| Cryptographic Failures Module | https://tryhackme.com/module/cryptofailures |
| Injection Attacks Module | https://tryhackme.com/module/injection-attacks |
| Command Injection | https://tryhackme.com/room/oscommandinjection |
| Insecure Deserialisation | https://tryhackme.com/room/insecuredeserialisation |
| Supply Chain Attacks | https://tryhackme.com/room/supplychainattacks |

### Official References

| Reference | Link |
|-----------|------|
| OWASP Top 10 2025 Official | https://owasp.org/Top10/ |
| OWASP Testing Guide | https://owasp.org/www-project-web-security-testing-guide/ |
| OWASP ASVS | https://owasp.org/www-project-application-security-verification-standard/ |
| PortSwigger Web Security Academy | https://portswigger.net/web-security |

---

## 🗂️ Quick Study Checklists (CPENT / CTF Mode)

### Before Attacking Any Web App

```
[ ] Map all endpoints: spidering, JS analysis, Burp sitemap
[ ] Check authentication: login, register, password reset, session handling
[ ] Check authorisation: try horizontal + vertical escalation on every object
[ ] Test all input points for injection (SQL, SSTI, CMDi, XSS)
[ ] Look for crypto issues: default keys, weak hashing, hardcoded secrets
[ ] Check for serialised data in cookies/requests
[ ] Review error messages for information leakage
[ ] Check security headers and TLS configuration
```

### Key Burp Suite Techniques

```
[ ] Use Repeater to manually test IDOR by changing IDs
[ ] Use Intruder for username enumeration and brute-force testing
[ ] Use Decoder to identify and decode base64/serialised blobs
[ ] Use Comparer to spot timing differences in auth responses
[ ] Use Logger++ or Proxy history to track all requests for review
[ ] Use Active Scan for automated injection detection (Pro only)
```

---

*Last updated: May 2026 | Based on OWASP Top 10:2025 and TryHackMe OWASP 2025 module*
