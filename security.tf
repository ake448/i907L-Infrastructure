# Internal Security Group - allows all traffic between instances
resource "aws_security_group" "internal" {
  name        = "internal-sg"
  description = "Allow all traffic between internal instances"
  vpc_id      = aws_vpc.main.id
 
  # Allow all traffic from instances in this security group (self-reference)
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self 			= true
  }

  # Allow all traffic from VPN security group (for WireGuard server communication)
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.vpn.id]
    description     = "Allow traffic from WireGuard VPN server"
  }

  # Allow RDP from VPN subnet
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/24"]
    description = "Allow RDP from VPN clients"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = {
    Name = "internal-sg"
  }
}
 
# VPN Security Group - allows WireGuard access
resource "aws_security_group" "vpn" {
  name        = "vpn-sg"
  description = "Allow WireGuard VPN access from admin IP"
  vpc_id      = aws_vpc.main.id
 
  # Allow WireGuard UDP 51820 from admin IPs
  dynamic "ingress" {
    for_each = var.admin_public_ips
    content {
      from_port   = 51820
      to_port     = 51820
      protocol    = "udp"
      cidr_blocks = [ingress.value]
      description = "Allow WireGuard from admin IP"
    }
  }

  # Allow SSH from admin IPs
  dynamic "ingress" {
    for_each = var.admin_public_ips
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "Allow SSH from admin IP"
    }
  }
 
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = {
    Name = "vpn-sg"
  }
}