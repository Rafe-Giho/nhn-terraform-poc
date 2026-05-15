locals {
  rules = flatten([
    for group_key, group in var.security_groups : [
      for index, rule in group.rules : merge(rule, {
        group_key = group_key
        rule_key  = "${group_key}-${index}"
      })
    ]
  ])
}

resource "nhncloud_networking_secgroup_v2" "this" {
  for_each = var.security_groups

  name = each.value.name
}

resource "nhncloud_networking_secgroup_rule_v2" "this" {
  for_each = { for rule in local.rules : rule.rule_key => rule }

  security_group_id = nhncloud_networking_secgroup_v2.this[each.value.group_key].id
  direction         = each.value.direction
  ethertype         = try(each.value.ethertype, "IPv4")
  protocol          = try(each.value.protocol, null)
  port_range_min    = try(each.value.port_range_min, null)
  port_range_max    = try(each.value.port_range_max, null)
  remote_ip_prefix  = try(each.value.remote_ip_prefix, null)
  remote_group_id   = try(each.value.remote_group_id, null)
  description       = try(each.value.description, null)
}

