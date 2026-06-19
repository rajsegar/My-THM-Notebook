# Protocols and Servers 02

## Overview

Older network protocols were designed when security was not a primary concern, so many of them send credentials and data in cleartext. This makes them vulnerable to sniffing, man-in-the-middle attacks, and password attacks.

This topic focuses on:
- Sniffing attacks
- Man-in-the-Middle (MITM) attacks
- Password attacks
- How TLS and SSH reduce these risks

---

## Key Protocols

| Protocol | Default Port | Secure Version | Secure Port | Notes |
|---|---:|---|---:|---|
| HTTP | 80 | HTTPS | 443 | Web traffic |
| FTP | 21 | FTPS | 990 | File transfer over TLS |
| SMTP | 25 | SMTPS / STARTTLS | 465 / 587 | Email sending |
| POP3 | 110 | POP3S | 995 | Email retrieval |
| IMAP | 143 | IMAPS | 993 | Email retrieval and sync |
| Telnet | 23 | SSH | 22 | Remote administration |

---

## CIA and DAD

### CIA Triad
- **Confidentiality**: Only intended parties can read the data.
- **Integrity**: Data is not altered in transit.
- **Availability**: Services stay accessible when needed.

### DAD Model
- **Disclosure** breaks confidentiality.
- **Alteration** breaks integrity.
- **Destruction** affects availability.

Attackers often aim to cause DAD against systems defenders want to protect with CIA.

---

## Sniffing Attack

A sniffing attack means capturing network traffic to read data travelling over the network. If the protocol uses cleartext, usernames, passwords, emails, and commands can be exposed.

### Where sniffing still matters
- Internal corporate networks
- Legacy systems
- Misconfigured services
- IoT devices
- Open or weak wireless networks
- Networks where encryption can be downgraded or stripped

### Common tools
- `tcpdump`
- `Wireshark`
- `tshark`
- `tcpflow`
- `ngrep`
- `NetworkMiner`

### Example
Capturing POP3 traffic on port 110 can reveal:
- `USER frank`
- `PASS D2xc9CgD`

### Useful tcpdump commands

```bash
sudo tcpdump port 110 -A
sudo tcpdump host 10.20.30.148 -A
sudo tcpdump port 80 -A
sudo tcpdump port 21 -A
sudo tcpdump -w capture.pcap
tcpdump -r capture.pcap -A
```

### Mitigation
- Use encrypted protocols
- Replace Telnet with SSH
- Use TLS for web, mail, and file transfer
- Segment networks
- Monitor for ARP spoofing and redirection attacks
- Treat internal networks as hostile

---

## Man-in-the-Middle (MITM) Attack

A MITM attack happens when the attacker intercepts communication between two parties and can read or modify the traffic without either side realising.

### Common MITM methods
- ARP spoofing
- DNS spoofing
- Rogue access points
- BGP hijacking

### MITM tools
- Bettercap
- Ettercap
- mitmproxy
- Responder

### MITM against encrypted traffic
Attackers may try:
- SSL stripping
- Fake certificates
- Abuse of compromised Certificate Authorities

### Modern defences
- HTTPS everywhere
- HSTS
- Certificate Transparency
- Certificate pinning
- Proper TLS validation
- PKI and trusted root certificates

---

## Transport Layer Security (TLS)

TLS protects confidentiality and integrity by encrypting traffic between client and server.

### SSL vs TLS
- SSL is deprecated and insecure
- TLS replaced SSL
- TLS 1.2 is still widely used and secure when properly configured
- TLS 1.3 is the modern standard

### Secure protocol upgrades

| Cleartext Protocol | Secure Version |
|---|---|
| HTTP | HTTPS |
| FTP | FTPS |
| SMTP | SMTPS / STARTTLS |
| POP3 | POP3S |
| IMAP | IMAPS |
| Telnet | SSH |

### Implicit TLS vs STARTTLS
- **Implicit TLS**: Encryption starts immediately on the dedicated secure port
- **STARTTLS**: Connection begins in cleartext and is upgraded to TLS later

Implicit TLS is generally safer because STARTTLS can be downgraded if not properly enforced.

### HTTPS workflow
1. Establish TCP connection
2. Perform TLS handshake
3. Send HTTP requests over encrypted channel

### Simplified TLS handshake
1. ClientHello
2. ServerHello
3. Key exchange
4. Finished

### TLS 1.3 advantages
- Faster handshake
- Forward secrecy by default
- Simpler and safer cipher suites
- More of the handshake is encrypted

### Certificate checks
Browsers validate:
- Who the certificate was issued to
- Which CA issued it
- Whether the certificate is still valid

### TLS testing tools
- `testssl.sh`
- `sslyze`
- SSL Labs
- `nmap --script ssl-enum-ciphers`

### Common TLS weaknesses
- TLS 1.0 / 1.1 still enabled
- Weak cipher suites
- Missing forward secrecy
- Expired or invalid certificates

---

## Secure Shell (SSH)

SSH is the secure replacement for Telnet and is used for remote administration and secure file transfer.

### SSH provides
- Server identity verification
- Encrypted communication
- Integrity protection

### SSH authentication methods
- Password authentication
- Public key authentication
- Certificate-based authentication
- Multi-factor authentication

### Basic SSH command

```bash
ssh username@target_ip
```

### Host key verification
On first connection, SSH shows the server fingerprint. You should verify it through a trusted channel before accepting it.

Known host keys are stored in:
```bash
~/.ssh/known_hosts
```

### SSH key generation

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

### Copy public key to server

```bash
ssh-copy-id mark@10.80.176.99
```

### Useful SSH options

```bash
ssh -p 2222 mark@10.80.176.99
ssh -i ~/.ssh/custom_key mark@10.80.176.99
ssh -J bastion.example.com mark@internal-server
ssh -L 8080:localhost:80 mark@10.80.176.99
ssh -D 9050 mark@10.80.176.99
ssh mark@10.80.176.99 "cat /etc/passwd"
```

### SSH config example

```bash
Host webserver
    HostName 10.80.176.99
    User mark
    Port 22
    IdentityFile ~/.ssh/id_ed25519
```

### Secure file transfer over SSH
- `sftp` is recommended
- `scp` still works but is being phased out
- `rsync over ssh` is best for syncing large directories

### SSH hardening
- Disable password authentication after keys are set up
- Disable direct root login
- Restrict allowed users or groups
- Use fail2ban
- Use modern ciphers and key exchange settings

---

## Password Attacks

Password attacks target authentication systems that rely on "something you know".

### Authentication factors
1. Something you know
2. Something you have
3. Something you are

### Common password attack types
- Password guessing
- Dictionary attack
- Brute force
- Credential stuffing
- Password spraying
- Hybrid attacks

### Why password attacks still work
Users still choose weak or reused passwords, and breach databases make automated attacks more effective.

### Useful wordlists
- `rockyou.txt`
- `SecLists`
- `CrackStation`
- Custom target-specific wordlists

---

## Hydra

THC Hydra is a fast password attack tool for online authentication services.

### General syntax

```bash
hydra -l username -P wordlist.txt server service
```

### Examples

```bash
hydra -l mark -P /usr/share/wordlists/rockyou.txt 10.80.176.99 ftp
hydra -l frank -P /usr/share/wordlists/rockyou.txt 10.80.176.99 ssh
hydra -l lazie -P /usr/share/wordlists/rockyou.txt 10.80.176.99 imap
hydra -L users.txt -P passwords.txt 10.80.176.99 ssh
```

### Useful Hydra options

| Option | Meaning |
|---|---|
| `-l` | Single username |
| `-L` | Username list |
| `-p` | Single password |
| `-P` | Password list |
| `-s` | Non-default port |
| `-V` / `-vV` | Verbose mode |
| `-t` | Parallel threads |
| `-d` | Debug mode |
| `-f` | Stop after first success |
| `-w` | Wait time |

### Other related tools
- Medusa
- Ncrack
- CrackMapExec / NetExec
- Burp Suite Intruder
- Hashcat
- John the Ripper

---

## Mitigation Against Password Attacks

- Enforce strong password policies
- Block known breached passwords
- Use account lockout carefully
- Add throttling and rate limiting
- Use CAPTCHA where appropriate
- Enable MFA
- Detect unusual login behaviour
- Apply IP-based controls
- Move toward passwordless authentication where possible

### Passwordless options
- Passkeys
- Hardware security keys
- Magic links
- Certificate-based auth

---

## Important Exam Points

- Cleartext protocols are vulnerable to sniffing and MITM.
- TLS protects confidentiality and integrity in transit.
- SSH replaces Telnet and also supports secure file transfer.
- STARTTLS upgrades a plaintext connection, while implicit TLS starts encrypted.
- Hydra is used for online password attacks against services like FTP, SSH, IMAP, and POP3.
- Strong authentication plus encryption is the main defence strategy.

---

## Quick Revision

### Insecure to secure replacements
- HTTP -> HTTPS
- FTP -> FTPS or SFTP
- Telnet -> SSH
- POP3 -> POP3S
- IMAP -> IMAPS
- SMTP -> SMTPS / STARTTLS

### Main attacks
- Sniffing = read traffic
- MITM = intercept and modify traffic
- Password attack = guess or reuse credentials

### Main defences
- TLS
- SSH
- MFA
- Rate limiting
- Strong password controls
- Certificate validation
- Network segmentation
