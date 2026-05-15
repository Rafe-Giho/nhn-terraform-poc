variable "security_groups" {
  description = "Security groups and rules."
  type = map(object({
    name = string
    rules = list(object({
      direction        = string
      ethertype        = optional(string, "IPv4")
      protocol         = optional(string)
      port_range_min   = optional(number)
      port_range_max   = optional(number)
      remote_ip_prefix = optional(string)
      remote_group_id  = optional(string)
      description      = optional(string)
    }))
  }))
}

