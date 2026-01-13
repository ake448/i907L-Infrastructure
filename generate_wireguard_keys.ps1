# WireGuard Key Generation Script
# Generates Curve25519 keys using WireGuard native commands and updates configuration files

Write-Host "Generating WireGuard Curve25519 keys using native WireGuard commands..." -ForegroundColor Cyan

# Check if wg command is available
try {
    $null = Get-Command wg -ErrorAction Stop
} catch {
    Write-Host "ERROR: WireGuard 'wg' command not found. Please install WireGuard." -ForegroundColor Red
    Write-Host "Download from: https://www.wireguard.com/install/" -ForegroundColor Yellow
    exit 1
}

# Generate private keys
Write-Host "Generating server private key..." -ForegroundColor Green
$serverPrivateKey = wg genkey
Write-Host "Generating client private key..." -ForegroundColor Green
$clientPrivateKey = wg genkey

# Generate public keys from private keys
Write-Host "Generating server public key..." -ForegroundColor Green
$serverPublicKey = $serverPrivateKey | wg pubkey
Write-Host "Generating client public key..." -ForegroundColor Green
$clientPublicKey = $clientPrivateKey | wg pubkey

Write-Host "`nGenerated keys:" -ForegroundColor Cyan
Write-Host "Server Private: $serverPrivateKey"
Write-Host "Server Public:  $serverPublicKey"
Write-Host "Client Private: $clientPrivateKey"
Write-Host "Client Public:  $clientPublicKey"

# Read existing terraform.tfvars
$tfvarsFile = "terraform.tfvars"
$existingContent = ""
if (Test-Path $tfvarsFile) {
    $existingContent = Get-Content $tfvarsFile -Raw
} else {
    Write-Host "Warning: $tfvarsFile not found. Creating new file." -ForegroundColor Yellow
}

# Remove existing WireGuard key definitions
$keyPatterns = @(
    '^wireguard_server_private_key\s*=.*$',
    '^wireguard_server_public_key\s*=.*$',
    '^wireguard_client_private_key\s*=.*$',
    '^wireguard_client_public_key\s*=.*$'
)

$lines = $existingContent -split "`n"
$filteredLines = @()

foreach ($line in $lines) {
    $shouldRemove = $false
    foreach ($pattern in $keyPatterns) {
        if ($line -match $pattern) {
            $shouldRemove = $true
            Write-Host "Removing existing key definition: $($line.Trim())" -ForegroundColor Yellow
            break
        }
    }
    if (-not $shouldRemove) {
        $filteredLines += $line
    }
}

$cleanedContent = $filteredLines -join "`n"

# Append new key definitions
$newKeys = @"

# WireGuard Keys (auto-generated)
wireguard_server_private_key = "$serverPrivateKey"
wireguard_server_public_key = "$serverPublicKey"
wireguard_client_private_key = "$clientPrivateKey"
wireguard_client_public_key = "$clientPublicKey"
"@

# Combine cleaned content with new keys
$finalContent = ($cleanedContent.TrimEnd() + "`n`n" + $newKeys.Trim() + "`n").TrimEnd()

# Write back to file
Set-Content -Path $tfvarsFile -Value $finalContent -NoNewline
Write-Host "`nKeys successfully written to $tfvarsFile" -ForegroundColor Green

# Update wireguard-client.conf
function Update-WireguardClientConfig {
    param (
        [string]$ClientPrivateKey,
        [string]$ServerPublicKey
    )
    
    $serverIp = "YOUR_SERVER_IP_HERE"
    
    $clientConfig = @"
[Interface]
PrivateKey = $ClientPrivateKey
Address = 10.10.0.2/24
DNS = 10.0.2.10, 8.8.8.8

[Peer]
PublicKey = $ServerPublicKey
Endpoint = ${serverIp}:51820
AllowedIPs = 10.10.0.0/24, 10.0.0.0/16
PersistentKeepalive = 25
"@
    
    Set-Content -Path "wireguard-client.conf" -Value $clientConfig
    Write-Host "Updated wireguard-client.conf" -ForegroundColor Green
    Write-Host "⚠️  IMPORTANT: Replace YOUR_SERVER_IP_HERE with your actual WireGuard server IP" -ForegroundColor Yellow
}

# Update wireguard-init-with-keys.sh (test version)
function Update-WireguardInitScript {
    param (
        [string]$ServerPrivateKey,
        [string]$ClientPublicKey
    )
    
    if (-not (Test-Path "wireguard-init.sh")) {
        Write-Host "Warning: wireguard-init.sh not found. Skipping test script creation." -ForegroundColor Yellow
        return
    }
    
    $content = Get-Content "wireguard-init.sh" -Raw
    
    # Replace template variables with actual keys
    $contentWithKeys = $content -replace '\$\{SERVER_PRIVATE_KEY\}', $ServerPrivateKey
    $contentWithKeys = $contentWithKeys -replace '\$\{CLIENT_PUBLIC_KEY\}', $ClientPublicKey
    
    Set-Content -Path "wireguard-init-with-keys.sh" -Value $contentWithKeys
    Write-Host "Created wireguard-init-with-keys.sh (for testing)" -ForegroundColor Green
    Write-Host "Note: The main wireguard-init.sh remains as a Terraform template" -ForegroundColor Cyan
}

# Update configuration files
Update-WireguardClientConfig -ClientPrivateKey $clientPrivateKey -ServerPublicKey $serverPublicKey
Update-WireguardInitScript -ServerPrivateKey $serverPrivateKey -ClientPublicKey $clientPublicKey

Write-Host "`n✅ All configuration files updated!" -ForegroundColor Green
Write-Host "`n📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. 📝 Update wireguard-client.conf: Replace YOUR_SERVER_IP_HERE with your WireGuard server IP"
Write-Host "2. 🚀 Run: terraform apply"
Write-Host "3. 🔗 Import wireguard-client.conf into your WireGuard client"
Write-Host "4. 🖥️  RDP to Windows servers: 10.0.2.10 (DC01), 10.0.2.11 (SQL01), etc."
Write-Host "`n🔐 Use 'infrastructure_ssh_key' for SSH access to the VPN server"
Write-Host "🗝️  Use generated passwords for Windows RDP access"
