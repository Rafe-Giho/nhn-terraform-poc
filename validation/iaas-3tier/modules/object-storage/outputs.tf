output "container_names" {
  description = "Container names by key."
  value       = { for key, container in nhncloud_objectstorage_container_v1.this : key => container.name }
}

output "container_ids" {
  description = "Container IDs by key."
  value       = { for key, container in nhncloud_objectstorage_container_v1.this : key => container.id }
}

