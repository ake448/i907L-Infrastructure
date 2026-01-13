# Network infrastructure - VPC, subnets, internet gateway, and routing
# AWS provider version 2.43.0

# Primary VPC for corporate infrastructure
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "corporate-vpc"
  }
}

# Internet Gateway for public subnet internet access
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "corporate-igw"
  }
}

# Public subnet - hosts WEB01 and WireGuard VPN server
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Private subnet - hosts DC01, SQL01, DEV01, CAN01
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private-subnet"
  }
}

# Public route table - allows internet access via IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Associate public route table with public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private route table - no direct internet access
# Routes VPN client traffic (10.10.0.0/24) through WireGuard server
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Route VPN traffic through WireGuard server
  route {
    cidr_block           = "10.10.0.0/24"
    network_interface_id = aws_network_interface.wireguard.id
  }

  tags = {
    Name = "private-rt"
  }
}

# Associate private route table with private subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Data source to retrieve available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}
