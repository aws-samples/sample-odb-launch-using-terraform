# ============================================================================
# General
# ============================================================================

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# Feature Flags — control what gets created
# ============================================================================

variable "create_exadata_infra" {
  description = "Set to true to create new Exadata infrastructure, false to use existing"
  type        = bool
  default     = true
}

variable "create_odb_network" {
  description = "Whether to create an ODB network"
  type        = bool
  default     = true
}

variable "create_peering_connection" {
  description = "Whether to create an ODB peering connection"
  type        = bool
  default     = true
}

variable "create_vm_cluster" {
  description = "Whether to create a VM cluster"
  type        = bool
  default     = false
}

variable "create_autonomous_vm_cluster" {
  description = "Whether to create an Autonomous VM cluster"
  type        = bool
  default     = false
}

# ============================================================================
# Existing Resource IDs (when not creating new)
# ============================================================================

variable "existing_exadata_infra_id" {
  description = "ID of existing Exadata infrastructure (required when create_exadata_infra = false)"
  type        = string
  default     = null
}

variable "existing_odb_network_id" {
  description = "ID of existing ODB network (used when create_odb_network = false)"
  type        = string
  default     = null
}

variable "existing_odb_network_arn" {
  description = "ARN of existing ODB network (used for routing when create_odb_network = false)"
  type        = string
  default     = null
}

# ============================================================================
# Networking — needed for peering
# ============================================================================

variable "vpc_id" {
  description = "VPC ID to peer with ODB network"
  type        = string
  default     = null
}

# ============================================================================
# ODB Network Configuration
# ============================================================================

variable "odb_availability_zone" {
  description = "Availability zone for ODB network (must be ODB-supported)"
  type        = string
}

variable "client_subnet_cidr" {
  description = "CIDR block for ODB client subnet (min /27, max /16)"
  type        = string
  default     = "192.168.1.0/27"
}

variable "backup_subnet_cidr" {
  description = "CIDR block for ODB backup subnet (min /28, max /16)"
  type        = string
  default     = "192.168.2.0/28"
}

variable "dns_prefix" {
  description = "DNS prefix for ODB network"
  type        = string
  default     = "odbnet"
}

variable "delete_associated_oci_resources" {
  description = "If true, deletes associated OCI VCN resources when the ODB network is destroyed. Default false leaves OCI resources intact."
  type        = bool
  default     = false
}

# ============================================================================
# Exadata Infrastructure Configuration (only when create_exadata_infra = true)
# ============================================================================

variable "exadata_availability_zone" {
  description = "Availability zone for Exadata infrastructure"
  type        = string
  default     = null
}

variable "exadata_shape" {
  description = "Exadata system model (only Exadata.X11M supported)"
  type        = string
  default     = "Exadata.X11M"
}

variable "exadata_compute_count" {
  description = "Number of database servers (2-32)"
  type        = number
  default     = 2
}

variable "exadata_storage_count" {
  description = "Number of storage servers (3-64)"
  type        = number
  default     = 3
}

variable "exadata_maintenance_preference" {
  description = "Maintenance preference: NO_PREFERENCE or CUSTOM_PREFERENCE"
  type        = string
  default     = "NO_PREFERENCE"
}

variable "exadata_maintenance_days_of_week" {
  description = "Days of week for maintenance (e.g., ['SUNDAY'])"
  type        = list(string)
  default     = ["SUNDAY"]
}

variable "exadata_maintenance_hours_of_day" {
  description = "Hours of day for maintenance (0-23)"
  type        = list(number)
  default     = [2, 3, 4]
}

variable "exadata_maintenance_lead_time_weeks" {
  description = "Lead time in weeks for maintenance"
  type        = number
  default     = 2
}

# ============================================================================
# VM Cluster Configuration
# ============================================================================

variable "vm_cpu_core_count" {
  description = "CPU core count for VM cluster"
  type        = number
  default     = 16
}

variable "vm_memory_size_gbs" {
  description = "Memory size in GBs"
  type        = number
  default     = 60
}

variable "vm_data_storage_size_tbs" {
  description = "Data storage size in TBs"
  type        = number
  default     = 2
}

variable "vm_db_node_storage_size_gbs" {
  description = "DB node storage size in GBs"
  type        = number
  default     = 120
}

variable "vm_gi_version" {
  description = "Grid Infrastructure version"
  type        = string
  default     = "19.0.0.0"
}

variable "vm_ssh_public_keys" {
  description = "SSH public keys for VM access"
  type        = list(string)
  default     = []
}

variable "vm_license_model" {
  description = "LICENSE_INCLUDED or BRING_YOUR_OWN_LICENSE"
  type        = string
  default     = "BRING_YOUR_OWN_LICENSE"
}

variable "vm_time_zone" {
  description = "Time zone for VM cluster"
  type        = string
  default     = "UTC"
}

variable "vm_hostname_prefix" {
  description = "Hostname prefix for VM cluster nodes"
  type        = string
  default     = "vmhost"
}

variable "vm_db_servers" {
  description = "List of DB server OCIDs for VM cluster"
  type        = list(string)
  default     = []
}

variable "vm_diagnostics_events_enabled" {
  description = "Enable diagnostics events collection"
  type        = bool
  default     = true
}

variable "vm_health_monitoring_enabled" {
  description = "Enable health monitoring"
  type        = bool
  default     = true
}

variable "vm_incident_logs_enabled" {
  description = "Enable incident logs collection"
  type        = bool
  default     = true
}

# ============================================================================
# Autonomous VM Cluster Configuration
# ============================================================================

variable "autonomous_total_container_databases" {
  type    = number
  default = 2
}

variable "autonomous_cpu_core_count_per_node" {
  type    = number
  default = 16
}

variable "autonomous_memory_per_ocpu_in_gbs" {
  type    = number
  default = 15
}

variable "autonomous_data_storage_size_in_tbs" {
  type    = number
  default = 2
}

variable "autonomous_db_servers" {
  type    = list(string)
  default = []
}

variable "autonomous_license_model" {
  type    = string
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "autonomous_time_zone" {
  type    = string
  default = "UTC"
}

variable "autonomous_maintenance_preference" {
  type    = string
  default = "NO_PREFERENCE"
}

variable "autonomous_scan_listener_port_tls" {
  type    = number
  default = 2484
}

variable "autonomous_scan_listener_port_non_tls" {
  type    = number
  default = 1521
}
