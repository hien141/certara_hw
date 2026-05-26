# This root file is the live example consuming our custom VPC module
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1" # Swap this out to whichever region you want to build in
}

# Declaring and passing variables into the child module
module "network" {
  source = "./modules/vpc"

  environment          = "certara-dev"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}

# Consuming an output from the module to prove it compiles successfully
output "vpc_id" {
  value = module.network.vpc_id
  description = "The ID of the VPC created by the module"
}
