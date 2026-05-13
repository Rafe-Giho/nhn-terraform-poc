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
    cidr = string
  }))
}

variable "distributed_routing" {
  description = "Routing table distributed mode."
  type        = bool
  default     = false
}

variable "internet_gateway_id" {
  description = "Existing Internet Gateway ID."
  type        = string
  default     = null
}

