
locals {
  cluster_name = "eks-${var.brand}-${terraform.workspace}"

  vpc_name = "vpc-${local.cluster_name}"

  ng_role_name = "ng-role-${local.cluster_name}"

  domain = "${var.brand}.mx"

  template_vars_grafana = {
    domain        = local.domain
    stage         = terraform.workspace
    smtp_host     = var.smtp_host
    smtp_user     = var.smtp_user
    smtp_password = var.smtp_password
  }

  helm_chart_grafana_values = templatefile(
    "${path.module}/grafana_values.yaml",
    local.template_vars_grafana
  )

  template_vars_ingress_controller = {
    aws_ssl_cert_arn = var.aws_ssl_cert_arn
  }

  helm_chart_ingress_controller_values = templatefile(
    "${path.module}/ingress-values.yaml",
    local.template_vars_ingress_controller
  )

  template_vars_ms_auth_postgresql = {
    "username" = var.postgresql_auth_username
    "database" = var.postgresql_auth_database
    "password" = var.postgresql_auth_password
  }

  helm_chart_ms_auth_postgresql_values = templatefile(
    "${path.module}/ms-auth-postgresql-values.yaml",
    local.template_vars_ms_auth_postgresql
  )

  template_vars_ms_clients_postgresql = {
    "username" = var.postgresql_clients_username
    "database" = var.postgresql_clients_database
    "password" = var.postgresql_clients_password
  }

  helm_chart_ms_clients_postgresql_values = templatefile(
    "${path.module}/ms-clients-postgresql-values.yaml",
    local.template_vars_ms_clients_postgresql
  )

  gateway_subdomain = terraform.workspace == "production" ? "gateway" : "gateway-${terraform.workspace}"
}
