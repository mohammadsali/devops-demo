variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.30"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "enable_cluster_logs" {
  type    = bool
  default = true
}

variable "admin_iam_arn" {
  description = "IAM user or role ARN to grant EKS admin access"
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR allowed to access EKS public API"
  type        = string
}
