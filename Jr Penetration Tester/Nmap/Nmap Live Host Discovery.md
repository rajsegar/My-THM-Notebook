# Nmap Live Host Discovery

> TryHackMe Jr Penetration Tester Path
> Topic: Nmap Live Host Discovery
> Goal: Learn how to find which hosts are alive before doing port scanning.

---

## 1. What is Nmap?

**Nmap** stands for **Network Mapper**. It is used by penetration testers and network defenders to:

* Find live hosts on a network
* Discover open ports
* Identify running services
* Perform basic service and OS detection
* Help with reconnaissance during authorised testing

In this note, the focus is only on **live host discovery**.

---

## 2. Why Host Discovery Matters

Before scanning ports, we need to know which systems are online.

If we scan offline hosts, we waste time and create unnecessary network noise.

### Main Questions

| Question                   | Meaning                   |
| -------------------------- | ------------------------- |
| Which systems are up?      | Find live hosts           |
| What services are running? | Port and service scanning |

This room focuses on the first question: **which systems are alive?**

---

## 3. Simple Nmap Scan Flow

A normal Nmap workflow looks like this:

```text
1. Choose target
2. Discover live hosts
3. Do reverse DNS lookup
4. Scan ports
5. Detect services
6. Run scripts if needed
7. Save results
```

For this note, we focus on:

```text
Target Enumeration → Host Discovery → Reverse DNS
```

---

## 4. Important Network Terms

### Network Segment

A **network segment** is a group of devices connected through the same physical or wireless network.

Examples:

* Same Ethernet switch
* Same Wi-Fi network

### Subnet

A **subnet** is a logical IP range.

Examples:

| Subnet           | Meaning                 |
| ---------------- | ----------------------- |
| `192.168.1.0/24` | Around 254 usable hosts |
| `10.10.0.0/16`   | Around 65,000 hosts     |

### Key Point

ARP works only inside the same local subnet.

If the target is in another subnet, traffic goes through a router, but ARP does not cross routers.

---

## 5. TCP/IP Layers Used for Host Discovery

Nmap can use different protocols to detect live hosts.

| Layer           | Protocol | Used For               |
| --------------- | -------- | ---------------------- |
| Link Layer      | ARP      | Local subnet discovery |
| Network Layer   | ICMP     | Ping-style discovery   |
| Transport Layer | TCP      | SYN/ACK ping discovery |
| Transport Layer | UDP      | UDP ping discovery     |

---

## 6. Target Enumeration

Before scanning, we need to tell Nmap what to scan.

### Scan a Single IP

```bash
nmap 10.10.10.5
```

### Scan Multiple Targets

```bash
nmap 10.10.10.5 10.10.10.6 example.com
```

### Scan an IP Range

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

### Scan a Subnet

```bash
nmap 10.10.10.0/24
```

This scans the whole `/24` subnet.

### Scan Targets From a File

Create a file:

```bash
nano targets.txt
```

Example file:

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

This only lists targets. It does not scan them.

To disable DNS lookup:

```bash
nmap -sL -n 10.10.10.0/24
```

---

## 7. Important Option: `-sn`

The option `-sn` means:

```text
Host discovery only
Do not scan ports
```

Example:

```bash
nmap -sn 10.10.10.0/24
```

This checks which hosts are alive, but it does not scan open ports.

### Remember

```bash
-sn = ping scan / host discovery only
```

---

# 8. ARP Host Discovery

## What is ARP?

**ARP** stands for **Address Resolution Protocol**.

It is used to find the MAC address of a device on the same local network.

### How ARP Discovery Works

```text
1. Nmap sends ARP request:
   "Who has this IP?"

2. Live host replies:
   "I have this IP. Here is my MAC address."

3. Nmap marks the host as alive.
```

### When ARP Works

ARP works only when:

* You are on the same subnet
* You are scanning a local network
* The target can receive broadcast ARP requests

### ARP Scan Command

```bash
sudo nmap -PR -sn 10.10.10.0/24
```

### Meaning

| Option          | Meaning             |
| --------------- | ------------------- |
| `sudo`          | Run with privileges |
| `-PR`           | Use ARP ping        |
| `-sn`           | Host discovery only |
| `10.10.10.0/24` | Target subnet       |

### When to Use ARP Scan

Use ARP scan when you are inside the same LAN.

Example situations:

* Internal pentest
* TryHackMe AttackBox inside lab network
* Post-exploitation internal discovery
* Local office network audit with permission

### Simple Memory Tip

```text
Same subnet? Use ARP.
Different subnet? Use ICMP/TCP/UDP.
```

---

# 9. ICMP Host Discovery

ICMP is commonly used for ping.

Normal ping uses:

| ICMP Type | Meaning      |
| --------- | ------------ |
| Type 8    | Echo Request |
| Type 0    | Echo Reply   |

## 9.1 ICMP Echo Scan

### Command

```bash
sudo nmap -PE -sn 10.10.10.0/24
```

### Meaning

| Option | Meaning             |
| ------ | ------------------- |
| `-PE`  | ICMP Echo Request   |
| `-sn`  | Host discovery only |

### How It Works

```text
Nmap sends ICMP Echo Request.
If host replies with ICMP Echo Reply, host is alive.
```

### Problem

Many firewalls block ICMP Echo requests.

So if a host does not reply, it does not always mean it is offline.

---

## 9.2 ICMP Timestamp Scan

### Command

```bash
sudo nmap -PP -sn 10.10.10.0/24
```

### Meaning

| Option | Meaning                |
| ------ | ---------------------- |
| `-PP`  | ICMP Timestamp Request |

### How It Works

Nmap sends an ICMP timestamp request.

If the target replies, Nmap marks it as alive.

### Use Case

Use this when normal ping is blocked.

---

## 9.3 ICMP Address Mask Scan

### Command

```bash
sudo nmap -PM -sn 10.10.10.0/24
```

### Meaning

| Option | Meaning                   |
| ------ | ------------------------- |
| `-PM`  | ICMP Address Mask Request |

### Important Note

This scan often fails because many systems and firewalls block this ICMP type.

If it returns no hosts, try another method.

---

# 10. TCP Host Discovery

TCP discovery is useful when ICMP is blocked.

Nmap sends TCP packets to common ports and checks whether the target responds.

Common ports:

| Port | Service                    |
| ---- | -------------------------- |
| 22   | SSH                        |
| 80   | HTTP                       |
| 443  | HTTPS                      |
| 8080 | Web proxy / alternate HTTP |

---

## 10.1 TCP SYN Ping Scan

### Command

```bash
sudo nmap -PS22,80,443 -sn 10.10.10.0/24
```

### Meaning

| Option      | Meaning             |
| ----------- | ------------------- |
| `-PS`       | TCP SYN ping        |
| `22,80,443` | Ports to test       |
| `-sn`       | Host discovery only |

### How It Works

```text
Nmap sends SYN packet.
If target replies with SYN/ACK or RST, the host is alive.
```

### Why RST Also Means Alive

Even if a port is closed, the host may reply with `RST`.

That reply proves the machine exists.

### Simple Memory Tip

```text
Any response = host is alive.
```

---

## 10.2 TCP ACK Ping Scan

### Command

```bash
sudo nmap -PA22,80,443 -sn 10.10.10.0/24
```

### Meaning

| Option | Meaning      |
| ------ | ------------ |
| `-PA`  | TCP ACK ping |

### How It Works

Nmap sends a TCP packet with the ACK flag.

If the host replies with RST, Nmap marks it as alive.

### Use Case

TCP ACK ping can sometimes pass through firewall rules differently than SYN ping.

---

# 11. UDP Host Discovery

UDP is different from TCP because it does not use a handshake.

## UDP Ping Scan

### Command

```bash
sudo nmap -PU53,161,162 -sn 10.10.10.0/24
```

### Meaning

| Option | Meaning   |
| ------ | --------- |
| `-PU`  | UDP ping  |
| `53`   | DNS       |
| `161`  | SNMP      |
| `162`  | SNMP Trap |

### How It Works

```text
Nmap sends UDP packet.
If UDP port is closed, target may reply with ICMP port unreachable.
That reply means the host is alive.
```

### Important Note

No reply does not always mean the host is offline.

UDP is often filtered by firewalls.

---

# 12. Reverse DNS Lookup

Reverse DNS means converting an IP address into a hostname.

Example:

```text
10.10.10.5 → web01.company.local
```

This can help identify system roles.

Examples:

| Hostname              | Possible Meaning  |
| --------------------- | ----------------- |
| `dc01.company.local`  | Domain controller |
| `mail.company.local`  | Mail server       |
| `web01.company.local` | Web server        |
| `db01.company.local`  | Database server   |

---

## Reverse DNS Options

| Option          | Meaning                   |
| --------------- | ------------------------- |
| `-n`            | Disable DNS lookup        |
| `-R`            | Force reverse DNS lookup  |
| `--dns-servers` | Use a specific DNS server |

### Disable DNS Lookup

```bash
nmap -sn -n 10.10.10.0/24
```

Use this when you want faster scans.

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

# 13. Best Commands to Remember

## Basic Host Discovery

```bash
nmap -sn 10.10.10.0/24
```

## ARP Scan for Local Network

```bash
sudo nmap -PR -sn 10.10.10.0/24
```

## ICMP Echo Scan

```bash
sudo nmap -PE -sn 10.10.10.0/24
```

## ICMP Timestamp Scan

```bash
sudo nmap -PP -sn 10.10.10.0/24
```

## ICMP Address Mask Scan

```bash
sudo nmap -PM -sn 10.10.10.0/24
```

## TCP SYN Ping Scan

```bash
sudo nmap -PS22,80,443 -sn 10.10.10.0/24
```

## TCP ACK Ping Scan

```bash
sudo nmap -PA22,80,443 -sn 10.10.10.0/24
```

## UDP Ping Scan

```bash
sudo nmap -PU53,161,162 -sn 10.10.10.0/24
```

## Fast Scan Without DNS

```bash
sudo nmap -sn -n 10.10.10.0/24
```

---

# 14. Quick Comparison Table

| Scan Type         | Command                              | Best For                    |
| ----------------- | ------------------------------------ | --------------------------- |
| ARP Scan          | `sudo nmap -PR -sn TARGET`           | Same local subnet           |
| ICMP Echo         | `sudo nmap -PE -sn TARGET`           | Ping-based discovery        |
| ICMP Timestamp    | `sudo nmap -PP -sn TARGET`           | When normal ping is blocked |
| ICMP Address Mask | `sudo nmap -PM -sn TARGET`           | Alternative ICMP test       |
| TCP SYN Ping      | `sudo nmap -PS22,80,443 -sn TARGET`  | When ICMP is blocked        |
| TCP ACK Ping      | `sudo nmap -PA22,80,443 -sn TARGET`  | Firewall behaviour testing  |
| UDP Ping          | `sudo nmap -PU53,161,162 -sn TARGET` | UDP-based discovery         |

---

# 15. Beginner Decision Guide

## If the target is on the same subnet

Use:

```bash
sudo nmap -PR -sn TARGET
```

## If ICMP is allowed

Use:

```bash
sudo nmap -PE -sn TARGET
```

## If ICMP is blocked

Try:

```bash
sudo nmap -PS22,80,443 -sn TARGET
```

or:

```bash
sudo nmap -PA22,80,443 -sn TARGET
```

## If TCP does not help

Try:

```bash
sudo nmap -PU53,161,162 -sn TARGET
```

## If scan is slow because of DNS

Use:

```bash
-n
```

Example:

```bash
sudo nmap -sn -n 10.10.10.0/24
```

---

# 16. My Practical Workflow

When I start host discovery, I can follow this order:

```bash
# 1. List targets without scanning
nmap -sL -n 10.10.10.0/24

# 2. Basic host discovery
sudo nmap -sn -n 10.10.10.0/24

# 3. Local subnet ARP scan
sudo nmap -PR -sn -n 10.10.10.0/24

# 4. ICMP discovery
sudo nmap -PE -sn -n 10.10.10.0/24

# 5. TCP discovery if ICMP is blocked
sudo nmap -PS22,80,443 -sn -n 10.10.10.0/24

# 6. ACK discovery
sudo nmap -PA22,80,443 -sn -n 10.10.10.0/24

# 7. UDP discovery
sudo nmap -PU53,161,162 -sn -n 10.10.10.0/24
```

---

# 17. Example Output to Understand

Example:

```bash
sudo nmap -PE -sn 10.200.6.0/24
```

Output:

```text
Nmap scan report for 10.200.6.1
Host is up.

Nmap scan report for 10.200.6.50
Host is up.

Nmap scan report for 10.200.6.250
Host is up.

Nmap done: 256 IP addresses (3 hosts up) scanned in 3.38 seconds
```

### Meaning

| Output                    | Meaning                         |
| ------------------------- | ------------------------------- |
| `Host is up`              | Target replied                  |
| `256 IP addresses`        | Nmap checked whole `/24` subnet |
| `3 hosts up`              | Nmap found 3 live systems       |
| `scanned in 3.38 seconds` | Time taken                      |

---

# 18. Common Mistakes

## Mistake 1: Forgetting `-sn`

Without `-sn`, Nmap may start port scanning.

Use:

```bash
nmap -sn TARGET
```

## Mistake 2: Thinking No Reply Means Offline

No reply can mean:

* Host is offline
* Firewall blocked request
* ICMP is disabled
* UDP/TCP packet was filtered

Always try more than one discovery method.

## Mistake 3: Using ARP Against a Remote Subnet

ARP does not cross routers.

Use ARP only on the same subnet.

## Mistake 4: DNS Slowing the Scan

Use `-n` to disable DNS lookup:

```bash
nmap -sn -n TARGET
```

---

# 19. Key Takeaways

* Host discovery is done before port scanning.
* `-sn` means host discovery only.
* ARP is best for the same local subnet.
* ICMP is useful but often blocked.
* TCP SYN/ACK ping can find hosts when ICMP is blocked.
* UDP ping can detect hosts using ICMP port-unreachable replies.
* Any response from a target usually means the host is alive.
* Use `-n` to make scans faster by disabling DNS lookup.
* Try multiple methods because firewalls can block some packet types.

---

# 20. Final Cheat Sheet

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

These notes are for learning, TryHackMe labs, authorised penetration testing, and defensive security practice.

