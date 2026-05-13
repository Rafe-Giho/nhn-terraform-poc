locals {
  common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
    "nhncloud.io/project"          = var.project_prefix
    "nhncloud.io/environment"      = var.environment
  }

  base_helm_releases = merge(
    var.enable_cert_manager ? {
      cert_manager = {
        name       = "cert-manager"
        namespace  = "cert-manager"
        repository = "https://charts.jetstack.io"
        chart      = "cert-manager"
        version    = "v1.16.2"
        values = [
          yamlencode({
            crds = {
              enabled = true
            }
          })
        ]
      }
    } : {},
    var.enable_argocd ? {
      argocd = {
        name       = "argocd"
        namespace  = "argocd"
        repository = "https://argoproj.github.io/argo-helm"
        chart      = "argo-cd"
        version    = "7.7.16"
        values = [
          yamlencode({
            server = {
              service = {
                type = "ClusterIP"
              }
            }
          })
        ]
      }
    } : {}
  )
}

module "platform" {
  source = "../../modules/k8s-platform"

  namespaces       = var.namespaces
  namespace_labels = local.common_labels
  common_labels    = local.common_labels
  storage_classes  = var.storage_classes
  helm_releases    = merge(local.base_helm_releases, var.extra_helm_releases)
}

