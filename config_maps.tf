resource "kubernetes_config_map" "common" {
  for_each = toset([
    kubernetes_namespace.admin.metadata[0].name,
    kubernetes_namespace.ms_auth.metadata[0].name,
    kubernetes_namespace.ms_clients.metadata[0].name,
    kubernetes_namespace.gateway.metadata[0].name,
  ])

  metadata {
    name      = "common"
    namespace = each.value
  }

  data = {
    api_port_server  = var.app_api_port_server
    grpc_port_server = var.app_grpc_port_server
  }
}

resource "kubernetes_config_map" "notifications" {
  metadata {
    name      = "notifications"
    namespace = "admin"
  }

  data = {
    email = var.notifications_email
  }
}

resource "kubernetes_config_map" "typeorm" {
  for_each = toset([
    kubernetes_namespace.ms_auth.metadata[0].name,
    kubernetes_namespace.ms_clients.metadata[0].name,
  ])

  metadata {
    name      = "typeorm"
    namespace = each.value
  }

  data = {
    "connection"     = var.typeorm_connection
    "entities"       = var.typeorm_entities
    "migrations"     = var.typeorm_migrations
    "migrations_dir" = var.typeorm_migrations_dir
  }
}
