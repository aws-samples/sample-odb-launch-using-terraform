# Scenario 2: Existing Exadata — Canada (Central)
# ODB-supported AZs: cac1-az1, cac1-az4

aws_region    = "ca-central-1"
name_prefix   = "odb-canada"
environment   = "prod"

# Existing Exadata infrastructure — replace with your ID
existing_exadata_infra_id = "exa_REPLACE_ME"

# VPC
vpc_cidr             = "10.19.0.0/16"
availability_zones   = ["ca-central-1a", "ca-central-1b"]
public_subnet_cidrs  = ["10.19.1.0/24", "10.19.2.0/24"]
private_subnet_cidrs = ["10.19.10.0/24", "10.19.11.0/24"]

# ODB Network — pick an AZ that maps to cac1-az1 or cac1-az4
odb_availability_zone  = "ca-central-1a"
odb_client_subnet_cidr = "172.2.0.0/24"
odb_backup_subnet_cidr = "172.3.0.0/24"
odb_dns_prefix         = "odbcanada"

# VM Cluster
create_vm_cluster         = true
vm_cluster_cpu_core_count = 16
vm_cluster_gi_version     = "19.0.0.0"
vm_cluster_license_model  = "BRING_YOUR_OWN_LICENSE"

# Autonomous VM Cluster
create_autonomous_vm_cluster = false

# SSH key — pass via CLI:
#   -var='vm_cluster_ssh_public_keys=["ssh-ecdsa AAAA..."]'
