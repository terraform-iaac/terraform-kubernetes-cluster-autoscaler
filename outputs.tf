output "name" {
  value = module.deploy.name
}
output "namespace" {
  value = var.create_namespace ? kubernetes_namespace.cluster_autoscaler[0].metadata[0].name : var.namespace
}
output "service_account_name" {
  value = kubernetes_service_account.cluster_autoscaler.metadata[0].name
}