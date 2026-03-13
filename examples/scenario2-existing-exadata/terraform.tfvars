# ============================================================================
# Scenario 2: Existing Exadata — us-west-2
# ============================================================================

aws_region    = "us-west-2"
name_prefix   = "prod-odb"
environment   = "prod"

# Existing Exadata infrastructure
existing_exadata_infra_id = "exa_5acz0ealqm"

# Fresh VPC (10.19.0.0/16 — verified unique in account)
vpc_cidr             = "10.19.0.0/16"
availability_zones   = ["us-west-2a", "us-west-2b"]
public_subnet_cidrs  = ["10.19.1.0/24", "10.19.2.0/24"]
private_subnet_cidrs = ["10.19.10.0/24", "10.19.11.0/24"]

# ODB Network (new — 172.2.0.0/24, 172.3.0.0/24)
odb_availability_zone  = "us-west-2c"
odb_client_subnet_cidr = "172.2.0.0/24"
odb_backup_subnet_cidr = "172.3.0.0/24"
odb_dns_prefix         = "prododb"

# VM Cluster
create_vm_cluster         = true
vm_cluster_cpu_core_count = 16
vm_cluster_gi_version     = "19.0.0.0"
vm_cluster_license_model  = "BRING_YOUR_OWN_LICENSE"
# db_servers auto-discovered from Exadata infra

# Autonomous VM Cluster
create_autonomous_vm_cluster = false

# SSH key — pass via CLI:
#   -var='vm_cluster_ssh_public_keys=["ssh-ecdsa AAAA..."]'
