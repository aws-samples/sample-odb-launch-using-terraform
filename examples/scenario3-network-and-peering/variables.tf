variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "name_prefix" {
  type = string
}

variable "environment" {
  type    = string
  default = "prod"
}

# VPC
variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

# ODB Network
variable "odb_availability_zone" {
  type = string
}

variable "odb_client_subnet_cidr" {
  type = string
}

variable "odb_backup_subnet_cidr" {
  type = string
}

variable "odb_dns_prefix" {
  type = string
}
