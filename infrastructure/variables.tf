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

variable "private_db_subnet_cidr_a" {
  description = "CIDR for private database subnet in AZ A"
  type        = string
  default     = "10.0.20.0/24"
}