# Example configuration for Europe (Frankfurt) - eu-central-1
# ODB-supported AZs: euc1-az2 (eu-central-1a), euc1-az1 (eu-central-1c)

aws_region               = "eu-central-1"
name_prefix              = "odb-frankfurt"
environment              = "prod"

# VPC Configuration - use 2 AZs for high availability
vpc_cidr                 = "10.4.0.0/16"
availability_zones       = ["eu-central-1a", "eu-central-1b"]
public_subnet_cidrs      = ["10.4.1.0/24", "10.4.2.0/24"]
private_subnet_cidrs     = ["10.4.10.0/24", "10.4.11.0/24"]

# ODB Configuration - must use ODB-supported AZ
# Option 1: euc1-az2 (eu-central-1a)
odb_availability_zone    = "eu-central-1a"
exadata_availability_zone = "eu-central-1a"

# Option 2: euc1-az1 (eu-central-1c) - uncomment to use
# odb_availability_zone    = "eu-central-1c"
# exadata_availability_zone = "eu-central-1c"

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
