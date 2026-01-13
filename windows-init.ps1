<powershell>
# Windows Server initialization script
# Opens Windows Firewall for VPN and management access

# Allow ALL traffic from VPN subnet (10.10.0.0/24)
New-NetFirewallRule -DisplayName "Allow All from VPN Subnet" -Direction Inbound -Action Allow -RemoteAddress 10.10.0.0/24 -ErrorAction SilentlyContinue

# Allow ALL traffic from VPC (10.0.0.0/16)
New-NetFirewallRule -DisplayName "Allow All from VPC" -Direction Inbound -Action Allow -RemoteAddress 10.0.0.0/16 -ErrorAction SilentlyContinue

# Enable ICMP (ping) from anywhere
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Allow ICMPv4-Out" -Protocol ICMPv4 -Direction Outbound -Action Allow -ErrorAction SilentlyContinue

# Allow RDP from anywhere (for troubleshooting)
New-NetFirewallRule -DisplayName "Allow RDP from Any" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3389 -ErrorAction SilentlyContinue

# Enable File and Printer Sharing
Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Enabled True -ErrorAction SilentlyContinue

# Enable Windows Remote Management (WinRM)
Enable-PSRemoting -Force -ErrorAction SilentlyContinue
Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any -ErrorAction SilentlyContinue

# Log completion
$logPath = "C:\Windows\Temp\windows-init.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Windows firewall fully opened for VPN and VPC access" | Out-File -FilePath $logPath -Append
"[$timestamp] Allowed: VPN (10.10.0.0/24), VPC (10.0.0.0/16), ICMP, RDP" | Out-File -FilePath $logPath -Append
</powershell>
