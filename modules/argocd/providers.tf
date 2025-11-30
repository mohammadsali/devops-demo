terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.58"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}