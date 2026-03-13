provider "aws" {
  region = var.aws_region
}

# ============================================================================
# VPC and Networking Resources
# ============================================================================

resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.name_prefix}-app-vpc"
    Environment = var.environment
  }
}

# Restrict default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.name_prefix}-default-sg-restricted"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = { for idx, az in var.availability_zones : idx => {
    az   = az
    cidr = var.public_subnet_cidrs[idx]
  } }

  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-public-${each.key}"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateways
resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain   = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "${var.name_prefix}-nat-${each.key}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = { for idx, az in var.availability_zones : idx => {
    az   = az
    cidr = var.private_subnet_cidrs[idx]
  } }

  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.name_prefix}-private-${each.key}"
  }
}

# Private Route Tables
resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.name_prefix}-private-rt-${each.key}"
  }
}

resource "aws_route" "private_nat" {
  for_each               = aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# ============================================================================
# Oracle Database@AWS Resources
# ============================================================================

# KMS Key for Oracle Database@AWS (ODB) encryption
resource "aws_kms_key" "odb" {
  description             = "KMS key for Oracle Database@AWS encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-odb-kms"
    }
  )
}

resource "aws_kms_alias" "odb" {
  name          = "alias/${var.name_prefix}-odb"
  target_key_id = aws_kms_key.odb.key_id
}

# VPC Flow Logs for network monitoring
resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.app_vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-vpc-flow-logs"
    }
  )
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/${var.name_prefix}-flow-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.odb.arn

  tags = local.common_tags
}

resource "aws_iam_role" "flow_logs" {
  name = "${var.name_prefix}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.name_prefix}-vpc-flow-logs-policy"
  role = aws_iam_role.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.flow_logs.arn}:*"
      }
    ]
  })
}

# Oracle Database@AWS (ODB) Network
resource "aws_odb_network" "main" {
  availability_zone_id = data.aws_availability_zone.odb_az.zone_id
  client_subnet_cidr   = var.odb_client_subnet_cidr
  backup_subnet_cidr   = var.odb_backup_subnet_cidr
  default_dns_prefix   = var.odb_network_dns_prefix
  display_name         = "${var.name_prefix}-odbnet"
  s3_access            = "ENABLED"
  zero_etl_access      = "DISABLED"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-odbnet"
    }
  )
}

# ODB Peering Connection
resource "aws_odb_network_peering_connection" "main" {
  odb_network_id  = aws_odb_network.main.id
  peer_network_id = aws_vpc.app_vpc.id
  display_name    = "${var.name_prefix}-odb-peering"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-odb-peering"
    }
  )

  depends_on = [aws_odb_network.main]
}

# Exadata Infrastructure
resource "aws_odb_cloud_exadata_infrastructure" "main" {
  availability_zone_id = data.aws_availability_zone.exadata_az.zone_id
  compute_count        = var.exadata_compute_count
  storage_count        = var.exadata_storage_count
  shape                = var.exadata_shape
  display_name         = "${var.name_prefix}-exadata-infra"

  maintenance_window {
    preference                        = var.exadata_maintenance_preference
    patching_mode                     = "ROLLING"
    is_custom_action_timeout_enabled  = true
    custom_action_timeout_in_mins     = 30
    
    dynamic "days_of_week" {
      for_each = var.exadata_maintenance_preference == "CUSTOM_PREFERENCE" ? var.exadata_maintenance_days_of_week : []
      content {
        name = days_of_week.value
      }
    }
    
    hours_of_day       = var.exadata_maintenance_preference == "CUSTOM_PREFERENCE" ? var.exadata_maintenance_hours_of_day : null
    lead_time_in_weeks = var.exadata_maintenance_preference == "CUSTOM_PREFERENCE" ? var.exadata_maintenance_lead_time_weeks : null
  }

  tags = merge(
    local.common_tags,
    {
      Name                = "${var.name_prefix}-exadata-infra"
      DataClassification  = var.data_classification
      ComplianceScope     = var.compliance_scope
    }
  )
}

# VM Cluster
resource "aws_odb_cloud_vm_cluster" "main" {
  count = var.create_vm_cluster ? 1 : 0

  cloud_exadata_infrastructure_id = aws_odb_cloud_exadata_infrastructure.main.id
  odb_network_id                  = aws_odb_network.main.id
  cpu_core_count                  = var.vm_cluster_cpu_core_count
  memory_size_in_gbs              = var.vm_cluster_memory_size_gbs
  data_storage_size_in_tbs        = var.vm_cluster_data_storage_size_tbs
  db_node_storage_size_in_gbs     = var.vm_cluster_db_node_storage_size_gbs
  gi_version                      = var.vm_cluster_gi_version
  display_name                    = "${var.name_prefix}-vmcluster"
  hostname_prefix                 = var.vm_cluster_hostname_prefix
  db_servers                      = var.vm_cluster_db_servers

  ssh_public_keys = var.vm_cluster_ssh_public_keys
  license_model   = var.vm_cluster_license_model
  timezone        = var.vm_cluster_time_zone

  data_collection_options {
    is_diagnostics_events_enabled = var.vm_cluster_diagnostics_events_enabled
    is_health_monitoring_enabled   = var.vm_cluster_health_monitoring_enabled
    is_incident_logs_enabled       = var.vm_cluster_incident_logs_enabled
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-vmcluster"
    }
  )

  depends_on = [
    aws_odb_cloud_exadata_infrastructure.main,
    aws_odb_network.main
  ]
}

# Autonomous VM Cluster
resource "aws_odb_cloud_autonomous_vm_cluster" "main" {
  count = var.create_autonomous_vm_cluster ? 1 : 0

  cloud_exadata_infrastructure_id           = aws_odb_cloud_exadata_infrastructure.main.id
  odb_network_id                            = aws_odb_network.main.id
  total_container_databases                 = var.autonomous_total_container_databases
  cpu_core_count_per_node                   = var.autonomous_cpu_core_count_per_node
  memory_per_oracle_compute_unit_in_gbs     = var.autonomous_memory_per_ocpu_in_gbs
  autonomous_data_storage_size_in_tbs       = var.autonomous_data_storage_size_in_tbs
  db_servers                                = var.autonomous_db_servers
  display_name                              = "${var.name_prefix}-autonomous-vmcluster"
  license_model                             = var.autonomous_license_model
  time_zone                                 = var.autonomous_time_zone
  scan_listener_port_tls                    = var.autonomous_scan_listener_port_tls
  scan_listener_port_non_tls                = var.autonomous_scan_listener_port_non_tls

  maintenance_window {
    preference = var.autonomous_maintenance_preference
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-autonomous-vmcluster"
    }
  )

  depends_on = [
    aws_odb_cloud_exadata_infrastructure.main,
    aws_odb_network.main
  ]
}
