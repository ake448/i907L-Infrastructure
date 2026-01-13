# Security Groups and Rules for VPC
# Using separate aws_security_group_rule resources to prevent inline rules from being dropped

# =============================================================================
# INTERNAL SECURITY GROUP - for Windows servers and internal communication
# =============================================================================
resource "aws_security_group" "internal" {
  name        = "internal-sg"
  description = "Allow all traffic between internal instances"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "internal-sg"
  }
}

# Allow all traffic from instances in this security group (self-reference)
resource "aws_security_group_rule" "internal_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.internal.id
  description       = "Allow traffic from instances in this security group"
}

# Allow all traffic from VPN security group (for WireGuard server communication)
resource "aws_security_group_rule" "internal_from_vpn_sg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.vpn.id
  security_group_id        = aws_security_group.internal.id
  description              = "Allow traffic from WireGuard VPN server"
}

# Allow all traffic from VPN client subnet (10.10.0.0/24)
# This handles traffic that may not be NATed
resource "aws_security_group_rule" "internal_from_vpn_cidr" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.10.0.0/24"]
  security_group_id = aws_security_group.internal.id
  description       = "Allow all traffic from VPN clients"
}

# Allow all outbound traffic
resource "aws_security_group_rule" "internal_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.internal.id
  description       = "Allow all outbound traffic"
}

# =============================================================================
# VPN SECURITY GROUP - for WireGuard server
# =============================================================================
resource "aws_security_group" "vpn" {
  name        = "vpn-sg"
  description = "Allow WireGuard VPN access and internal communication"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "vpn-sg"
  }
}

# Allow WireGuard UDP 51820 from admin IPs
resource "aws_security_group_rule" "vpn_wireguard" {
  count             = length(var.admin_public_ips)
  type              = "ingress"
  from_port         = 51820
  to_port           = 51820
  protocol          = "udp"
  cidr_blocks       = [var.admin_public_ips[count.index]]
  security_group_id = aws_security_group.vpn.id
  description       = "Allow WireGuard from admin IP"
}

# Allow SSH from admin IPs
resource "aws_security_group_rule" "vpn_ssh" {
  count             = length(var.admin_public_ips)
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_public_ips[count.index]]
  security_group_id = aws_security_group.vpn.id
  description       = "Allow SSH from admin IP"
}

# Allow all traffic from internal security group (for response traffic)
resource "aws_security_group_rule" "vpn_from_internal_sg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.internal.id
  security_group_id        = aws_security_group.vpn.id
  description              = "Allow traffic from internal instances"
}

# Allow all traffic from VPC CIDR (for routing responses)
resource "aws_security_group_rule" "vpn_from_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.vpn.id
  description       = "Allow traffic from VPC"
}

# Allow all outbound traffic
resource "aws_security_group_rule" "vpn_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpn.id
  description       = "Allow all outbound traffic"
}
