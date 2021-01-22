resource "kubernetes_namespace" "logging" {
  metadata {
    annotations = {
      name = "kube-logging"
    }
    name = "kube-logging"
  }
}
