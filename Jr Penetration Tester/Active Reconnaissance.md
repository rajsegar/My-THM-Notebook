# Active Reconnaissance - Study Notes

> **Room:** TryHackMe - Jr Penetration Tester Path
> **Topic:** Active Reconnaissance
> **Critical Rule:** Never perform active recon without explicit written authorisation (contract / bug bounty scope).

---

## 1. Active vs Passive Recon

| | Passive | Active |
|---|---|---|
| Traffic to target? | No | Yes |
| Examples | DNS, WHOIS, certs, Shodan, search engines | Browser, ping, traceroute, telnet, netcat |
| Leaves traces? | No | Yes - logs, IDS/WAF alerts, honeypots |
| Risk | Low | Higher |

**Rule:** Always passive first, then active once you have scope + permission.

---

## 2. Web Browser + DevTools

### Ports
- HTTP → TCP **80** (rare now, usually redirects)
- HTTPS → TCP **443** (standard)
- HTTP/3 → QUIC over **UDP 443** (shows as `h3` in Network tab)
- Custom ports: `https://target.com:8443/` or `http://192.168.1.100:8080/`

### DevTools Shortcut
- Linux/Windows: `Ctrl + Shift + I`
- macOS: `Option + Command + I`

### Key Tabs for Recon

#### Network Tab
- All requests + responses in real time
- Look for headers: `Server`, `X-Powered-By`, `Content-Security-Policy`
- Check cookies, status codes, timings

#### Sources Tab
- Browse JS, CSS, HTML files
- Hunt in JS for:
  - Hidden API endpoints
  - Internal paths/directories (`/admin`, `/api/v2/`)
  - Developer comments with secrets
  - References to internal services

#### Application Tab
- Inspect: Cookies, Local Storage, Session Storage
- Look for: session tokens, accidentally exposed API keys, auth data

#### Security Tab
- TLS certificate details: issuer, validity
- **Subject Alternative Names (SANs)** → reveals extra subdomains/related domains

### Useful Extensions
| Extension | Purpose |
|---|---|
| FoxyProxy | Quick proxy switching (Burp/ZAP/SOCKS) |
| User-Agent Switcher | Pretend to be mobile/old browser |
| Wappalyzer | Quick tech stack fingerprint (CMS, server, JS framework) |

> **Note:** Rapid page loads, weird user-agents, heavy DevTools use can still be flagged by WAF/EDR.

---

## 3. Ping - Host Liveness Check

### How It Works
- Uses **ICMP** protocol
- Sends: Echo Request (type 8)
- Receives: Echo Reply (type 0)

### Commands
```bash
# Linux / macOS
ping -c 5 10.10.10.10
ping -c 5 tryhackme.com
ping -4 target        # force IPv4
ping -6 target        # force IPv6
ping6 target          # IPv6 standalone

# Windows
ping -n 5 10.10.10.10
```

### Reading Output

| Result | Meaning | Next Step |
|---|---|---|
| Fast replies, 0% loss | Host alive, ICMP allowed | Proceed to port scanning |
| "Destination Host Unreachable" | Host down or no route | Check if VM is on |
| 100% loss, no error message | ICMP filtered/blocked | Use Nmap TCP/UDP discovery |
| High latency / heavy loss | Congestion, distance, or filtering | Investigate with traceroute |

### TTL - Rough OS Hint
| OS | Default TTL |
|---|---|
| Linux/Unix | ~64 |
| Windows | ~128 |

> TTL you see = default TTL - hop count. Treat as indicator only, not proof.

---

## 4. Traceroute / MTR - Path Mapping

### Purpose
- Discover all routers (hops) between you and target
- Identify where filtering or latency occurs
- Map network infrastructure

### How It Works
- Exploits the **TTL field** in IP header
- Sends packets with TTL = 1, 2, 3... incrementally
- Each router that drops a packet (TTL=0) sends back ICMP "Time-to-Live Exceeded"
- This reveals each hop's IP address

### Commands
```bash
# Linux / macOS
traceroute target
traceroute -T target    # TCP mode (bypass UDP filters)
traceroute -I target    # ICMP mode
traceroute -6 target    # IPv6
traceroute6 target      # IPv6 standalone

# Windows
tracert target

# Real-time continuous view
mtr target              # traceroute + ping stats combined
```

### Reading Output
- Each line = one hop (router)
- Up to 3 RTT values per hop (3 probes sent)
- `*` = no reply (rate-limited, firewall, ICMP suppressed)
- Different IPs on same hop = load balancing

### Key Points
- Routes are **NOT fixed** - BGP/OSPF, load balancing, anycast (CDNs) change paths
- Run twice and you may get completely different paths
- `mtr` = best tool for continuous path + loss monitoring

---

## 5. Telnet - Legacy Banner Grabbing

### Background
- Protocol from 1969, default port **23**
- Everything in **cleartext** (including passwords) → insecure
- Replaced by SSH for remote access
- Still useful for: **manual TCP banner grabbing**

### Install
```bash
apt install telnet
```

### Banner Grabbing Example (HTTP)
```bash
telnet 10.10.10.10 80
# Then type:
GET / HTTP/1.1
host: example
# Press Enter twice
```
Look for: `Server: nginx/1.6.2` → software + version → check CVEs

### Works For Any TCP Service
| Port | Service | What you get |
|---|---|---|
| 80 | HTTP | Web server name + version |
| 21 | FTP | FTP server banner (auto on connect) |
| 25 | SMTP | Mail server banner |
| 23 | Telnet | Telnet daemon info |

### Limitation
- **Cannot handle TLS/SSL**
- For HTTPS use:
  - `curl --head https://target`
  - `openssl s_client -connect target:443`
  - `ncat --ssl target 443`

---

## 6. Netcat (nc) - Swiss Army Knife

### Why nc over Telnet?
- Supports TCP **and** UDP
- Works as client **or** server
- More flexible, scriptable
- `ncat` (Nmap version) adds IPv6 + SSL support

### Banner Grabbing (Client Mode)
```bash
# HTTP banner grab
nc 10.10.10.10 80
# Type:
GET / HTTP/1.1
host: netcat
# Press Enter (sometimes Shift+Enter)

# FTP banner (auto on connect)
nc 10.10.10.10 21

# SMTP banner
nc 10.10.10.10 25
```

### Listening (Server Mode)
```bash
# On the listener/server
nc -vnlp 1234

# On the connector/client
nc SERVER_IP 1234
```

### Flags Reference
| Flag | Meaning |
|---|---|
| `-l` | Listen mode |
| `-p` | Specify port (must be right before port number) |
| `-n` | No DNS resolution |
| `-v` | Verbose output |
| `-vv` | Very verbose |
| `-k` | Keep listening after client disconnects |
| `-6` | IPv6 mode |

> Ports below 1024 require **root** to listen on.
> For encryption: use `ncat --ssl` or wrap with stunnel.

---

## 7. Active Recon Workflow (Muscle Memory)

```
1. BROWSER + DEVTOOLS
   - Visit target, Wappalyzer snapshot
   - Network tab: headers, cookies, tech stack
   - Sources tab: JS for API endpoints, hidden paths
   - Application tab: tokens, storage
   - Security tab: SANs for more subdomains

2. PING
   - Check host liveness
   - Note TTL for rough OS hint
   - If ICMP blocked → switch to Nmap TCP discovery

3. TRACEROUTE / MTR
   - Map hops, find where filtering starts
   - Spot CDN edges, cloud infra
   - Use mtr for continuous monitoring

4. TELNET / NETCAT
   - Banner grab key ports (80, 21, 25, custom)
   - Map service versions → CVEs / Exploit-DB
   - Prefer nc over telnet

5. NMAP (next step)
   - Use all above info to tune: scan type, ports, timing, decoys
```

---

## 8. Quick Command Reference

| Command | Example |
|---|---|
| ping (Linux) | `ping -c 10 MACHINE_IP` |
| ping (Windows) | `ping -n 10 MACHINE_IP` |
| ping IPv6 | `ping -6 MACHINE_IP` or `ping6 MACHINE_IP` |
| traceroute (Linux) | `traceroute MACHINE_IP` |
| traceroute TCP | `traceroute -T MACHINE_IP` |
| traceroute ICMP | `traceroute -I MACHINE_IP` |
| tracert (Windows) | `tracert MACHINE_IP` |
| traceroute IPv6 | `traceroute -6 MACHINE_IP` |
| mtr | `mtr MACHINE_IP` |
| telnet | `telnet MACHINE_IP PORT` |
| netcat client | `nc MACHINE_IP PORT` |
| netcat server | `nc -vnlp PORT` |
| netcat IPv6 | `nc -6 MACHINE_IP PORT` |
| curl HTTP banner | `curl -I http://MACHINE_IP` |
| curl HTTPS banner | `curl -I https://MACHINE_IP` |
| openssl TLS | `openssl s_client -connect MACHINE_IP:443` |

---

## 9. Things to Remember

- **Active recon = legal risk** without permission. Always get written scope.
- Browser traffic blends in with normal users - stealth advantage.
- TTL hints at OS but is affected by hop count - not guaranteed.
- Traceroute paths change between runs (BGP, anycast, load balancing).
- `*` in traceroute = ICMP suppressed, not always a dead end.
- Telnet = cleartext only. For TLS services use openssl or ncat.
- netcat can be both client AND server - useful for connectivity testing.
- SANs in TLS certs often reveal extra subdomains - always check.
- Wappalyzer is passive while browsing - no extra requests.
- Modern WAFs/EDR detect unusual patterns even in normal-looking browser traffic.
