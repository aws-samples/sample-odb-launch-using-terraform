# Example configuration for Asia Pacific (Tokyo) - ap-northeast-1
# ODB-supported AZs: apne1-az4 (ap-northeast-1a), apne1-az1 (ap-northeast-1c)

aws_region               = "ap-northeast-1"
name_prefix              = "odb-tokyo"
environment              = "prod"

# VPC Configuration - use 2 AZs for high availability
vpc_cidr                 = "10.3.0.0/16"
availability_zones       = ["ap-northeast-1a", "ap-northeast-1c"]
public_subnet_cidrs      = ["10.3.1.0/24", "10.3.2.0/24"]
private_subnet_cidrs     = ["10.3.10.0/24", "10.3.11.0/24"]

# ODB Configuration - must use ODB-supported AZ
# Option 1: apne1-az4 (ap-northeast-1a)
odb_availability_zone    = "ap-northeast-1a"
exadata_availability_zone = "ap-northeast-1a"

# Option 2: apne1-az1 (ap-northeast-1c) - uncomment to use
# odb_availability_zone    = "ap-northeast-1c"
# exadata_availability_zone = "ap-northeast-1c"

odb_client_subnet_cidr   = "192.168.1.0/27"
odb_backup_subnet_cidr   = "192.168.2.0/28"
odb_network_dns_prefix   = "odbnet"

# Exadata Infrastructure
exadata_shape            = "Exadata.X11M"
exadata_compute_count    = 2
exadata_storage_count    = 3

# VM Cluster Configuration
create_vm_cluster        = true
create_autonomous_vm_cluster = false
vm_cluster_cpu_core_count = 16
vm_cluster_gi_version    = "19.0.0.0"
vm_cluster_license_model = "BRING_YOUR_OWN_LICENSE"
