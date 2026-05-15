output "vpc_id" {
  description = "VPC ID."
  value       = nhncloud_networking_vpc_v2.this.id
}

output "routing_table_id" {
  description = "Routing table ID."
  value       = nhncloud_networking_routingtable_v2.this.id
}

output "subnet_ids" {
  description = "Subnet IDs by key."
  value       = { for key, subnet in nhncloud_networking_vpcsubnet_v2.this : key => subnet.id }
}

output "subnet_cidrs" {
  description = "Subnet CIDRs by key."
  value       = { for key, subnet in nhncloud_networking_vpcsubnet_v2.this : key => subnet.cidr }
}

