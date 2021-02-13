resource "aws_ecr_repository" "ms_notifications" {
  name                 = "ms-notifications"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "kubernetes_service" "ms_notifications" {
  metadata {
    name      = "ms-notifications"
    namespace = kubernetes_namespace.admin.metadata[0].name

    labels = {
      app = "ms-notifications"

      service = "ms-notifications"
    }
  }

  spec {
    port {
      name        = "graphql"
      port        = 80
      target_port = var.app_api_port_server
      protocol    = "TCP"
    }

    port {
      name        = "grpc"
      port        = 9090
      target_port = var.app_grpc_port_server
      protocol    = "TCP"
    }

    selector = {
      app = "ms-notifications"
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress" "ms_notifications" {
  metadata {
    name      = "ms-notifications"
    namespace = kubernetes_namespace.admin.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "ms-notifications-${terraform.workspace}.${local.domain}"
      http {
        path {
          path = "/health"
          backend {
            service_name = "ms-notifications"
            service_port = "80"
          }
        }
        path {
          path = "/graphql"
          backend {
            service_name = "ms-notifications"
            service_port = "80"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_account" "ms_notifications" {
  metadata {
    name      = "ms-notifications"
    namespace = kubernetes_namespace.admin.metadata[0].name
  }
}

resource "kubernetes_deployment" "ms_notifications" {
  depends_on = [
    kubernetes_config_map.common,
    kubernetes_config_map.notifications,
    kubernetes_secret.mongodb,
    kubernetes_secret.aws,
  ]

  metadata {
    name      = "ms-notifications"
    namespace = kubernetes_namespace.admin.metadata[0].name

    labels = {
      app = "ms-notifications"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ms-notifications"
      }
    }

    template {
      metadata {
        labels = {
          app = "ms-notifications"
        }
      }

      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = "admin"
        }

        container {
          name  = "ms-notifications"
          image = "641854051393.dkr.ecr.us-west-2.amazonaws.com/ms-notifications:latest"

          env {
            name = "APP_PORT"

            value_from {
              config_map_key_ref {
                name = "common"
                key  = "api_port_server"
              }
            }
          }

          env {
            name = "GRPC_PORT"

            value_from {
              config_map_key_ref {
                name = "common"
                key  = "grpc_port_server"
              }
            }
          }

          env {
            name = "MONGO_URI"

            value_from {
              secret_key_ref {
                name = "mongodb"
                key  = "url_notifications"
              }
            }
          }

          env {
            name = "AWS_ACCESS_KEY_ID"

            value_from {
              secret_key_ref {
                name = "aws"
                key  = "access_key_id"
              }
            }
          }

          env {
            name = "AWS_SECRET_ACCESS_KEY"

            value_from {
              secret_key_ref {
                name = "aws"
                key  = "secret_access_key"
              }
            }
          }

          env {
            name = "AWS_REGION"

            value_from {
              secret_key_ref {
                name = "aws"
                key  = "region"
              }
            }
          }

          env {
            name = "EMAIL_FROM"

            value_from {
              config_map_key_ref {
                name = "notifications"
                key  = "email"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "5000"
            }

            initial_delay_seconds = 60
            timeout_seconds       = 3
            period_seconds        = 3
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "5000"
            }

            period_seconds    = 10
            success_threshold = 3
            failure_threshold = 6
          }
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "25%"
        max_surge       = "75%"
      }
    }
  }
}
