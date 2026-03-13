# Example configuration for US East (N. Virginia) - us-east-1
# ODB-supported AZs: use1-az4 (us-east-1b), use1-az6 (us-east-1c)

aws_region               = "us-east-1"
name_prefix              = "odb-useast1"
environment              = "prod"

# VPC Configuration - use 2 AZs for high availability
vpc_cidr                 = "10.0.0.0/16"
availability_zones       = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs     = ["10.0.10.0/24", "10.0.11.0/24"]

# ODB Configuration - must use ODB-supported AZ
# Option 1: use1-az6 (us-east-1c)
odb_availability_zone    = "us-east-1c"
exadata_availability_zone = "us-east-1c"

# Option 2: use1-az4 (us-east-1b) - uncomment to use
# odb_availability_zone    = "us-east-1b"
# exadata_availability_zone = "us-east-1b"

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
