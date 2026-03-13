variable "aws_region" {
  description = "AWS region for resources (must be ODB-supported: us-east-1, us-east-2, us-west-2, ap-northeast-1, eu-central-1)"
  type        = string
  default     = "us-east-1"

  validation {
    condition = contains([
      "us-east-1",
      "us-east-2", 
      "us-west-2",
      "ap-northeast-1",
      "eu-central-1"
    ], var.aws_region)
    error_message = "Region must be one of: us-east-1, us-east-2, us-west-2, ap-northeast-1, eu-central-1"
  }
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "odb"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

# ============================================================================
# VPC Configuration
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones for VPC subnets (use 2 AZs for high availability)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# ============================================================================
# ODB Network Configuration
# ============================================================================

variable "odb_availability_zone" {
  description = <<-EOT
    Availability zone for ODB network. Must use ODB-supported AZ for the selected region:
    - us-east-1: us-east-1b (use1-az4) or us-east-1c (use1-az6)
    - us-east-2: us-east-2a (use2-az1) or us-east-2b (use2-az2)
    - us-west-2: us-west-2c (usw2-az3) or us-west-2d (usw2-az4)
    - ap-northeast-1: ap-northeast-1a (apne1-az4) or ap-northeast-1c (apne1-az1)
    - eu-central-1: eu-central-1a (euc1-az2) or eu-central-1c (euc1-az1)
  EOT
  type        = string
  default     = "us-east-1c" # Maps to use1-az6
}

variable "odb_client_subnet_cidr" {
  description = "CIDR block for ODB client subnet (minimum /27, maximum /16)"
  type        = string
  default     = "192.168.1.0/27"
  
  validation {
    condition     = can(cidrhost(var.odb_client_subnet_cidr, 0))
    error_message = "Must be a valid CIDR block between /16 and /27"
  }
}

variable "odb_backup_subnet_cidr" {
  description = "CIDR block for ODB backup subnet (minimum /28, maximum /16)"
  type        = string
  default     = "192.168.2.0/28"
  
  validation {
    condition     = can(cidrhost(var.odb_backup_subnet_cidr, 0))
    error_message = "Must be a valid CIDR block between /16 and /28"
  }
}

variable "odb_network_dns_prefix" {
  description = "Default DNS prefix for ODB network"
  type        = string
  default     = "odbnet"
}

# ============================================================================
# Exadata Infrastructure Configuration
# ============================================================================

variable "exadata_availability_zone" {
  description = <<-EOT
    Availability zone for Exadata infrastructure. Must match odb_availability_zone.
    All ODB resources must be deployed in the same ODB-supported AZ.
  EOT
  type        = string
  default     = "us-east-1c" # Maps to use1-az6
}

variable "exadata_shape" {
  description = "Exadata system model (only Exadata.X11M is supported)"
  type        = string
  default     = "Exadata.X11M"
  
  validation {
    condition     = var.exadata_shape == "Exadata.X11M"
    error_message = "Only Exadata.X11M is supported for Oracle Database@AWS"
  }
}




variable "exadata_compute_count" {
  description = "Number of database servers (2-32)"
  type        = number
  default     = 2
  
  validation {
    condition     = var.exadata_compute_count >= 2 && var.exadata_compute_count <= 32
    error_message = "Compute count must be between 2 and 32"
  }
}

variable "exadata_storage_count" {
  description = "Number of storage servers (3-64)"
  type        = number
  default     = 3
  
  validation {
    condition     = var.exadata_storage_count >= 3 && var.exadata_storage_count <= 64
    error_message = "Storage count must be between 3 and 64"
  }
}

# ============================================================================
# VM Cluster or Autonomous VM Cluster Selection
# ============================================================================

variable "create_vm_cluster" {
  description = "Whether to create a VM cluster (for user-managed databases)"
  type        = bool
  default     = true
}

variable "create_autonomous_vm_cluster" {
  description = "Whether to create an Autonomous VM cluster (for Autonomous Databases)"
  type        = bool
  default     = false
}

# ============================================================================
# VM Cluster Configuration
# ============================================================================

variable "vm_cluster_cpu_core_count" {
  description = "Number of CPU cores for VM cluster"
  type        = number
  default     = 16
}

variable "vm_cluster_memory_size_gbs" {
  description = "Memory size in GBs for VM cluster"
  type        = number
  default     = 60
}

variable "vm_cluster_data_storage_size_tbs" {
  description = "Data storage size in TBs"
  type        = number
  default     = 2
}

variable "vm_cluster_db_node_storage_size_gbs" {
  description = "DB node storage size in GBs"
  type        = number
  default     = 120
}

variable "vm_cluster_gi_version" {
  description = "Grid Infrastructure version (e.g., 19.0.0.0)"
  type        = string
  default     = "19.0.0.0"
}

variable "vm_cluster_ssh_public_keys" {
  description = "List of SSH public keys for VM cluster access (store in AWS Secrets Manager)"
  type        = list(string)
  default     = []
  sensitive   = true
}

variable "vm_cluster_license_model" {
  description = "License model (LICENSE_INCLUDED or BRING_YOUR_OWN_LICENSE)"
  type        = string
  default     = "BRING_YOUR_OWN_LICENSE"
  
  validation {
    condition     = contains(["LICENSE_INCLUDED", "BRING_YOUR_OWN_LICENSE"], var.vm_cluster_license_model)
    error_message = "Must be LICENSE_INCLUDED or BRING_YOUR_OWN_LICENSE"
  }
}

variable "vm_cluster_time_zone" {
  description = "Time zone for VM cluster"
  type        = string
  default     = "UTC"
}

# ============================================================================
# Autonomous VM Cluster Configuration
# ============================================================================

variable "autonomous_total_container_databases" {
  description = "Total number of Autonomous Container Databases"
  type        = number
  default     = 2
}

variable "autonomous_cpu_core_count_per_node" {
  description = "CPU core count per node for Autonomous VM cluster"
  type        = number
  default     = 16
}

variable "autonomous_memory_per_ocpu_in_gbs" {
  description = "Memory per OCPU in GBs for Autonomous VM cluster"
  type        = number
  default     = 15
}

variable "autonomous_data_storage_size_in_tbs" {
  description = "Data storage size in TBs for Autonomous VM cluster"
  type        = number
  default     = 2
}

variable "autonomous_db_servers" {
  description = "List of DB server OCIDs for Autonomous VM cluster"
  type        = list(string)
  default     = []
}

variable "autonomous_license_model" {
  description = "License model for Autonomous VM cluster"
  type        = string
  default     = "BRING_YOUR_OWN_LICENSE"
  
  validation {
    condition     = contains(["LICENSE_INCLUDED", "BRING_YOUR_OWN_LICENSE"], var.autonomous_license_model)
    error_message = "Must be LICENSE_INCLUDED or BRING_YOUR_OWN_LICENSE"
  }
}

variable "autonomous_time_zone" {
  description = "Time zone for Autonomous VM cluster"
  type        = string
  default     = "UTC"
}

variable "autonomous_maintenance_preference" {
  description = "Maintenance preference for Autonomous VM cluster"
  type        = string
  default     = "NO_PREFERENCE"
  
  validation {
    condition     = contains(["NO_PREFERENCE", "CUSTOM_PREFERENCE"], var.autonomous_maintenance_preference)
    error_message = "Must be NO_PREFERENCE or CUSTOM_PREFERENCE"
  }
}

variable "autonomous_maintenance_days_of_week" {
  description = "Days of week for Autonomous VM cluster maintenance (e.g., ['MONDAY', 'WEDNESDAY'])"
  type        = list(string)
  default     = null
}

variable "autonomous_maintenance_hours_of_day" {
  description = "Hours of day for Autonomous VM cluster maintenance (0-23)"
  type        = list(number)
  default     = null
}

variable "autonomous_maintenance_lead_time_weeks" {
  description = "Lead time in weeks for Autonomous VM cluster maintenance"
  type        = number
  default     = null
}


# ============================================================================
# Security Group Configuration
# ============================================================================

variable "create_bastion_sg" {
  description = "Whether to create a bastion host security group"
  type        = bool
  default     = false
}

variable "bastion_allowed_cidr" {
  description = "CIDR block allowed to SSH to bastion host (must not be 0.0.0.0/0)"
  type        = string
  default     = "10.0.0.0/8"
  
  validation {
    condition     = var.bastion_allowed_cidr != "0.0.0.0/0"
    error_message = "Bastion SSH access must be restricted to specific CIDR blocks, not 0.0.0.0/0"
  }
}

variable "vm_cluster_hostname_prefix" {
  description = "Hostname prefix for VM cluster nodes"
  type        = string
  default     = "vmhost"
}

variable "vm_cluster_db_servers" {
  description = "List of DB server OCIDs for VM cluster"
  type        = list(string)
  default     = []
}

variable "autonomous_scan_listener_port_tls" {
  description = "SCAN listener port for TLS connections"
  type        = number
  default     = 2484
}

variable "autonomous_scan_listener_port_non_tls" {
  description = "SCAN listener port for non-TLS connections"
  type        = number
  default     = 1521
}

variable "vm_cluster_diagnostics_events_enabled" {
  description = "Enable diagnostics events collection for VM cluster"
  type        = bool
  default     = true
}

variable "vm_cluster_health_monitoring_enabled" {
  description = "Enable health monitoring for VM cluster"
  type        = bool
  default     = true
}

variable "vm_cluster_incident_logs_enabled" {
  description = "Enable incident logs collection for VM cluster"
  type        = bool
  default     = true
}

# ============================================================================
# Security and Compliance Configuration
# ============================================================================

variable "data_classification" {
  description = "Data classification level (Public/Internal/Confidential/Restricted)"
  type        = string
  default     = "Internal"
  
  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted"], var.data_classification)
    error_message = "Must be one of: Public, Internal, Confidential, Restricted"
  }
}

variable "compliance_scope" {
  description = "Compliance requirements (e.g., PCI, HIPAA, SOC2)"
  type        = string
  default     = "None"
}

variable "exadata_maintenance_preference" {
  description = "Maintenance preference for Exadata infrastructure"
  type        = string
  default     = "CUSTOM_PREFERENCE"
  
  validation {
    condition     = contains(["NO_PREFERENCE", "CUSTOM_PREFERENCE"], var.exadata_maintenance_preference)
    error_message = "Must be NO_PREFERENCE or CUSTOM_PREFERENCE"
  }
}

variable "exadata_maintenance_days_of_week" {
  description = "Days of week for Exadata maintenance (e.g., ['SUNDAY'])"
  type        = list(string)
  default     = ["SUNDAY"]
}

variable "exadata_maintenance_hours_of_day" {
  description = "Hours of day for Exadata maintenance (0-23)"
  type        = list(number)
  default     = [2, 3, 4]
}

variable "exadata_maintenance_lead_time_weeks" {
  description = "Lead time in weeks for Exadata maintenance"
  type        = number
  default     = 2
}
