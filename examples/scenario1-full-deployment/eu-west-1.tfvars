# Scenario 1: Full Deployment — Europe (Ireland/Dublin)
# ODB-supported AZs: euw1-az3

aws_region    = "eu-west-1"
name_prefix   = "odb-dublin"
environment   = "prod"

# VPC
vpc_cidr             = "10.2.0.0/16"
availability_zones   = ["eu-west-1a", "eu-west-1b"]
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24"]

# ODB Network — pick an AZ that maps to euw1-az3
odb_availability_zone  = "eu-west-1c"
odb_client_subnet_cidr = "192.168.1.0/24"
odb_backup_subnet_cidr = "192.168.2.0/24"

# Exadata Infrastructure
exadata_availability_zone = "eu-west-1c"
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
