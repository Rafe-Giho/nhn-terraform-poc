resource "nhncloud_objectstorage_container_v1" "this" {
  for_each = var.containers

  name         = coalesce(try(each.value.name, null), "${var.name_prefix}-${each.key}")
  content_type = try(each.value.content_type, null)
  versioning   = try(each.value.versioning, true)
  metadata     = merge(var.metadata, try(each.value.metadata, {}))
}

