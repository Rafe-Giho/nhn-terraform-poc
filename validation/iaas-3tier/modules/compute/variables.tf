variable "instances" {
  description = "Compute instances keyed by logical name."
  type = map(object({
    name                          = string
    flavor_id                     = string
    key_pair                      = optional(string)
    availability_zone             = optional(string)
    network_id                    = string
    subnet_id                     = optional(string)
    fixed_ip_v4                   = optional(string)
    security_groups               = optional(list(string), [])
    user_data_base64              = optional(string)
    boot_image_id                 = string
    boot_volume_size              = optional(number, 30)
    boot_destination_type         = optional(string, "volume")
    boot_delete_on_termination    = optional(bool, true)
    boot_block_device_source_type = optional(string, "image")
  }))
}
