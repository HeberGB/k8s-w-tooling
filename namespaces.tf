resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "kube-monitoring"
    }
    name = "kube-monitoring"
  }
}

resource "kubernetes_namespace" "admin" {
  metadata {
    annotations = {
      name = "admin"
    }
    name = "admin"
  }
}
