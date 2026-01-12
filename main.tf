# Main Terraform configuration file
# AWS provider version 2.43.0 - Corporate infrastructure deployment

terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "2.43.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Local variable for VPN server configuration
locals {
  wireguard_port = 51820
  vpn_subnet_id  = aws_subnet.public.id
  vpn_vpc_id     = aws_vpc.main.id
}
