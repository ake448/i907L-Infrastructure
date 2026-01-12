# Generate SSH key for WireGuard server access
# Run this script to create the key pair

Write-Host "Generating SSH key pair for WireGuard server access..."

# Check if ssh-keygen is available
try {
    $null = Get-Command ssh-keygen -ErrorAction Stop
} catch {
    Write-Host "ERROR: ssh-keygen not found. Please install OpenSSH or Git for Windows." -ForegroundColor Red
    exit 1
}

# Generate the key pair
ssh-keygen -t rsa -b 4096 -f infrastructure_ssh_key -N ""

Write-Host "SSH key pair generated successfully!" -ForegroundColor Green
Write-Host "Files created:"
Write-Host "  infrastructure_ssh_key      (private key - use for SSH)"
Write-Host "  infrastructure_ssh_key.pub  (public key - imported by Terraform)"
Write-Host ""
Write-Host "To use the private key with SSH:"
Write-Host "  ssh -i infrastructure_ssh_key ubuntu@<server-ip>"
Write-Host ""
Write-Host "Next: Run 'terraform apply' to deploy with the new SSH key"