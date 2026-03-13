# Scenario 3: Networking + ODB Network + Peering — US East (N. Virginia)
# ODB-supported AZs: use1-az4, use1-az6

aws_region    = "us-east-1"
name_prefix   = "odb-net-virginia"
environment   = "prod"

vpc_cidr             = "10.20.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]

odb_availability_zone  = "us-east-1f"
odb_client_subnet_cidr = "172.2.0.0/24"
odb_backup_subnet_cidr = "172.3.0.0/24"
odb_dns_prefix         = "odbnetvirginia"
