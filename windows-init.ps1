<powershell>
# Windows Server initialization script
# Configures Windows Firewall to allow ICMP (ping) and common management protocols

# Enable ICMP Echo Request (ping) - Inbound
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow -ErrorAction SilentlyContinue

# Enable ICMP Echo Reply - Outbound
New-NetFirewallRule -DisplayName "Allow ICMPv4-Out" -Protocol ICMPv4 -Direction Outbound -Action Allow -ErrorAction SilentlyContinue

# Enable File and Printer Sharing (for SMB between servers)
Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Enabled True -ErrorAction SilentlyContinue

# Enable Windows Remote Management (WinRM)
Enable-PSRemoting -Force -ErrorAction SilentlyContinue

# Allow WinRM through firewall
Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any -ErrorAction SilentlyContinue

# Log completion
$logPath = "C:\Windows\Temp\windows-init.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Windows firewall configured successfully" | Out-File -FilePath $logPath -Append
"[$timestamp] ICMP enabled, File/Printer Sharing enabled, WinRM enabled" | Out-File -FilePath $logPath -Append
</powershell>
