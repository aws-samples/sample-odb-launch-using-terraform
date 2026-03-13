# ============================================================================
# Scenario 3: Networking + ODB Network + Peering
#
# Creates:
#   - VPC, Subnets, NAT Gateways, Route Tables, IGW (networking module)
#   - ODB Network
#   - ODB Peering Connection
#
# No Exadata infrastructure or VM clusters. Use this to pre-provision
# networking and ODB connectivity before deploying compute via scenario1
# or scenario2.
#
# Usage:
#   terraform init
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

# ---- ODB Network + Peering (no Exadata, no clusters) ----
module "odb" {
  source = "../../modules/odb"

  name_prefix = var.name_prefix
  tags        = local.common_tags

  # No Exadata infra
  create_exadata_infra = false

  # Create ODB Network
  create_odb_network    = true
  odb_availability_zone = var.odb_availability_zone
  client_subnet_cidr    = var.odb_client_subnet_cidr
  backup_subnet_cidr    = var.odb_backup_subnet_cidr
  dns_prefix            = var.odb_dns_prefix

  # Create Peering
  create_peering_connection = true
  vpc_id                    = module.networking.vpc_id

  # No clusters
  create_vm_cluster            = false
  create_autonomous_vm_cluster = false

  depends_on = [module.networking]
}
