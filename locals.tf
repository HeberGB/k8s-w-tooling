
locals {
  cluster_name = "eks-${var.brand}-${terraform.workspace}"

  vpc_name = "vpc-${local.cluster_name}"

  ng_role_name = "ng-role-${local.cluster_name}"

  template_vars_grafana = {
    stage                        = terraform.workspace
    aws_ssl_cert_arn             = var.aws_ssl_cert_arn
    github_client_id             = var.github_client_id
    github_client_secret         = var.github_client_secret
    github_allowed_organizations = var.github_allowed_organizations
    smtp_host                    = var.smtp_host
    smtp_user                    = var.smtp_user
    smtp_password                = var.smtp_password
  }

  helm_chart_grafana_values = templatefile(
    "${path.module}/grafana_values.yaml",
    local.template_vars_grafana
  )
}
