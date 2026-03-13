locals {
  # Common tags to apply to all resources
  common_tags = {
    Project     = "Oracle Database@AWS"
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }

  # ODB-supported regions and their availability zones
  # Maps physical AZ IDs to logical AZ names per region
  odb_supported_regions = {
    "us-east-1" = {
      region_name = "US East (N. Virginia)"
      azs = {
        "use1-az4" = "us-east-1b"
        "use1-az6" = "us-east-1c"
      }
    }
    "us-east-2" = {
      region_name = "US East (Ohio)"
      azs = {
        "use2-az1" = "us-east-2a"
        "use2-az2" = "us-east-2b"
      }
    }
    "us-west-2" = {
      region_name = "US West (Oregon)"
      azs = {
        "usw2-az3" = "us-west-2c"
        "usw2-az4" = "us-west-2d"
      }
    }
    "ap-northeast-1" = {
      region_name = "Asia Pacific (Tokyo)"
      azs = {
        "apne1-az4" = "ap-northeast-1a"
        "apne1-az1" = "ap-northeast-1c"
      }
    }
    "eu-central-1" = {
      region_name = "Europe (Frankfurt)"
      azs = {
        "euc1-az2" = "eu-central-1a"
        "euc1-az1" = "eu-central-1c"
      }
    }
  }

  # Validate that the selected region supports ODB
  is_odb_supported_region = contains(keys(local.odb_supported_regions), var.aws_region)

  # Get available ODB AZs for the selected region
  available_odb_azs = local.is_odb_supported_region ? local.odb_supported_regions[var.aws_region].azs : {}

  # Validate that the selected ODB AZ is supported
  is_valid_odb_az = contains(values(local.available_odb_azs), var.odb_availability_zone)

  # Calculate total storage based on Exadata X11M (80TB per storage server)
  total_storage_tb = var.exadata_storage_count * 80

  # Calculate total compute based on Exadata X11M (760 ECPUs per compute node)
  total_compute = var.exadata_compute_count * 760

  # Compute unit label for X11M
  compute_unit = "ECPUs"

  # Resource naming
  resource_prefix = "${var.name_prefix}-${var.environment}"
}
