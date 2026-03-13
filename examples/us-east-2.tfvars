# Example configuration for US East (Ohio) - us-east-2
# ODB-supported AZs: use2-az1 (us-east-2a), use2-az2 (us-east-2b)

aws_region               = "us-east-2"
name_prefix              = "odb-useast2"
environment              = "prod"

# VPC Configuration - use 2 AZs for high availability
vpc_cidr                 = "10.1.0.0/16"
availability_zones       = ["us-east-2a", "us-east-2b"]
public_subnet_cidrs      = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs     = ["10.1.10.0/24", "10.1.11.0/24"]

# ODB Configuration - must use ODB-supported AZ
# Option 1: use2-az1 (us-east-2a)
odb_availability_zone    = "us-east-2a"
exadata_availability_zone = "us-east-2a"

# Option 2: use2-az2 (us-east-2b) - uncomment to use
# odb_availability_zone    = "us-east-2b"
# exadata_availability_zone = "us-east-2b"

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
