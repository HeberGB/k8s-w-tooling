resource "helm_release" "grafana" {
  name = "monitoring"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = "kube-monitoring"

  values = [local.helm_chart_values]
}
