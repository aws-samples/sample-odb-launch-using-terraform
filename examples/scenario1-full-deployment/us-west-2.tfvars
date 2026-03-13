# Scenario 1: Full Deployment — US West (Oregon)
# ODB-supported AZs: usw2-az3, usw2-az4

aws_region    = "us-west-2"
name_prefix   = "odb-oregon"
environment   = "prod"

# VPC
vpc_cidr             = "10.2.0.0/16"
availability_zones   = ["us-west-2a", "us-west-2b"]
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24"]

# ODB Network — pick an AZ that maps to usw2-az3 or usw2-az4
odb_availability_zone  = "us-west-2c"
odb_client_subnet_cidr = "192.168.1.0/24"
odb_backup_subnet_cidr = "192.168.2.0/24"

# Exadata Infrastructure
exadata_availability_zone = "us-west-2c"
exadata_shape             = "Exadata.X11M"
exadata_compute_count     = 2
exadata_storage_count     = 3

# VM Cluster
create_vm_cluster         = true
create_autonomous_vm_cluster = false
vm_cluster_cpu_core_count = 16
vm_cluster_gi_version     = "19.0.0.0"
vm_cluster_license_model  = "BRING_YOUR_OWN_LICENSE"

# SSH key — pass via CLI:
#   -var='vm_cluster_ssh_public_keys=["ssh-ecdsa AAAA..."]'
