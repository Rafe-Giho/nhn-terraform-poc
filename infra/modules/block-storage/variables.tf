variable "volumes" {
  description = "Block storage volumes keyed by logical name."
  type = map(object({
    name              = string
    size              = number
    description       = optional(string)
    availability_zone = optional(string)
    volume_type       = optional(string, "General HDD")
    snapshot_id       = optional(string)
  }))
  default = {}
}

variable "instance_ids" {
  description = "Instance IDs keyed by logical name."
  type        = map(string)
  default     = {}
}

variable "attachments" {
  description = "Volume attachments keyed by logical name."
  type = map(object({
    volume_key   = string
    instance_key = string
  }))
  default = {}
}
