resource "nhncloud_lb_loadbalancer_v2" "this" {
  for_each = var.load_balancers

  name               = each.value.name
  description        = try(each.value.description, null)
  vip_subnet_id      = each.value.vip_subnet_id
  vip_address        = try(each.value.vip_address, null)
  security_group_ids = try(each.value.security_group_ids, [])
  admin_state_up     = try(each.value.admin_state_up, true)
  loadbalancer_type  = try(each.value.loadbalancer_type, "shared")
}

resource "nhncloud_lb_listener_v2" "this" {
  for_each = var.listeners

  name                      = each.value.name
  description               = try(each.value.description, null)
  protocol                  = each.value.protocol
  protocol_port             = each.value.protocol_port
  loadbalancer_id           = nhncloud_lb_loadbalancer_v2.this[each.value.load_balancer_key].id
  connection_limit          = try(each.value.connection_limit, null)
  timeout_client_data       = try(each.value.timeout_client_data, null)
  timeout_member_connect    = try(each.value.timeout_member_connect, null)
  timeout_member_data       = try(each.value.timeout_member_data, null)
  timeout_tcp_inspect       = try(each.value.timeout_tcp_inspect, null)
  default_tls_container_ref = try(each.value.default_tls_container_ref, null)
  sni_container_refs        = try(each.value.sni_container_refs, null)
  admin_state_up            = try(each.value.admin_state_up, true)
  keepalive_timeout         = try(each.value.keepalive_timeout, null)
}

resource "nhncloud_lb_pool_v2" "this" {
  for_each = var.pools

  name           = each.value.name
  description    = try(each.value.description, null)
  protocol       = each.value.protocol
  listener_id    = nhncloud_lb_listener_v2.this[each.value.listener_key].id
  lb_method      = each.value.lb_method
  member_port    = try(each.value.member_port, null)
  admin_state_up = try(each.value.admin_state_up, true)

  dynamic "persistence" {
    for_each = try(each.value.persistence, null) == null ? [] : [each.value.persistence]

    content {
      type        = persistence.value.type
      cookie_name = try(persistence.value.cookie_name, null)
    }
  }
}

resource "nhncloud_lb_member_v2" "this" {
  for_each = var.members

  pool_id        = nhncloud_lb_pool_v2.this[each.value.pool_key].id
  subnet_id      = each.value.subnet_id
  address        = each.value.address
  protocol_port  = each.value.protocol_port
  weight         = try(each.value.weight, 1)
  admin_state_up = try(each.value.admin_state_up, true)
}

resource "nhncloud_lb_monitor_v2" "this" {
  for_each = var.monitors

  name              = each.value.name
  pool_id           = nhncloud_lb_pool_v2.this[each.value.pool_key].id
  type              = each.value.type
  delay             = each.value.delay
  timeout           = each.value.timeout
  max_retries       = each.value.max_retries
  url_path          = try(each.value.url_path, null)
  http_method       = try(each.value.http_method, null)
  expected_codes    = try(each.value.expected_codes, null)
  admin_state_up    = try(each.value.admin_state_up, true)
  host_header       = try(each.value.host_header, null)
  health_check_port = try(each.value.health_check_port, null)
}
