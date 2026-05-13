output "cluster_id" {
  description = "NKS cluster ID."
  value       = nhncloud_kubernetes_cluster_v1.this.id
}

output "api_address" {
  description = "NKS API address."
  value       = nhncloud_kubernetes_cluster_v1.this.api_address
}

output "cluster_status" {
  description = "NKS cluster status."
  value       = nhncloud_kubernetes_cluster_v1.this.status
}

output "node_addresses" {
  description = "NKS node addresses."
  value       = nhncloud_kubernetes_cluster_v1.this.node_addresses
}

output "additional_nodegroup_ids" {
  description = "Additional node group IDs."
  value       = { for key, nodegroup in nhncloud_kubernetes_nodegroup_v1.additional : key => nodegroup.id }
}

