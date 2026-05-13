output "namespaces" {
  description = "Created namespaces."
  value       = [for namespace in kubernetes_namespace_v1.this : namespace.metadata[0].name]
}

output "storage_classes" {
  description = "Created StorageClasses."
  value       = [for storage_class in kubernetes_storage_class_v1.this : storage_class.metadata[0].name]
}

output "helm_releases" {
  description = "Installed Helm releases."
  value       = { for key, release in helm_release.this : key => release.name }
}

