resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "kube-monitoring"
    }
    name = "kube-monitoring"
  }
}