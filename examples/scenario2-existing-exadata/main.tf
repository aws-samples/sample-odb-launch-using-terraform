# ============================================================================
# Scenario 2: Use Existing Exadata Infrastructure
#
# Creates from scratch:
#   - VPC, Subnets, NAT Gateways (networking module)
#   - ODB Network
#   - ODB Peering Connection
#   - VM Cluster
#   - Autonomous VM Cluster (optional)
#
# Uses existing:
#   - Exadata Infrastructure (via data source)
#   - DB Servers (auto-discovered)
#
# Usage:
#   terraform init
#   SSH_KEY=$(cat ~/.ssh/id_ecdsa.pub)
#   terraform apply -var-file="terraform.tfvars" \
#     -var="vm_cluster_ssh_public_keys=[\"${SSH_KEY}\"]"
# ============================================================================

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Project     = "Oracle Database@AWS"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ---- Networking (fresh VPC) ----
module "networking" {
  source = "../../modules/networking"

  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

# ---- ODB (existing Exadata, new everything else) ----
module "odb" {
  source = "../../modules/odb"

  name_prefix = var.name_prefix
  tags        = local.common_tags

  # Existing Exadata infra — do NOT create
  create_exadata_infra      = false
  existing_exadata_infra_id = var.existing_exadata_infra_id

  # Create ODB Network from scratch
  create_odb_network    = true
  odb_availability_zone = var.odb_availability_zone
  client_subnet_cidr    = var.odb_client_subnet_cidr
  backup_subnet_cidr    = var.odb_backup_subnet_cidr
  dns_prefix            = var.odb_dns_prefix

  # Create Peering
  create_peering_connection = true
  vpc_id                    = module.networking.vpc_id

  # VM Cluster
  create_vm_cluster           = var.create_vm_cluster
  vm_cpu_core_count           = var.vm_cluster_cpu_core_count
  vm_memory_size_gbs          = var.vm_cluster_memory_size_gbs
  vm_data_storage_size_tbs    = var.vm_cluster_data_storage_size_tbs
  vm_db_node_storage_size_gbs = var.vm_cluster_db_node_storage_size_gbs
  vm_gi_version               = var.vm_cluster_gi_version
  vm_ssh_public_keys          = var.vm_cluster_ssh_public_keys
  vm_license_model            = var.vm_cluster_license_model
  vm_hostname_prefix          = var.vm_cluster_hostname_prefix
  # db_servers auto-discovered from Exadata infra

  # Autonomous VM Cluster
  create_autonomous_vm_cluster = var.create_autonomous_vm_cluster

  depends_on = [module.networking]
}
