# Protocols and Servers - THM Notes

> **Room:** Protocols and Servers | **Path:** Jr Penetration Tester

---

## Table of Contents
- [Why Learn These Protocols?](#why-learn)
- [Telnet](#telnet)
- [HTTP](#http)
- [FTP](#ftp)
- [SMTP](#smtp)
- [POP3](#pop3)
- [IMAP](#imap)
- [Protocol Reference Table](#reference-table)

---

## Why Learn These Protocols?

These protocols (HTTP, FTP, POP3, SMTP, IMAP) are **decades old** but still relevant because:

- **Still in use** - Legacy systems, IoT devices, internal networks still use cleartext versions
- **Pen testing reality** - You WILL find these during real assessments
- **Understanding attacks** - Knowing how SMTP works = understanding email spoofing; knowing HTTP = understanding web vulns
- **Cleartext = dangerous** - Credentials travel unencrypted and can be sniffed

> **Prerequisites:** TCP/IP knowledge, ports, client-server model, Linux terminal

---

## Telnet

### What is it?
- Application-layer protocol to connect to a remote system's terminal
- Default port: **23**
- **All traffic is unencrypted (cleartext)**

### Where you'll find it during a Pentest
- Legacy routers, switches, industrial controllers
- Embedded/IoT devices
- Internal networks with poor security
- Misconfigured systems

> **Finding an open port 23 = significant finding** (legacy system or misconfiguration)

### Telnet Client as a Testing Tool
Even though Telnet servers are rare, the **Telnet client** is super useful for manually talking to any TCP-based text protocol:
```bash
telnet <target> 80    # Talk to a web server manually
telnet <target> 21    # Talk to FTP manually
telnet <target> 25    # Talk to SMTP manually
```

### Why Telnet is Insecure
- Username AND password travel in cleartext across the network
- Anyone with network access can capture credentials:
  - Attackers on the same network segment
  - Compromised routers/switches
  - Malicious insiders
  - MITM attackers
- **Secure alternative: SSH** (encrypts everything)

---

## HTTP

### What is it?
- Protocol used to transfer web pages
- Default port: **80** (HTTP) | **443** (HTTPS)
- **Cleartext** - anyone on the network can read the traffic

### HTTP vs HTTPS
| Feature | HTTP | HTTPS |
|---------|------|-------|
| Port | 80 | 443 |
| Encryption | None (cleartext) | TLS encrypted |
| Commands | Same | Same (just wrapped in TLS) |
| Browser label | "Not Secure" | Padlock icon |

### Manually Sending HTTP Requests (with Telnet)
```bash
telnet <target-ip> 80
GET /index.html HTTP/1.1
host: telnet
[press Enter twice]
```

**Example response:**
```
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
Content-Type: text/html
...
```

### Key Pentest Takeaway
- **Server header leaks info** - e.g., `Server: nginx/1.18.0 (Ubuntu)` reveals:
  - Web server software + version
  - OS type
  - Both can be used to look up known CVEs
- Security-conscious admins suppress/obscure this

### Popular Web Servers
- **Nginx** - Most widely used, high performance
- **Apache** - Highly configurable, huge module ecosystem
- **IIS** - Microsoft's server, common in Windows enterprise

### HTTP Versions
| Version | Notes |
|---------|-------|
| HTTP/1.1 | Text-based, easiest to interact with manually |
| HTTP/2 | Binary, multiplexing, harder to use with Telnet |
| HTTP/3 | Uses QUIC (UDP-based), fastest, increasingly common |

---

## FTP

### What is it?
- File Transfer Protocol - designed for efficient file transfer
- Default port: **21** (control) | **20** (data - active mode)
- **Cleartext** - credentials and files visible in traffic

### Where you'll still find plain FTP
- Legacy systems/old apps
- Anonymous FTP servers (public file distribution)
- Internal networks
- Embedded devices and network equipment
- Misconfigured servers

### FTP Modes
| Mode | Who initiates data connection | Firewall-friendly? |
|------|-------------------------------|--------------------|
| **Active** | Server initiates back to client (port 20) | No - often blocked by NAT/firewall |
| **Passive** | Client initiates both connections | Yes - default for modern clients |

### Manually Interacting with FTP (via Telnet)
```bash
telnet <target> 21
USER frank
PASS D2xc9CgD
SYST          # shows system type
PASV          # switch to passive mode
TYPE A        # ASCII mode
TYPE I        # Binary mode
STAT          # show server status
QUIT
```

### Downloading Files (actual FTP client)
```bash
ftp <target>
# Login when prompted
ls            # list files
ascii         # switch to ASCII mode (for text files)
get README.txt
exit
```

### Anonymous FTP - Always Try This!
```bash
ftp <target>
USER anonymous
PASS anything@example.com   # any email works
```
> **Why it matters:** Anonymous FTP servers may contain:
> - Sensitive files accidentally exposed
> - Config backups
> - Write access = upload malicious files

### Secure Alternatives to FTP
| Alternative | Port | Notes |
|-------------|------|-------|
| SFTP | 22 | FTP over SSH - most common replacement |
| FTPS | 990 (implicit) / 21 (STARTTLS) | FTP + TLS encryption |
| SCP | 22 | Runs over SSH, being deprecated in favour of SFTP |

---

## SMTP

### What is it?
- Simple Mail Transfer Protocol - used to **send** email
- Communicates with MTA (Mail Transfer Agent)

### Email Delivery Components
```
You (MUA) --> MSA --> MTA --> [Internet] --> MTA --> MDA --> Recipient (MUA)
```
| Component | Role |
|-----------|------|
| **MUA** | Mail User Agent - your email client (Outlook, Thunderbird) |
| **MSA** | Mail Submission Agent - checks your email for errors |
| **MTA** | Mail Transfer Agent - routes mail between servers |
| **MDA** | Mail Delivery Agent - stores email in recipient's mailbox |

### SMTP Ports
| Port | Use | Encryption |
|------|-----|------------|
| **25** | Server-to-server (MTA to MTA) | Optional via STARTTLS |
| **587** | Client submission (MUA to MSA) | STARTTLS - recommended |
| **465** | SMTPS (implicit TLS) | Encrypted from start |

### Manually Sending Email via Telnet
```bash
telnet <target> 25
helo telnet
mail from: <sender@example.com>
rcpt to: <recipient@example.com>
data
subject: Test Email
Hello, this is a test!
.                          # single dot on its own line = end of message
quit
```

### Key Security Issue - Email Spoofing!
> The `mail from:` address is **not verified** by the server. This is how email spoofing works - you can claim to be anyone. SMTP was designed for trusted networks, not the modern internet.

### Why SMTP Matters for Pentesters
- Email = #1 phishing vector
- Open relay misconfiguration = server used for spam
- Cleartext SMTP = credentials and content sniffable
- Email header analysis for incident response
- Modern defences: **SPF, DKIM, DMARC** (covered in Protocols & Servers 2)

---

## POP3

### What is it?
- Post Office Protocol v3 - used to **download** email from a server
- Default port: **110** (cleartext) | **995** (POP3S - TLS)
- **Download and delete model** - emails removed from server after download

### POP3 Commands
| Command | Description |
|---------|-------------|
| `USER username` | Identifies the user |
| `PASS password` | Authenticates |
| `STAT` | Returns number of messages + total size |
| `LIST` | Lists all messages with sizes |
| `RETR n` | Retrieves message number n |
| `DELE n` | Marks message n for deletion |
| `RSET` | Unmarks messages marked for deletion |
| `QUIT` | Ends session, deletes marked messages |

### Manually Interacting with POP3
```bash
telnet <target> 110
USER frank
PASS D2xc9CgD
STAT              # e.g. +OK 1 179 = 1 message, 179 bytes
LIST
RETR 1            # retrieve message 1
QUIT
```

### POP3 Behaviour - Download & Delete
- Emails stored **locally** on your device after download
- Deletes from server by default (configurable)
- Not synced across multiple devices
- If device is lost = emails gone (unless backed up)

### When to use POP3
- Offline email access with limited internet
- Minimise server storage
- Single-device email access
- Local email archiving

### Pentest Value
- Credentials sent in cleartext over port 110 = sniffable
- Successful access = read sensitive emails, find password reset links
- Credentials may be **reused** on other systems

---

## IMAP

### What is it?
- Internet Message Access Protocol - **synchronised** email across multiple devices
- Default port: **143** (cleartext) | **993** (IMAPS - TLS)
- **Server-side storage model** - emails stay on the server

### IMAP vs POP3
| Feature | IMAP | POP3 |
|---------|------|------|
| Email stored | On server | Locally (downloaded) |
| Multi-device sync | Yes | No |
| Read/unread sync | Yes | No |
| Folder sync | Yes | No |
| Server storage | Higher | Lower |
| Works offline | Limited | Yes |

### IMAP Commands
| Command | Description |
|---------|-------------|
| `LOGIN user pass` | Authenticate |
| `LIST` | List all mailbox folders |
| `SELECT folder` | Open folder (read/write) |
| `EXAMINE folder` | Open folder (read-only) |
| `FETCH n BODY` | Retrieve message n |
| `SEARCH criteria` | Search messages |
| `STORE n FLAGS` | Mark message as read |
| `LOGOUT` | End session |

> **Important:** Every IMAP command needs a unique **tag** prefix (e.g., `c1`, `c2`, `c3`)

### Manually Interacting with IMAP
```bash
telnet <target> 143
c1 LOGIN frank D2xc9CgD
c2 LIST "" "*"           # list all folders
c3 EXAMINE INBOX
c4 LOGOUT
```

### IMAP Server Capability Banner
When you first connect, the server lists its capabilities:
- `IMAP4rev1` - IMAP version
- `STARTTLS` - supports upgrading to encrypted connection
- `IDLE` - server can push new mail notifications
- `ACL` - access control list support

> This is useful **recon info** during a pentest.

### Why IMAP is More Dangerous for Attackers
Compromised IMAP credentials give:
- **Persistent access** - emails stay on server, attacker keeps reading new ones
- **Historical data** - years of email history accessible
- **Password reset abuse** - search for reset emails to hijack other accounts
- **Business email compromise** - invoice fraud, impersonation
- **Lateral movement** - emails often contain creds, internal docs

---

## Reference Table

### Protocol Quick Reference
| Protocol | Default Port | Purpose | Cleartext? | Secure Alternative | Secure Port |
|----------|-------------|---------|-----------|-------------------|-------------|
| FTP | 21 | File Transfer | YES | SFTP / FTPS | 22 / 990 |
| HTTP | 80 | Web Browsing | YES | HTTPS | 443 |
| IMAP | 143 | Email (receive/sync) | YES | IMAPS | 993 |
| POP3 | 110 | Email (download) | YES | POP3S | 995 |
| SMTP | 25 | Email (send) | YES | SMTPS / STARTTLS | 465 / 587 |
| Telnet | 23 | Remote Access | YES | SSH | 22 |

### Key Takeaways for Pentesters

1. **All these protocols = cleartext by default** - sniff the network, get the creds
2. **Telnet client** is your manual testing tool for any TCP text-based protocol
3. **FTP anonymous login** - always test this
4. **SMTP spoofing** - sender address is not verified
5. **IMAP access** = goldmine (persistent, historical, lateral movement)
6. **Finding cleartext protocols** on internal networks = significant finding
7. **Server headers in HTTP** can reveal version info for CVE research

### Secure Alternatives Summary
```
Telnet  -->  SSH
HTTP    -->  HTTPS
FTP     -->  SFTP or FTPS
SMTP    -->  SMTPS (port 465) or SMTP+STARTTLS (port 587)
POP3    -->  POP3S (port 995)
IMAP    -->  IMAPS (port 993)
```

---

> **Next Room:** Protocols and Servers 2 - covers TLS encryption, sniffing attacks, MITM, and password attacks against these protocols.

