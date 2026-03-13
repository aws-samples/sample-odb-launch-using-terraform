# Example configuration for US West (Oregon) - us-west-2
# ODB-supported AZs: usw2-az3 (us-west-2c), usw2-az4 (us-west-2d)

aws_region               = "us-west-2"
name_prefix              = "odb-uswest2"
environment              = "prod"

# VPC Configuration - use 2 AZs for high availability
vpc_cidr                 = "10.2.0.0/16"
availability_zones       = ["us-west-2a", "us-west-2b"]
public_subnet_cidrs      = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs     = ["10.2.10.0/24", "10.2.11.0/24"]

# ODB Configuration - must use ODB-supported AZ
# Option 1: usw2-az3 (us-west-2c)
odb_availability_zone    = "us-west-2c"
exadata_availability_zone = "us-west-2c"

# Option 2: usw2-az4 (us-west-2d) - uncomment to use
# odb_availability_zone    = "us-west-2d"
# exadata_availability_zone = "us-west-2d"

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
