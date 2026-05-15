output "vpc_id" {
  description = "VPC ID."
  value       = nhncloud_networking_vpc_v2.this.id
}

output "routing_table_id" {
  description = "Default routing table ID."
  value       = try(nhncloud_networking_routingtable_v2.this[var.default_routing_table_key].id, values(nhncloud_networking_routingtable_v2.this)[0].id)
}

output "routing_table_ids" {
  description = "Routing table IDs by key."
  value       = { for key, route_table in nhncloud_networking_routingtable_v2.this : key => route_table.id }
}

output "subnet_ids" {
  description = "Subnet IDs by key."
  value       = { for key, subnet in nhncloud_networking_vpcsubnet_v2.this : key => subnet.id }
}

output "subnet_cidrs" {
  description = "Subnet CIDRs by key."
  value       = { for key, subnet in nhncloud_networking_vpcsubnet_v2.this : key => subnet.cidr }
}

output "subnet_routing_table_keys" {
  description = "Subnet routing table key by subnet key."
  value       = { for key, subnet in var.subnets : key => coalesce(try(subnet.routing_table_key, null), var.default_routing_table_key) }
}

output "internet_gateway_route_table_ids" {
  description = "Routing table IDs with Internet Gateway attachment."
  value       = { for key, attachment in nhncloud_networking_routingtable_attach_gateway_v2.internet : key => attachment.routingtable_id }
}
