variable "namespaces" {
  description = "Namespaces to create."
  type        = set(string)
}

variable "namespace_labels" {
  description = "Labels applied to every namespace."
  type        = map(string)
  default     = {}
}

variable "common_labels" {
  description = "Common Kubernetes labels."
  type        = map(string)
  default     = {}
}

variable "storage_classes" {
  description = "Kubernetes StorageClasses."
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
  default = {}
}

variable "helm_releases" {
  description = "Helm releases for platform addons."
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

