# 👂 Shell Listeners

Netcat is the classic listener, but these tools give you encryption, better interactivity, and more control.

## Listener Tools

| Tool | Best For | Key Advantage |
|---|---|---|
| `nc` | Basic listening | Simple, available everywhere |
| `rlwrap` | Wraps nc | Arrow keys + command history |
| `ncat` | Improved nc | SSL encryption support |
| `socat` | Advanced sockets | Flexible, powerful, verbose |

---

## Commands

### nc — Basic
```bash
nc -lvnp 443
```

### rlwrap — Better Shell Experience ⭐ Recommended Default
```bash
rlwrap nc -lvnp 443
```
Adds arrow keys, history, and line editing. **Use this over plain nc by default.**

### ncat — Encrypted Listener
```bash
# Standard
ncat -lvnp 443

# SSL encrypted (evades IDS/network monitoring)
ncat --ssl -lvnp 443
```

### socat — Advanced Socket Listener
```bash
socat -d -d TCP-LISTEN:443 STDOUT
```
| Part | Meaning |
|---|---|
| `-d -d` | Double verbose output |
| `TCP-LISTEN:443` | Open TCP listener on port 443 |
| `STDOUT` | Print incoming data to terminal |

---

## Which Listener to Use

```
Default practice    →  rlwrap nc -lvnp 443
Need encryption     →  ncat --ssl -lvnp 443
Advanced/stable     →  socat
CTF/quick access    →  nc -lvnp 443
```
