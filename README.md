# Kubernetes Cluster Autoscaler for AWS EKS

Terraform module for deploy Cluster Autoscaler for AWS EKS to your kubernetes cluster.

## Wokrflow

This module creates all necessary resources for deploy AWS Cluster Autoscale inside your kubernetes cluster. It helps you to manage your EKS cluster node size (as EC2 Auto Scaling Group) based on internal kubernetes metrics.
Also, optional (default ***false***), you can enable instance autoscaling using prometheus metrics.

## Software Requirements

Name | Description
--- | --- |
Terraform | >= 0.14.9
Kubernetes provider | >= 1.11.1

## Usage

```
module "cluster_autoscaler" {
  source = "../"

  aws_region   = "us-west-1"
  cluster_name = "my-EKS-cluster-name"

  // Optional
  resources = {
    request_cpu    = "150m"
    request_memory = "600Mi"
  }
}
```
### Note: If you want to use other metrics, please set 'service_monitor_enable' to true and set namespace where your monitoring system deployed:

     additional_deployment_commands = [
        "--balance-similar-node-groups=true",
        "--skip-nodes-with-local-storage=false"
     ]

### You can add additional Cluster Autoscaler container arguments via 'additional_deployment_commands'. See all possible args in official [Cluster Autoscaler docs](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-the-parameters-to-ca):

     service_monitor_enable = true
     metrics_namespace      = "monitoring-prometheus"

## Inputs

Name | Description | Type | Default | Example | Required
--- | --- | --- | --- |--- |--- 
cloud_provider | Cloud Provier name (support only 'aws') | `string` | `aws` | n/a | no
aws_region | Region where EKS deployed | `string` | n/a | `us-east-1` | yes |
aws_role_arn | AWS role for Cluster Autoscaler | `string` | `null` | `arn:aws:iam::123456789:role/eks-oidc-cluster-autoscaler` | no
app_name | Name of Cluster Autoscaler | `string` | `cluster-autoscaler` | n/a | no
namespace | Name of kubernetes namespace for cluster autoscaler | `string` | `cluster-autoscaler` | n/a | no
create_namespace | Create namespace by module ? true or false | `bool` | `true` | n/a | no
cluster_name | EKS cluster name | `string` | n/a | `my-EKS-cluste-name` | yes
node_selector | Choose node where you want to deploy Cluster Autoscaler | `map(string)` | `null` | <pre>{<br>   spot_node_pool    = true<br>   service_node_pool = false<br>}</pre> | no
service_monitor_enable | Enable Service Monitor? If true set variable 'metrics_namespace' | `bool` | `false` | n/a | no |
metrics_namespace |Namespace where metrics collector (such as Prometheus) deployed | `string` | `null` | `monitoring` | no
rbac_psp_enable | Enable Pod Security Policies (PSP) | `bool` | `false` | n/a | no
docker_image | Image for cluster autoscaler | `string` | `k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.1` | n/a | no
additional_deployment_commands | Your additional args to Cluster Autoscaler deployment | `list(string)` | `[]` | <pre>[<br>   "--balance-similar-node-groups=true",<br>   "--skip-nodes-with-local-storage=false"<br>]</pre>  | no
service_ports | Ports for auth request from ingress to service | <pre>list(object({<br>    name  = string<br>    internal_port = string<br>    external_port = string<br>}))</pre> | <pre>[<br>  {<br>    name          = "http"<br>    internal_port = "http"<br>    external_port = "http"<br>  }<br>] | n/a | no
resources | Your Cluster Autoscaler deployment limits | `map(string)` | <pre>{<br>   request_cpu    = "100m"<br>   request_memory = "300Mi"<br>} | n/a | no

## Outputs
Name | Description
--- | --- 
name | Name of Cluster Autoscaler
namespace | Name of namespace where Cluster Autoscaler deployed
service_account_name | Name of Cluster Autoscaler service account

