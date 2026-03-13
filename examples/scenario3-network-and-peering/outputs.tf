# Networking
output "vpc_id" {
  value = module.networking.vpc_id
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_route_table_ids" {
  value = module.networking.private_route_table_ids
}

# ODB Network
output "odb_network_id" {
  value = module.odb.odb_network_id
}

output "odb_network_arn" {
  description = "ARN of the ODB network (needed for manual route creation)"
  value       = module.odb.odb_network_arn
}

# Peering
output "peering_connection_id" {
  value = module.odb.odb_peering_connection_id
}

output "peering_status" {
  value = module.odb.odb_peering_status
}
