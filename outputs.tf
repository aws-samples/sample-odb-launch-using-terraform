output "vpc_id" {
  description = "ID of the application VPC"
  value       = aws_vpc.app_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the application VPC"
  value       = aws_vpc.app_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [for s in aws_subnet.private : s.id]
}

output "nat_gateway_ids" {
  description = "IDs of NAT gateways"
  value       = [for n in aws_nat_gateway.nat : n.id]
}

# ODB Network Outputs
output "odb_network_id" {
  description = "ID of the ODB network"
  value       = aws_odb_network.main.id
}

output "odb_network_display_name" {
  description = "Display name of the ODB network"
  value       = aws_odb_network.main.display_name
}

output "odb_client_subnet_cidr" {
  description = "Client subnet CIDR of the ODB network"
  value       = aws_odb_network.main.client_subnet_cidr
}

output "odb_backup_subnet_cidr" {
  description = "Backup subnet CIDR of the ODB network"
  value       = aws_odb_network.main.backup_subnet_cidr
}

# ODB Peering Outputs
output "odb_peering_connection_id" {
  description = "ID of the ODB peering connection"
  value       = aws_odb_network_peering_connection.main.id
}

output "odb_peering_status" {
  description = "Status of the ODB peering connection"
  value       = aws_odb_network_peering_connection.main.status
}

# Exadata Infrastructure Outputs
output "exadata_infrastructure_id" {
  description = "ID of the Exadata infrastructure"
  value       = aws_odb_cloud_exadata_infrastructure.main.id
}

output "exadata_infrastructure_shape" {
  description = "Shape of the Exadata infrastructure"
  value       = aws_odb_cloud_exadata_infrastructure.main.shape
}

output "exadata_compute_count" {
  description = "Number of compute nodes in Exadata infrastructure"
  value       = aws_odb_cloud_exadata_infrastructure.main.compute_count
}

output "exadata_storage_count" {
  description = "Number of storage servers in Exadata infrastructure"
  value       = aws_odb_cloud_exadata_infrastructure.main.storage_count
}

# VM Cluster Outputs
output "vm_cluster_id" {
  description = "ID of the VM cluster"
  value       = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].id : null
}

output "vm_cluster_display_name" {
  description = "Display name of the VM cluster"
  value       = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].display_name : null
}

output "vm_cluster_cpu_core_count" {
  description = "CPU core count of the VM cluster"
  value       = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].cpu_core_count : null
}

output "vm_cluster_memory_size_gbs" {
  description = "Memory size in GBs of the VM cluster"
  value       = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].memory_size_in_gbs : null
}

output "vm_cluster_gi_version" {
  description = "Grid Infrastructure version of the VM cluster"
  value       = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].gi_version : null
}

output "vm_cluster_scan_dns_name" {
  description = "SCAN DNS name of the VM cluster"
  value       = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].scan_dns_name : null
}

# Autonomous VM Cluster Outputs
output "autonomous_vm_cluster_id" {
  description = "ID of the Autonomous VM cluster"
  value       = var.create_autonomous_vm_cluster ? aws_odb_cloud_autonomous_vm_cluster.main[0].id : null
}

output "autonomous_vm_cluster_display_name" {
  description = "Display name of the Autonomous VM cluster"
  value       = var.create_autonomous_vm_cluster ? aws_odb_cloud_autonomous_vm_cluster.main[0].display_name : null
}

output "autonomous_vm_cluster_total_container_databases" {
  description = "Total container databases in Autonomous VM cluster"
  value       = var.create_autonomous_vm_cluster ? aws_odb_cloud_autonomous_vm_cluster.main[0].total_container_databases : null
}

# Connection Information
output "connection_info" {
  description = "Connection information for the ODB deployment"
  value = {
    vpc_id                   = aws_vpc.app_vpc.id
    odb_network_id           = aws_odb_network.main.id
    peering_connection_id    = aws_odb_network_peering_connection.main.id
    vm_cluster_id            = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].id : null
    vm_cluster_scan_dns      = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].scan_dns_name : null
    autonomous_vm_cluster_id = var.create_autonomous_vm_cluster ? aws_odb_cloud_autonomous_vm_cluster.main[0].id : null
  }
}

# Security Outputs
output "kms_key_id" {
  description = "KMS key ID for Oracle Database@AWS encryption"
  value       = aws_kms_key.odb.id
}

output "kms_key_arn" {
  description = "KMS key ARN for Oracle Database@AWS encryption"
  value       = aws_kms_key.odb.arn
}

output "flow_logs_log_group" {
  description = "CloudWatch log group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "odb_admin_role_arn" {
  description = "IAM role ARN for Oracle Database@AWS administration"
  value       = aws_iam_role.odb_admin.arn
}

# Region and Availability Zone Information
output "deployment_region" {
  description = "AWS region where ODB is deployed"
  value = {
    region      = var.aws_region
    region_name = local.odb_supported_regions[var.aws_region].region_name
  }
}

output "deployment_availability_zone" {
  description = "Availability zone where ODB resources are deployed"
  value = {
    odb_az      = var.odb_availability_zone
    exadata_az  = var.exadata_availability_zone
    az_match    = var.odb_availability_zone == var.exadata_availability_zone
  }
}

output "available_odb_azs" {
  description = "Available ODB-supported availability zones for the selected region"
  value       = local.available_odb_azs
}

output "deployment_summary" {
  description = "Summary of the ODB deployment configuration"
  value = {
    region                = var.aws_region
    region_name           = local.odb_supported_regions[var.aws_region].region_name
    availability_zone     = var.odb_availability_zone
    exadata_shape         = var.exadata_shape
    compute_count         = var.exadata_compute_count
    storage_count         = var.exadata_storage_count
    total_storage_tb      = local.total_storage_tb
    total_compute         = local.total_compute
    compute_unit          = local.compute_unit
    cluster_type          = var.create_vm_cluster ? "VM Cluster" : "Autonomous VM Cluster"
    vpc_cidr              = var.vpc_cidr
    odb_client_subnet     = var.odb_client_subnet_cidr
    environment           = var.environment
  }
}
