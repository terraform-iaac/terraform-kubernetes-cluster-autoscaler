resource "kubernetes_namespace" "cluster_autoscaler" {
  count = var.create_namespace ? 1 : 0

  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "kubernetes_manifest" "service_monitoring" {
  count = var.service_monitor_enable ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"

    metadata = {
      name      = var.app_name
      namespace = var.metrics_namespace
      labels = {
        release = var.prometheus_release_label
      }
    }

    spec = {
      endpoints = [
        {
          port     = var.service_ports.0.name
          interval = "10s"
          path     = "/metrics"
        }
      ]
      namespaceSelector = {
        matchNames = [
          var.create_namespace ? kubernetes_namespace.cluster_autoscaler[0].metadata[0].name : var.namespace
        ]
      }
      selector = {
        matchLabels = {
          app = module.deploy.name
        }
      }
    }
  }
}
