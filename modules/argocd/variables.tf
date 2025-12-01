variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_data" {
  type = string
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access ArgoCD UI"
  type        = string
}