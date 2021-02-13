resource "aws_ecr_repository" "client_notifications" {
  name                 = "client-notifications"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "kubernetes_service" "client_notifications" {
  metadata {
    name      = "client-notifications"
    namespace = kubernetes_namespace.admin.metadata[0].name

    labels = {
      app = "client-notifications"

      service = "client-notifications"
    }
  }

  spec {
    port {
      name     = "http"
      port     = 80
      protocol = "TCP"
    }

    selector = {
      app = "client-notifications"
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress" "client_notifications" {
  metadata {
    name      = "client-notifications"
    namespace = kubernetes_namespace.admin.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "notifications-${terraform.workspace}.${local.domain}"
      http {
        path {
          path = "/"
          backend {
            service_name = "client-notifications"
            service_port = "80"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_account" "client_notifications" {
  metadata {
    name      = "client-notifications"
    namespace = kubernetes_namespace.admin.metadata[0].name
  }
}

resource "kubernetes_deployment" "client_notifications" {
  metadata {
    name      = "client-notifications"
    namespace = kubernetes_namespace.admin.metadata[0].name

    labels = {
      app = "client-notifications"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "client-notifications"
      }
    }

    template {
      metadata {
        labels = {
          app = "client-notifications"
        }
      }

      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = "admin"
        }

        container {
          name              = "client-notifications"
          image             = "641854051393.dkr.ecr.us-west-2.amazonaws.com/client-notifications:latest"
          image_pull_policy = "Always"
          liveness_probe {
            http_get {
              path = "/"
              port = "80"
            }

            initial_delay_seconds = 60
            timeout_seconds       = 3
            period_seconds        = 3
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "80"
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
