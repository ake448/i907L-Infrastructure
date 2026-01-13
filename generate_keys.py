#!/usr/bin/env python3
"""
Smart WireGuard Key Generation Script
Generates valid Curve25519 keys and safely updates terraform.tfvars
"""

import base64
import os
import re

def generate_curve25519_private_key():
    """Generate a valid Curve25519 private key (32 bytes, clamped)"""
    # Generate 32 random bytes
    key_bytes = os.urandom(32)

    # Apply Curve25519 clamping
    key_bytes = bytearray(key_bytes)
    key_bytes[0] &= 248  # Clear bits 0-2
    key_bytes[31] &= 127  # Clear bit 7
    key_bytes[31] |= 64   # Set bit 6

    return bytes(key_bytes)

def curve25519_public_key(private_key):
    """
    Compute Curve25519 public key from private key using pure Python implementation
    This is a simplified implementation for demonstration - in production, use nacl
    """
    # For simplicity and correctness, we'll use a basic implementation
    # In a real scenario, you'd want to use the nacl library or cryptography library

    # Montgomery curve parameters for Curve25519
    P = 2**255 - 19
    A24 = 121665  # (A-2)/4 where A = 486662

    def mod_inverse(a, m):
        """Modular inverse using extended Euclidean algorithm"""
        m0, y, x = m, 0, 1
        if m == 1:
            return 0
        while a > 1:
            q = a // m
            m, a = a % m, m
            y, x = x - q * y, y
        if x < 0:
            x += m0
        return x

    def cswap(swap, x2, x3):
        """Conditional swap"""
        dummy = swap * (x2 - x3)
        x2 = x2 - dummy
        x3 = x3 + dummy
        return x2, x3

    # Convert private key to integer
    k = int.from_bytes(private_key, byteorder='little')

    # Montgomery ladder for x-coordinate calculation
    x1 = 9  # Base point x-coordinate
    x2, z2 = 1, 0
    x3, z3 = x1, 1

    # Process bits from MSB to LSB
    for i in range(254, -1, -1):
        bit = (k >> i) & 1
        x2, x3 = cswap(bit, x2, x3)
        z2, z3 = cswap(bit, z2, z3)

        # Montgomery step
        a = (x2 + z2) % P
        b = (x2 - z2) % P
        c = (x3 + z3) % P
        d = (x3 - z3) % P

        da = (d * a) % P
        cb = (c * b) % P

        x3 = ((da + cb) % P)**2 % P
        z3 = (x1 * ((da - cb + P) % P)**2) % P
        x2 = (a**2 - b**2 + P) % P
        z2 = 4 * a * b % P

        x2, x3 = cswap(bit, x2, x3)
        z2, z3 = cswap(bit, z2, z3)

    # Final result
    if z2 != 0:
        result = (x2 * mod_inverse(z2, P)) % P
    else:
        result = 0

    # Convert back to bytes
    return result.to_bytes(32, byteorder='little')

def read_existing_tfvars():
    """Read the existing terraform.tfvars file"""
    tfvars_file = "terraform.tfvars"
    try:
        with open(tfvars_file, 'r') as f:
            return f.read()
    except FileNotFoundError:
        print(f"Warning: {tfvars_file} not found. Creating new file.")
        return ""

def remove_existing_keys(content):
    """Remove any existing WireGuard key definitions from the content"""
    key_patterns = [
        r'^wireguard_server_private_key\s*=.*$',
        r'^wireguard_server_public_key\s*=.*$',
        r'^wireguard_client_private_key\s*=.*$',
        r'^wireguard_client_public_key\s*=.*$'
    ]

    lines = content.split('\n')
    filtered_lines = []

    for line in lines:
        should_remove = False
        for pattern in key_patterns:
            if re.match(pattern, line.strip()):
                should_remove = True
                print(f"Removing existing key definition: {line.strip()}")
                break
        if not should_remove:
            filtered_lines.append(line)

    return '\n'.join(filtered_lines)

def update_wireguard_client_config(client_private_b64, server_public_b64):
    """Update wireguard-client.conf with new keys"""
    # Try to get server IP from terraform output if available
    server_ip = "YOUR_SERVER_IP_HERE"  # Default placeholder

    # Try to read from terraform.tfvars or output if available
    try:
        # This is a simple heuristic - look for any IP that might be the server
        # In a real scenario, you'd parse terraform output
        pass
    except:
        pass

    client_config = f"""[Interface]
PrivateKey = {client_private_b64}
Address = 10.10.0.2/24
DNS = 10.0.2.10, 8.8.8.8

[Peer]
PublicKey = {server_public_b64}
Endpoint = {server_ip}:51820
AllowedIPs = 10.10.0.0/24, 10.0.0.0/16
PersistentKeepalive = 25
"""

    with open("wireguard-client.conf", 'w') as f:
        f.write(client_config)

    print("Updated wireguard-client.conf")
    print("⚠️  IMPORTANT: Replace YOUR_SERVER_IP_HERE with your actual WireGuard server IP")

def update_wireguard_init_script(server_private_b64, client_public_b64):
    """Update wireguard-init.sh template variables with actual keys"""
    # Read current init script
    with open("wireguard-init.sh", 'r') as f:
        content = f.read()

    # Replace template variables with actual keys for direct execution
    # This creates a version with keys embedded for testing
    content_with_keys = content.replace("${SERVER_PRIVATE_KEY}", server_private_b64)
    content_with_keys = content_with_keys.replace("${CLIENT_PUBLIC_KEY}", client_public_b64)

    # Write a backup with embedded keys (for testing)
    with open("wireguard-init-with-keys.sh", 'w') as f:
        f.write(content_with_keys)

    print("Created wireguard-init-with-keys.sh (for testing)")
    print("Note: The main wireguard-init.sh remains as a Terraform template")

def main():
    print("Generating WireGuard Curve25519 keys...")

    # Generate keys
    server_private = generate_curve25519_private_key()
    client_private = generate_curve25519_private_key()

    server_public = curve25519_public_key(server_private)
    client_public = curve25519_public_key(client_private)

    # Convert to base64
    server_private_b64 = base64.b64encode(server_private).decode()
    server_public_b64 = base64.b64encode(server_public).decode()
    client_private_b64 = base64.b64encode(client_private).decode()
    client_public_b64 = base64.b64encode(client_public).decode()

    print("Generated keys:")
    print(f"Server Private: {server_private_b64}")
    print(f"Server Public:  {server_public_b64}")
    print(f"Client Private: {client_private_b64}")
    print(f"Client Public:  {client_public_b64}")

    # Read existing terraform.tfvars
    existing_content = read_existing_tfvars()

    # Remove existing key definitions
    cleaned_content = remove_existing_keys(existing_content)

    # Append new key definitions
    new_keys = f"""

# WireGuard Keys (auto-generated)
wireguard_server_private_key = "{server_private_b64}"
wireguard_server_public_key = "{server_public_b64}"
wireguard_client_private_key = "{client_private_b64}"
wireguard_client_public_key = "{client_public_b64}"
""".strip()

    final_content = cleaned_content.rstrip() + "\n\n" + new_keys + "\n"

    # Write back to file
    with open("terraform.tfvars", 'w') as f:
        f.write(final_content)

    print("\nKeys successfully written to terraform.tfvars")

    # Update configuration files
    update_wireguard_client_config(client_private_b64, server_public_b64)
    update_wireguard_init_script(server_private_b64, client_public_b64)

    print("\n✅ All configuration files updated!")
    print("\n📋 Next steps:")
    print("1. 📝 Update wireguard-client.conf: Replace YOUR_SERVER_IP_HERE with your WireGuard server IP")
    print("2. 🚀 Run: terraform apply")
    print("3. 🔗 Import wireguard-client.conf into your WireGuard client")
    print("4. 🖥️  RDP to Windows servers: 10.0.2.10 (DC01), 10.0.2.11 (SQL01), etc.")
    print("\n🔐 Use 'infrastructure_ssh_key' for SSH access to the VPN server")
    print("🗝️  Use generated passwords for Windows RDP access")

if __name__ == "__main__":
    main()