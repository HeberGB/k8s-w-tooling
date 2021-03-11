resource "kubernetes_secret" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = "admin"
  }

  data = {
    "url_notifications" = var.mongodb_url_notifications
  }
}

resource "kubernetes_secret" "aws" {
  metadata {
    name      = "aws"
    namespace = "admin"
  }

  data = {
    "access_key_id"     = var.aws_access_key_id
    "secret_access_key" = var.aws_secret_access_key
    "region"            = var.region
  }
}

resource "kubernetes_secret" "auth" {
  for_each = toset([
    kubernetes_namespace.ms_auth.metadata[0].name,
  ])

  metadata {
    name      = "auth"
    namespace = each.value
  }

  data = {
    "jwt_secret"               = var.auth_jwt_secret
    "app_token_sign"           = var.auth_app_token_sign
    "app_token_ttl"            = var.auth_app_token_ttl
    "app_refresh_token_length" = var.auth_app_refresh_token_length
    "app_refresh_token_ttl"    = var.auth_app_refresh_token_ttl
    "random_password_length"   = var.auth_random_password_length
    "random_pin_length"        = var.auth_random_pin_length
    "login_retries"            = var.auth_login_retries
  }
}

resource "kubernetes_secret" "postgresql" {
  for_each = toset([
    kubernetes_namespace.ms_auth.metadata[0].name,
  ])

  metadata {
    name      = "postgresql"
    namespace = each.value
  }

  data = {
    "root_password"        = var.postgresql_auth_root_password
    "username"             = var.postgresql_auth_username
    "database"             = var.postgresql_auth_database
    "password"             = var.postgresql_auth_password
    "replication_password" = var.postgresql_auth_replication_password
  }
}

resource "kubernetes_secret" "redis" {
  for_each = toset([
    kubernetes_namespace.ms_auth.metadata[0].name,
  ])

  metadata {
    name      = "redis"
    namespace = each.value
  }

  data = {
    "host"     = var.redis_auth_host_password
    "port"     = var.redis_auth_port
    "password" = var.redis_auth_password
  }
}
