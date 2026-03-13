# ============================================================================
# General
# ============================================================================

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "name_prefix" {
  type = string
}

variable "environment" {
  type    = string
  default = "prod"
}

# ============================================================================
# Existing Exadata Infrastructure
# ============================================================================

variable "existing_exadata_infra_id" {
  description = "ID of the existing Exadata infrastructure (e.g., exa_5acz0ealqm)"
  type        = string
}

# ============================================================================
# VPC / Networking
# ============================================================================

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

# ============================================================================
# ODB Network
# ============================================================================

variable "odb_availability_zone" {
  type    = string
  default = "us-west-2c"
}

variable "odb_client_subnet_cidr" {
  type = string
}

variable "odb_backup_subnet_cidr" {
  type = string
}

variable "odb_dns_prefix" {
  description = "Unique DNS prefix for ODB network"
  type        = string
}

# ============================================================================
# VM Cluster
# ============================================================================

variable "create_vm_cluster" {
  type    = bool
  default = true
}

variable "vm_cluster_cpu_core_count" {
  type    = number
  default = 16
}

variable "vm_cluster_memory_size_gbs" {
  type    = number
  default = 60
}

variable "vm_cluster_data_storage_size_tbs" {
  type    = number
  default = 2
}

variable "vm_cluster_db_node_storage_size_gbs" {
  type    = number
  default = 120
}

variable "vm_cluster_gi_version" {
  type    = string
  default = "19.0.0.0"
}

variable "vm_cluster_ssh_public_keys" {
  type      = list(string)
  default   = []
  sensitive = true
}

variable "vm_cluster_license_model" {
  type    = string
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "vm_cluster_hostname_prefix" {
  type    = string
  default = "vmhost"
}

# ============================================================================
# Autonomous VM Cluster
# ============================================================================

variable "create_autonomous_vm_cluster" {
  type    = bool
  default = false
}
