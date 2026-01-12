# Deployment Validation Checklist
# Use this to verify the infrastructure meets all requirements

## Architecture Requirements ✓

### 1. Networking
- [ ] VPC created with CIDR 10.0.0.0/16
- [ ] Public subnet created with CIDR 10.0.1.0/24
- [ ] Private subnet created with CIDR 10.0.2.0/24
- [ ] Internet Gateway created and attached to VPC
- [ ] Public route table with 0.0.0.0/0 → IGW route
- [ ] Public subnet associated with public route table
- [ ] Private route table created without internet route
- [ ] Private subnet associated with private route table

### 2. Windows Servers - MANDATORY (All 5 required)

#### DC01 - Domain Controller (Private Subnet)
- [ ] **Instance Type**: t3.large ✓
- [ ] **OS**: Windows Server 2022 Core (NOT Full) ✓
- [ ] **Static IP**: 10.0.2.10 ✓
- [ ] **Pricing Model**: On-Demand only (NO Spot) ✓
- [ ] **Root Volume Size**: 50 GB ✓
- [ ] **Subnet**: Private (10.0.2.0/24) ✓
- [ ] **Security Group**: internal-sg ✓
- [ ] **Instance Name Tag**: DC01 ✓

#### SQL01 - SQL Server (Private Subnet)
- [ ] **Instance Type**: t3.large ✓
- [ ] **OS**: Windows Server 2022 Full (with GUI) ✓
- [ ] **Static IP**: 10.0.2.11 ✓
- [ ] **Pricing Model**: On-Demand only (NO Spot) ✓
- [ ] **Root Volume Size**: 100 GB ✓
- [ ] **Subnet**: Private (10.0.2.0/24) ✓
- [ ] **Security Group**: internal-sg ✓
- [ ] **Instance Name Tag**: SQL01 ✓

#### DEV01 - Development Server (Private Subnet)
- [ ] **Instance Type**: t3.medium ✓
- [ ] **OS**: Windows Server 2022 Full (with GUI) ✓
- [ ] **Static IP**: 10.0.2.12 ✓
- [ ] **Pricing Model**: On-Demand ✓
- [ ] **Root Volume Size**: 50 GB ✓
- [ ] **Subnet**: Private (10.0.2.0/24) ✓
- [ ] **Security Group**: internal-sg ✓
- [ ] **Instance Name Tag**: DEV01 ✓

#### CAN01 - Industrial Control Server (Private Subnet)
- [ ] **Instance Type**: t3.medium ✓
- [ ] **OS**: Windows Server 2022 Full (with GUI) ✓
- [ ] **Static IP**: 10.0.2.13 ✓
- [ ] **Pricing Model**: On-Demand ✓
- [ ] **Root Volume Size**: 50 GB ✓
- [ ] **Subnet**: Private (10.0.2.0/24) ✓
- [ ] **Security Group**: internal-sg ✓
- [ ] **Instance Name Tag**: CAN01 ✓

#### WEB01 - Web Server (Public Subnet)
- [ ] **Instance Type**: t3.medium ✓
- [ ] **OS**: Windows Server 2022 Full (with GUI) ✓
- [ ] **Static IP**: 10.0.1.50 ✓
- [ ] **Pricing Model**: On-Demand ✓
- [ ] **Root Volume Size**: 50 GB ✓
- [ ] **Subnet**: Public (10.0.1.0/24) ✓
- [ ] **Security Group**: internal-sg ✓
- [ ] **Instance Name Tag**: WEB01 ✓
- [ ] **Only server in public subnet**: Yes ✓

### 3. Security Groups

#### Internal Security Group (internal-sg)
- [ ] Allows ALL TCP traffic between instances in group (self-reference)
- [ ] Allows ALL UDP traffic between instances in group (self-reference)
- [ ] Allows ICMP between instances in group (self-reference)
- [ ] Allows all outbound traffic (0.0.0.0/0)
- [ ] Does NOT allow RDP from internet

#### VPN Security Group (vpn-sg)
- [ ] Allows UDP port 51820 (WireGuard) from admin_public_ip only
- [ ] Allows TCP port 22 (SSH) from admin_public_ip for management
- [ ] Allows all outbound traffic (0.0.0.0/0)

### 4. WireGuard VPN
- [ ] VPN server created in public subnet with Ubuntu 20.04 LTS ✓
- [ ] Instance type: t3.medium ✓
- [ ] Elastic IP assigned for stable endpoint ✓
- [ ] Security group allows UDP 51820 from admin IP ✓
- [ ] Server private key generated via tls_private_key ✓
- [ ] Client private key generated via tls_private_key ✓
- [ ] WireGuard config template created (wireguard-client.conf) ✓
- [ ] VPN server initialization script provided (wireguard-init.sh) ✓
- [ ] IP forwarding configured in user_data ✓
- [ ] NAT rules for internal network configured ✓

## File Structure Requirements ✓

Required files present:
- [ ] main.tf ✓
- [ ] network.tf ✓
- [ ] windows.tf ✓
- [ ] ec2.tf ✓
- [ ] vpn.tf ✓
- [ ] variables.tf ✓
- [ ] outputs.tf ✓
- [ ] versions.tf ✓
- [ ] wireguard-init.sh ✓
- [ ] wireguard-client.conf ✓

## Variables Requirements ✓

All required variables defined:
- [ ] ubuntu_ami ✓
- [ ] win2022_core_ami ✓
- [ ] win2022_full_ami ✓
- [ ] admin_public_ip ✓
- [ ] aws_region ✓

## Outputs Requirements ✓

All required outputs defined:
- [ ] wireguard_client_config (sensitive) ✓
- [ ] wireguard_server_public_ip ✓
- [ ] dc01_private_ip ✓
- [ ] sql01_private_ip ✓
- [ ] dev01_private_ip ✓
- [ ] can01_private_ip ✓
- [ ] web01_private_ip ✓
- [ ] windows_servers summary ✓
- [ ] deployment_summary ✓

## AWS Provider Version ✓

- [ ] Provider version: 2.43.0 (locked in versions.tf) ✓
- [ ] Provider source: hashicorp/aws ✓
- [ ] Terraform version requirement: >= 0.12 ✓

## Code Quality

- [ ] All resources have descriptive comments
- [ ] All resources have Name tags
- [ ] No hardcoded credentials in code
- [ ] No unsecured outputs (sensitive marked correctly)
- [ ] All variables have descriptions
- [ ] All outputs have descriptions

## Pre-Deployment Checklist

Before running `terraform apply`:

- [ ] AWS credentials configured (`aws configure`)
- [ ] Correct AWS region set in variables.tf
- [ ] Admin public IP set correctly in terraform.tfvars
- [ ] AMI IDs valid for selected region
- [ ] AWS account has sufficient EC2 quota
- [ ] AWS account has required IAM permissions
- [ ] SSH key pair configured for EC2 access (optional)
- [ ] Budget alerts set in AWS Billing

## Post-Deployment Verification

After `terraform apply` completes:

```bash
# Get all outputs
terraform output

# Verify 5 Windows servers exist
aws ec2 describe-instances --filters "Name=tag:Name,Values=DC01,SQL01,DEV01,CAN01,WEB01" --query 'Reservations[].Instances[].{Name:Tags[?Key==`Name`].Value|[0],IP:PrivateIpAddress,Type:InstanceType}' --output table

# Verify WireGuard server exists
aws ec2 describe-instances --filters "Name=tag:Name,Values=wireguard-vpn-server" --query 'Reservations[].Instances[].{Name:Tags[?Key==`Name`].Value|[0],PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress}' --output table

# Check VPC created
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=corporate-vpc" --output table

# Check subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)" --output table
```

## Critical Checks

### ✓ Server Deployment
- [ ] All 5 Windows servers created (DC01, SQL01, DEV01, CAN01, WEB01)
- [ ] DC01 uses Server Core (no GUI)
- [ ] SQL01 uses Full installation (GUI)
- [ ] DEV01 uses Full installation (GUI)
- [ ] CAN01 uses Full installation (GUI)
- [ ] WEB01 uses Full installation (GUI)
- [ ] All servers have static IPs assigned
- [ ] All servers in correct subnets

### ✓ Pricing Model
- [ ] DC01 is On-Demand only (verified in instance_market_options)
- [ ] SQL01 is On-Demand only (verified in instance_market_options)
- [ ] DEV01 is On-Demand (no Spot configuration)
- [ ] CAN01 is On-Demand (no Spot configuration)
- [ ] WEB01 is On-Demand (no Spot configuration)

### ✓ Networking
- [ ] VPC CIDR: 10.0.0.0/16
- [ ] Public subnet CIDR: 10.0.1.0/24
- [ ] Private subnet CIDR: 10.0.2.0/24
- [ ] IGW attached to VPC
- [ ] Public route table has internet route
- [ ] Private route table has NO internet route
- [ ] WEB01 is ONLY server in public subnet

### ✓ Security
- [ ] Internal SG allows intra-group traffic
- [ ] Internal SG denies RDP from internet
- [ ] VPN SG allows WireGuard only from admin IP
- [ ] VPN SG allows SSH from admin IP

## Documentation ✓

- [ ] README.md with complete architecture documentation
- [ ] QUICKSTART.md with deployment instructions
- [ ] terraform.tfvars.example with configuration template
- [ ] This validation checklist

## Sign-Off

**Terraform Configuration Version**: 2.43.0
**AWS Provider Version**: 2.43.0 (locked)
**Configuration Date**: 2026-01-10
**All Requirements Met**: YES ✓

---

Use this checklist to verify the deployment is complete and meets all specifications.
