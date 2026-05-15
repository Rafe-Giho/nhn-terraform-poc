output "vpc_id" {
  description = "Created VPC ID."
  value       = module.network.vpc_id
}

output "subnet_ids" {
  description = "Created subnet IDs."
  value       = module.network.subnet_ids
}

output "security_group_ids" {
  description = "Security group IDs by key."
  value       = module.security.security_group_ids
}

output "instance_ids" {
  description = "Compute instance IDs by key."
  value       = module.compute.instance_ids
}

output "instance_access_ip_v4" {
  description = "Compute instance fixed IPv4 addresses by key."
  value       = module.compute.access_ip_v4
}

output "volume_ids" {
  description = "Data volume IDs by key."
  value       = module.block_storage.volume_ids
}

output "load_balancer_ids" {
  description = "Load balancer IDs by key."
  value       = module.load_balancer.load_balancer_ids
}

output "load_balancer_vip_addresses" {
  description = "Load balancer VIP addresses by key."
  value       = module.load_balancer.vip_addresses
}

output "object_storage_containers" {
  description = "Object Storage container names."
  value       = module.object_storage.container_names
}
