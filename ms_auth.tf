resource "aws_ecr_repository" "ms_auth" {
  name                 = "ms-auth"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "helm_release" "ms_auth_postgresql" {
  depends_on = [
    module.eks.node_groups
  ]

  name = "ms-auth-postgresql"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.ms_auth.metadata[0].name

  values = [local.helm_chart_ms_auth_postgresql_values]
}



resource "kubernetes_service" "ms_auth" {
  metadata {
    name      = "ms-auth"
    namespace = kubernetes_namespace.ms_auth.metadata[0].name

    labels = {
      app = "ms-auth"

      service = "ms-auth"
    }
  }

  spec {
    port {
      name        = "graphql"
      port        = 80
      target_port = var.app_api_port_server
      protocol    = "TCP"
    }

    selector = {
      app = "ms-auth"
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress" "ms_auth" {
  metadata {
    name      = "ms-auth"
    namespace = kubernetes_namespace.ms_auth.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "ms-auth-${terraform.workspace}.${local.domain}"
      http {
        path {
          path = "/"
          backend {
            service_name = "ms-auth"
            service_port = "80"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_account" "ms_auth" {
  metadata {
    name      = "ms-auth"
    namespace = kubernetes_namespace.ms_auth.metadata[0].name
  }
}

resource "kubernetes_deployment" "ms_auth" {
  metadata {
    name      = "ms-auth"
    namespace = kubernetes_namespace.ms_auth.metadata[0].name

    labels = {
      app = "ms-auth"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ms-auth"
      }
    }

    template {
      metadata {
        labels = {
          app = "ms-auth"
        }
      }

      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = "admin"
        }

        container {
          name  = "ms-auth"
          image = "641854051393.dkr.ecr.us-west-2.amazonaws.com/ms-auth:latest"

          env {
            name = "APP_PORT"

            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.common["ms-auth"].metadata[0].name
                key  = "api_port_server"
              }
            }
          }

          env {
            name = "APP_TOKEN_SIGN"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.auth["ms-auth"].metadata[0].name
                key  = "app_token_sign"
              }
            }
          }

          env {
            name = "APP_TOKEN_TTL"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.auth["ms-auth"].metadata[0].name
                key  = "app_token_ttl"
              }
            }
          }

          env {
            name = "APP_REFRESH_TOKEN_LENGTH"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.auth["ms-auth"].metadata[0].name
                key  = "app_refresh_token_length"
              }
            }
          }

          env {
            name = "APP_REFRESH_TOKEN_TTL"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.auth["ms-auth"].metadata[0].name
                key  = "app_refresh_token_ttl"
              }
            }
          }

          env {
            name  = "TYPEORM_HOST"
            value = "${helm_release.ms_auth_postgresql.name}.${helm_release.ms_auth_postgresql.namespace}.svc.cluster.local"
          }

          env {
            name  = "TYPEORM_PORT"
            value = 5432
          }

          env {
            name = "TYPEORM_DATABASE"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql["ms-auth"].metadata[0].name
                key  = "database"
              }
            }
          }

          env {
            name = "TYPEORM_USERNAME"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql["ms-auth"].metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "TYPEORM_PASSWORD"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql["ms-auth"].metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name = "TYPEORM_CONNECTION"

            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.typeorm["ms-auth"].metadata[0].name
                key  = "connection"
              }
            }
          }

          env {
            name = "TYPEORM_MIGRATIONS"

            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.typeorm["ms-auth"].metadata[0].name
                key  = "migrations"
              }
            }
          }

          env {
            name = "TYPEORM_MIGRATIONS_DIR"

            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.typeorm["ms-auth"].metadata[0].name
                key  = "migrations_dir"
              }
            }
          }

          env {
            name = "TYPEORM_ENTITIES"

            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.typeorm["ms-auth"].metadata[0].name
                key  = "entities"
              }
            }
          }

          env {
            name = "REDIS_HOST"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.redis["ms-auth"].metadata[0].name
                key  = "host"
              }
            }
          }

          env {
            name = "REDIS_PORT"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.redis["ms-auth"].metadata[0].name
                key  = "port"
              }
            }
          }

          env {
            name = "REDIS_PASSWORD"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.redis["ms-auth"].metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name = "RANDOM_PASSWORD_LENGTH"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.auth["ms-auth"].metadata[0].name
                key  = "random_password_length"
              }
            }
          }

          env {
            name = "RANDOM_PIN_LENGTH"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.auth["ms-auth"].metadata[0].name
                key  = "random_pin_length"
              }
            }
          }

          env {
            name = "LOGIN_RETRIES"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.auth["ms-auth"].metadata[0].name
                key  = "login_retries"
              }
            }
          }

          env {
            name  = "GRPC_URL_NOTIFICATIONS"
            value = "${kubernetes_service.ms_notifications.metadata[0].name}.${kubernetes_service.ms_notifications.metadata[0].namespace}.svc.cluster.local:9090"
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
