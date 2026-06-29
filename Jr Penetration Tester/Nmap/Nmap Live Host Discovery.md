# Nmap Live Host Discovery

> **TryHackMe Jr Penetration Tester Path**  
> **Topic:** Nmap Live Host Discovery  
> **Goal:** Learn how to find live hosts before doing port scanning.

---

## Table of Contents

- [1. What is Nmap?](#1-what-is-nmap)
- [2. Why Host Discovery Matters](#2-why-host-discovery-matters)
- [3. Target Enumeration](#3-target-enumeration)
- [4. Important Option: `-sn`](#4-important-option--sn)
- [5. ARP Host Discovery](#5-arp-host-discovery)
- [6. ICMP Host Discovery](#6-icmp-host-discovery)
- [7. TCP Host Discovery](#7-tcp-host-discovery)
- [8. UDP Host Discovery](#8-udp-host-discovery)
- [9. Reverse DNS Lookup](#9-reverse-dns-lookup)
- [10. Beginner Workflow](#10-beginner-workflow)
- [11. Command Cheat Sheet](#11-command-cheat-sheet)
- [12. Common Mistakes](#12-common-mistakes)
- [13. Key Takeaways](#13-key-takeaways)

---

## 1. What is Nmap?

**Nmap** stands for **Network Mapper**.

It is a free and open-source tool used for network discovery and security testing.

Penetration testers use Nmap to:

- Find live hosts
- Discover open ports
- Identify running services
- Detect versions
- Run Nmap scripts
- Support reconnaissance during authorised testing

In this note, the focus is only on **live host discovery**.

---

## 2. Why Host Discovery Matters

Before scanning ports, we should first identify which systems are online.

If we scan offline hosts, we waste time and generate unnecessary network noise.

### Main Questions

| Question | Meaning |
|---|---|
| Which systems are up? | Live host discovery |
| What services are running? | Port and service scanning |

This note focuses on the first question:

> **Which hosts are alive?**

---

## 3. Target Enumeration

Before scanning, we need to tell Nmap what target to scan.

### Single IP

```bash
nmap 10.10.10.5
```

### Multiple Targets

```bash
nmap 10.10.10.5 10.10.10.6 example.com
```

### IP Range

```bash
nmap 10.10.10.1-20
```

This scans:

```text
10.10.10.1
10.10.10.2
10.10.10.3
...
10.10.10.20
```

### Subnet

```bash
nmap 10.10.10.0/24
```

This scans the whole `/24` subnet.

### Targets From a File

Create a file:

```bash
nano targets.txt
```

Example:

```text
10.10.10.5
10.10.10.6
example.com
```

Run:

```bash
nmap -iL targets.txt
```

### List Targets Without Scanning

```bash
nmap -sL 10.10.10.0/24
```

Disable DNS lookup:

```bash
nmap -sL -n 10.10.10.0/24
```

---

## 4. Important Option: `-sn`

The option `-sn` means:

```text
Host discovery only
Do not scan ports
```

Example:

```bash
nmap -sn 10.10.10.0/24
```

This checks which hosts are alive but does not scan open ports.

### Easy Memory Tip

```text
-sn = host discovery only
```

---

## 5. ARP Host Discovery

## What is ARP?

**ARP** stands for **Address Resolution Protocol**.

ARP is used to find the MAC address of a device on the same local network.

### How ARP Discovery Works

```text
1. Nmap sends an ARP request:
   "Who has this IP address?"

2. The live host replies:
   "I have this IP. This is my MAC address."

3. Nmap marks the host as alive.
```

### When ARP Works

ARP works when:

- You are on the same subnet
- You are scanning a local network
- The target can receive broadcast ARP requests

ARP does **not** cross routers.

### ARP Scan Command

```bash
sudo nmap -PR -sn 10.10.10.0/24
```

### Command Breakdown

| Option | Meaning |
|---|---|
| `sudo` | Run with privileges |
| `-PR` | Use ARP ping |
| `-sn` | Host discovery only |
| `10.10.10.0/24` | Target subnet |

### When to Use ARP Scan

Use ARP scan during:

- Internal network testing
- TryHackMe lab networks
- Same-subnet discovery
- Post-exploitation internal enumeration
- Local office network audits with permission

### Easy Memory Tip

```text
Same subnet? Use ARP.
Different subnet? Use ICMP, TCP, or UDP.
```

---

## 6. ICMP Host Discovery

ICMP is commonly used for ping.

Normal ping uses:

| ICMP Type | Meaning |
|---|---|
| Type 8 | Echo Request |
| Type 0 | Echo Reply |

---

### 6.1 ICMP Echo Scan

Command:

```bash
sudo nmap -PE -sn 10.10.10.0/24
```

| Option | Meaning |
|---|---|
| `-PE` | ICMP Echo Request |
| `-sn` | Host discovery only |

How it works:

```text
Nmap sends ICMP Echo Request.
If the host replies with ICMP Echo Reply, the host is alive.
```

### Important Note

Many firewalls block ICMP Echo requests.

No reply does **not** always mean the host is offline.

---

### 6.2 ICMP Timestamp Scan

Command:

```bash
sudo nmap -PP -sn 10.10.10.0/24
```

| Option | Meaning |
|---|---|
| `-PP` | ICMP Timestamp Request |

Use this when normal ICMP Echo ping is blocked.

---

### 6.3 ICMP Address Mask Scan

Command:

```bash
sudo nmap -PM -sn 10.10.10.0/24
```

| Option | Meaning |
|---|---|
| `-PM` | ICMP Address Mask Request |

This method often fails because many systems and firewalls block this ICMP type.

If it returns no hosts, try another method.

---

## 7. TCP Host Discovery

TCP discovery is useful when ICMP is blocked.

Nmap sends TCP packets to common ports and checks whether the target responds.

Common useful ports:

| Port | Service |
|---|---|
| 22 | SSH |
| 80 | HTTP |
| 443 | HTTPS |
| 8080 | Alternative HTTP |

---

### 7.1 TCP SYN Ping Scan

Command:

```bash
sudo nmap -PS22,80,443 -sn 10.10.10.0/24
```

| Option | Meaning |
|---|---|
| `-PS` | TCP SYN ping |
| `22,80,443` | Ports to test |
| `-sn` | Host discovery only |

How it works:

```text
Nmap sends SYN packet.
If the target replies with SYN/ACK or RST, the host is alive.
```

### Why RST Means Alive

Even if the port is closed, the host may reply with `RST`.

That reply proves the machine exists.

### Easy Memory Tip

```text
Any response = host is alive.
```

---

### 7.2 TCP ACK Ping Scan

Command:

```bash
sudo nmap -PA22,80,443 -sn 10.10.10.0/24
```

| Option | Meaning |
|---|---|
| `-PA` | TCP ACK ping |

How it works:

```text
Nmap sends a TCP packet with ACK flag.
If the host replies with RST, Nmap marks it as alive.
```

TCP ACK ping can sometimes behave differently through firewall rules compared with SYN ping.

---

## 8. UDP Host Discovery

UDP does not use a handshake like TCP.

### UDP Ping Scan

Command:

```bash
sudo nmap -PU53,161,162 -sn 10.10.10.0/24
```

| Option | Meaning |
|---|---|
| `-PU` | UDP ping |
| `53` | DNS |
| `161` | SNMP |
| `162` | SNMP Trap |

How it works:

```text
Nmap sends a UDP packet.
If the UDP port is closed, the target may reply with ICMP port unreachable.
That reply means the host is alive.
```

### Important Note

No reply does not always mean the host is offline.

UDP is often filtered by firewalls.

---

## 9. Reverse DNS Lookup

Reverse DNS converts an IP address into a hostname.

Example:

```text
10.10.10.5 -> web01.company.local
```

This can help identify system roles.

| Hostname | Possible Meaning |
|---|---|
| `dc01.company.local` | Domain Controller |
| `mail.company.local` | Mail Server |
| `web01.company.local` | Web Server |
| `db01.company.local` | Database Server |

### Reverse DNS Options

| Option | Meaning |
|---|---|
| `-n` | Disable DNS lookup |
| `-R` | Force reverse DNS lookup |
| `--dns-servers` | Use a specific DNS server |

### Disable DNS Lookup

```bash
nmap -sn -n 10.10.10.0/24
```

Use this for faster scanning.

### Force Reverse DNS Lookup

```bash
nmap -sn -R 10.10.10.0/24
```

Use this when hostnames may help your recon.

### Use a Specific DNS Server

```bash
nmap -sn --dns-servers 10.10.10.1 10.10.10.0/24
```

---

## 10. Beginner Workflow

This is a simple workflow I can follow during labs or authorised testing.

```bash
# 1. List targets without scanning
nmap -sL -n 10.10.10.0/24

# 2. Basic host discovery
sudo nmap -sn -n 10.10.10.0/24

# 3. Local subnet ARP scan
sudo nmap -PR -sn -n 10.10.10.0/24

# 4. ICMP discovery
sudo nmap -PE -sn -n 10.10.10.0/24

# 5. TCP SYN discovery if ICMP is blocked
sudo nmap -PS22,80,443 -sn -n 10.10.10.0/24

# 6. TCP ACK discovery
sudo nmap -PA22,80,443 -sn -n 10.10.10.0/24

# 7. UDP discovery
sudo nmap -PU53,161,162 -sn -n 10.10.10.0/24
```

---

## 11. Command Cheat Sheet

| Scan Type | Command | Best For |
|---|---|---|
| Basic host discovery | `nmap -sn TARGET` | Quick live host check |
| ARP scan | `sudo nmap -PR -sn TARGET` | Same local subnet |
| ICMP Echo scan | `sudo nmap -PE -sn TARGET` | Ping-based discovery |
| ICMP Timestamp scan | `sudo nmap -PP -sn TARGET` | When Echo is blocked |
| ICMP Address Mask scan | `sudo nmap -PM -sn TARGET` | Alternative ICMP test |
| TCP SYN ping | `sudo nmap -PS22,80,443 -sn TARGET` | When ICMP is blocked |
| TCP ACK ping | `sudo nmap -PA22,80,443 -sn TARGET` | Firewall behaviour testing |
| UDP ping | `sudo nmap -PU53,161,162 -sn TARGET` | UDP-based discovery |
| Disable DNS | `nmap -sn -n TARGET` | Faster scan |
| List only | `nmap -sL -n TARGET` | Preview target list |

---

## 12. Common Mistakes

### Mistake 1: Forgetting `-sn`

Without `-sn`, Nmap may start port scanning.

Use:

```bash
nmap -sn TARGET
```

---

### Mistake 2: Thinking No Reply Means Offline

No reply can mean:

- Host is offline
- Firewall blocked request
- ICMP is disabled
- TCP packet was filtered
- UDP packet was filtered

Always try more than one discovery method.

---

### Mistake 3: Using ARP Against a Remote Subnet

ARP does not cross routers.

Use ARP only on the same local subnet.

---

### Mistake 4: DNS Slowing the Scan

Use `-n` to disable DNS lookup:

```bash
nmap -sn -n TARGET
```

---

## 13. Key Takeaways

- Host discovery is done before port scanning.
- `-sn` means host discovery only.
- ARP is best for same-subnet discovery.
- ICMP is useful but often blocked.
- TCP SYN and ACK ping can find hosts when ICMP is blocked.
- UDP ping can detect hosts using ICMP port-unreachable replies.
- Any response from a target usually means the host is alive.
- Use `-n` to make scans faster by disabling DNS lookup.
- Try multiple methods because firewalls can block some packet types.

---

## Final Mini Cheat Sheet

```bash
# Host discovery only
nmap -sn TARGET

# Disable DNS lookup
nmap -sn -n TARGET

# ARP discovery
sudo nmap -PR -sn TARGET

# ICMP Echo discovery
sudo nmap -PE -sn TARGET

# ICMP Timestamp discovery
sudo nmap -PP -sn TARGET

# ICMP Address Mask discovery
sudo nmap -PM -sn TARGET

# TCP SYN ping discovery
sudo nmap -PS22,80,443 -sn TARGET

# TCP ACK ping discovery
sudo nmap -PA22,80,443 -sn TARGET

# UDP ping discovery
sudo nmap -PU53,161,162 -sn TARGET

# List targets only, no scanning
nmap -sL -n TARGET
```

---

## Legal Reminder

Only scan systems that you own or have permission to test.

These notes are for TryHackMe labs, learning, authorised penetration testing, and defensive security practice.

