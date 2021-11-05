resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = var.app_name
    namespace = var.create_namespace ? kubernetes_namespace.cluster_autoscaler[0].metadata[0].name : var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.aws_role_arn
    }
  }
}

resource "kubernetes_cluster_role" "cluster_autoscaler" {
  metadata {
    name = "${kubernetes_service_account.cluster_autoscaler.metadata[0].name}-cluster-role-config"
  }

  rule {
    api_groups = [""]
    resources  = ["events", "endpoints"]
    verbs      = ["create", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/status"]
    verbs      = ["update"]
  }
  rule {
    api_groups     = [""]
    resources      = ["endpoints"]
    resource_names = ["${var.app_name}"]
    verbs          = ["get", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "services", "replicationcontrollers", "persistentvolumeclaims", "persistentvolumes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "patch", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets", "daemonsets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["replicasets", "daemonsets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "csinodes", "csidrivers", "csistoragecapacities"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create"]
  }
  rule {
    api_groups     = ["coordination.k8s.io"]
    resources      = ["leases"]
    resource_names = ["${var.app_name}"]
    verbs          = ["get", "update"]
  }
}
resource "kubernetes_cluster_role_binding" "cluster_autoscaler" {
  metadata {
    name = kubernetes_service_account.cluster_autoscaler.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_autoscaler.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cluster_autoscaler.metadata[0].name
    namespace = var.create_namespace ? kubernetes_namespace.cluster_autoscaler[0].metadata[0].name : var.namespace
  }
}


resource "kubernetes_cluster_role" "cluster_autoscaler_psp" {
  count = var.rbac_psp_enable ? 1 : 0

  metadata {
    name = "${kubernetes_service_account.cluster_autoscaler.metadata[0].name}-psp-cluster-role-config"
  }

  rule {
    api_groups     = ["extensions", "policy"]
    resources      = ["podsecuritypolicies"]
    resource_names = ["${var.app_name}"]
    verbs          = ["use"]
  }
}
resource "kubernetes_cluster_role_binding" "cluster_autoscaler_psp" {
  count = var.rbac_psp_enable ? 1 : 0

  metadata {
    name = kubernetes_service_account.cluster_autoscaler.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_autoscaler_psp[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cluster_autoscaler.metadata[0].name
    namespace = var.create_namespace ? kubernetes_namespace.cluster_autoscaler[0].metadata[0].name : var.namespace
  }
}


resource "kubernetes_role" "cluster_autoscaler" {
  metadata {
    name      = "${kubernetes_service_account.cluster_autoscaler.metadata[0].name}-role-config"
    namespace = var.create_namespace ? kubernetes_namespace.cluster_autoscaler[0].metadata[0].name : var.namespace
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create", "list", "watch"]
  }
  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
    verbs          = ["delete", "get", "update", "watch"]
  }
  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["cluster-autoscaler"]
    verbs          = ["get", "update"]
  }
}
resource "kubernetes_role_binding" "cluster_autoscaler" {
  metadata {
    name      = kubernetes_service_account.cluster_autoscaler.metadata[0].name
    namespace = var.create_namespace ? kubernetes_namespace.cluster_autoscaler[0].metadata[0].name : var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.cluster_autoscaler.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cluster_autoscaler.metadata[0].name
    namespace = var.create_namespace ? kubernetes_namespace.cluster_autoscaler[0].metadata[0].name : var.namespace
  }
}