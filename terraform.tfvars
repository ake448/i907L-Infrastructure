# Terraform Variables File - Corporate Infrastructure Deployment
# Copy this file to terraform.tfvars and update with your values

# AWS Region for deployment
aws_region = "us-east-1"

# Your public IPs for WireGuard VPN access
# Get your IP with: curl -4 ifconfig.co
admin_public_ips = ["23.127.9.242/32", "207.140.152.226/32"]

# (Optional) Override default AMI IDs for your region
# Uncomment and update if needed

# Ubuntu 20.04 LTS AMI (for WireGuard VPN server)
# Find latest with: aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" --region us-east-1
ubuntu_ami = "ami-0030e4319cbf4dbf2"

# Windows Server 2022 Core AMI (for DC01 - Domain Controller)
# Find latest with: aws ec2 describe-images --owners amazon --filters "Name=name,Values=Windows_Server-2022-English-Core*" --region us-east-1
win2022_core_ami = "ami-070f5c660bdb29846"

# Windows Server 2022 with Desktop Experience (Full GUI)
# For DC01, SQL01, DEV01, CAN01, WEB01
# Find latest with: aws ec2 describe-images --owners amazon --filters "Name=name,Values=Windows_Server-2022-English-Full*" --region us-east-1
win2022_full_ami = "ami-0fc8a85749a35ce56"

# Environment name for tagging
environment = "production"

# Common tags applied to all instances
instance_tags = {
  Environment = "production"
  ManagedBy   = "terraform"
  Project     = "corporate-infrastructure"
}
