# Scenario 3: Networking + ODB Network + Peering — Asia Pacific (Tokyo)
# ODB-supported AZs: apne1-az1, apne1-az4

aws_region    = "ap-northeast-1"
name_prefix   = "odb-net-tokyo"
environment   = "prod"

vpc_cidr             = "10.20.0.0/16"
availability_zones   = ["ap-northeast-1a", "ap-northeast-1c"]
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]

odb_availability_zone  = "ap-northeast-1a"
odb_client_subnet_cidr = "172.2.0.0/24"
odb_backup_subnet_cidr = "172.3.0.0/24"
odb_dns_prefix         = "odbnettokyo"
