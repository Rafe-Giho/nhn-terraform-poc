output "namespaces" {
  description = "Platform namespaces."
  value       = module.platform.namespaces
}

output "storage_classes" {
  description = "Platform StorageClasses."
  value       = module.platform.storage_classes
}

output "helm_releases" {
  description = "Platform Helm releases."
  value       = module.platform.helm_releases
}

