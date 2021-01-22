resource "kubernetes_service" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = "kube-logging"

    labels = {
      app = "elasticsearch"
    }
  }

  spec {
    port {
      name = "rest"
      port = 9200
    }

    port {
      name = "inter-node"
      port = 9300
    }

    selector = {
      app = "elasticsearch"
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_stateful_set" "es_cluster" {
  metadata {
    name      = "es-cluster"
    namespace = "kube-logging"
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "elasticsearch"
      }
    }

    template {
      metadata {
        labels = {
          app = "elasticsearch"
        }
      }

      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = "tools"
        }
        init_container {
          name    = "fix-permissions"
          image   = "busybox"
          command = ["sh", "-c", "chown -R 1000:1000 /usr/share/elasticsearch/data"]

          volume_mount {
            name       = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }

          security_context {
            privileged = true
          }
        }

        init_container {
          name    = "increase-vm-max-map"
          image   = "busybox"
          command = ["sysctl", "-w", "vm.max_map_count=262144"]

          security_context {
            privileged = true
          }
        }

        init_container {
          name    = "increase-fd-ulimit"
          image   = "busybox"
          command = ["sh", "-c", "ulimit -n 65536"]

          security_context {
            privileged = true
          }
        }

        container {
          name  = "elasticsearch"
          image = "docker.elastic.co/elasticsearch/elasticsearch:7.10.2"

          port {
            name           = "rest"
            container_port = 9200
            protocol       = "TCP"
          }

          port {
            name           = "inter-node"
            container_port = 9300
            protocol       = "TCP"
          }

          env {
            name  = "cluster.name"
            value = "k8s-logs"
          }

          env {
            name = "node.name"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name  = "discovery.seed_hosts"
            value = "es-cluster-0.elasticsearch,es-cluster-1.elasticsearch,es-cluster-2.elasticsearch"
          }

          env {
            name  = "cluster.initial_master_nodes"
            value = "es-cluster-0,es-cluster-1,es-cluster-2"
          }

          env {
            name  = "ES_JAVA_OPTS"
            value = "-Xms512m -Xmx512m"
          }

          resources {
            limits {
              cpu = "1"
            }

            requests {
              cpu = "100m"
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "data"

        labels = {
          app = "elasticsearch"
        }
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "100Gi"
          }
        }

        storage_class_name = "gp2"
      }
    }

    service_name = "elasticsearch"
  }
}

