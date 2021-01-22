resource "kubernetes_service" "kibana" {
  metadata {
    name      = "kibana"
    namespace = "kube-logging"

    labels = {
      app = "kibana"
    }
  }

  spec {
    port {
      port = 5601
    }

    selector = {
      app = "kibana"
    }
  }
}

resource "kubernetes_deployment" "kibana" {
  metadata {
    name      = "kibana"
    namespace = "kube-logging"

    labels = {
      app = "kibana"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kibana"
      }
    }

    template {
      metadata {
        labels = {
          app = "kibana"
        }
      }

      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = "tools"
        }
        container {
          name  = "kibana"
          image = "docker.elastic.co/kibana/kibana:7.10.2"

          port {
            container_port = 5601
          }

          env {
            name  = "ELASTICSEARCH_URL"
            value = "http://elasticsearch:9200"
          }

          resources {
            limits {
              cpu = "1"
            }

            requests {
              cpu = "100m"
            }
          }
        }
      }
    }
  }
}

