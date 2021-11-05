module "cluster_autoscaler" {
  source = "../"

  aws_region   = "us-west-1"
  cluster_name = "my-EKS-cluster-name"

  // Optional
  additional_deployment_commands = [
    "--balance-similar-node-groups=true",
    "--skip-nodes-with-local-storage=false"
  ]
  service_monitor_enable = true
  metrics_namespace      = "monitoring-prometheus"

  resources = {
    request_cpu    = "150m"
    request_memory = "600Mi"
  }
}