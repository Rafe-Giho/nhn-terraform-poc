variable "cluster" {
  description = "NKS cluster configuration."
  type = object({
    name                = string
    cluster_template_id = optional(string, "iaas_console")
    fixed_network       = string
    fixed_subnet        = string
    flavor_id           = string
    keypair             = string
    node_count          = optional(number, 1)
    labels              = map(string)
    addons = list(object({
      name    = string
      version = string
      options = optional(map(string), {})
    }))
  })
}

variable "nodegroups" {
  description = "Additional NKS node groups."
  type = map(object({
    name       = string
    node_count = optional(number, 1)
    flavor_id  = string
    image_id   = string
    version    = optional(string)
    labels     = map(string)
  }))
  default = {}
}
