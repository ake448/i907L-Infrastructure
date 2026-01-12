#!/bin/bash
# WireGuard VPN Server initialization script
# Installs and configures WireGuard server with IP forwarding and NAT

set -e

# Update system packages
apt-get update
apt-get install -y wireguard wireguard-tools resolvconf net-tools

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Ensure WireGuard module is loaded
modprobe wireguard

# Create WireGuard directory
mkdir -p /etc/wireguard
chmod 700 /etc/wireguard

# Create WireGuard config directory
mkdir -p /etc/wireguard/keys
chmod 700 /etc/wireguard/keys

# Note: Server keys should be injected via Terraform
# This script expects them to exist in /etc/wireguard/keys/

# Generate WireGuard interface configuration
# Server runs on 10.10.0.1/24 with UDP 51820
cat > /etc/wireguard/wg0.conf << 'EOF'
[Interface]
PrivateKey = {{SERVER_PRIVATE_KEY}}
Address = 10.10.0.1/24
ListenPort = 51820

# Enable NAT for clients to reach internal network
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Peer: Admin client
[Peer]
PublicKey = {{CLIENT_PUBLIC_KEY}}
AllowedIPs = 10.10.0.2/32
EOF

# Set permissions
chmod 600 /etc/wireguard/wg0.conf

# Configure DNS to use DC01 as primary DNS server
cat > /etc/resolvconf/resolv.conf.d/base << 'EOF'
nameserver 10.0.2.10
nameserver 8.8.8.8
EOF

# Update resolv.conf with new DNS configuration
resolvconf -u

# Enable and start WireGuard interface
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# Log successful initialization
echo "WireGuard server initialized successfully" > /var/log/wireguard-init.log
date >> /var/log/wireguard-init.log
