# WireGuard VPN server configuration
# AWS provider version 2.43.0
# Generates cryptographic keys and deploys VPN server to public subnet

# WireGuard keys are now defined as variables (see variables.tf)

# Network interface for WireGuard VPN server (10.10.0.1/24)
# Placed in public subnet for internet accessibility
resource "aws_network_interface" "wireguard" {
  subnet_id         = aws_subnet.public.id
  source_dest_check = false  # Required for NAT/routing VPN traffic
  security_groups   = [
    aws_security_group.vpn.id,
    aws_security_group.internal.id
  ]

  tags = {
    Name = "wireguard-eni"
  }
}

# Elastic IP for stable VPN endpoint
resource "aws_eip" "wireguard" {
  instance = aws_instance.wireguard.id
  domain   = "vpc"

  tags = {
    Name = "wireguard-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

# WireGuard VPN server - Ubuntu 20.04 LTS
# PUBLIC SUBNET - t3.small - On-Demand
# Runs on port UDP 51820
resource "aws_instance" "wireguard" {
  ami           = var.ubuntu_ami
  instance_type = "t3.small"

  network_interface {
    network_interface_id = aws_network_interface.wireguard.id
    device_index         = 0
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  # User data script to configure WireGuard
  user_data = base64encode(templatefile("${path.module}/wireguard-init.sh", {
    SERVER_PRIVATE_KEY = var.wireguard_server_private_key
    CLIENT_PUBLIC_KEY  = var.wireguard_client_public_key
  }))

  tags = {
    Name = "wireguard-vpn-server"
    Role = "vpn-gateway"
  }

  key_name = aws_key_pair.infrastructure_key.key_name

  depends_on = [aws_internet_gateway.main]
}

# Data source to get instance information after creation
data "aws_instance" "wireguard" {
  instance_id = aws_instance.wireguard.id
}

# SSH key pair - generate locally with: ssh-keygen -t rsa -b 4096 -f infrastructure_ssh_key -N ""
# This creates infrastructure_ssh_key (private) and infrastructure_ssh_key.pub (public)
resource "aws_key_pair" "infrastructure_key" {
  key_name   = "infrastructure-ssh-key"
  public_key = file("infrastructure_ssh_key.pub")
}
