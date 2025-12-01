module "vpc" {
  source = "../../modules/vpc"

  name        = "devops-demo-vpc"
  environment = "demo"
  vpc_cidr    = "10.10.0.0/16"

  azs             = ["ca-central-1a", "ca-central-1b"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets  = ["10.10.101.0/24", "10.10.102.0/24"]
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = "devops-demo-eks"
  cluster_version = "1.30"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  instance_types = ["t3.small"]
  min_size       = 1
  max_size       = 3
  desired_size   = 2
  admin_iam_arn = "arn:aws:iam::048753696790:user/admin-user-cli"
  allowed_cidr  = "142.112.179.154/32"
}

variable "enable_argocd" {
  description = "Flag to enable ArgoCD deployment"
  type        = bool
  default     = false
}

module "argocd" {
  source = "../../modules/argocd"
  count  = var.enable_argocd ? 1 : 0

  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_data  = module.eks.cluster_certificate_authority_data
  namespace        = "argocd"
  allowed_cidr     = "142.112.179.154/32"

  depends_on = [module.eks]
}