# Penetration Testing Frameworks

## Overview

Penetration testing frameworks provide structured, repeatable methodologies for conducting security assessments. Rather than performing unorganised ad-hoc testing, frameworks establish defined phases, legal boundaries, and consistent reporting standards. Professionals use multiple frameworks in combination — one to govern the overall process, another to guide specific test categories, and a scoring system to communicate severity.

---

## PTES — Penetration Testing Execution Standard

The **Penetration Testing Execution Standard (PTES)** is the most widely adopted framework in the industry. It defines seven sequential phases that take a tester from initial client agreement through to final deliverable.

### The 7 Phases

| Phase | Core Activities |
|---|---|
| **1. Pre-engagement Interactions** | Define scope, sign Rules of Engagement (RoE), establish legal authorisation, agree on timeline and communication protocols |
| **2. Intelligence Gathering** | OSINT — Google dorking, Shodan, LinkedIn, WHOIS, subdomain enumeration, passive recon |
| **3. Threat Modeling** | Map attack surface, identify high-value targets (crown jewels), model realistic adversary behaviour |
| **4. Vulnerability Analysis** | Active scanning (Nessus, Nikto, OpenVAS), manual probing, CVE correlation against discovered services |
| **5. Exploitation** | Actively exploit vulnerabilities — RCE, SQLi, auth bypass, JWT attacks, NoSQL injection, privilege escalation |
| **6. Post-Exploitation** | Pivot, lateral movement, credential dumping, persistence, demonstrate real business impact |
| **7. Reporting** | Executive summary + technical findings with CVSS scores, evidence screenshots, reproduction steps, and remediation recommendations |

> **Key insight:** Pre-engagement and reporting are equally critical as exploitation. A pentest without proper scoping is legally dangerous; a pentest without a quality report delivers zero client value.

---

## OWASP WSTG — Web Security Testing Guide

The **OWASP Web Security Testing Guide (WSTG)** is the primary reference for **web application** and **API** penetration testing. It provides granular test cases aligned to the OWASP Top 10 and beyond.

### Coverage Areas

- Authentication and session management testing
- Input validation (SQLi, XSS, XXE, SSRF, Command Injection)
- API security (REST/GraphQL endpoint enumeration and exploitation)
- Business logic flaws
- Cryptographic weakness testing (weak ciphers, JWT misconfiguration)
- File inclusion and path traversal

### Test Case IDs

Each test case carries a unique identifier (e.g., `WSTG-AUTHN-01` for authentication testing). Reference these IDs directly in pentest reports for precision and professionalism. Clients and developers can cross-reference OWASP documentation for remediation guidance.

---

## OSSTMM — Open Source Security Testing Methodology Manual

The **OSSTMM**, maintained by ISECOM, is a peer-reviewed methodology covering **operational security across five attack channels**:

1. **Human Security** — Social engineering, phishing, vishing
2. **Physical Security** — Badge cloning, tailgating, lock picking, CCTV evasion
3. **Wireless Communications** — WiFi (WPA2/WPA3), Bluetooth, RFID/NFC
4. **Telecommunications** — VoIP, PSTN, SS7 attacks
5. **Data Networks** — Traditional network and infrastructure penetration testing

### RAV — Risk Assessment Values

OSSTMM introduces a quantitative metric called **RAV (Risk Assessment Value)** — a numerical measurement of actual security posture post-test, not merely a list of vulnerabilities. This makes findings more scientific and defensible, particularly when aligning with **ISO 27001** or **GDPR** compliance requirements.

---

## PTF — Penetration Testing Framework

The **PTF** is a hands-on, tool-oriented reference that maps testing categories to specific tools:

| Test Category | Tools |
|---|---|
| Network Footprinting | `nmap`, `recon-ng`, `maltego` |
| Web Application Testing | `burpsuite`, `nikto`, `sqlmap` |
| Password Cracking | `hashcat`, `john the ripper` |
| Wireless Testing | `aircrack-ng`, `wireshark` |
| VoIP Security | `svmap`, `sipvicious` |
| Exploitation | `metasploit`, `cobalt strike` |

Think of PTF as a **toolkit reference** — used to determine which tool to pick up for each specific test category within a larger engagement.

---

## CVSS — Common Vulnerability Scoring System

Regardless of which framework governs the engagement, **CVSSv3** is the universal language for communicating severity to clients.

| Score Range | Severity | Example Vulnerability |
|---|---|---|
| 9.0 – 10.0 | **Critical** | Unauthenticated remote code execution |
| 7.0 – 8.9 | **High** | Authentication bypass, privilege escalation |
| 4.0 – 6.9 | **Medium** | Reflected XSS, information disclosure |
| 0.1 – 3.9 | **Low** | Minor misconfiguration, non-sensitive data exposure |
| 0.0 | **None** | Informational finding |

Always include CVSS scores in reports. They help clients prioritise remediation and give security teams a standardised triage queue.

---

## Combining Frameworks in Practice

Real-world engagements combine multiple frameworks:

```
PTES        → Overall engagement structure (all 7 phases)
WSTG        → Test case checklist for web/API targets
OSSTMM      → When scope includes physical, wireless, or social engineering
PTF         → Tool selection per test category
CVSS v3     → Severity scoring in all deliverables
OWASP Top 10 → Report mapping for client communication
```

### Typical Web App Engagement Flow

1. **Pre-engagement** (PTES Phase 1) — Agree scope, sign RoE, define targets
2. **Recon** (PTES Phase 2) — Subdomain enum, tech stack fingerprinting
3. **Testing** (WSTG) — Work through WSTG test cases systematically
4. **Exploitation** (PTES Phase 5 + PTF tools) — Exploit confirmed vulns with appropriate tooling
5. **Report** (PTES Phase 7 + CVSS) — Document findings with WSTG IDs, CVSS scores, and remediation steps

---

## Quick Reference — Framework Comparison

| Framework | Focus | Best Used For |
|---|---|---|
| **PTES** | Process / Lifecycle | Structuring any pentest engagement end-to-end |
| **OWASP WSTG** | Web Applications & APIs | Web app and API-specific test cases |
| **OSSTMM** | Operational Security (all channels) | Holistic assessments including physical/wireless |
| **PTF** | Tooling Reference | Choosing the right tool per test category |
| **CVSS** | Severity Scoring | Communicating vulnerability impact in reports |

---

*Source: TryHackMe — Jr Penetration Tester Path*
