resource "kubernetes_config_map" "common" {
  metadata {
    name      = "common"
    namespace = "admin"
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
