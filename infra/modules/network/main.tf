resource "nhncloud_networking_vpc_v2" "this" {
  name   = "${var.name_prefix}-vpc"
  cidrv4 = var.vpc_cidr
}

resource "nhncloud_networking_routingtable_v2" "this" {
  for_each = var.routing_tables

  name        = coalesce(try(each.value.name, null), "${var.name_prefix}-${each.key}-rt")
  vpc_id      = nhncloud_networking_vpc_v2.this.id
  distributed = try(each.value.distributed, false)
}

resource "nhncloud_networking_routingtable_attach_gateway_v2" "internet" {
  for_each = {
    for key, route_table in var.routing_tables : key => route_table
    if try(route_table.internet_gateway_id, null) != null
  }

  routingtable_id = nhncloud_networking_routingtable_v2.this[each.key].id
  gateway_id      = each.value.internet_gateway_id
}

resource "nhncloud_networking_vpcsubnet_v2" "this" {
  for_each = var.subnets

  name            = "${var.name_prefix}-${each.key}-subnet"
  vpc_id          = nhncloud_networking_vpc_v2.this.id
  cidr            = each.value.cidr
  routingtable_id = nhncloud_networking_routingtable_v2.this[coalesce(try(each.value.routing_table_key, null), var.default_routing_table_key)].id
}
