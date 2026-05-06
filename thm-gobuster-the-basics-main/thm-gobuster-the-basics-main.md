[README.md](https://github.com/user-attachments/files/27450587/README.md)

# TryHackMe — Gobuster: The Basics

> **Platform:** TryHackMe | **Difficulty:** Easy | **Category:** Reconnaissance / Enumeration  
> **Tools:** Gobuster, Wordlists (SecLists, DirBuster)

---

## 📋 Room Checklist

### Setup
- [ ] Start the TryHackMe machine
- [ ] Start the AttackBox
- [ ] Open terminal and run: `sudo nano /etc/resolv-dnsmasq`
- [ ] Insert `nameserver MACHINE_IP` as the **first** line
- [ ] Save (`CTRL+O`, `ENTER`) and exit (`CTRL+X`)
- [ ] Restart Dnsmasq: `/etc/init.d/dnsmasq restart`
- [ ] Confirm Gobuster is installed: `gobuster --help`

### dir Mode Tasks
- [ ] Run basic dir enumeration against the target
- [ ] Use `-x` flag to enumerate specific file extensions (`.php`, `.js`, etc.)
- [ ] Identify accessible directories from status codes
- [ ] Enumerate a sub-path if an interesting directory is found

### dns Mode Tasks
- [ ] Run DNS subdomain enumeration with `-d` flag
- [ ] Use `-i` flag to reveal IP addresses for found subdomains
- [ ] Identify all valid subdomains returned

### vhost Mode Tasks
- [ ] Run vhost enumeration with `--append-domain` flag
- [ ] Use `--exclude-length` to filter false positives
- [ ] Confirm true positives (Status: 200)
- [ ] Document all discovered virtual hosts

---

## 📝 Notes

### What is Gobuster?
- Open-source offensive security tool written in **Go (Golang)**
- Brute forces web directories, DNS subdomains, virtual hosts, S3 buckets, and GCS buckets using wordlists
- Sits between the **Reconnaissance** and **Scanning** phases of ethical hacking
- Included by default in **Kali Linux**; available via [GitHub](https://github.com/OJ/gobuster)

### Key Concepts

| Concept | Definition |
|---|---|
| **Enumeration** | Listing all available resources, whether accessible or not |
| **Brute Force** | Trying every possibility from a wordlist until a match is found |
| **Virtual Host (vhost)** | Different websites hosted on the **same IP/server** |
| **Subdomain** | Domain configured in **DNS**, pointing to potentially different infrastructure |

---

## ⚙️ Global Flags (All Modes)

| Short | Long | Description |
|---|---|---|
| `-t` | `--threads` | Number of concurrent threads (default: 10) |
| `-w` | `--wordlist` | Path to the wordlist |
| | `--delay` | Time each thread waits between requests |
| | `--debug` | Enable debug output |
| `-o` | `--output` | Output file to write results to |
| `-q` | `--quiet` | Suppress banner/noise |
| `-v` | `--verbose` | Verbose output (show errors) |

---

## 📁 dir Mode — Directory & File Enumeration

**Purpose:** Enumerate directories and files on a web server.

### Basic Syntax
```bash
gobuster dir -u "http://www.example.thm" -w /path/to/wordlist
```

### Common Flags

| Short | Long | Description |
|---|---|---|
| `-u` | `--url` | Target URL (required) |
| `-w` | `--wordlist` | Path to wordlist (required) |
| `-x` | `--extensions` | File extensions to search (e.g. `.php,.js`) |
| `-r` | `--followredirect` | Follow HTTP redirects |
| `-s` | `--status-codes` | Show only specific status codes |
| `-b` | `--status-codes-blacklist` | Hide specific status codes |
| `-k` | `--no-tls-validation` | Skip TLS certificate check (useful for CTFs) |
| `-c` | `--cookies` | Pass cookies with each request |
| `-H` | `--headers` | Pass custom headers |
| `-U` | `--username` | Username for authenticated requests |
| `-P` | `--password` | Password for authenticated requests |
| `-n` | `--no-status` | Hide status codes from output |

### Examples
```bash
# Basic directory scan
gobuster dir -u "http://www.example.thm" -w /usr/share/wordlists/dirb/small.txt -t 64

# Scan with file extension filtering
gobuster dir -u "http://www.example.thm" -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x .php,.js

# Follow redirects
gobuster dir -u "http://www.example.thm" -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -r
```

### Notes
- Gobuster does **not** enumerate recursively — re-run against any interesting sub-path manually
- Use the **hostname** (not just IP) if the server uses virtual hosting to avoid targeting wrong site
- WordPress directory structure follows a predictable pattern (`wp-admin`, `wp-content`, `wp-includes`)

---

## 🌐 dns Mode — Subdomain Enumeration

**Purpose:** Brute force DNS subdomains of a target domain.

### Basic Syntax
```bash
gobuster dns -d example.thm -w /path/to/wordlist
```

### Common Flags

| Short | Long | Description |
|---|---|---|
| `-d` | `--domain` | Target domain (required) |
| `-w` | `--wordlist` | Path to wordlist (required) |
| `-i` | `--show-ips` | Show resolved IP addresses |
| `-c` | `--show-cname` | Show CNAME records (cannot use with `-i`) |
| `-r` | `--resolver` | Custom DNS resolver to use |

### Example
```bash
gobuster dns -d example.thm -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt
```

### Example Output
```
Found: www.example.thm
Found: shop.example.thm
Found: academy.example.thm
Found: primary.example.thm
```

### Notes
- Useful for finding forgotten or unpatched subdomains during a pentest
- A patched vulnerability on the main domain may still exist on a subdomain
- Each wordlist entry is prepended to the domain: `word.example.thm`

---

## 🖥️ vhost Mode — Virtual Host Enumeration

**Purpose:** Brute force virtual hosts (different websites on the same server/IP).

### Basic Syntax
```bash
gobuster vhost -u "http://example.thm" -w /path/to/wordlist
```

### Common Flags

| Short | Long | Description |
|---|---|---|
| `-u` | `--url` | Base URL / target IP (required) |
| `-w` | `--wordlist` | Path to wordlist (required) |
| | `--domain` | Appends this domain to wordlist entries |
| | `--append-domain` | Appends domain to each wordlist entry |
| | `--exclude-length` | Exclude responses by body length (filters false positives) |
| `-r` | `--follow-redirect` | Follow HTTP redirects |
| `-m` | `--method` | HTTP method (GET, POST, etc.) |

### Example
```bash
gobuster vhost -u "http://MACHINE_IP" --domain example.thm \
  -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt \
  --append-domain --exclude-length 250-320
```

### How vhost Requests Work
Gobuster changes the `Host:` header of each request:
```
GET / HTTP/1.1
Host: www.example.thm
User-Agent: gobuster/3.6
```
- `www` → filled from wordlist
- `.example` → second-level domain (set via `--domain`)
- `.thm` → top-level domain (set via `--domain`)

### vhost vs dns Mode

| | **vhost mode** | **dns mode** |
|---|---|---|
| **Method** | Sends HTTP requests, changes `Host:` header | Performs DNS lookups |
| **Flag** | `-u` (URL/IP) | `-d` (domain name) |
| **Detects** | IP-based virtual hosts on same server | DNS-configured subdomains |
| **Use case** | No DNS setup, direct IP access | Full DNS infrastructure present |

### Notes
- Always use `--append-domain` when domain isn't embedded in the URL
- Use `--exclude-length` to filter 404 false positives (they tend to share similar response sizes)
- Virtual hosts and subdomains can look identical but are fundamentally different

---

## 🗂️ Useful Wordlists

| Path | Use Case |
|---|---|
| `/usr/share/wordlists/dirb/small.txt` | Quick directory scan |
| `/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt` | Thorough directory scan |
| `/usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt` | Subdomain / vhost enumeration |

---

## 🔗 Resources

- [Gobuster GitHub Repository](https://github.com/OJ/gobuster)
- [SecLists Wordlists](https://github.com/danielmiessler/SecLists)
- [TryHackMe Room](https://tryhackme.com/room/gobusterthebasics)
