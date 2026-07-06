variable "domain_name" {
  description = "The domain name for the ACM certificate"
  type        = string
}

variable "admin_email" {
  description = "The email address for administrative alerts"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_a" {
  description = "CIDR for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_b" {
  description = "CIDR for public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_app_subnet_cidr_a" {
  description = "CIDR for private application subnet in AZ A"
  type        = string
  default     = "10.0.10.0/24"
}

variable "private_app_subnet_cidr_b" {
  description = "CIDR for private application subnet in AZ B"
  type        = string
  default     = "10.0.11.0/24"
}

variable "private_db_subnet_cidr_a" {
  description = "CIDR for private database subnet in AZ A"
  type        = string
  default     = "10.0.20.0/24"
}

variable "private_db_subnet_cidr_b" {
  description = "CIDR for private database subnet in AZ B"
  type        = string
  default     = "10.0.21.0/24"
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "db_parameter_group_family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = "postgres16"
}

variable "db_engine" {
  description = "Database engine (e.g., postgres, mysql, mariadb)"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Major version for the DB engine"
  type        = string
  default     = "16"
}

variable "db_port" {
  type    = number
  default = 5432
}