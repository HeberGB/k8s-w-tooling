variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

variable "brand" {
  description = "Brand or company name"
}

locals {
  cluster_name = "eks-${var.brand}-${terraform.workspace}"
}

locals {
  vpc_name = "vpc-${local.cluster_name}"
}

locals {
  ng_role_name = "ng-role-${local.cluster_name}"
}
