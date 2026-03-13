variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "name_prefix" {
  type    = string
  default = "Production-odb"
}

variable "environment" {
  type    = string
  default = "prod"
}

# VPC
variable "vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.2.10.0/24", "10.2.11.0/24"]
}

# ODB Network
variable "odb_availability_zone" {
  type    = string
  default = "us-west-2c"
}

variable "odb_client_subnet_cidr" {
  type    = string
  default = "192.168.1.0/27"
}

variable "odb_backup_subnet_cidr" {
  type    = string
  default = "192.168.2.0/28"
}

# Exadata
variable "exadata_availability_zone" {
  type    = string
  default = "us-west-2c"
}

variable "exadata_shape" {
  type    = string
  default = "Exadata.X11M"
}

variable "exadata_compute_count" {
  type    = number
  default = 2
}

variable "exadata_storage_count" {
  type    = number
  default = 3
}

# Cluster selection
variable "create_vm_cluster" {
  type    = bool
  default = true
}

variable "create_autonomous_vm_cluster" {
  type    = bool
  default = false
}

# VM Cluster
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

variable "vm_cluster_db_servers" {
  type    = list(string)
  default = []
}
