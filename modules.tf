module "deploy" {
  source  = "terraform-iaac/deployment/kubernetes"
  version = "1.1.5"

  name          = var.app_name
  namespace     =  var.create_namespace ? kubernetes_namespace.cluster_autoscaler[0].metadata[0].name : var.namespace
  image         = var.docker_image
  internal_port = var.service_ports

  command = concat([
    "./cluster-autoscaler",
    "--cloud-provider=${var.cloud_provider}",
    "--namespace=${kubernetes_namespace.cluster_autoscaler.metadata[0].name}",
    "--node-group-auto-discovery=asg:tag=k8s.io/${var.app_name}/enabled,k8s.io/${var.app_name}/${var.cluster_name}",
  ],var.additional_deployment_commands)

  env = [
    {
      name  = "AWS_REGION"
      value = var.aws_region
    }
  ]
  resources = var.resources

  service_account_name  = kubernetes_service_account.cluster_autoscaler.metadata[0].name
  service_account_token = true

  liveness_probe = [
    {
      http_get = [
        {
          path = "/health-check"
          port = var.service_ports.0.internal_port
        }
      ]
      initial_delay_seconds = 10
      period_seconds        = 10
      timeout_seconds       = 120
    }
  ]

  node_selector = var.node_selector
}
