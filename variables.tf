variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

variable "brand" {
  description = "Brand or company name"
}

variable "github_client_id" {
  description = "Github client id to oauth"
}

variable "github_client_secret" {
  description = "Github client secret to oauth"
}

variable "github_allowed_organizations" {
  description = "Github allowed organizations to oauth"
}

variable "smtp_host" {
  description = "SMTP host with port to send emails"
}


variable "smtp_user" {
  description = "SMTP email address to send emails"
}

variable "smtp_password" {
  description = "SMTP password to send emails"
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

locals {
  template_vars = {
    stage                        = terraform.workspace
    github_client_id             = var.github_client_id
    github_client_secret         = var.github_client_secret
    github_allowed_organizations = var.github_allowed_organizations
    smtp_host                    = var.smtp_host
    smtp_user                    = var.smtp_user
    smtp_password                = var.smtp_password
  }

  helm_chart_values = templatefile(
    "${path.module}/grafana_values.yaml",
    local.template_vars
  )
}
