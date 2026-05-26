variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "environment" {
  type        = string
  description = "Environment name for tagging (e.g., dev, prod)"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of 2 CIDR blocks for the public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of 2 CIDR blocks for the private subnets"
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}
