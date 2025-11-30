terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.58"
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = var.name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.environment
    Name        = var.name
  }
}
