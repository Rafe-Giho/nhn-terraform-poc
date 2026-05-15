output "instance_ids" {
  description = "Instance IDs by key."
  value       = { for key, instance in nhncloud_compute_instance_v2.this : key => instance.id }
}

output "access_ip_v4" {
  description = "Detected fixed IPv4 addresses by key."
  value       = { for key, instance in nhncloud_compute_instance_v2.this : key => instance.access_ip_v4 }
}

output "instance_names" {
  description = "Instance names by key."
  value       = { for key, instance in nhncloud_compute_instance_v2.this : key => instance.name }
}

output "port_ids" {
  description = "Networking port IDs by key for instances that use explicit subnet placement."
  value       = { for key, port in nhncloud_networking_port_v2.this : key => port.id }
}
