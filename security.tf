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
 
  # Allow WireGuard UDP 51820 from admin IP only
  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["${var.admin_public_ip}/32"]
  }

  # Allow SSH from admin IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["23.127.9.242/32"]
    description = "Allow SSH from admin IP"
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