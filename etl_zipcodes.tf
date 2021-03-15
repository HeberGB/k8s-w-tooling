resource "aws_ecr_repository" "etl_zipcodes" {
  name                 = "etl-zipcodes"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "kubernetes_job" "etl_zipcodes" {
  metadata {
    name      = "etl-zipcodes"
    namespace = kubernetes_namespace.ms_clients.metadata[0].name
  }

  spec {
    backoff_limit = 0

    template {
      metadata {
        labels = {
          app = "ms-clients"
        }
      }

      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = "admin"
        }

        container {
          name  = "etl"
          image = "641854051393.dkr.ecr.us-west-2.amazonaws.com/etl-zipcodes:latest"

          env {
            name = "URI_DB_ZIPCODES"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_ms_clients["ms-clients"].metadata[0].name
                key  = "uri"
              }
            }
          }
        }

        restart_policy = "Never"
      }
    }
  }
}
