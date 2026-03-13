# Networking
output "vpc_id" {
  value = module.networking.vpc_id
}

# Exadata (existing)
output "exadata_infra_id" {
  value = module.odb.exadata_infrastructure_id
}

output "discovered_db_servers" {
  value = module.odb.discovered_db_server_ids
}

# ODB Network
output "odb_network_id" {
  value = module.odb.odb_network_id
}

output "odb_network_arn" {
  description = "ARN of the ODB network (needed for manual route creation)"
  value       = module.odb.odb_network_arn
}

output "private_route_table_ids" {
  value = module.networking.private_route_table_ids
}

# Peering
output "peering_connection_id" {
  value = module.odb.odb_peering_connection_id
}

# VM Cluster
output "vm_cluster_id" {
  value = module.odb.vm_cluster_id
}

output "vm_cluster_system_version" {
  value = module.odb.vm_cluster_system_version
}

# Autonomous VM Cluster
output "autonomous_vm_cluster_id" {
  value = module.odb.autonomous_vm_cluster_id
}
