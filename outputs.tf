# Infrastructure outputs - VPN configuration, server IPs, and connection details
# AWS provider version 2.43.0

output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

# WireGuard VPN Configuration Outputs
output "wireguard_server_public_ip" {
  description = "Public IP address of WireGuard VPN server"
  value       = aws_eip.wireguard.public_ip
}

output "wireguard_server_private_ip" {
  description = "Private IP address of WireGuard VPN server (10.10.0.1)"
  value       = aws_instance.wireguard.private_ip
}


# Windows Server Private IP Outputs
output "dc01_private_ip" {
  description = "Private IP of DC01 (Domain Controller)"
  value       = aws_instance.dc01.private_ip
}

output "sql01_private_ip" {
  description = "Private IP of SQL01 (SQL Server)"
  value       = aws_instance.sql01.private_ip
}

output "dev01_private_ip" {
  description = "Private IP of DEV01 (Development Server)"
  value       = aws_instance.dev01.private_ip
}

output "can01_private_ip" {
  description = "Private IP of CAN01 (Industrial Control)"
  value       = aws_instance.can01.private_ip
}

output "web01_private_ip" {
  description = "Private IP of WEB01 (Web Server)"
  value       = aws_instance.web01.private_ip
}

# Public subnet server (WEB01)
output "web01_instance_id" {
  description = "Instance ID of WEB01 (public subnet)"
  value       = aws_instance.web01.id
}

# All Windows servers summary
output "windows_servers" {
  description = "Summary of all Windows Server instances"
  value = {
    DC01 = {
      instance_id = aws_instance.dc01.id
      private_ip  = aws_instance.dc01.private_ip
      type        = "Windows Server 2022 Core"
      subnet      = "private (10.0.2.0/24)"
    }
    SQL01 = {
      instance_id = aws_instance.sql01.id
      private_ip  = aws_instance.sql01.private_ip
      type        = "Windows Server 2022 Full"
      subnet      = "private (10.0.2.0/24)"
    }
    DEV01 = {
      instance_id = aws_instance.dev01.id
      private_ip  = aws_instance.dev01.private_ip
      type        = "Windows Server 2022 Full"
      subnet      = "private (10.0.2.0/24)"
    }
    CAN01 = {
      instance_id = aws_instance.can01.id
      private_ip  = aws_instance.can01.private_ip
      type        = "Windows Server 2022 Full"
      subnet      = "private (10.0.2.0/24)"
    }
    WEB01 = {
      instance_id = aws_instance.web01.id
      private_ip  = aws_instance.web01.private_ip
      type        = "Windows Server 2022 Full"
      subnet      = "public (10.0.1.0/24)"
    }
  }
}

# Security group information
output "internal_security_group_id" {
  description = "ID of internal security group (allows all intra-group traffic)"
  value       = aws_security_group.internal.id
}

output "vpn_security_group_id" {
  description = "ID of VPN security group (allows UDP 51820 from admin IP)"
  value       = aws_security_group.vpn.id
}

# Connection summary
output "deployment_summary" {
  description = "Complete deployment summary for reference"
  value = {
    vpc_cidr           = "10.0.0.0/16"
    public_subnet_cidr = "10.0.1.0/24"
    private_subnet_cidr = "10.0.2.0/24"
    wireguard_subnet   = "10.10.0.0/24 (VPN)"
    total_servers      = 6  # 5 Windows + 1 WireGuard Ubuntu
    windows_servers    = 5
    vpn_port           = 51820
  }
}

# SSH key note
output "ssh_key_instructions" {
  description = "Instructions for SSH access to WireGuard server"
  value       = "SSH key generated locally. Use 'infrastructure_ssh_key' file with: ssh -i infrastructure_ssh_key ubuntu@${aws_eip.wireguard.public_ip}"
}

# VPN Connection Instructions
output "vpn_setup_instructions" {
  description = "Instructions for connecting to the VPN"
  value = <<-EOT
  
  VPN CONNECTION SETUP:
  1. Update wireguard-client.conf with server IP: ${aws_eip.wireguard.public_ip}
  2. Import wireguard-client.conf into your WireGuard client
  3. Connect to VPN
  4. Access servers via RDP:
     - DC01:  mstsc /v:10.0.2.10
     - SQL01: mstsc /v:10.0.2.11
     - DEV01: mstsc /v:10.0.2.12
     - CAN01: mstsc /v:10.0.2.13
     - WEB01: mstsc /v:10.0.1.50
  
  EOT
}

# Windows Password Retrieval Instructions
output "windows_password_commands" {
  description = "Commands to retrieve Windows Administrator passwords"
  value = {
    DC01 = "aws ec2 get-password-data --instance-id ${aws_instance.dc01.id} --priv-launch-key infrastructure_ssh_key --region ${var.aws_region} --query 'PasswordData' --output text"
    SQL01 = "aws ec2 get-password-data --instance-id ${aws_instance.sql01.id} --priv-launch-key infrastructure_ssh_key --region ${var.aws_region} --query 'PasswordData' --output text"
    DEV01 = "aws ec2 get-password-data --instance-id ${aws_instance.dev01.id} --priv-launch-key infrastructure_ssh_key --region ${var.aws_region} --query 'PasswordData' --output text"
    CAN01 = "aws ec2 get-password-data --instance-id ${aws_instance.can01.id} --priv-launch-key infrastructure_ssh_key --region ${var.aws_region} --query 'PasswordData' --output text"
    WEB01 = "aws ec2 get-password-data --instance-id ${aws_instance.web01.id} --priv-launch-key infrastructure_ssh_key --region ${var.aws_region} --query 'PasswordData' --output text"
  }
}

# Quick Access Summary
output "quick_access" {
  description = "Quick reference for common tasks"
  value = <<-EOT
  
  QUICK ACCESS GUIDE:
  
  VPN Server IP: ${aws_eip.wireguard.public_ip}
  VPN Subnet: 10.10.0.0/24 (Your client IP: 10.10.0.2)
  
  SSH to VPN Server:
    ssh -i infrastructure_ssh_key ubuntu@${aws_eip.wireguard.public_ip}
  
  Get Windows Passwords (wait 5 min after boot):
    PowerShell: terraform output -json windows_password_commands | ConvertFrom-Json
    Then run the command for the server you need
  
  RDP via VPN (connect to VPN first):
    DC01:  10.0.2.10 (Domain Controller)
    SQL01: 10.0.2.11 (SQL Server)
    DEV01: 10.0.2.12 (Development)
    CAN01: 10.0.2.13 (Industrial Control)
    WEB01: 10.0.1.50 (Web Server)
  
  Username: Administrator
  
  EOT
}