resource "nhncloud_blockstorage_volume_v2" "this" {
  for_each = var.volumes

  name              = each.value.name
  description       = try(each.value.description, null)
  size              = each.value.size
  availability_zone = try(each.value.availability_zone, null)
  volume_type       = try(each.value.volume_type, "General HDD")
  snapshot_id       = try(each.value.snapshot_id, null)
}

resource "nhncloud_compute_volume_attach_v2" "this" {
  for_each = var.attachments

  instance_id = var.instance_ids[each.value.instance_key]
  volume_id   = nhncloud_blockstorage_volume_v2.this[each.value.volume_key].id
}
