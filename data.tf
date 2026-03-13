# Data sources for additional AWS information

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Get availability zone details for ODB validation
data "aws_availability_zone" "odb_az" {
  name = var.odb_availability_zone
}

# Get availability zone details for Exadata
data "aws_availability_zone" "exadata_az" {
  name = var.exadata_availability_zone
}


# Data source for ODB Network (if importing existing)
# data "aws_odb_network" "existing" {
#   id = "odb-network-id"
# }

# Data source for ODB Peering Connection (if importing existing)
# data "aws_odb_network_peering_connection" "existing" {
#   id = "peering-connection-id"
# }

# Data source for Exadata Infrastructure (if importing existing)
# data "aws_odb_cloud_exadata_infrastructure" "existing" {
#   id = "exadata-infrastructure-id"
# }

# Data source for VM Cluster (if importing existing)
# data "aws_odb_cloud_vm_cluster" "existing" {
#   id = "vm-cluster-id"
# }

# Data source for Autonomous VM Cluster (if importing existing)
# data "aws_odb_cloud_autonomous_vm_cluster" "existing" {
#   id = "autonomous-vm-cluster-id"
# }
