# Scenario 3: Networking + ODB Network + Peering — US West (Oregon)
# ODB-supported AZs: usw2-az3, usw2-az4

aws_region    = "us-west-2"
name_prefix   = "odb-net-oregon"
environment   = "prod"

vpc_cidr             = "10.20.0.0/16"
availability_zones   = ["us-west-2a", "us-west-2b"]
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]

odb_availability_zone  = "us-west-2c"
odb_client_subnet_cidr = "172.2.0.0/24"
odb_backup_subnet_cidr = "172.3.0.0/24"
odb_dns_prefix         = "odbnetoregon"
