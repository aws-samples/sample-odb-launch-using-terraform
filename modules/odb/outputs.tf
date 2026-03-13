# ============================================================================
# Exadata Infrastructure
# ============================================================================

output "exadata_infrastructure_id" {
  description = "ID of the Exadata infrastructure (created or existing)"
  value       = var.create_exadata_infra ? aws_odb_cloud_exadata_infrastructure.main[0].id : try(data.aws_odb_cloud_exadata_infrastructure.existing[0].id, null)
}

output "discovered_db_server_ids" {
  description = "DB server IDs auto-discovered from the Exadata infrastructure"
  value       = local.discovered_db_server_ids
}

output "exadata_infrastructure_shape" {
  description = "Shape of the Exadata infrastructure"
  value       = var.create_exadata_infra ? aws_odb_cloud_exadata_infrastructure.main[0].shape : try(data.aws_odb_cloud_exadata_infrastructure.existing[0].shape, null)
}

# ============================================================================
# ODB Network
# ============================================================================

output "odb_network_id" {
  description = "ID of the ODB network"
  value       = var.create_odb_network ? aws_odb_network.main[0].id : null
}

output "odb_network_arn" {
  description = "ARN of the ODB network (needed for manual route creation via AWS CLI)"
  value       = var.create_odb_network ? aws_odb_network.main[0].arn : null
}

output "odb_network_display_name" {
  description = "Display name of the ODB network"
  value       = var.create_odb_network ? aws_odb_network.main[0].display_name : null
}

# ============================================================================
# ODB Peering
# ============================================================================

output "odb_peering_connection_id" {
  description = "ID of the ODB peering connection"
  value       = var.create_peering_connection ? aws_odb_network_peering_connection.main[0].id : null
}

output "odb_peering_status" {
  description = "Status of the ODB peering connection"
  value       = var.create_peering_connection ? aws_odb_network_peering_connection.main[0].status : null
}

# ============================================================================
# VM Cluster
# ============================================================================

output "vm_cluster_id" {
  description = "ID of the VM cluster"
  value       = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].id : null
}

output "vm_cluster_display_name" {
  description = "Display name of the VM cluster"
  value       = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].display_name : null
}

output "vm_cluster_scan_dns_name" {
  description = "SCAN DNS name of the VM cluster"
  value       = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].scan_dns_name : null
}

output "vm_cluster_system_version" {
  description = "System version of the VM cluster (auto-determined from gi_version)"
  value       = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].system_version : null
}

output "vm_cluster_gi_version" {
  description = "GI version of the VM cluster"
  value       = var.create_vm_cluster ? aws_odb_cloud_vm_cluster.main[0].gi_version_computed : null
}

# ============================================================================
# Autonomous VM Cluster
# ============================================================================

output "autonomous_vm_cluster_id" {
  description = "ID of the Autonomous VM cluster"
  value       = var.create_autonomous_vm_cluster ? aws_odb_cloud_autonomous_vm_cluster.main[0].id : null
}

output "autonomous_vm_cluster_display_name" {
  description = "Display name of the Autonomous VM cluster"
  value       = var.create_autonomous_vm_cluster ? aws_odb_cloud_autonomous_vm_cluster.main[0].display_name : null
}
