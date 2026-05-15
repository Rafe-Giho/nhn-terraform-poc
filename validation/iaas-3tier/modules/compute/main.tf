resource "nhncloud_networking_port_v2" "this" {
  for_each = {
    for key, instance in var.instances : key => instance
    if try(instance.subnet_id, null) != null
  }

  name           = "${each.value.name}-port"
  network_id     = each.value.network_id
  admin_state_up = true

  fixed_ip {
    subnet_id  = each.value.subnet_id
    ip_address = try(each.value.fixed_ip_v4, null)
  }
}

resource "nhncloud_compute_instance_v2" "this" {
  for_each = var.instances

  name              = each.value.name
  flavor_id         = each.value.flavor_id
  key_pair          = try(each.value.key_pair, null)
  availability_zone = try(each.value.availability_zone, null)
  security_groups   = try(each.value.security_groups, [])
  user_data         = try(each.value.user_data_base64, null)

  dynamic "network" {
    for_each = try(each.value.subnet_id, null) == null ? [1] : []

    content {
      uuid = each.value.network_id
    }
  }

  dynamic "network" {
    for_each = try(each.value.subnet_id, null) == null ? [] : [1]

    content {
      port = nhncloud_networking_port_v2.this[each.key].id
    }
  }

  block_device {
    uuid                  = each.value.boot_image_id
    source_type           = try(each.value.boot_block_device_source_type, "image")
    destination_type      = try(each.value.boot_destination_type, "volume")
    boot_index            = 0
    volume_size           = try(each.value.boot_volume_size, 30)
    delete_on_termination = try(each.value.boot_delete_on_termination, true)
  }
}
