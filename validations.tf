# Validation checks for ODB deployment

# Validate that the selected region supports ODB
resource "null_resource" "validate_odb_region" {
  lifecycle {
    precondition {
      condition     = local.is_odb_supported_region
      error_message = <<-EOT
        Region '${var.aws_region}' does not support Oracle Database@AWS.
        Supported regions are:
        - us-east-1 (US East N. Virginia)
        - us-east-2 (US East Ohio)
        - us-west-2 (US West Oregon)
        - ap-northeast-1 (Asia Pacific Tokyo)
        - eu-central-1 (Europe Frankfurt)
      EOT
    }
  }
}

# Validate that the selected ODB AZ is valid for the region
resource "null_resource" "validate_odb_az" {
  lifecycle {
    precondition {
      condition     = local.is_valid_odb_az
      error_message = <<-EOT
        Availability zone '${var.odb_availability_zone}' is not supported for ODB in region '${var.aws_region}'.
        Supported AZs for ${var.aws_region}:
        ${join("\n        ", [for k, v in local.available_odb_azs : "- ${v} (${k})"])}
      EOT
    }
  }
}

# Validate that ODB and Exadata AZs match
resource "null_resource" "validate_az_match" {
  lifecycle {
    precondition {
      condition     = var.odb_availability_zone == var.exadata_availability_zone
      error_message = <<-EOT
        ODB network and Exadata infrastructure must be in the same availability zone.
        ODB AZ: ${var.odb_availability_zone}
        Exadata AZ: ${var.exadata_availability_zone}
        All ODB resources must be deployed in a single ODB-supported AZ.
      EOT
    }
  }
}

# Validate that either VM cluster or Autonomous VM cluster is selected (not both)
resource "null_resource" "validate_cluster_selection" {
  lifecycle {
    precondition {
      condition     = (var.create_vm_cluster && !var.create_autonomous_vm_cluster) || (!var.create_vm_cluster && var.create_autonomous_vm_cluster)
      error_message = "You must select either VM Cluster (create_vm_cluster=true) OR Autonomous VM Cluster (create_autonomous_vm_cluster=true), but not both."
    }
  }
}
