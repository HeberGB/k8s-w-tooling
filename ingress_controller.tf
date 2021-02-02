resource "helm_release" "ingress_controller" {
  name      = "ingress-controller"
  namespace = "kube-system"

  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "3.22.0"
  chart      = "ingress-nginx"

  values = [local.helm_chart_ingress_controller_values]
}
