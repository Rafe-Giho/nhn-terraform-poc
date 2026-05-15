locals {
  name_prefix = "${var.project_prefix}-${var.environment}"

  common_metadata = {
    project     = var.project_prefix
    environment = var.environment
    managed_by  = "terraform"
  }

  security_groups = {
    public_entrypoint = {
      name = "${local.name_prefix}-public-entrypoint-sg"
      rules = concat(
        [
          for cidr in var.public_ingress_cidrs : {
            direction        = "ingress"
            ethertype        = "IPv4"
            protocol         = "tcp"
            port_range_min   = 80
            port_range_max   = 80
            remote_ip_prefix = cidr
            description      = "public http"
          }
        ],
        [
          for cidr in var.public_ingress_cidrs : {
            direction        = "ingress"
            ethertype        = "IPv4"
            protocol         = "tcp"
            port_range_min   = 443
            port_range_max   = 443
            remote_ip_prefix = cidr
            description      = "public https"
          }
        ]
      )
    }

    platform_admin = {
      name = "${local.name_prefix}-platform-admin-sg"
      rules = [
        for cidr in var.management_cidrs : {
          direction        = "ingress"
          ethertype        = "IPv4"
          protocol         = "tcp"
          port_range_min   = 22
          port_range_max   = 22
          remote_ip_prefix = cidr
          description      = "ssh from management cidr"
        }
      ]
    }
  }

  nks_labels = {
    kube_tag                      = var.nks_kubernetes_version
    availability_zone             = var.nks_availability_zone
    boot_volume_size              = tostring(var.nks_boot_volume_size)
    boot_volume_type              = var.nks_boot_volume_type
    ca_enable                     = tostring(var.nks_autoscaler.enabled)
    ca_max_node_count             = tostring(var.nks_autoscaler.max_node_count)
    ca_min_node_count             = tostring(var.nks_autoscaler.min_node_count)
    ca_scale_down_delay_after_add = tostring(var.nks_autoscaler.scale_down_delay_after_add)
    ca_scale_down_enable          = tostring(var.nks_autoscaler.scale_down_enabled)
    ca_scale_down_unneeded_time   = tostring(var.nks_autoscaler.scale_down_unneeded_time)
    ca_scale_down_util_thresh     = tostring(var.nks_autoscaler.scale_down_util_threshold)
    cert_manager_api              = "True"
    clusterautoscale              = "nodegroupfeature"
    external_network_id           = var.nks_external_network_id
    external_subnet_id_list       = var.nks_external_subnet_id_list
    master_lb_floating_ip_enabled = "true"
    node_image                    = var.nks_node_image_id
    strict_sg_rules               = "false"
  }
}

module "network" {
  source = "../../../../../modules/network"

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  subnets             = var.subnets
  internet_gateway_id = var.internet_gateway_id
}

module "security" {
  source = "../../../../../modules/security"

  security_groups = local.security_groups
}

module "object_storage" {
  source = "../../../../../modules/object-storage"

  name_prefix = local.name_prefix
  containers  = var.object_storage_containers
  metadata    = local.common_metadata
}

module "nks" {
  source = "../../../../../modules/nks"

  cluster = {
    name                = "${local.name_prefix}-${var.nks_cluster_name}"
    cluster_template_id = "iaas_console"
    fixed_network       = module.network.vpc_id
    fixed_subnet        = module.network.subnet_ids[var.nks_subnet_key]
    flavor_id           = var.nks_node_flavor_id
    keypair             = var.nks_keypair_name
    node_count          = var.nks_node_count
    labels              = local.nks_labels
    addons = [
      {
        name    = "calico"
        version = var.nks_calico_version
        options = {
          mode = var.nks_calico_mode
        }
      },
      {
        name    = "coredns"
        version = var.nks_coredns_version
      }
    ]
  }

  nodegroups = var.additional_nodegroups
}
