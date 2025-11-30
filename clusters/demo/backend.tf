terraform {
  backend "s3" {
    bucket         = "salman-tf-state-bucket"
    key            = "demo/eks/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
