variable "load_balancers" {
  description = "Load balancers keyed by logical name."
  type = map(object({
    name               = string
    description        = optional(string)
    vip_subnet_id      = string
    vip_address        = optional(string)
    security_group_ids = optional(list(string), [])
    admin_state_up     = optional(bool, true)
    loadbalancer_type  = optional(string, "shared")
  }))
  default = {}
}

variable "listeners" {
  description = "Listeners keyed by logical name."
  type = map(object({
    name                      = string
    description               = optional(string)
    load_balancer_key         = string
    protocol                  = string
    protocol_port             = number
    connection_limit          = optional(number)
    timeout_client_data       = optional(number)
    timeout_member_connect    = optional(number)
    timeout_member_data       = optional(number)
    timeout_tcp_inspect       = optional(number)
    default_tls_container_ref = optional(string)
    sni_container_refs        = optional(list(string))
    admin_state_up            = optional(bool, true)
    keepalive_timeout         = optional(number)
  }))
  default = {}
}

variable "pools" {
  description = "Pools keyed by logical name."
  type = map(object({
    name           = string
    description    = optional(string)
    listener_key   = string
    protocol       = string
    lb_method      = string
    member_port    = optional(number)
    admin_state_up = optional(bool, true)
    persistence = optional(object({
      type        = string
      cookie_name = optional(string)
    }))
  }))
  default = {}
}

variable "members" {
  description = "Pool members keyed by logical name."
  type = map(object({
    pool_key       = string
    subnet_id      = string
    address        = string
    protocol_port  = number
    weight         = optional(number, 1)
    admin_state_up = optional(bool, true)
  }))
  default = {}
}

variable "monitors" {
  description = "Health monitors keyed by logical name."
  type = map(object({
    name              = string
    pool_key          = string
    type              = string
    delay             = number
    timeout           = number
    max_retries       = number
    url_path          = optional(string)
    http_method       = optional(string)
    expected_codes    = optional(string)
    admin_state_up    = optional(bool, true)
    host_header       = optional(string)
    health_check_port = optional(number)
  }))
  default = {}
}
