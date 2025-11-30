terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.58"
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_irsa = true

  cluster_endpoint_public_access  = true   ### this should be false for production environment####
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs = [
  "142.112.179.154/32"
]
  cluster_enabled_log_types = var.enable_cluster_logs ? [
    "api",
    "audit",
    "authenticator",
  ] : []

  cloudwatch_log_group_retention_in_days = var.enable_cluster_logs ? 90 : null

  eks_managed_node_groups = {
    default = {
      instance_types = var.instance_types
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.desired_size
    }
  }
}
