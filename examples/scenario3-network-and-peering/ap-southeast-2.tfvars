# Scenario 3: Networking + ODB Network + Peering — Asia Pacific (Sydney)
# ODB-supported AZs: apse2-az2

aws_region    = "ap-southeast-2"
name_prefix   = "odb-net-sydney"
environment   = "prod"

vpc_cidr             = "10.20.0.0/16"
availability_zones   = ["ap-southeast-2a", "ap-southeast-2b"]
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]

odb_availability_zone  = "ap-southeast-2a"
odb_client_subnet_cidr = "172.2.0.0/24"
odb_backup_subnet_cidr = "172.3.0.0/24"
odb_dns_prefix         = "odbnetsydney"
