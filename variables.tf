variable "cloud_provider" {
  description = "Cloud Provier name (support only 'aws')"
  default     = "aws"
}
variable "aws_region" {
  description = "Region where EKS deployed"
}
variable "aws_role_arn" {
  description = "AWS role for Cluster Autoscaler"
  default     = null
}

variable "app_name" {
  description = "Name of Cluster Autoscaler"
  default     = "cluster-autoscaler"
}
variable "create_namespace" {
  description = "Create namespace by module ? true or false"
  type        = bool
  default     = true
}
variable "namespace" {
  description = "Name of kubernetes namespace for cluster autoscaler"
  default     = "cluster-autoscaler"
}
variable "cluster_name" {
  description = "EKS cluster name"
}
variable "node_selector" {
  description = "Choose node where you want to deploy Cluster Autoscaler"
  type        = map(string)
  default     = null
}

variable "service_monitor_enable" {
  description = "Enable Service Monitor? If true set variable 'metrics_namespace'"
  type        = bool
  default     = false
}
variable "metrics_namespace" {
  description = "Namespace where metrics collector (such as Prometheus) is deployed"
  default     = null
}
variable "prometheus_release_label" {
  description = "Prometheus release label ( typically name of helm chart )"
  type        = string
  default     = "kube-prometheus-stack"
}
variable "rbac_psp_enable" {
  description = "Enable Pod Security Policies (PSP)"
  type        = bool
  default     = false
}

variable "docker_image_registry" {
  description = "Image registry for cluster autoscaler"
  default     = "k8s.gcr.io/autoscaling/cluster-autoscaler"
}
variable "docker_image_tag" {
  description = "Image tag for cluster autoscaler"
  default     = "v1.21.1"
}
variable "additional_deployment_commands" {
  type        = list(string)
  description = "Your additional args to Cluster Autoscaler deployment (see Autoscaler docks: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-the-parameters-to-ca)"
  default     = []
}
variable "service_ports" {
  description = "Ports for auth request from ingress to service"
  default = [
    {
      name          = "http"
      internal_port = "8085"
      external_port = "8085"
    }
  ]
}
variable "resources" {
  description = "Your Cluster Autoscaler deployment limits"
  default = {
    request_cpu    = "100m"
    request_memory = "300Mi"
  }
}