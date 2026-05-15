output "vpc_id" {
  description = "Created VPC ID."
  value       = module.network.vpc_id
}

output "subnet_ids" {
  description = "Created subnet IDs."
  value       = module.network.subnet_ids
}

output "security_group_ids" {
  description = "Created security group IDs."
  value       = module.security.security_group_ids
}

output "object_storage_containers" {
  description = "Object Storage container names."
  value       = module.object_storage.container_names
}

output "nks_cluster_id" {
  description = "NKS cluster ID."
  value       = module.nks.cluster_id
}

output "nks_api_address" {
  description = "NKS API endpoint."
  value       = module.nks.api_address
}

