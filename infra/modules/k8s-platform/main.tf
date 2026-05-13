resource "kubernetes_namespace_v1" "this" {
  for_each = var.namespaces

  metadata {
    name   = each.value
    labels = merge(var.common_labels, var.namespace_labels)
  }
}

resource "kubernetes_storage_class_v1" "this" {
  for_each = var.storage_classes

  metadata {
    name        = coalesce(try(each.value.name, null), each.key)
    labels      = merge(var.common_labels, try(each.value.labels, {}))
    annotations = try(each.value.annotations, {})
  }

  storage_provisioner    = each.value.storage_provisioner
  reclaim_policy         = try(each.value.reclaim_policy, "Retain")
  volume_binding_mode    = try(each.value.volume_binding_mode, "Immediate")
  allow_volume_expansion = try(each.value.allow_volume_expansion, false)
  parameters             = try(each.value.parameters, {})
}

resource "helm_release" "this" {
  for_each = var.helm_releases

  name             = coalesce(try(each.value.name, null), each.key)
  namespace        = each.value.namespace
  repository       = each.value.repository
  chart            = each.value.chart
  version          = try(each.value.version, null)
  values           = try(each.value.values, [])
  create_namespace = false
  wait             = try(each.value.wait, true)
  timeout          = try(each.value.timeout, 600)

  dynamic "set" {
    for_each = try(each.value.set, {})

    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [kubernetes_namespace_v1.this]
}

