# Scenario 3: Networking + ODB Network + Peering — Europe (Ireland/Dublin)
# ODB-supported AZs: euw1-az3

aws_region    = "eu-west-1"
name_prefix   = "odb-net-dublin"
environment   = "prod"

vpc_cidr             = "10.20.0.0/16"
availability_zones   = ["eu-west-1a", "eu-west-1b"]
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]

odb_availability_zone  = "eu-west-1c"
odb_client_subnet_cidr = "172.2.0.0/24"
odb_backup_subnet_cidr = "172.3.0.0/24"
odb_dns_prefix         = "odbnetdublin"
