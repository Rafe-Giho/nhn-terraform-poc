variable "name_prefix" {
  description = "Name prefix."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR."
  type        = string
}

variable "subnets" {
  description = "Subnet map."
  type = map(object({
    cidr              = string
    routing_table_key = optional(string)
  }))
}

variable "routing_tables" {
  description = "Routing table map. Attach an Internet Gateway only to public route tables."
  type = map(object({
    name                = optional(string)
    distributed         = optional(bool, false)
    internet_gateway_id = optional(string)
  }))
  default = {
    private = {}
  }
}

variable "default_routing_table_key" {
  description = "Routing table key used when a subnet does not specify routing_table_key."
  type        = string
  default     = "private"

  validation {
    condition     = length(var.default_routing_table_key) > 0
    error_message = "default_routing_table_key must not be empty."
  }
}
