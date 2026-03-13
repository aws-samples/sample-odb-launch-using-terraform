# Scenario 2: Existing Exadata — Asia Pacific (Sydney)
# ODB-supported AZs: apse2-az2

aws_region    = "ap-southeast-2"
name_prefix   = "odb-sydney"
environment   = "prod"

# Existing Exadata infrastructure — replace with your ID
existing_exadata_infra_id = "exa_REPLACE_ME"

# VPC
vpc_cidr             = "10.19.0.0/16"
availability_zones   = ["ap-southeast-2a", "ap-southeast-2b"]
public_subnet_cidrs  = ["10.19.1.0/24", "10.19.2.0/24"]
private_subnet_cidrs = ["10.19.10.0/24", "10.19.11.0/24"]

# ODB Network — pick an AZ that maps to apse2-az2
odb_availability_zone  = "ap-southeast-2a"
odb_client_subnet_cidr = "172.2.0.0/24"
odb_backup_subnet_cidr = "172.3.0.0/24"
odb_dns_prefix         = "odbsydney"

# VM Cluster
create_vm_cluster         = true
vm_cluster_cpu_core_count = 16
vm_cluster_gi_version     = "19.0.0.0"
vm_cluster_license_model  = "BRING_YOUR_OWN_LICENSE"

# Autonomous VM Cluster
create_autonomous_vm_cluster = false

# SSH key — pass via CLI:
#   -var='vm_cluster_ssh_public_keys=["ssh-ecdsa AAAA..."]'
