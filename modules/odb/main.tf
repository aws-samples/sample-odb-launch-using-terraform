# ============================================================================
# Oracle Database@AWS (ODB) Module
#
# Supports 3 deployment scenarios via input variables:
#   1. Full deployment    — create_exadata_infra = true
#   2. Existing Exadata   — create_exadata_infra = false, existing_exadata_infra_id set
#   3. Network only       — create_odb_network = true, create_vm_cluster = false
# ============================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# ============================================================================
# Data Sources
# ============================================================================

data "aws_availability_zone" "odb_az" {
  name = var.odb_availability_zone
}

data "aws_availability_zone" "exadata_az" {
  count = var.create_exadata_infra ? 1 : 0
  name  = var.exadata_availability_zone
}

# Whether any cluster is being created (determines if Exadata lookup is needed)
locals {
  needs_exadata = var.create_exadata_infra || var.create_vm_cluster || var.create_autonomous_vm_cluster
}

# Look up existing Exadata infra when not creating a new one but clusters need it
data "aws_odb_cloud_exadata_infrastructure" "existing" {
  count = (!var.create_exadata_infra && local.needs_exadata) ? 1 : 0
  id    = var.existing_exadata_infra_id
}

locals {
  # Resolve Exadata infra ID — either from new resource, existing data source, or null
  exadata_infra_id = var.create_exadata_infra ? (
    aws_odb_cloud_exadata_infrastructure.main[0].id
  ) : (
    local.needs_exadata ? data.aws_odb_cloud_exadata_infrastructure.existing[0].id : null
  )

  # Auto-discover DB server IDs from the Exadata infra
  discovered_db_server_ids = local.needs_exadata ? [
    for s in data.aws_odb_db_servers.exadata[0].db_servers : s.id
    if s.status == "AVAILABLE"
  ] : []

  # Use explicitly provided db_servers if set, otherwise use discovered ones
  effective_vm_db_servers        = length(var.vm_db_servers) > 0 ? var.vm_db_servers : local.discovered_db_server_ids
  effective_autonomous_db_servers = length(var.autonomous_db_servers) > 0 ? var.autonomous_db_servers : local.discovered_db_server_ids
}

# Look up DB servers from the Exadata infrastructure (only when clusters are needed)
data "aws_odb_db_servers" "exadata" {
  count                           = local.needs_exadata ? 1 : 0
  cloud_exadata_infrastructure_id = local.exadata_infra_id
}

# ============================================================================
# Exadata Infrastructure (only when create_exadata_infra = true)
# ============================================================================

resource "aws_odb_cloud_exadata_infrastructure" "main" {
  count = var.create_exadata_infra ? 1 : 0

  availability_zone_id = data.aws_availability_zone.exadata_az[0].zone_id
  compute_count        = var.exadata_compute_count
  storage_count        = var.exadata_storage_count
  shape                = var.exadata_shape
  display_name         = "${var.name_prefix}-exadata-infra"

  maintenance_window {
    preference                       = var.exadata_maintenance_preference
    patching_mode                    = "ROLLING"
    is_custom_action_timeout_enabled = var.exadata_maintenance_preference == "CUSTOM_PREFERENCE"
    custom_action_timeout_in_mins    = var.exadata_maintenance_preference == "CUSTOM_PREFERENCE" ? 30 : 0

    dynamic "days_of_week" {
      for_each = var.exadata_maintenance_preference == "CUSTOM_PREFERENCE" ? var.exadata_maintenance_days_of_week : []
      content {
        name = days_of_week.value
      }
    }

    hours_of_day       = var.exadata_maintenance_preference == "CUSTOM_PREFERENCE" ? var.exadata_maintenance_hours_of_day : null
    lead_time_in_weeks = var.exadata_maintenance_preference == "CUSTOM_PREFERENCE" ? var.exadata_maintenance_lead_time_weeks : null
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-exadata-infra"
  })
}

# ============================================================================
# ODB Network
# ============================================================================

resource "aws_odb_network" "main" {
  count = var.create_odb_network ? 1 : 0

  availability_zone_id       = data.aws_availability_zone.odb_az.zone_id
  client_subnet_cidr         = var.client_subnet_cidr
  backup_subnet_cidr         = var.backup_subnet_cidr
  default_dns_prefix         = var.dns_prefix
  display_name               = "${var.name_prefix}-odbnet"
  s3_access                  = "ENABLED"
  zero_etl_access            = "DISABLED"
  delete_associated_resources = var.delete_associated_oci_resources

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-odbnet"
  })
}

# ============================================================================
# ODB Peering Connection
# ============================================================================

resource "aws_odb_network_peering_connection" "main" {
  count = var.create_peering_connection ? 1 : 0

  odb_network_id  = var.create_odb_network ? aws_odb_network.main[0].id : var.existing_odb_network_id
  peer_network_id = var.vpc_id
  display_name    = "${var.name_prefix}-odb-peering"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-odb-peering"
  })
}

# ============================================================================
# ODB Peering Routes — NOT YET SUPPORTED IN TERRAFORM
#
# The AWS EC2 API supports `OdbNetworkArn` as a route target via:
#   aws ec2 create-route --route-table-id <id> \
#     --destination-cidr-block <odb-client-cidr> \
#     --odb-network-arn <odb-network-arn>
#
# However, the Terraform AWS provider does NOT yet expose `odb_network_arn`
# on the `aws_route` resource. A GitHub issue is tracking this:
#   https://github.com/hashicorp/terraform-provider-aws/issues/44672
#
# WORKAROUND: After `terraform apply`, manually add routes using the AWS CLI:
#   for rtb in $(terraform output -json private_route_table_ids | jq -r '.[]'); do
#     aws ec2 create-route \
#       --route-table-id "$rtb" \
#       --destination-cidr-block "<odb-client-subnet-cidr>" \
#       --odb-network-arn "$(terraform output -raw odb_network_arn)"
#   done
#
# This block will be replaced with a native `aws_route` resource once the
# Terraform provider adds `odb_network_arn` support.
# ============================================================================

# ============================================================================
# VM Cluster
# ============================================================================

resource "aws_odb_cloud_vm_cluster" "main" {
  count = var.create_vm_cluster ? 1 : 0

  cloud_exadata_infrastructure_id = local.exadata_infra_id
  odb_network_id                  = var.create_odb_network ? aws_odb_network.main[0].id : var.existing_odb_network_id
  cpu_core_count                  = var.vm_cpu_core_count
  memory_size_in_gbs              = var.vm_memory_size_gbs
  data_storage_size_in_tbs        = var.vm_data_storage_size_tbs
  db_node_storage_size_in_gbs     = var.vm_db_node_storage_size_gbs
  gi_version                      = var.vm_gi_version
  display_name                    = "${var.name_prefix}-vmcluster"
  hostname_prefix                 = var.vm_hostname_prefix
  db_servers                      = local.effective_vm_db_servers

  ssh_public_keys = var.vm_ssh_public_keys
  license_model   = var.vm_license_model
  timezone        = var.vm_time_zone

  data_collection_options {
    is_diagnostics_events_enabled = var.vm_diagnostics_events_enabled
    is_health_monitoring_enabled  = var.vm_health_monitoring_enabled
    is_incident_logs_enabled      = var.vm_incident_logs_enabled
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vmcluster"
  })
}

# ============================================================================
# Autonomous VM Cluster
# ============================================================================

resource "aws_odb_cloud_autonomous_vm_cluster" "main" {
  count = var.create_autonomous_vm_cluster ? 1 : 0

  cloud_exadata_infrastructure_id       = local.exadata_infra_id
  odb_network_id                        = var.create_odb_network ? aws_odb_network.main[0].id : var.existing_odb_network_id
  total_container_databases             = var.autonomous_total_container_databases
  cpu_core_count_per_node               = var.autonomous_cpu_core_count_per_node
  memory_per_oracle_compute_unit_in_gbs = var.autonomous_memory_per_ocpu_in_gbs
  autonomous_data_storage_size_in_tbs   = var.autonomous_data_storage_size_in_tbs
  db_servers                            = local.effective_autonomous_db_servers
  display_name                          = "${var.name_prefix}-autonomous-vmcluster"
  license_model                         = var.autonomous_license_model
  time_zone                             = var.autonomous_time_zone
  scan_listener_port_tls                = var.autonomous_scan_listener_port_tls
  scan_listener_port_non_tls            = var.autonomous_scan_listener_port_non_tls

  maintenance_window {
    preference = var.autonomous_maintenance_preference
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-autonomous-vmcluster"
  })
}
