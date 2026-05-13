output "security_group_ids" {
  description = "Security group IDs by key."
  value       = { for key, sg in nhncloud_networking_secgroup_v2.this : key => sg.id }
}

output "security_group_names" {
  description = "Security group names by key."
  value       = { for key, sg in nhncloud_networking_secgroup_v2.this : key => sg.name }
}

