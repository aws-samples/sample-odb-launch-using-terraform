# ============================================================================
# Scenario 1: Full End-to-End Deployment
#
# Creates everything from scratch:
#   - VPC, Subnets, NAT Gateways (networking module)
#   - Exadata Infrastructure (NEW)
#   - ODB Network
#   - ODB Peering Connection
#   - VM Cluster (or Autonomous VM Cluster)
#
# Usage:
#   terraform init
#   terraform plan -var-file="terraform.tfvars"
#   terraform apply -var-file="terraform.tfvars"
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

# ---- Networking ----
module "networking" {
  source = "../../modules/networking"

  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

# ---- ODB (full deployment) ----
module "odb" {
  source = "../../modules/odb"

  name_prefix = var.name_prefix
  tags        = local.common_tags

  # Create everything
  create_exadata_infra      = true
  create_odb_network        = true
  create_peering_connection = true
  create_vm_cluster         = var.create_vm_cluster
  create_autonomous_vm_cluster = var.create_autonomous_vm_cluster

  # Networking
  vpc_id                  = module.networking.vpc_id

  # ODB Network
  odb_availability_zone = var.odb_availability_zone
  client_subnet_cidr    = var.odb_client_subnet_cidr
  backup_subnet_cidr    = var.odb_backup_subnet_cidr

  # Exadata Infrastructure
  exadata_availability_zone = var.exadata_availability_zone
  exadata_shape             = var.exadata_shape
  exadata_compute_count     = var.exadata_compute_count
  exadata_storage_count     = var.exadata_storage_count

  # VM Cluster
  vm_cpu_core_count           = var.vm_cluster_cpu_core_count
  vm_memory_size_gbs          = var.vm_cluster_memory_size_gbs
  vm_data_storage_size_tbs    = var.vm_cluster_data_storage_size_tbs
  vm_db_node_storage_size_gbs = var.vm_cluster_db_node_storage_size_gbs
  vm_gi_version               = var.vm_cluster_gi_version
  vm_ssh_public_keys          = var.vm_cluster_ssh_public_keys
  vm_license_model            = var.vm_cluster_license_model
  vm_hostname_prefix          = var.vm_cluster_hostname_prefix
  vm_db_servers               = var.vm_cluster_db_servers

  depends_on = [module.networking]
}
