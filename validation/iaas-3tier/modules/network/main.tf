resource "nhncloud_networking_vpc_v2" "this" {
  name   = "${var.name_prefix}-vpc"
  cidrv4 = var.vpc_cidr
}

resource "nhncloud_networking_routingtable_v2" "this" {
  name        = "${var.name_prefix}-rt"
  vpc_id      = nhncloud_networking_vpc_v2.this.id
  distributed = var.distributed_routing
}

resource "nhncloud_networking_routingtable_attach_gateway_v2" "internet" {
  count = var.internet_gateway_id == null ? 0 : 1

  routingtable_id = nhncloud_networking_routingtable_v2.this.id
  gateway_id      = var.internet_gateway_id
}

resource "nhncloud_networking_vpcsubnet_v2" "this" {
  for_each = var.subnets

  name            = "${var.name_prefix}-${each.key}-subnet"
  vpc_id          = nhncloud_networking_vpc_v2.this.id
  cidr            = each.value.cidr
  routingtable_id = nhncloud_networking_routingtable_v2.this.id
}

