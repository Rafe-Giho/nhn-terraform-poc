provider "nhncloud" {
  user_name = var.nhncloud_user_name
  tenant_id = var.nhncloud_tenant_id
  password  = var.nhncloud_password
  auth_url  = var.nhncloud_auth_url
  region    = var.nhncloud_region
}
