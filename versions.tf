terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # IMPORTANT: Configure remote state backend for production use
  # Uncomment and configure with your S3 bucket and DynamoDB table
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "odb/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   kms_key_id     = "arn:aws:kms:region:account:key/key-id"
  #   dynamodb_table = "terraform-state-lock"
  #   
  #   # Enable versioning on the S3 bucket
  #   # Enable server-side encryption with KMS
  #   # Restrict bucket access with IAM policies
  # }
}
