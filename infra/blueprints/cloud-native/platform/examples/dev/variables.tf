variable "kubeconfig_path" {
  description = "Path to the NKS kubeconfig file."
  type        = string
}

variable "kubeconfig_context" {
  description = "Optional kubeconfig context."
  type        = string
  default     = null
}

variable "project_prefix" {
  description = "Project prefix."
  type        = string
  default     = "nhn-poc"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "namespaces" {
  description = "Platform namespaces."
  type        = set(string)
  default = [
    "argocd",
    "cert-manager",
    "cicd",
    "apps",
    "observability",
    "ingress-system"
  ]
}

variable "enable_argocd" {
  description = "Install Argo CD with Helm."
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Install cert-manager with Helm."
  type        = bool
  default     = true
}

variable "storage_classes" {
  description = "StorageClasses for NKS."
  type = map(object({
    name                   = optional(string)
    storage_provisioner    = string
    reclaim_policy         = optional(string, "Retain")
    volume_binding_mode    = optional(string, "Immediate")
    allow_volume_expansion = optional(bool, false)
    parameters             = optional(map(string), {})
    labels                 = optional(map(string), {})
    annotations            = optional(map(string), {})
  }))
  default = {
    cinder_hdd = {
      name                = "nhn-cinder-hdd-retain"
      storage_provisioner = "cinder.csi.openstack.org"
      reclaim_policy      = "Retain"
      volume_binding_mode = "Immediate"
      parameters = {
        type = "General HDD"
      }
    }
  }
}

variable "extra_helm_releases" {
  description = "Additional Helm releases. Use this for GitLab Runner, Tekton, NGINX Gateway, monitoring, etc."
  type = map(object({
    name       = optional(string)
    namespace  = string
    repository = string
    chart      = string
    version    = optional(string)
    values     = optional(list(string), [])
    set        = optional(map(string), {})
    wait       = optional(bool, true)
    timeout    = optional(number, 600)
  }))
  default = {}
}

