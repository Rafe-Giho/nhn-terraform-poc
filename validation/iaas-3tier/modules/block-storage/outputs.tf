output "volume_ids" {
  description = "Block storage volume IDs by key."
  value       = { for key, volume in nhncloud_blockstorage_volume_v2.this : key => volume.id }
}

output "attachments" {
  description = "Volume attachment IDs by key."
  value       = { for key, attachment in nhncloud_compute_volume_attach_v2.this : key => attachment.id }
}
