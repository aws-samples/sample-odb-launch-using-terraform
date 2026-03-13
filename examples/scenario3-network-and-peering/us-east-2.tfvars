# Scenario 3: Networking + ODB Network + Peering — US East (Ohio)
# ODB-supported AZs: use2-az1, use2-az2

aws_region    = "us-east-2"
name_prefix   = "odb-net-ohio"
environment   = "prod"

vpc_cidr             = "10.20.0.0/16"
availability_zones   = ["us-east-2a", "us-east-2b"]
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]

odb_availability_zone  = "us-east-2a"
odb_client_subnet_cidr = "172.2.0.0/24"
odb_backup_subnet_cidr = "172.3.0.0/24"
odb_dns_prefix         = "odbnetohio"
