# Network interfaces for Windows instances (private IPs)
# AWS provider version 2.43.0

# DC01 network interface - 10.0.2.10
resource "aws_network_interface" "dc01" {
  subnet_id           = aws_subnet.private.id
  private_ips         = ["10.0.2.10"]
  security_groups     = [aws_security_group.internal.id]
  
  tags = {
    Name = "dc01-eni"
  }
}

# SQL01 network interface - 10.0.2.11
resource "aws_network_interface" "sql01" {
  subnet_id           = aws_subnet.private.id
  private_ips         = ["10.0.2.11"]
  security_groups     = [aws_security_group.internal.id]
  
  tags = {
    Name = "sql01-eni"
  }
}

# DEV01 network interface - 10.0.2.12
resource "aws_network_interface" "dev01" {
  subnet_id           = aws_subnet.private.id
  private_ips         = ["10.0.2.12"]
  security_groups     = [aws_security_group.internal.id]
  
  tags = {
    Name = "dev01-eni"
  }
}

# CAN01 network interface - 10.0.2.13
resource "aws_network_interface" "can01" {
  subnet_id           = aws_subnet.private.id
  private_ips         = ["10.0.2.13"]
  security_groups     = [aws_security_group.internal.id]
  
  tags = {
    Name = "can01-eni"
  }
}

# WEB01 network interface - 10.0.1.50 (public subnet)
resource "aws_network_interface" "web01" {
  subnet_id           = aws_subnet.public.id
  private_ips         = ["10.0.1.50"]
  security_groups     = [aws_security_group.internal.id]
  
  tags = {
    Name = "web01-eni"
  }
}

# DC01 - Windows Server 2022 Core - Domain Controller
# PRIVATE SUBNET - t3.medium - On-Demand - Static IP 10.0.2.10
resource "aws_instance" "dc01" {
  ami           = var.win2022_core_ami
  instance_type = "t3.medium"

  key_name = aws_key_pair.infrastructure_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.dc01.id
    device_index         = 0
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  user_data = file("${path.module}/windows-init.ps1")

  tags = merge(
    var.instance_tags,
    {
      Name = "DC01"
      Role = "domain-controller"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# SQL01 - Windows Server 2022 Full (GUI) - SQL Server
# PRIVATE SUBNET - t3.medium - On-Demand - Static IP 10.0.2.11
resource "aws_instance" "sql01" {
  ami           = var.win2022_full_ami
  instance_type = "t3.medium"

  key_name = aws_key_pair.infrastructure_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.sql01.id
    device_index         = 0
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 100
    delete_on_termination = true
  }

  user_data = file("${path.module}/windows-init.ps1")

  tags = merge(
    var.instance_tags,
    {
      Name = "SQL01"
      Role = "database-server"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# DEV01 - Windows Server 2022 Full (GUI) - Development Server
# PRIVATE SUBNET - t3.medium - On-Demand - Static IP 10.0.2.12
resource "aws_instance" "dev01" {
  ami           = var.win2022_full_ami
  instance_type = "t3.medium"

  key_name = aws_key_pair.infrastructure_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.dev01.id
    device_index         = 0
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  user_data = file("${path.module}/windows-init.ps1")

  tags = merge(
    var.instance_tags,
    {
      Name = "DEV01"
      Role = "development-server"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# CAN01 - Windows Server 2022 Full (GUI) - CANOpen/Industrial Control
# PRIVATE SUBNET - t3.medium - On-Demand - Static IP 10.0.2.13
resource "aws_instance" "can01" {
  ami           = var.win2022_full_ami
  instance_type = "t3.medium"

  key_name = aws_key_pair.infrastructure_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.can01.id
    device_index         = 0
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  user_data = file("${path.module}/windows-init.ps1")

  tags = merge(
    var.instance_tags,
    {
      Name = "CAN01"
      Role = "industrial-control"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# WEB01 - Windows Server 2022 Full (GUI) - Web Server
# PUBLIC SUBNET - t3.medium - On-Demand - Static IP 10.0.1.50
resource "aws_instance" "web01" {
  ami           = var.win2022_full_ami
  instance_type = "t3.medium"

  key_name = aws_key_pair.infrastructure_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.web01.id
    device_index         = 0
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  user_data = file("${path.module}/windows-init.ps1")

  tags = merge(
    var.instance_tags,
    {
      Name = "WEB01"
      Role = "web-server"
    }
  )

  depends_on = [aws_internet_gateway.main]
}
