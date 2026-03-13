output "vpc_id" {
  value = module.networking.vpc_id
}

output "exadata_infrastructure_id" {
  value = module.odb.exadata_infrastructure_id
}

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

output "odb_peering_connection_id" {
  value = module.odb.odb_peering_connection_id
}

output "vm_cluster_id" {
  value = module.odb.vm_cluster_id
}

output "vm_cluster_scan_dns_name" {
  value = module.odb.vm_cluster_scan_dns_name
}
