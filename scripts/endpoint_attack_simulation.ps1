<#
.SYNOPSIS
    Adversary Endpoint Execution & Persistence Simulation
    Used to validate Sysmon EventCode 1 & Windows Security EventCode 4698/7045 detections.
#>

Write-Host "[*] Executing Endpoint Adversary Emulation..." -ForegroundColor Cyan

# 1. Obfuscated PowerShell Execution (T1059.001)
Write-Host "[+] Simulating Base64 Encoded PowerShell Execution..." -ForegroundColor Yellow
$Command = "Write-Output 'Adversary Execution Test'"
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Command)
$EncodedCommand = [Convert]::ToBase64String($Bytes)
powershell.exe -nop -w hidden -enc $EncodedCommand

# 2. Local Reconnaissance / Discovery (T1087.001, T1082)
Write-Host "[+] Simulating Local Discovery Commands..." -ForegroundColor Yellow
whoami /all
net user
net localgroup administrators
systeminfo

# 3. Persistence via Scheduled Task Creation (T1053.005)
Write-Host "[+] Simulating Persistence via Scheduled Task..." -ForegroundColor Yellow
schtasks /create /tn "Updater_Security_Task" /tr "powershell.exe -w hidden -c Get-Process" /sc onlogon /ru "SYSTEM" /f

Write-Host "[*] Emulation script execution completed." -ForegroundColor Green
