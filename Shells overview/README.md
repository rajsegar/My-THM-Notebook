# 🐚 Shells — THM Complete Reference

> **Room coverage:** Linux Shells · Reverse Shells · Bind Shells · Shell Listeners · Shell Payloads · Web Shells

---

## 📁 Files in This Section

| File | Contents |
|---|---|
| [Linux-Shells.md](./Linux-Shells.md) | Shell types, commands, scripting (Bash/Fish/Zsh) |
| [Reverse-Shell.md](./Reverse-Shell.md) | How reverse shells work + all payloads |
| [Bind-Shell.md](./Bind-Shell.md) | Bind shell mechanics + comparison |
| [Shell-Listeners.md](./Shell-Listeners.md) | nc, rlwrap, ncat, socat |
| [Web-Shell.md](./Web-Shell.md) | PHP web shells, upload vectors, detection |

---

## ⚡ Quick Recall Card

```
REVERSE SHELL  = Target → connects back → Attacker (bypasses firewall)
BIND SHELL     = Attacker → connects to → Target (target opens port)
WEB SHELL      = Browser → HTTP request → Server executes command

Pattern for ALL payloads: CONNECT → REDIRECT stdin/stdout/stderr → SPAWN SHELL

Bash    = /dev/tcp/IP/PORT trick + FD redirection
PHP     = fsockopen() + exec/system/shell_exec/passthru/popen
Python  = socket() + dup2(0,1,2) + pty.spawn("bash")
Others  = Telnet (mkfifo bridge), AWK (/inet/tcp), BusyBox (nc -e sh)
```

---

## 🎯 Why Shells Matter in Pentesting

| Activity | What It Means |
|---|---|
| Remote Control | Run commands on target from anywhere |
| Privilege Escalation | Low-privilege → root/admin |
| Data Exfiltration | Read/copy sensitive files |
| Persistence | Backdoors, hidden users |
| Post-Exploitation | Deploy malware, delete logs |
| Pivoting | Hop into deeper network targets |

> **Key:** A shell is often just a *foothold* — the real target is deeper in the network.
> `Attacker → Compromised Server (Shell) → Internal DB → Domain Controller`
