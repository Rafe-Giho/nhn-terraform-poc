variable "name_prefix" {
  description = "Name prefix."
  type        = string
}

variable "containers" {
  description = "Object Storage containers."
  type = map(object({
    name         = optional(string)
    versioning   = optional(bool, true)
    content_type = optional(string)
    metadata     = optional(map(string), {})
  }))
}

variable "metadata" {
  description = "Common metadata."
  type        = map(string)
  default     = {}
}

