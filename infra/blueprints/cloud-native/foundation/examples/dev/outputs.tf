output "vpc_id" {
  description = "Created VPC ID."
  value       = module.network.vpc_id
}

output "subnet_ids" {
  description = "Created subnet IDs."
  value       = module.network.subnet_ids
}

output "routing_table_ids" {
  description = "Created routing table IDs by key."
  value       = module.network.routing_table_ids
}

output "subnet_routing_table_keys" {
  description = "Subnet to routing table mapping."
  value       = module.network.subnet_routing_table_keys
}

output "security_group_ids" {
  description = "Created security group IDs."
  value       = module.security.security_group_ids
}

output "object_storage_containers" {
  description = "Object Storage container names."
  value       = module.object_storage.container_names
}

output "devops_server_instance_ids" {
  description = "DevOps integration server instance IDs."
  value       = module.devops_compute.instance_ids
}

output "devops_server_private_ips" {
  description = "DevOps integration server private IPv4 addresses."
  value       = module.devops_compute.access_ip_v4
}

output "devops_data_volume_ids" {
  description = "DevOps integration server data volume IDs."
  value       = module.devops_block_storage.volume_ids
}

output "nks_cluster_id" {
  description = "NKS cluster ID."
  value       = module.nks.cluster_id
}

output "nks_api_address" {
  description = "NKS API endpoint."
  value       = module.nks.api_address
}
