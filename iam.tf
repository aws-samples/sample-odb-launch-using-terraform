# ============================================================================
# IAM Roles and Policies for Oracle Database@AWS (ODB)
# ============================================================================

# IAM role for Oracle Database@AWS administration
resource "aws_iam_role" "odb_admin" {
  name        = "${var.name_prefix}-odb-admin-role"
  description = "IAM role for Oracle Database@AWS administration"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-odb-admin-role"
    }
  )
}

# IAM policy for Oracle Database@AWS management
resource "aws_iam_role_policy" "odb_admin" {
  name = "${var.name_prefix}-odb-admin-policy"
  role = aws_iam_role.odb_admin.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ODBNetworkManagement"
        Effect = "Allow"
        Action = [
          "odb:GetNetwork",
          "odb:ListNetworks",
          "odb:DescribeNetwork"
        ]
        Resource = aws_odb_network.main.arn
      },
      {
        Sid    = "ODBInfrastructureManagement"
        Effect = "Allow"
        Action = [
          "odb:GetCloudExadataInfrastructure",
          "odb:ListCloudExadataInfrastructures"
        ]
        Resource = aws_odb_cloud_exadata_infrastructure.main.arn
      },
      {
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/odb/*"
      },
      {
        Sid    = "KMSKeyAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.odb.arn
      }
    ]
  })
}
