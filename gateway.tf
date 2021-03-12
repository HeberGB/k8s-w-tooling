resource "aws_ecr_repository" "gateway" {
  name                 = "gateway"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "kubernetes_service" "gateway" {
  metadata {
    name      = "gateway"
    namespace = kubernetes_namespace.gateway.metadata[0].name

    labels = {
      app = "gateway"

      service = "gateway"
    }
  }

  spec {
    port {
      port        = 80
      target_port = var.app_api_port_server
      protocol    = "TCP"
    }

    selector = {
      app = "gateway"
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress" "gateway" {
  metadata {
    name      = "gateway"
    namespace = kubernetes_namespace.gateway.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "${local.gateway_subdomain}.cclos.mx"

      http {
        path {
          path = "/"

          backend {
            service_name = "gateway"
            service_port = "80"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_account" "gateway" {
  metadata {
    name      = "gateway"
    namespace = kubernetes_namespace.gateway.metadata[0].name
  }
}

resource "kubernetes_deployment" "gateway" {
  metadata {
    name      = "gateway"
    namespace = kubernetes_namespace.gateway.metadata[0].name

    labels = {
      app = "gateway"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "gateway"
      }
    }

    template {
      metadata {
        labels = {
          app = "gateway"
        }
      }

      spec {
        node_selector = {
          "purpose" = "admin"
        }

        container {
          name  = "gateway"
          image = "641854051393.dkr.ecr.us-west-2.amazonaws.com/gateway:latest"

          port {
            container_port = 5000
            protocol       = "TCP"
          }

          env {
            name = "APP_PORT"

            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.common["gateway"].metadata[0].name
                key  = "api_port_server"
              }
            }
          }

          env {
            name  = "PLAYGROUND"
            value = "true"
          }

          env {
            name = "APP_TOKEN_SIGN"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.auth["gateway"].metadata[0].name
                key  = "app_token_sign"
              }
            }
          }

          env {
            name = "APP_TOKEN_TTL"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.auth["gateway"].metadata[0].name
                key  = "app_token_ttl"
              }
            }
          }

          env {
            name  = "MS_AUTH_URL"
            value = "http://${kubernetes_service.ms_auth.metadata[0].name}.${kubernetes_service.ms_auth.metadata[0].namespace}.svc.cluster.local/graphql"
          }

          env {
            name  = "MS_CLIENTS_URL"
            value = "http://${kubernetes_service.ms_clients.metadata[0].name}.${kubernetes_service.ms_clients.metadata[0].namespace}.svc.cluster.local/graphql"
          }

          liveness_probe {
            http_get {
              path = "/.well-known/apollo/server-health"
              port = "5000"
            }

            initial_delay_seconds = 60
            timeout_seconds       = 3
            period_seconds        = 3
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/.well-known/apollo/server-health"
              port = "5000"
            }

            period_seconds    = 10
            success_threshold = 3
            failure_threshold = 6
          }

          image_pull_policy = "Always"
        }

        service_account_name = kubernetes_service_account.gateway.metadata[0].name
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
