# 📑 Security Incident Investigation & Triage Report

| Metadata | Details |
| :--- | :--- |
| **Incident ID** | `INC-2026-0824-01` |
| **Incident Type** | RDP Brute Force, Malicious PowerShell Execution & Persistence |
| **Severity** | High |
| **Status** | Resolved / Closed |
| **Affected Asset** | Windows Server 2022 (`Windows-Server-Target`) |
| **Source / Attacker** | Kali Linux VM |
| **Lead Analyst** | SOC L1/L2 Analyst |

---

## 1. Executive Summary
Splunk SIEM triggered multiple correlated alerts indicating an automated brute force attack targeting local accounts via RDP. Following unauthorized access attempts, endpoint telemetry flagged suspicious obfuscated PowerShell execution, reconnaissance commands (`whoami`, `net user`, `quser`), and an attempt to maintain persistence via Scheduled Task creation. Immediate host triage, firewall containment, and remediation procedures were successfully executed.

---

## 2. Attack Timeline & Telemetry Correlation

| Timestamp | Source Telemetry | Event ID | Description / Alert Triggered |
| :--- | :--- | :--- | :--- |
| **T+00:00** | Windows Security | `4625` | Influx of failed logons (>20 failures in <180s) targeting `Administrator`. |
| **T+01:15** | Splunk Alert | - | Alert: `Windows RDP / Logon Brute Force Attempt` fired. |
| **T+02:40** | Sysmon Operational | `1` | Alert: `Obfuscated & Suspicious PowerShell Execution` triggered (`-nop -w hidden -enc`). |
| **T+03:10** | Sysmon Operational | `1` | Alert: `Host & Domain Reconnaissance Activity` triggered (`whoami.exe`, `net.exe`, `quser.exe`). |
| **T+04:05** | Windows Security | `4698` | Alert: `Unauthorized Scheduled Task Creation` flagged. |

---

## 3. Investigation & Deep Dive

### Phase 1: Credential Access (T1110.001)
* **Log Source:** Windows Security Log (EventCode `4625` - An account failed to log on)
* **Analysis:** 
  * Over 20 consecutive logon failures observed from the adversary host within a 180-second window.
  * Targeted user account: `Administrator`.
  * Failure SubStatus `0xC000006A` confirmed invalid password submissions.

### Phase 2: Execution & Discovery (T1059.001, T1087.001, T1082)
* **Log Source:** Microsoft Sysmon Operational Log (EventCode `1` - Process Creation)
* **Analysis:**
  * Process `powershell.exe` spawned with encoded arguments (`-enc`, `-nop`, `-w hidden`).
  * Secondary discovery binaries executed in sequence: `whoami.exe /all`, `net.exe user`, `systeminfo.exe`, and `quser.exe`.
  * Parent process hierarchy validated non-interactive shell spawning.

### Phase 3: Persistence Attempt (T1053.005)
* **Log Source:** Windows Security Log (EventCode `4698` - A scheduled task was created)
* **Analysis:**
  * Non-system user account executed `schtasks.exe` to register a scheduled task configured to execute at logon.
  * The task payload attempted to execute hidden PowerShell commands under the `SYSTEM` context.

---

## 4. MITRE ATT&CK Mapping

* **Credential Access:** `T1110.001` - Brute Force: Password Guessing
* **Execution:** `T1059.001` - Command and Scripting Interpreter: PowerShell
* **Discovery:** `T1087.001` - Account Discovery: Local Account
* **Discovery:** `T1082` - System Information Discovery
* **Persistence:** `T1053.005` - Scheduled Task/Job: Scheduled Task

---

## 5. Containment, Eradication & Remediation

1. **Network Containment:** Blocked adversary IP address at the local firewall level.
2. **Credential Hardening:** Enforced account lockout policies for repeated failed attempts and triggered password rotation for administrative accounts.
3. **Artifact Removal:** Removed unauthorized scheduled task entries and terminated suspicious background execution trees.

---

## 6. Defensive Hardening Recommendations

* Implement Multi-Factor Authentication (MFA) on all remote management interfaces (RDP).
* Enforce PowerShell Constrained Language Mode (CLM) and enable deep Script Block Logging (EventCode `4104`).
* Restrict direct RDP access from untrusted subnets using Network Level Authentication (NLA) and bastion hosts.
