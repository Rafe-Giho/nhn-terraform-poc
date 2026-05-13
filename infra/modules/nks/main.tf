resource "nhncloud_kubernetes_cluster_v1" "this" {
  name                = var.cluster.name
  cluster_template_id = var.cluster.cluster_template_id
  fixed_network       = var.cluster.fixed_network
  fixed_subnet        = var.cluster.fixed_subnet
  flavor_id           = var.cluster.flavor_id
  keypair             = var.cluster.keypair
  node_count          = var.cluster.node_count
  labels              = var.cluster.labels

  dynamic "addons" {
    for_each = var.cluster.addons

    content {
      name    = addons.value.name
      version = addons.value.version
      options = try(addons.value.options, {})
    }
  }

  lifecycle {
    ignore_changes = [node_count]
  }
}

resource "nhncloud_kubernetes_nodegroup_v1" "additional" {
  for_each = var.nodegroups

  cluster_id = nhncloud_kubernetes_cluster_v1.this.id
  name       = each.value.name
  node_count = try(each.value.node_count, 1)
  flavor_id  = each.value.flavor_id
  image_id   = each.value.image_id
  version    = try(each.value.version, null)
  labels     = each.value.labels

  lifecycle {
    ignore_changes = [node_count, version]
  }
}
