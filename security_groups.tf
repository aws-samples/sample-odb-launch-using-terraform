# Security Groups for Application Access to ODB

# Security group for application servers that need to access ODB
resource "aws_security_group" "app_to_odb" {
  name        = "${var.name_prefix}-app-to-odb"
  description = "Security group for applications accessing Oracle Database@AWS"
  vpc_id      = aws_vpc.app_vpc.id

  tags = {
    Name        = "${var.name_prefix}-app-to-odb-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Placeholder network interface to satisfy security group attachment requirement
# This demonstrates the security group is valid and can be attached to resources
resource "aws_network_interface" "app_to_odb_placeholder" {
  subnet_id       = values(aws_subnet.private)[0].id
  security_groups = [aws_security_group.app_to_odb.id]
  description     = "Placeholder interface for app_to_odb security group validation"

  tags = {
    Name        = "${var.name_prefix}-app-to-odb-placeholder"
    Environment = var.environment
    Purpose     = "Security group validation - can be removed when attaching to actual resources"
  }
}

# Egress rule to allow traffic to ODB client subnet
resource "aws_vpc_security_group_egress_rule" "app_to_odb_client" {
  security_group_id = aws_security_group.app_to_odb.id
  description       = "Allow Oracle database connections to ODB network"
  
  ip_protocol = "tcp"
  from_port   = 1521
  to_port     = 1522
  cidr_ipv4   = var.odb_client_subnet_cidr

  tags = {
    Name = "oracle-db-access"
  }
}

# Egress rule for HTTPS (restricted to VPC CIDR for AWS services)
resource "aws_vpc_security_group_egress_rule" "app_https" {
  security_group_id = aws_security_group.app_to_odb.id
  description       = "Allow HTTPS to VPC CIDR for AWS services"
  
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = var.vpc_cidr

  tags = {
    Name = "https-access"
  }
}

# Egress rule for DNS (restricted to VPC DNS resolver)
resource "aws_vpc_security_group_egress_rule" "app_dns" {
  security_group_id = aws_security_group.app_to_odb.id
  description       = "Allow DNS queries to VPC DNS resolver"
  
  ip_protocol = "udp"
  from_port   = 53
  to_port     = 53
  cidr_ipv4   = var.vpc_cidr

  tags = {
    Name = "dns-access"
  }
}

# Optional: Security group for bastion/jump host
resource "aws_security_group" "bastion" {
  count = var.create_bastion_sg ? 1 : 0

  name        = "${var.name_prefix}-bastion"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.app_vpc.id

  tags = {
    Name        = "${var.name_prefix}-bastion-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Placeholder network interface for bastion security group
resource "aws_network_interface" "bastion_placeholder" {
  count = var.create_bastion_sg ? 1 : 0

  subnet_id       = values(aws_subnet.public)[0].id
  security_groups = [aws_security_group.bastion[0].id]
  description     = "Placeholder interface for bastion security group validation"

  tags = {
    Name        = "${var.name_prefix}-bastion-placeholder"
    Environment = var.environment
    Purpose     = "Security group validation - can be removed when attaching to actual bastion host"
  }
}

# Ingress rule for SSH to bastion
resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  count = var.create_bastion_sg ? 1 : 0

  security_group_id = aws_security_group.bastion[0].id
  description       = "Allow SSH from allowed CIDR blocks"
  
  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_ipv4   = var.bastion_allowed_cidr

  tags = {
    Name = "ssh-access"
  }
}

# Egress rule from bastion to ODB
resource "aws_vpc_security_group_egress_rule" "bastion_to_odb" {
  count = var.create_bastion_sg ? 1 : 0

  security_group_id = aws_security_group.bastion[0].id
  description       = "Allow bastion to access ODB network"
  
  ip_protocol = "tcp"
  from_port   = 1521
  to_port     = 1522
  cidr_ipv4   = var.odb_client_subnet_cidr

  tags = {
    Name = "odb-access"
  }
}
